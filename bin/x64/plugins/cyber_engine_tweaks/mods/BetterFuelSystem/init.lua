--:: ========================================================================================== ::--
--::                                                                                            ::--
--::   █████╗  ███╗   ██╗ ████████╗  ██╗  ██╗   ██╗  █████╗  ███╗   ██╗     [ SYSTEM ]          ::--
--::  ██╔══██╗ ████╗  ██║ ╚══██╔══╝  ██║  ██║   ██║ ██╔══██╗ ████╗  ██║     [ ONLINE ]          ::--
--::  ███████║ ██╔██╗ ██║    ██║     ██║  ██║   ██║ ███████║ ██╔██╗ ██║                         ::--
--::  ██╔══██║ ██║╚██╗██║    ██║     ██║  ╚██╗ ██╔╝ ██╔══██║ ██║╚██╗██║     v. 1.0.0            ::--
--::  ██║  ██║ ██║ ╚████║    ██║     ██║   ╚████╔╝  ██║  ██║ ██║ ╚████║     Code: Lua           ::--
--::  ╚═╝  ╚═╝ ╚═╝  ╚═══╝    ╚═╝     ╚═╝    ╚═══╝   ╚═╝  ╚═╝ ╚═╝  ╚═══╝                         ::--
--::                                                                                            ::--
--:: __________________________________________________________________________________________ ::--
--::                                                                                            ::--
--::  Copyright (C) 2025, Ant1Van. All rights reserved.                                         ::--
--::  This mod is under the MIT License.                                                        ::--
--::  https://opensource.org/licenses/mit-license.php                                           ::--
--:: ========================================================================================== ::--

local BetterFuelSystem = {
    runtimeData = {
        inMenu = false,
        inGame = false,
        initialized = false,
        inVehicle = false,
        blackboardInitialized = false,
        vehicleDetected = false,
    },

    Utils = require("modules/Utils"),
    VehicleMonitor = require("modules/VehicleMonitor"),
    Money = require("modules/Money"),
    GameUI = require("modules/external/GameUI"),
    GasMarkers = require("modules/GasStationMarkers"),
    lastMenuState = false,
}
local Cron = require("modules/external/Cron")

