//:: ========================================================================================== :://
//::                                                                                            :://
//::   BetterFuelSystem Logger Module                                                          :://
//::                                                                                            :://
//::   Simple logging with mod name prefix                                                     :://
//::   See: https://wiki.redmodding.org/redscript/references-and-examples/logging            :://
//:: ========================================================================================== :://

module BetterFuelSystem

public static func Log(value: script_ref<String>) -> Void {
  FTLog(s"[BetterFuelSystem] \(value)");
}

public static func LogWarning(value: script_ref<String>) -> Void {
  FTLogWarning(s"[BetterFuelSystem] \(value)");
}

public static func LogError(value: script_ref<String>) -> Void {
  FTLogError(s"[BetterFuelSystem] \(value)");
}
