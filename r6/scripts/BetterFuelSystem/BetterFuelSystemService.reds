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
import BetterFuelSystem.Workbench.*
import Codeware.UI.*


public class FuelData extends IScriptable {
    public let fuelType: String;      // type fuel
    public let tankCapacity: Float;   // Tank capacity
    public let currentFuel: Float;    // Current fuel level
    
    public static func Create(fuelType: String, tankCapacity: Float, currentFuel: Float) -> ref<FuelData> {
        let self = new FuelData();
        self.fuelType = fuelType;
        self.tankCapacity = tankCapacity;
        self.currentFuel = currentFuel;
        return self;
    }
}

public class BetterFuelSystemService extends ScriptableService {
    // Fuel data storage for each vehicle
    private persistent let vehicleFuelData: ref<inkHashMap>;
    private let currentVehicleID: String;
    
    private cb func OnLoad() {
        if !IsDefined(this.vehicleFuelData) {
            this.vehicleFuelData = new inkHashMap();
        }
        this.currentVehicleID = "";
        this.pendingRefuelAmount = 0.0;
    }

    private cb func OnReload() {
        //LogChannel(n"BetterFuelSystem", "Scripts reloaded");
    }

    private cb func OnInitialize() {
        //LogChannel(n"BetterFuelSystem", "Scripts initialized");
    }

    private cb func OnUninitialize() {
        //LogChannel(n"BetterFuelSystem", "Scripts uninitialized");
    }
    
    // Method for setting fuel data from Lua
    public func SetVehicleFuelData(vehicleID: String, fuelType: String, tankCapacity: Float, currentFuel: Float) -> Void {
        // Use TDBID.ToNumber() according to the redscript hash maps documentation
        // https://wiki.redmodding.org/redscript/references-and-examples/common-patterns/hash-maps
        let hash = TDBID.ToNumber(TDBID.Create(vehicleID));
        
        // Create a new object with the current data
        let fuelData = FuelData.Create(fuelType, tankCapacity, currentFuel);
        
        // If the key already exists, delete the old data
        if this.vehicleFuelData.KeyExist(hash) {
            this.vehicleFuelData.Remove(hash);
        }
        
        // Add the new data
        this.vehicleFuelData.Insert(hash, fuelData);
        this.currentVehicleID = vehicleID;
    }
    
    //  Method to get the fuel data
    public func GetVehicleFuelData(vehicleID: String) -> ref<FuelData> {
        // Use TDBID.ToNumber() according to the redscript hash maps documentation
        let hash = TDBID.ToNumber(TDBID.Create(vehicleID));
        let data = this.vehicleFuelData.Get(hash);
        if IsDefined(data) {
            return data as FuelData;
        }
        return null;
    }

    public func GetCurrentVehicleFuelData() -> ref<FuelData> {
        if StrLen(this.currentVehicleID) == 0 {
            return null;
        }
        return this.GetVehicleFuelData(this.currentVehicleID);
    }

    private let pendingRefuelAmount: Float;
    
    public func SetPendingRefuelAmount(amount: Float) -> Void {
        this.pendingRefuelAmount = amount;
    }
    
    public func GetPendingRefuelAmount() -> Float {
        return this.pendingRefuelAmount;
    }

    public func GetCurrentVehicleID() -> String {
        return this.currentVehicleID;
    }
    
    // Method to check if the vehicle data is available
    public func HasVehicleData(vehicleID: String) -> Bool {
        let hash = TDBID.ToNumber(TDBID.Create(vehicleID));
        return IsDefined(this.vehicleFuelData.Get(hash));
    }
    
    // Method to delete the vehicle data
    public func RemoveVehicleData(vehicleID: String) -> Void {
        let hash = TDBID.ToNumber(TDBID.Create(vehicleID));
        if IsDefined(this.vehicleFuelData.Get(hash)) {
            this.vehicleFuelData.Remove(hash);
        }
    }
}

public static func GetBetterFuelSystemServiceInstance() -> ref<BetterFuelSystemService> {
    let serviceContainer = GameInstance.GetScriptableServiceContainer();
    if !IsDefined(serviceContainer) {
        return null;
    }

    return serviceContainer.GetService(n"BetterFuelSystem.BetterFuelSystemService") as BetterFuelSystemService;
}