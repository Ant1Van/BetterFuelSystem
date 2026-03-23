local Utils = require("modules/Utils")
local FuelManager = require("modules/FuelManager")
local vehicles_db = require("modules/vehicles_db")
local motorcycles_db = require("modules/motorcycles_db")
local Localization = require("modules/Localization")

local VehicleMonitor = {}

function VehicleMonitor:new()
    local instance = {}
    setmetatable(instance, self)
    self.__index = self

    instance.currentVehicle = nil
    instance.blackboard = nil
    
    instance.fuelLevel = 60
    instance.maxFuel = 60
    instance.fuelType = "Regular"

    -- Базовый расход топлива (общий по умолчанию)
    instance.baseFuelConsumptionRate = 0.2

    -- Текущий расход для КОНКРЕТНОЙ машины (может переопределяться в БД)
    instance.fuelConsumptionRate = instance.baseFuelConsumptionRate

    -- Флаг: применять ли стандартный бонус для байков (-10% расхода)
    -- Если в БД указан свой расход/множитель – этот флаг отключим.
    instance.applyBikeBonus = true
    instance.maxRPM = 6000
    instance.rpmMultiplier = 0.002
    instance.lowFuelThreshold = 6
    instance.lowFuelWarningShown = false
    instance.emptyFuelWarningShown = false
    instance.engineStoppedByEmptyFuel = false
    instance.lastLowFuelSoundTime = 0
    instance.lowFuelSoundInterval = 8.0  -- Интервал между звуками (в секундах)
    
    instance.vehicleID = nil
    instance.vehicleFuelData = nil
    instance.wasPaused = false 
    
    -- Таймер для синхронизации данных с redscript
    instance.syncTimer = 0.0
    instance.syncInterval = 0.5  -- Синхронизация каждые 0.5 секунды

    return instance
end

function VehicleMonitor:init()
    self.currentVehicle = Game.GetMountedVehicle(Game.GetPlayer())
    
    if not self.currentVehicle then return end

    local vehicleID = FuelManager.GetVehicleID(self.currentVehicle)
    
    if vehicleID then
        -- ДЕБАГ: Пишем ID машины при посадке, чтобы ты мог проверить БД
       -- print("[BFS] Init Vehicle ID: " .. tostring(vehicleID))
        
        self.vehicleID = vehicleID
        self.vehicleFuelData = FuelManager.GetOrCreateFuel(vehicleID)

        -- Настройка расхода топлива для КОНКРЕТНОГО транспорта
        -- Можно задать либо абсолютный расход, либо множитель к базовому.
        local def = vehicles_db[vehicleID] or motorcycles_db[vehicleID]
        if def then
            -- 1) Приоритет: явный абсолютный расход (литров в секунду при max RPM)
            if def.fuelConsumptionRate then
                self.fuelConsumptionRate = def.fuelConsumptionRate
                self.applyBikeBonus = false -- пользователь сам задал расход
            -- 2) Альтернатива: множитель от базового расхода
            elseif def.fuelConsumptionMultiplier then
                self.fuelConsumptionRate = self.baseFuelConsumptionRate * def.fuelConsumptionMultiplier
                self.applyBikeBonus = false -- пользователь сам задал поведение
            else
                -- 3) Ничего не указано: используем старое поведение
                self.fuelConsumptionRate = self.baseFuelConsumptionRate
                self.applyBikeBonus = true
            end
        else
            -- Если машина не в БД – полностью дефолт
            self.fuelConsumptionRate = self.baseFuelConsumptionRate
            self.applyBikeBonus = true
        end

        if self.vehicleFuelData then
            self.fuelLevel = self.vehicleFuelData.fuel or 60
            self.maxFuel = self.vehicleFuelData.maxFuel or 60
            self.fuelType = self.vehicleFuelData.fuelType or "Regular"
            
            self:refreshBlackboard()
            
            -- СРАЗУ синхронизируем данные с сервисом, чтобы UI был готов
            self:syncFuelData()
            
            -- Проверяем топливо при входе в машину - если топлива нет, останавливаем двигатель
            if self.fuelLevel <= 0 then
                self.fuelLevel = 0
                if self.currentVehicle and self.currentVehicle.TurnEngineOn then
                    self.currentVehicle:TurnEngineOn(false)
                end
                self.emptyFuelWarningShown = true
                self.lowFuelWarningShown = true
                self.engineStoppedByEmptyFuel = true
            end
        end
    end
end

function VehicleMonitor:isGamePaused()
    if Game.GetTimeSystem():IsPausedState() then return true end

    local bbDefs = Game.GetAllBlackboardDefs()
    local bbSys = Game.GetBlackboardSystem()
    
    if bbDefs and bbSys then
        local uiBB = bbSys:Get(bbDefs.UI_System)
        if uiBB and uiBB:GetBool(bbDefs.UI_System.IsInMenu) then return true end

        local photoBB = bbSys:Get(bbDefs.PhotoMode)
        if photoBB and photoBB:GetBool(bbDefs.PhotoMode.IsActive) then return true end
    end
    return false
end

