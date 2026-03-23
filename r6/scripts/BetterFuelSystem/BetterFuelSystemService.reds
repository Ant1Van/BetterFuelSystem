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

// Класс для хранения данных о топливе
public class FuelData extends IScriptable {
    public let fuelType: String;      // Тип топлива
    public let tankCapacity: Float;   // Объём бака
    public let currentFuel: Float;    // Текущее количество топлива
    
    public static func Create(fuelType: String, tankCapacity: Float, currentFuel: Float) -> ref<FuelData> {
        let self = new FuelData();
        self.fuelType = fuelType;
        self.tankCapacity = tankCapacity;
        self.currentFuel = currentFuel;
        return self;
    }
}

public class BetterFuelSystemService extends ScriptableService {
    // Хранилище данных о топливе для каждого транспортного средства
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
    
    // Метод для установки данных о топливе из Lua
    public func SetVehicleFuelData(vehicleID: String, fuelType: String, tankCapacity: Float, currentFuel: Float) -> Void {
        // Используем TDBID.ToNumber() согласно документации redscript hash maps
        // https://wiki.redmodding.org/redscript/references-and-examples/common-patterns/hash-maps
        let hash = TDBID.ToNumber(TDBID.Create(vehicleID));
        
        // Создаем новый объект с актуальными данными
        let fuelData = FuelData.Create(fuelType, tankCapacity, currentFuel);
        
        // Если ключ уже существует, удаляем старые данные
        if this.vehicleFuelData.KeyExist(hash) {
            this.vehicleFuelData.Remove(hash);
        }
        
        // Добавляем новые данные
        this.vehicleFuelData.Insert(hash, fuelData);
        this.currentVehicleID = vehicleID;
    }
    
    // Метод для получения данных о топливе
    public func GetVehicleFuelData(vehicleID: String) -> ref<FuelData> {
        // Используем TDBID.ToNumber() согласно документации redscript hash maps
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
    
    // Метод для проверки наличия данных о транспортном средстве
    public func HasVehicleData(vehicleID: String) -> Bool {
        let hash = TDBID.ToNumber(TDBID.Create(vehicleID));
        return IsDefined(this.vehicleFuelData.Get(hash));
    }
    
    // Метод для удаления данных о транспортном средстве
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