function BetterFuelSystem:new()
    registerForEvent("onInit", function()
        
        -- Initialize gas station markers
        if self.GasMarkers and type(self.GasMarkers) == "table" then
            self.GasMarkers.setup({
                points_path         = "gas_stations.json",
                cluster_radius      = 10.0,
                clampToGround       = true,
                visibleThroughWalls = true,
                trace               = true,  -- Enable trace for debugging
                title               = "PETROCHEM",
                desc                = "Fuel Station",
            })
            --print("[BetterFuelSystem] Gas station markers initialized.")
        else
            --print("[BetterFuelSystem] WARNING: GasStationMarkers module not loaded. Check if modules/GasStationMarkers.lua exists.")
        end
        
        self.GameUI.OnSessionStart(function()
            self.runtimeData.inGame = true
            self.runtimeData.initialized = false
            self.runtimeData.inVehicle = false
            self.runtimeData.blackboardInitialized = false
            
            -- Refresh gas markers when session starts (with retries)
            if self.GasMarkers and self.GasMarkers.refresh then
                local retries = 0
                local function tryRefresh()
                    local ms = Game.GetMappinSystem()
                    if ms then
                        self.GasMarkers.refresh(true)
                    else
                        retries = retries + 1
                        if retries < 10 then
                            Cron.After(1.0, tryRefresh)
                        else
                            --print("[BetterFuelSystem] WARNING: MappinSystem not available after 10 retries.")
                        end
                    end
                end
                Cron.After(2.0, tryRefresh)
            end
        end)

        self.GameUI.OnSessionEnd(function()
            self.runtimeData.inGame = false
            self.runtimeData.initialized = false
            self.runtimeData.inVehicle = false
            self.runtimeData.blackboardInitialized = false
        end)

        Observe("PlayerPuppet", "OnGameAttached", function(this)
            this:RegisterInputListener(this)
        end)

        Override("BetterFuelSystem.Workbench.BTCallback", "RequestRefuelFromLua;", function()
            local monitor = BetterFuelSystem and BetterFuelSystem.VehicleMonitor
            local money = BetterFuelSystem and BetterFuelSystem.Money

            if monitor and money then
                monitor:syncFuelData()

                local availableSpace = monitor:getFuelDeficit()
                if availableSpace <= 0 then
                    money.notifyTankFull()
                    return false
                end

                local fuelAmount = 0.0
                local serviceContainer = Game.GetScriptableServiceContainer()
                if serviceContainer then
                    local service = serviceContainer:GetService("BetterFuelSystem.BetterFuelSystemService")
                    if service then
                        fuelAmount = service:GetPendingRefuelAmount()
                    end
                end

                local amountToFill = fuelAmount
                if not amountToFill or amountToFill <= 0 then
                    amountToFill = availableSpace
                else
                    amountToFill = math.min(amountToFill, availableSpace)
                end

                if amountToFill <= 0 then
                    money.notifyTankFull()
                    return false
                end

                local fuelType = monitor:getFuelType() or "Regular"
                local cost = money.calculateCost(fuelType, amountToFill)

                if cost > 0 then
                    local paid = money.trySpend(cost)
                    if not paid then
                        money.notifyInsufficient(cost)
                        --print("[BetterFuelSystem Lua] Refuel aborted: insufficient funds.")
                        return false
                    end
                end

                local filled = monitor:refuel(amountToFill)

                if filled > 0 then
                    money.notifyPurchase(filled, cost, fuelType)
                else
                    money.notifyTankFull()
                end
            end
            return false
        end)

        Override("BetterFuelSystem.Workbench.BTCallback", "RequestFuelDataSync;", function()
            if BetterFuelSystem and BetterFuelSystem.VehicleMonitor then
                local success = BetterFuelSystem.VehicleMonitor:syncFuelData()
                return success == true
            else
                --print("[BetterFuelSystem Lua] VehicleMonitor not available to sync fuel data.")
            end
            return false
        end)

        Override("BetterFuelSystem.Workbench.BTCallback", "GetFuelType;", function()
            if BetterFuelSystem and BetterFuelSystem.VehicleMonitor then
                BetterFuelSystem.VehicleMonitor:syncFuelData()
                local fuelType = BetterFuelSystem.VehicleMonitor:getFuelType()
                if fuelType ~= nil then
                    return fuelType
                end
            end
            return ""
        end)
    end)

    registerForEvent("onShutdown", function ()
        if self.GasMarkers and self.GasMarkers.shutdown then
            self.GasMarkers.shutdown()
        end
        --print("[BetterFuelSystem] Mod Main Logic Shutdown (Lua).")
    end)

    registerForEvent("onUpdate", function (deltaTime) 
        if deltaTime <= 0.001 then
            return
        end
        
        if self.runtimeData.inGame and not self.runtimeData.initialized then
            self.runtimeData.initialized = true
        end

        if self.runtimeData.inGame then
            local player = Game.GetPlayer()
            local vehicle = Game.GetMountedVehicle(player)
            
            local isPlayerDriving = false
            if vehicle and player then
                isPlayerDriving = self.Utils.IsPlayerDriving(vehicle, player)
                print("[BFS][init] onUpdate: vehicle=" .. tostring(vehicle ~= nil) .. ", isPlayerDriving=" .. tostring(isPlayerDriving))
            end

            if vehicle and not self.runtimeData.vehicleDetected then
                print("[BFS][init] Vehicle detected, initializing monitor...")
                self.runtimeData.vehicleDetected = true
                Cron.After(4, function()
                    self.VehicleMonitor:init()
                    self.runtimeData.blackboardInitialized = true
                    print("[BFS][init] VehicleMonitor initialized")
                end)
            elseif not vehicle and self.runtimeData.vehicleDetected then
                print("[BFS][init] Vehicle lost, saving and unregistering...")
                self.VehicleMonitor:save()
                self.VehicleMonitor:unregisterListeners()
                self.runtimeData.vehicleDetected = false
            end

            if self.runtimeData.vehicleDetected then
                self.VehicleMonitor:update(deltaTime)
            end
            
            local isInMenu = self.GameUI and self.GameUI.IsMenu and self.GameUI.IsMenu() or false
            if self.lastMenuState and not isInMenu then
                if self.GasMarkers and self.GasMarkers.refresh then
                    self.GasMarkers.refresh(true)
                end
            end
            self.lastMenuState = isInMenu
            
            Cron.Update(deltaTime)
        end
    end)
    return self
end

return BetterFuelSystem:new()