function VehicleMonitor:update(deltaTime)
    if not self.currentVehicle then return end
    
    -- ВАЖНО: Проверяем, управляет ли игрок транспортом
    local player = Game.GetPlayer()
    local isPlayerDriving = Utils.IsPlayerDriving(self.currentVehicle, player)
    if not isPlayerDriving then
        -- Игрок не управляет транспортом - не считаем расход топлива
        return
    end

    local isPaused = self:isGamePaused()
    if isPaused ~= self.wasPaused then
        -- ДЕБАГ: логируем смену состояния паузы
        --print("[BFS][VehicleMonitor] Pause state changed, isPaused = " .. tostring(isPaused))
        self.wasPaused = isPaused
    end
    if isPaused then return end

    if not self.blackboard then
        self:refreshBlackboard()
        if not self.blackboard then return end
    end

    local blackboardDefs = Game.GetAllBlackboardDefs()
    local ok, rpmValue = pcall(function() return self.blackboard:GetFloat(blackboardDefs.Vehicle.RPMValue) end)
    local _, speedValue = pcall(function() return self.blackboard:GetFloat(blackboardDefs.Vehicle.SpeedValue) end)
    
    if not ok then self.blackboard = nil; return end
    
    rpmValue = rpmValue or 0
    speedValue = speedValue or 0

    -- ДЕБАГ: базовые значения с блэкборда
    --print(string.format("[BFS][VehicleMonitor] update: fuel=%.3f, rpm=%.1f, speed=%.1f", self.fuelLevel or -1, rpmValue, speedValue))

    local isEngineOn = false
    if self.currentVehicle.IsEngineOn then 
        isEngineOn = self.currentVehicle:IsEngineOn()
    end
    
    if not isEngineOn and (rpmValue > 100 or math.abs(speedValue) > 0.5) then
        isEngineOn = true
    end

    if isEngineOn or rpmValue > 0 then
        if rpmValue <= 0 then rpmValue = 500 end

        -- Базовый расход для текущего транспорта
        local consumptionRate = self.fuelConsumptionRate

        -- ДЕБАГ: логируем режим расхода
        

        -- Старое поведение: байки тратят на 10% меньше
        -- Это работает ТОЛЬКО если пользователь не задал свой расход в БД.
        if self.applyBikeBonus and self:isBike(self.currentVehicle) then
            consumptionRate = consumptionRate * 0.9
        end

        local dynamicConsumptionRate = consumptionRate * (rpmValue / self.maxRPM)
        local consumption = dynamicConsumptionRate + (rpmValue / self.maxRPM) * self.rpmMultiplier
        local originalDrainPerTick = consumption / 60
        local drainAmount = originalDrainPerTick * 10 * deltaTime

        -- ДЕБАГ: логируем дренаж топлива
       

        self.fuelLevel = self.fuelLevel - drainAmount

        if self.vehicleFuelData then
            self.vehicleFuelData.fuel = self.fuelLevel
        end
    end

    -- Периодическая синхронизация данных с redscript для обновления HUD
    self.syncTimer = self.syncTimer + deltaTime
    if self.syncTimer >= self.syncInterval then
        self.syncTimer = 0.0
        self:syncFuelData()
    end

    -- ВАЖНО: события (в том числе проверка на 0 топлива) вызываем ВСЕГДА,
    -- даже если двигатель уже считается заглушенным
    self:handleEvents()
end

function VehicleMonitor:handleEvents()
    -- ДЕБАГ: общий лог вызова обработки событий
    

    if self.fuelLevel <= 0 then
        self.fuelLevel = 0
        
        -- Предупреждение о пустом баке показываем ТОЛЬКО ОДИН РАЗ,
        -- пока игрок не заправится/не изменится уровень топлива.
        if not self.emptyFuelWarningShown then
            Game.GetPlayer():SetWarningMessage(Localization.getText("FuelTankEmpty"))
            self.emptyFuelWarningShown = true
            self.lowFuelWarningShown = true -- чтобы "LowFuel" тоже не спамился при 0
        end
        
        -- ВАЖНО: постоянно проверяем и останавливаем двигатель, если топливо = 0
        -- Это нужно для случая, когда игрок выходит и заходит обратно в машину
        if self.currentVehicle and self.currentVehicle.TurnEngineOn then
            local engineRunning = false
            if self.currentVehicle.IsEngineOn then
                engineRunning = self.currentVehicle:IsEngineOn()
            end
            if engineRunning then
                self.currentVehicle:TurnEngineOn(false)
            end
        end
        self.engineStoppedByEmptyFuel = true
        return
    end

    -- Если бак не пуст, то работаем с обычным "мало топлива"
    if self.fuelLevel <= self.lowFuelThreshold and not self.lowFuelWarningShown then
        Game.GetPlayer():SetWarningMessage(Localization.getText("LowFuelWarning"))
        self.lowFuelWarningShown = true
    elseif self.fuelLevel > self.lowFuelThreshold then
        self.lowFuelWarningShown = false
        self.emptyFuelWarningShown = false
    end
end

