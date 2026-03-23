local Utils = {}

Utils.rpmListener = nil
Utils.speedListener = nil
Utils.gearListener = nil

Utils.rpmValue = 0
Utils.speedValue = 0
Utils.gearValue = 0
Utils.vehicleMaxRPM = 6000

function Utils.log(message)
    print("[BetterFuelSystem] " .. message)
end

function Utils.registerBlackboardListeners(vehicle) -- REGISTER BLACKBOARD LISTENERS FOR VEHICLE
    if not vehicle then
        return
    end

    local blackboardSystem = Game.GetBlackboardSystem()
    local vehicleID = vehicle:GetEntityID()
    local blackboardDefs = Game.GetAllBlackboardDefs()
    

    local vehicleBlackboard = blackboardSystem:GetLocalInstanced(vehicleID, blackboardDefs.Vehicle) 

    if not vehicleBlackboard then
        return
    end

    Utils.rpmListener = function(_, value)
        Utils.rpmValue = value
        
    end

    Utils.speedListener = function(_, value)
        Utils.speedValue = value
        
    end

    Utils.gearListener = function(_, value)
        Utils.gearValue = value
        
    end

    vehicleBlackboard:RegisterListenerFloat(blackboardDefs.Vehicle.RPMValue, Utils.rpmListener)
    vehicleBlackboard:RegisterListenerFloat(blackboardDefs.Vehicle.SpeedValue, Utils.speedListener)
    vehicleBlackboard:RegisterListenerInt(blackboardDefs.Vehicle.GearValue, Utils.gearListener)

end

function Utils.unregisterBlackboardListeners(vehicle)
    if not vehicle then
        return
    end

    local blackboardSystem = Game.GetBlackboardSystem()
    local vehicleID = vehicle:GetEntityID()
    local blackboardDefs = Game.GetAllBlackboardDefs()
    
    local vehicleBlackboard = blackboardSystem:GetLocalInstanced(vehicleID, blackboardDefs.Vehicle)

    if not vehicleBlackboard then
        return
    end

    vehicleBlackboard:UnregisterListenerFloat(blackboardDefs.Vehicle.RPMValue, Utils.rpmListener)
    vehicleBlackboard:UnregisterListenerFloat(blackboardDefs.Vehicle.SpeedValue, Utils.speedListener)
    vehicleBlackboard:UnregisterListenerInt(blackboardDefs.Vehicle.GearValue, Utils.gearListener)
end

-- Проверяет, управляет ли игрок транспортом (а не просто находится в нём)
-- Использует несколько методов проверки для надёжности
-- 
-- Ищет следующие функции в nativeDB (если текущие не работают):
-- 1. Vehicle:GetDriver() - получить водителя транспорта
-- 2. Vehicle:GetSeatIndex(player) - получить индекс места игрока (0 = водитель)
-- 3. Vehicle:IsPlayerDriving() - проверить, управляет ли игрок
-- 4. Game.IsPlayerDriving() - глобальная проверка
-- 5. Проверка через blackboard: Vehicle.IsPlayerDriving
function Utils.IsPlayerDriving(vehicle, player)
    if not vehicle or not player then
        print("[BFS][Utils.IsPlayerDriving] ERROR: vehicle or player is nil")
        return false
    end
    
    -- Метод 1: Проверка через GetDriver (если доступно)
    local success, driver = pcall(function()
        if vehicle.GetDriver then
            return vehicle:GetDriver()
        end
        return nil
    end)
    
    if success and driver then
        -- Сравниваем водителя с игроком
        if driver == player then
            print("[BFS][Utils.IsPlayerDriving] Method 1 (GetDriver): TRUE - Player is driver")
            return true
        else
            print("[BFS][Utils.IsPlayerDriving] Method 1 (GetDriver): FALSE - Driver is not player")
        end
    end
    
    -- Метод 2: Проверка через GetSeatIndex (если доступно)
    -- Seat index 0 обычно означает водительское место
    local success2, seatIndex = pcall(function()
        if vehicle.GetSeatIndex then
            return vehicle:GetSeatIndex(player)
        end
        return nil
    end)
    
    if success2 and seatIndex ~= nil then
        -- Seat index 0 = водитель
        if seatIndex == 0 then
            print("[BFS][Utils.IsPlayerDriving] Method 2 (GetSeatIndex): TRUE - Seat index = 0 (driver)")
            return true
        else
            print("[BFS][Utils.IsPlayerDriving] Method 2 (GetSeatIndex): FALSE - Seat index = " .. tostring(seatIndex))
        end
    end
    
    -- Метод 3: Проверка через IsPlayerDriving (если доступно)
    local success3, isDriving = pcall(function()
        if vehicle.IsPlayerDriving then
            return vehicle:IsPlayerDriving()
        end
        return nil
    end)
    
    if success3 and isDriving ~= nil then
        print("[BFS][Utils.IsPlayerDriving] Method 3 (vehicle.IsPlayerDriving): " .. tostring(isDriving))
        return isDriving == true
    end
    
    -- Метод 4: Проверка через Game.IsPlayerDriving (если доступно)
    local success4, isDrivingGlobal = pcall(function()
        if Game.IsPlayerDriving then
            return Game.IsPlayerDriving()
        end
        return nil
    end)
    
    if success4 and isDrivingGlobal ~= nil then
        print("[BFS][Utils.IsPlayerDriving] Method 4 (Game.IsPlayerDriving): " .. tostring(isDrivingGlobal))
        return isDrivingGlobal == true
    end
    
    -- Метод 5: Проверка через blackboard состояния игрока
    -- ВАЖНО: Состояние != 0 означает что игрок в транспорте, но НЕ означает что он управляет!
    -- Состояние 3 = в транспорте (может быть пассажиром!)
    -- Поэтому НЕ используем blackboard для определения управления - только для информации
    local success5, vehicleState = pcall(function()
        if player.GetPlayerStateMachineBlackboard then
            local blackboard = player:GetPlayerStateMachineBlackboard()
            if blackboard then
                local bbDefs = Game.GetAllBlackboardDefs()
                if bbDefs and bbDefs.PlayerStateMachine and bbDefs.PlayerStateMachine.Vehicle then
                    local state = blackboard:GetInt(bbDefs.PlayerStateMachine.Vehicle)
                    print("[BFS][Utils.IsPlayerDriving] Method 5 (Blackboard INFO): state = " .. tostring(state) .. " (0=not in vehicle, 3=in vehicle but may be passenger)")
                    -- НЕ возвращаем результат - blackboard не может точно определить управление
                end
            end
        end
        return nil
    end)
    
    -- Метод 6: Проверка через IsControlledByLocalPeer (если игрок контролирует транспорт)
    local success6, isControlled = pcall(function()
        if vehicle.IsControlledByLocalPeer then
            return vehicle:IsControlledByLocalPeer()
        end
        return nil
    end)
    
    if success6 and isControlled ~= nil then
        print("[BFS][Utils.IsPlayerDriving] Method 6 (IsControlledByLocalPeer): " .. tostring(isControlled))
        return isControlled == true
    end
    
    -- Если все методы не сработали, НЕ предполагаем что игрок управляет
    -- Лучше НЕ считать расход, чем считать когда игрок пассажир!
    print("[BFS][Utils.IsPlayerDriving] WARNING: All methods failed, returning FALSE (safer - no fuel consumption)")
    return false
end

return Utils
