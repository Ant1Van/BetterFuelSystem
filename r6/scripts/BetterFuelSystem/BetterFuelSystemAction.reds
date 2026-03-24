//:: ========================================================================================== :://
//::                                                                                            :://
//::   █████╗  ███╗   ██╗ ████████╗  ██╗  ██╗   ██╗  █████╗  ███╗   ██╗     [ SYSTEM ]          :://
//::  ██╔══██╗ ████╗  ██║ ╚══██╔══╝  ██║  ██║   ██║ ██╔══██╗ ████╗  ██║     [ ONLINE ]          :://
//::  ███████║ ██╔██╗ ██║    ██║     ██║  ██║   ██║ ███████║ ██╔██╗ ██║     [ REDSCRIPT ]       :://
//::  ██╔══██║ ██║╚██╗██║    ██║     ██║  ╚██╗ ██╔╝ ██╔══██║ ██║╚██╗██║     v. 1.0.0            :://
//::  ██║  ██║ ██║ ╚████║    ██║     ██║   ╚████╔╝  ██║  ██║ ██║ ╚████║                         :://
//::  ╚═╝  ╚═╝ ╚═╝  ╚═══╝    ╚═╝     ╚═╝    ╚═══╝   ╚═╝  ╚═╝ ╚═╝  ╚═══╝                         :://
//::                                                                                            :://
//:: __________________________________________________________________________________________ :://
//::                                                                                            :://
//::  Copyright (C) 2025, Ant1Van. All rights reserved.                                         :://
//::  This mod is under the MIT License.                                                        :://
//::  https://opensource.org/licenses/mit-license.php                                           :://
//:: ========================================================================================== :://


module BetterFuelSystem

import BetterFuelSystem.BetterFuelSystemPopup
import Codeware.Localization.*
import Codeware.UI.*

public static func GetGasStations() -> array<Vector4> {
    return [
        new Vector4(-265.30515, -1884.0623, 8.619392, 1.0), 
        new Vector4(-150.29979, -1975.7863, 5.8980026, 1.0), 
        new Vector4(743.4587, -1026.5077, 27.927948, 1.0), 
        new Vector4(342.11194, -931.5839, 24.76944, 1.0), 
        new Vector4(328.76538, -912.7226, 24.76944, 1.0),
        new Vector4(1696.4524, -747.9551, 49.88601, 1.0), 
        new Vector4(2587.1013, -12.164787, 80.744934, 1.0), 
        new Vector4(1490.3348, -1382.0677, 51.24347, 1.0), 
        new Vector4(-123.270096, -4399.742, 58.965744, 1.0), 
        new Vector4(-1691.6865, -4992.5835, 80.20059, 1.0), 
        new Vector4(-1814.9635, -4279.0073, 74.013214, 1.0),
        new Vector4(-593.85486, -711.4331, 8.947876, 1.0),
        new Vector4(-1323.2358, 2233.0151, 15.7690735, 1.0),
        new Vector4(-324.7967, 1399.4001, 43.03463, 1.0),
        new Vector4(-2436.2734, -221.40077, 7.8751297, 1.0),
        new Vector4(-898.43085, 1893.9088, 36.157684, 1.0),
        new Vector4(-2258.9006, -2566.7612, 25.261398, 1.0),
        new Vector4(-1413.9508, 1356.0709, 57.399277, 1.0),
        new Vector4(-1495.4105, 1026.1951, 22.495834, 1.0),
        new Vector4(99.95268, 797.1646, 128.3878, 1.0),
        new Vector4(-1995.488, 651.43665, 10.360001, 1.0),
        new Vector4(-2295.397, -2143.2217, 11.646996, 1.0),
        new Vector4(796.4182, -718.8439, 22.428009, 1.0),
        new Vector4(-1192.412, -1183.8212, 32.72499, 1.0)
    ];
}

private static func IsPlayerNearGasStation(playerPosition: Vector4, maxDistance: Float) -> Bool {
    let gasStations = GetGasStations();
    let i: Int32 = 0;
    let stationsCount: Int32 = ArraySize(gasStations);
    
    while i < stationsCount {
        let playerPos3D = new Vector3(playerPosition.X, playerPosition.Y, playerPosition.Z);
        let stationPos3D = new Vector3(gasStations[i].X, gasStations[i].Y, gasStations[i].Z);
        
        let dx = playerPos3D.X - stationPos3D.X;
        let dy = playerPos3D.Y - stationPos3D.Y;
        let dz = playerPos3D.Z - stationPos3D.Z;
        
        let distance = SqrtF(dx * dx + dy * dy + dz * dz);
        
        // Debug logging for the new station
        if Equals(gasStations[i].X, 593.85486) && Equals(gasStations[i].Y, -711.4331) {
            //LogChannel(n"DEBUG", s"Distance to station (593.85, -711.43): \(distance), max: \(maxDistance)");
        }
        
        if distance <= maxDistance {
            return true;
        }
        i += 1;
    }
    return false;
}

@wrapMethod(gameuiInGameMenuGameController)
private final func RegisterInputListenersForPlayer(playerPuppet: ref<GameObject>) {
    wrappedMethod(playerPuppet);

    if playerPuppet.IsControlledByLocalPeer() {
        playerPuppet.RegisterInputListener(this, n"open_better_fuel_system");
    }
}

@wrapMethod(gameuiInGameMenuGameController)
protected cb func OnAction(action: ListenerAction, consumer: ListenerActionConsumer) -> Bool {
    let result = wrappedMethod(action, consumer);

    let actionName = ListenerAction.GetName(action);
    let actionType = ListenerAction.GetType(action);

    if Equals(actionName, n"open_better_fuel_system") && Equals(actionType, gameinputActionType.BUTTON_HOLD_COMPLETE) {
        let player = this.GetPlayerControlledObject() as PlayerPuppet;
        let blackboard = player.GetPlayerStateMachineBlackboard();
        let state = IntEnum<gamePSMVehicle>(blackboard.GetInt(GetAllBlackboardDefs().PlayerStateMachine.Vehicle));

        if Equals(state, gamePSMVehicle.Default) {
            return result;
        }

        if !Codeware.Require("1.1.4") {
            //LogChannel(n"DEBUG", "BetterFuelSystem requires Codeware 1.1.4+");
            return result;
        }

        let playerPosition = player.GetWorldPosition();
        let isNear = IsPlayerNearGasStation(playerPosition, 10.0);
        //LogChannel(n"DEBUG", s"Player position: X=\(playerPosition.X), Y=\(playerPosition.Y), Z=\(playerPosition.Z), Near station: \(isNear)");
        if !isNear {
            return result;
        }

        BetterFuelSystemPopup.Show(this);
        ListenerActionConsumer.DontSendReleaseEvent(consumer);
        return true;
    }
    
    return result;
}