function VehicleMonitor:refreshBlackboard()
    if not self.currentVehicle then return end
    local bb = self.currentVehicle:GetBlackboard()
    if bb then
        self.blackboard = bb
    else
        local blackboardSystem = Game.GetBlackboardSystem()
        local blackboardDefs = Game.GetAllBlackboardDefs()
        local vehicleID_entity = self.currentVehicle:GetEntityID()
        if blackboardSystem and vehicleID_entity then
            pcall(function()
                self.blackboard = blackboardSystem:GetLocalInstanced(vehicleID_entity, blackboardDefs.Vehicle)
            end)
        end
    end
end

function VehicleMonitor:unregisterListeners()
    self:save()
    self.currentVehicle = nil
    self.blackboard = nil
    self.vehicleID = nil
    self.wasPaused = false
end

function VehicleMonitor:isBike(vehicle)
    if not vehicle then return false end
    local id = FuelManager.GetVehicleID(vehicle)
    return motorcycles_db[id] ~= nil
end

function VehicleMonitor:getFuel() return self.fuelLevel end
function VehicleMonitor:getMaxFuel() return self.maxFuel end
function VehicleMonitor:getFuelType() return self.fuelType end
function VehicleMonitor:getFuelDeficit() return math.max(0, (self.maxFuel or 60) - (self.fuelLevel or 0)) end

function VehicleMonitor:save()
    if self.vehicleID and self.fuelLevel then
        FuelManager.SaveFuel(self.vehicleID, self.fuelLevel)
    end
end

function VehicleMonitor:refuel(fuelAmount)
    -- Если fuelAmount не указан, используем старое поведение (заправка до полного бака)
    local amountToFill = fuelAmount
    if not amountToFill or amountToFill <= 0 then
        local deficit = self:getFuelDeficit()
        if deficit <= 0 then return 0 end
        amountToFill = deficit
    end
    
    -- Ограничиваем количество доступным местом в баке
    local deficit = self:getFuelDeficit()
    amountToFill = math.min(amountToFill, deficit)
    
    if amountToFill <= 0 then return 0 end
    
    -- Заправляем на указанное количество
    self.fuelLevel = (self.fuelLevel or 0) + amountToFill
    -- Ограничиваем максимальным объемом бака (на всякий случай)
    if self.fuelLevel > self.maxFuel then
        self.fuelLevel = self.maxFuel
    end
    
    -- Обновляем данные в FuelManager
    if self.vehicleFuelData then
        self.vehicleFuelData.fuel = self.fuelLevel
    end
    self:refreshBlackboard()
    
    -- Сбрасываем флаги предупреждений если бак полный или почти полный
    if self.fuelLevel >= self.maxFuel then
        self.lowFuelWarningShown = false
        self.emptyFuelWarningShown = false
        -- Если двигатель был заглушен из-за пустого бака – автоматически запускаем его после заправки
        if self.engineStoppedByEmptyFuel and self.currentVehicle and self.currentVehicle.TurnEngineOn then
            self.currentVehicle:TurnEngineOn(true)
        end
        self.engineStoppedByEmptyFuel = false
    elseif self.fuelLevel > self.lowFuelThreshold then
        self.lowFuelWarningShown = false
        -- Если топливо появилось, запускаем двигатель если он был заглушен
        if self.engineStoppedByEmptyFuel and self.currentVehicle and self.currentVehicle.TurnEngineOn then
            self.currentVehicle:TurnEngineOn(true)
        end
        self.engineStoppedByEmptyFuel = false
    end
    
    -- Синхронизируем данные с Redscript
    self:syncFuelData()
    
    return amountToFill
end

function VehicleMonitor:syncFuelData()
    local player = Game.GetPlayer()
    local mountedVehicle = Game.GetMountedVehicle(player)
    if not mountedVehicle and not self.vehicleID then return false end
    local vID = mountedVehicle and FuelManager.GetVehicleID(mountedVehicle) or self.vehicleID
    if not vID then return false end
    
    -- Получаем данные из FuelManager (или создаем если нет)
    local data = FuelManager.GetOrCreateFuel(vID)
    if data then
        -- Обновляем данные из self (актуальные значения)
        self.fuelLevel = self.fuelLevel or data.fuel or 0
        self.maxFuel = self.maxFuel or data.maxFuel or 60
        self.fuelType = self.fuelType or data.fuelType or "Regular"
        
        -- Если топлива больше 0, сбрасываем флаг пустого бака
        if self.fuelLevel > 0 then
            self.emptyFuelWarningShown = false
            self.engineStoppedByEmptyFuel = false
        end
        
        self.vehicleID = vID
        self.vehicleFuelData = data
        
        -- Обновляем данные в FuelManager актуальным значением
        if self.vehicleFuelData then
            self.vehicleFuelData.fuel = self.fuelLevel
        end
        
        -- Отправляем актуальные данные в redscript сервис для HUD
        local service = Game.GetScriptableServiceContainer():GetService("BetterFuelSystem.BetterFuelSystemService")
        if service then
            service:SetVehicleFuelData(vID, self.fuelType, self.maxFuel, self.fuelLevel)
        end
        
        return true
    end
    return false
end

return VehicleMonitor:new()