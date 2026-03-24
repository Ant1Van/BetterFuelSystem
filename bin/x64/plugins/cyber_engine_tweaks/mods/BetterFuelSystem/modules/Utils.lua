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

function Utils.registerBlackboardListeners(vehicle)
    if not vehicle then return end

    local blackboardSystem = Game.GetBlackboardSystem()
    local vehicleID = vehicle:GetEntityID()
    local blackboardDefs = Game.GetAllBlackboardDefs()
    local vehicleBlackboard = blackboardSystem:GetLocalInstanced(vehicleID, blackboardDefs.Vehicle)

    if not vehicleBlackboard then return end

    Utils.rpmListener = function(_, value) Utils.rpmValue = value end
    Utils.speedListener = function(_, value) Utils.speedValue = value end
    Utils.gearListener = function(_, value) Utils.gearValue = value end

    vehicleBlackboard:RegisterListenerFloat(blackboardDefs.Vehicle.RPMValue, Utils.rpmListener)
    vehicleBlackboard:RegisterListenerFloat(blackboardDefs.Vehicle.SpeedValue, Utils.speedListener)
    vehicleBlackboard:RegisterListenerInt(blackboardDefs.Vehicle.GearValue, Utils.gearListener)
end

function Utils.unregisterBlackboardListeners(vehicle)
    if not vehicle then return end

    local blackboardSystem = Game.GetBlackboardSystem()
    local vehicleID = vehicle:GetEntityID()
    local blackboardDefs = Game.GetAllBlackboardDefs()
    local vehicleBlackboard = blackboardSystem:GetLocalInstanced(vehicleID, blackboardDefs.Vehicle)

    if not vehicleBlackboard then return end

    vehicleBlackboard:UnregisterListenerFloat(blackboardDefs.Vehicle.RPMValue, Utils.rpmListener)
    vehicleBlackboard:UnregisterListenerFloat(blackboardDefs.Vehicle.SpeedValue, Utils.speedListener)
    vehicleBlackboard:UnregisterListenerInt(blackboardDefs.Vehicle.GearValue, Utils.gearListener)
end

return Utils