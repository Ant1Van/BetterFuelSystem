module BetterFuelSystem.Workbench
import BetterFuelSystem.*

public struct BTCallback {
    public static func RequestRefuelFromLua() -> Void {}
    public static func RequestFuelDataSync() -> Bool {
        return false;
    }
    public static func GetFuelType() -> String {
        return "";
    }
}