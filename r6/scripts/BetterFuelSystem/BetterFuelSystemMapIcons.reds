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

// Detect our fuel station pins via the debugCaption we set in GasStationMarkers.lua
@addMethod(BaseMappinBaseController)
protected final func __bfsIsFuelStationPin() -> Bool {
  let cap: String = this.GetMappin().GetDisplayName();
  let parts: array<String> = StrSplit(cap, "|");
  return ArraySize(parts) > 0 && Equals(parts[0], "BetterFuelSystem");
}

// Apply custom fuel icon
@addMethod(BaseMappinBaseController)
protected final func __bfsApplyFuelIcon(opt forMinimap: Bool) -> Void {
  if !this.__bfsIsFuelStationPin() { return; }

  // Use fuel icon from vehicle atlas
  let atlasPath: ResRef = r"ep1\\gameplay\\gui\\widgets\\vehicle\\sport\\v_sport2_villefort_deleon\\villefort_deleon.inkatlas";
  let partName: CName = n"fuel";

  inkImageRef.SetAtlasResource(this.iconWidget, atlasPath);
  inkImageRef.SetTexturePart(this.iconWidget, partName);

  // Scale for minimap vs world map
  let s: Float = forMinimap ? 0.60 : 0.65;
  inkWidgetRef.SetScale(this.iconWidget, new Vector2(s, s));
}

// Minimap pin
@wrapMethod(MinimapPOIMappinController)
protected final func UpdateIcon() -> Void {
  wrappedMethod();
  this.__bfsApplyFuelIcon(true);
}

// World floating pin
@wrapMethod(QuestMappinController)
protected func UpdateIcon() -> Void {
  wrappedMethod();
  this.__bfsApplyFuelIcon(false);
}

// World Map screen
@wrapMethod(BaseWorldMapMappinController)
protected func UpdateIcon() -> Void {
  wrappedMethod();
  this.__bfsApplyFuelIcon(false);
}

