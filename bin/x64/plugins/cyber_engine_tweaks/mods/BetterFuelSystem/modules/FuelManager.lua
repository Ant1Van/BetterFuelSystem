local config = require("modules/external/config")
local vehicles_db = require("modules/vehicles_db")
local motorcycles_db = require("modules/motorcycles_db")

local FuelManager = {}

-- Путь сохранения топлива.
-- Относительно рабочей директории процесса (обычно это bin/x64),
-- поэтому "plugins/..." на деле превращается в bin/x64/plugins/...
-- т.е. файл будет лежать рядом с init.lua мода.
local savePath = "fuel_data.json"
local fuelData = {}
local serviceName = "BetterFuelSystem.BetterFuelSystemService"

local function getService()
    if not Game or not Game.GetScriptableServiceContainer then return nil end
    local container = Game.GetScriptableServiceContainer()
    if not container then return nil end
    return container:GetService(serviceName)
end

if config.fileExists(savePath) then
    fuelData = config.loadFile(savePath)
else
    config.saveFile(savePath, fuelData)
end

function FuelManager.GetVehicleID(vehicle)
    if not vehicle then return nil end

    local recordID = vehicle:GetRecordID()
    if not recordID then return nil end

    local idStr = nil
    
    pcall(function()
        idStr = TweakDBID.new(recordID):ToString()
    end)

    if (not idStr or idStr == "") and recordID.value then
        idStr = recordID.value
    end

    if idStr then
        -- ДЕБАГ ОТКЛЮЧЕН
        -- print("[BFS CHECK] Found ID: " .. tostring(idStr)) 
        return idStr
    end

    return nil
end

function FuelManager.IsPlayerOwnedVehicle(vehicleID)
    local inCars = vehicles_db[vehicleID]
    local inBikes = motorcycles_db[vehicleID]
    
    if inCars or inBikes then
        -- print("[BFS]  Vehicle found in DB: " .. tostring(vehicleID)) -- ОТКЛЮЧЕНО
        return true
    else
        -- ДЕБАГ СПАМ ОТКЛЮЧЕН
        -- print("[BFS]  VEHICLE NOT IN DATABASE! ID: " .. tostring(vehicleID))
        return false
    end
end

function FuelManager.GetOrCreateFuel(vehicleID)
    if not vehicleID then return nil end

    -- 1. Сначала проверяем, есть ли данные уже в памяти (даже для NPC машин)
    if fuelData[vehicleID] then
        return fuelData[vehicleID]
    end

    local service = getService()

    -- 2. Если данных нет, проверяем базу данных (Это "Наша" машина?)
    local def = vehicles_db[vehicleID] or motorcycles_db[vehicleID]
    
    if def then
        -- ЭТО МАШИНА ИЗ БАЗЫ: Создаем и сохраняем
        if service then
            service:SetVehicleFuelData(vehicleID, def.fuelType, def.maxFuel, def.maxFuel)
        end
        fuelData[vehicleID] = {
            fuel = def.maxFuel,
            maxFuel = def.maxFuel,
            fuelType = def.fuelType,
            isOwned = true -- Пометка, что эту можно сохранять в файл
        }
        config.saveFile(savePath, fuelData)
        return fuelData[vehicleID]
    else
        -- 3. ЭТО МАШИНА НЕ ИЗ БАЗЫ (NPC/Украденная): Создаем временные данные
        -- Мы НЕ сохраняем это в файл, но храним в памяти, пока идет игра
        if service then
            service:SetVehicleFuelData(vehicleID, "Regular", 60.0, 60.0)
        end
        
        fuelData[vehicleID] = {
            fuel = 60,
            maxFuel = 60,
            fuelType = "Regular",
            isOwned = false, -- Пометка, что это временная
            temporary = true
        }
        return fuelData[vehicleID]
    end
end

function FuelManager.HasFuelData(vehicleID)
    return fuelData[vehicleID] ~= nil
end

function FuelManager.SaveFuel(vehicleID, value)
    if fuelData[vehicleID] then
        fuelData[vehicleID].fuel = value
        
        -- ВАЖНОЕ ИСПРАВЛЕНИЕ:
        -- Сохраняем в JSON файл только если машина есть в базе (isOwned)
        if fuelData[vehicleID].isOwned then
            config.saveFile(savePath, fuelData)
        end

        -- Но сервис обновляем всегда, чтобы UI работал
        local service = getService()
        if service then
            service:SetVehicleFuelData(vehicleID, fuelData[vehicleID].fuelType, fuelData[vehicleID].maxFuel, value)
        end
    end
end

return FuelManager