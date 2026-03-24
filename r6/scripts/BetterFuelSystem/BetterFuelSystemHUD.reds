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

import Codeware.UI.VirtualResolutionWatcher

// Small polling callback
public class BFS_HUDTick extends DelayCallback {
  private let hud: wref<FuelIndicatorManager>;

  public func Call() -> Void {
    if IsDefined(this.hud) {
      this.hud.__tickArmed = false;
      this.hud.Refresh();
      this.hud.ArmNextTick();
    }
  }

  public static func Create(h: ref<FuelIndicatorManager>) -> ref<BFS_HUDTick> {
    let t = new BFS_HUDTick();
    t.hud = h;
    return t;
  }
}

// HUD widget (Fuel indicator)
public class FuelIndicatorManager extends IScriptable {

  // --- update scheduling ---
  private let vrw: ref<VirtualResolutionWatcher>;
  private let tick: ref<BFS_HUDTick>;
  private let tickPeriod: Float = 0.25; // 4 Hz
  public let __tickArmed: Bool;

  // --- build & state caches ---
  private let __built: Bool;
  private let m_title: wref<inkText>;
  private let m_text: wref<inkText>;

  // --- placement (virtual 3840x2160 canvas) ---
  private let MARGIN_LEFT: Float   = 440.0;
  private let MARGIN_BOTTOM: Float = 320.0;

  // --- typography ---
  private let FONT_SIZE_TITLE: Int32 = 36;
  private let FONT_SIZE_VALUE: Int32 = 38;

  // --- horizontal layout ---
  private let X_FUEL_LABEL: Float = 0.0;
  private let X_FUEL_VALUE: Float = 70.0;

  // --- vertical offsets ---
  private let Y_LINE: Float = 0.0;
  private let Y_VALUE_OFFSET: Float = 3.5;

  // Hard reset (called on world change)
  public func OnNewWorld() -> Void {
    this.__built = false;
    this.__tickArmed = false;
    this.m_title = null;
    this.m_text = null;
  }

  // Check if root widget exists
  private func RootExists(vwin: wref<inkCompoundWidget>) -> Bool {
    if !IsDefined(vwin) { return false; }
    let w = vwin.GetWidgetByPathName(n"Root/BFS_FullScreenSlot/BFS_WidgetSlot/BFS_HUDRoot");
    return IsDefined(w);
  }

  // Find root widget
  private func FindRoot() -> ref<inkCanvas> {
    let inkSys: ref<inkSystem> = GameInstance.GetInkSystem();
    if !IsDefined(inkSys) { return null; }
    let hudLayer = inkSys.GetLayer(n"inkHUDLayer");
    if !IsDefined(hudLayer) { return null; }
    let vwin: ref<inkCompoundWidget> = hudLayer.GetVirtualWindow();
    if !IsDefined(vwin) { return null; }
    return vwin.GetWidgetByPathName(n"Root/BFS_FullScreenSlot/BFS_WidgetSlot/BFS_HUDRoot") as inkCanvas;
  }

  // Arms the next delayed refresh tick (if not already armed)
  public func ArmNextTick() -> Void {
    if this.__tickArmed { return; }
    let ds = GameInstance.GetDelaySystem(GetGameInstance());
    this.tick = BFS_HUDTick.Create(this);
    this.__tickArmed = true;
    ds.DelayCallback(this.tick, this.tickPeriod, false);
  }

  // Apply HUD position (fixed coordinates like Odometr's ApplyHUDPosFromService)
  private func ApplyHUDPos() -> Void {
    let inkSys: ref<inkSystem> = GameInstance.GetInkSystem();
    if !IsDefined(inkSys) { return; }
    let hudLayer = inkSys.GetLayer(n"inkHUDLayer");
    if !IsDefined(hudLayer) { return; }
    let vwin: ref<inkCompoundWidget> = hudLayer.GetVirtualWindow();
    if !IsDefined(vwin) { return; }
    let slot: ref<inkCanvas> = vwin.GetWidgetByPathName(n"Root/BFS_FullScreenSlot/BFS_WidgetSlot") as inkCanvas;
    if IsDefined(slot) {
      slot.SetTranslation(new Vector2(this.MARGIN_LEFT, 2160.0 - this.MARGIN_BOTTOM));
    }
  }

  // Ensure UI tree exists and is scaled/positioned
  public func Ensure() -> Void {
    let inkSys: ref<inkSystem> = GameInstance.GetInkSystem();
    if !IsDefined(inkSys) { return; }
    let hudLayer = inkSys.GetLayer(n"inkHUDLayer");
    if !IsDefined(hudLayer) { return; }
    let vwin: ref<inkCompoundWidget> = hudLayer.GetVirtualWindow();
    if !IsDefined(vwin) { return; }

    let rootNode = vwin.GetWidgetByPathName(n"Root") as inkCompoundWidget;
    if !IsDefined(rootNode) { return; }

    // If widgets were destroyed by a save/load, force rebuild
    if this.__built && !this.RootExists(vwin) {
      this.__built = false;
    }

    if !this.__built {
      // (1) fullscreen virtual canvas (create or reuse)
      let fs: ref<inkCanvas> = vwin.GetWidgetByPathName(n"Root/BFS_FullScreenSlot") as inkCanvas;
      if !IsDefined(fs) {
        fs = new inkCanvas();
        fs.SetName(n"BFS_FullScreenSlot");
        fs.SetSize(new Vector2(3840.0, 2160.0));
        fs.SetRenderTransformPivot(new Vector2(0.0, 0.0));
        fs.SetInteractive(false);
        fs.Reparent(rootNode);
      } else {
        fs.SetInteractive(false);
      }
      if !IsDefined(this.vrw) {
        this.vrw = new VirtualResolutionWatcher();
        this.vrw.Initialize(GetGameInstance());
      }
      this.vrw.ScaleWidget(fs);

      // (2) local slot (create or reuse)
      let slot: ref<inkCanvas> = fs.GetWidgetByPathName(n"BFS_WidgetSlot") as inkCanvas;
      if !IsDefined(slot) {
        slot = new inkCanvas();
        slot.SetName(n"BFS_WidgetSlot");
        slot.SetFitToContent(true);
        slot.SetInteractive(false);
        slot.Reparent(fs);
        slot.SetScale(new Vector2(1.0, 1.0));
      } else {
        slot.SetInteractive(false);
      }
      // Update placement every Ensure
      this.ApplyHUDPos();

      // (3) content root (create or reuse)
      let root: ref<inkCanvas> = slot.GetWidgetByPathName(n"BFS_HUDRoot") as inkCanvas;
      if !IsDefined(root) {
        root = new inkCanvas();
        root.SetName(n"BFS_HUDRoot");
        root.SetInteractive(false);
        root.SetAnchor(inkEAnchor.TopLeft);
        root.Reparent(slot);
      }

      // Colors
      let red: HDRColor; red.Red = 1.0; red.Green = 0.0; red.Blue = 0.0; red.Alpha = 1.0;
      let cyan: HDRColor; cyan.Red = 0.0; cyan.Green = 1.0; cyan.Blue = 1.0; cyan.Alpha = 1.0;

      // Title "FUEL" 
      let title: ref<inkText> = root.GetWidgetByPathName(n"BFS_Title") as inkText;
      if !IsDefined(title) {
        title = new inkText();
        title.SetName(n"BFS_Title");
        title.SetAnchor(inkEAnchor.TopLeft);
        title.SetFontFamily("base\\gameplay\\gui\\fonts\\raj\\raj.inkfontfamily");
        title.SetFontStyle(n"Medium");
        title.SetFontSize(this.FONT_SIZE_TITLE);
        title.SetLetterCase(textLetterCase.OriginalCase);
        title.SetTintColor(red);
        title.SetOpacity(0.8);
        title.SetTranslation(new Vector2(this.X_FUEL_LABEL, this.Y_LINE));
        title.SetText("FUEL");
        title.SetInteractive(false);
        title.Reparent(root);
      }
      this.m_title = title;

      // Fuel value text
      let text: ref<inkText> = root.GetWidgetByPathName(n"BFS_Text") as inkText;
      if !IsDefined(text) {
        text = new inkText();
        text.SetName(n"BFS_Text");
        text.SetAnchor(inkEAnchor.TopLeft);
        text.SetFontFamily("base\\gameplay\\gui\\fonts\\digital_readout\\digitalreadout.inkfontfamily");
        text.SetFontStyle(n"Regular");
        text.SetFontSize(this.FONT_SIZE_VALUE);
        text.SetLetterCase(textLetterCase.OriginalCase);
        text.SetTintColor(cyan);
        text.SetOpacity(1.0);
        text.SetTranslation(new Vector2(this.X_FUEL_VALUE, this.Y_LINE + this.Y_VALUE_OFFSET));
        text.SetText("0/0L");
        text.SetInteractive(false);
        text.Reparent(root);
      }
      this.m_text = text;

      this.__built = true;

    } else {
      // Already built: keep scaling fresh, rebind the plate if needed, and keep nodes non-interactive.
      let fs2c: ref<inkCanvas> = vwin.GetWidgetByPathName(n"Root/BFS_FullScreenSlot") as inkCanvas;
      if IsDefined(fs2c) {
        fs2c.SetInteractive(false);
        if IsDefined(this.vrw) { this.vrw.ScaleWidget(fs2c); }
      }

      let slot2: ref<inkCanvas> = vwin.GetWidgetByPathName(n"Root/BFS_FullScreenSlot/BFS_WidgetSlot") as inkCanvas;
      if IsDefined(slot2) {
        slot2.SetInteractive(false);
      }

      this.ApplyHUDPos();

      if !this.RootExists(vwin) {
        this.__built = false;
      }
    }

    this.Refresh();
    this.ArmNextTick();
  }

  // Refresh data (called from tick callback)
  public func Refresh() -> Void {
    let root = this.FindRoot();
    if !IsDefined(root) { return; }

    let gameInstance = GetGameInstance();
    let player = GetPlayer(gameInstance) as PlayerPuppet;
    let inVehicle: Bool = false;
    
    if IsDefined(player) {
      let vehicle = player.GetMountedVehicle();
      inVehicle = IsDefined(vehicle);
    }

    // Показываем HUD только если игрок сам за рулём (не пассажир/такси)
    let isDriver: Bool = false;
    let svc = GetBetterFuelSystemServiceInstance();
    if IsDefined(svc) {
      isDriver = svc.IsPlayerDriving();
    }

    if !inVehicle || !isDriver {
      this.Hide();
      return;
    }

    this.Show();

    let service = GetBetterFuelSystemServiceInstance();
    if !IsDefined(service) {
      if IsDefined(this.m_text) {
        this.m_text.SetText("0/0L");
      }
      return;
    }

    let fuelData = service.GetCurrentVehicleFuelData();
    if !IsDefined(fuelData) {
      if IsDefined(this.m_text) {
        this.m_text.SetText("0/0L");
      }
      return;
    }

    let currentFuel = fuelData.currentFuel;
    let maxFuel = fuelData.tankCapacity;

    if IsDefined(this.m_text) {
      let current = Cast<Int32>(currentFuel);
      let max = Cast<Int32>(maxFuel);
      
      let fuelText: String;
      if current < 100 && current >= 10 {
        fuelText = " " + ToString(current) + "/" + ToString(max) + "L";
      } else if current < 10 {
        fuelText = "  " + ToString(current) + "/" + ToString(max) + "L";
      } else {
        fuelText = ToString(current) + "/" + ToString(max) + "L";
      }
      
      this.m_text.SetText(fuelText);
    }
  }

  public func Show() -> Void {
    let root = this.FindRoot();
    if IsDefined(root) {
      root.SetVisible(true);
    }
  }

  public func Hide() -> Void {
    let root = this.FindRoot();
    if IsDefined(root) {
      root.SetVisible(false);
    }
  }
}

// Lifecycle hooks
@addField(UISystem)
public let bfsFuelIndicatorManager: ref<FuelIndicatorManager>;

@wrapMethod(UISystem)
public final func PushGameContext(context: UIGameContext) -> Void {
  wrappedMethod(context);
  if !IsDefined(this.bfsFuelIndicatorManager) { this.bfsFuelIndicatorManager = new FuelIndicatorManager(); }
  this.bfsFuelIndicatorManager.Ensure();
}

@wrapMethod(UISystem)
public final func PopGameContext(context: UIGameContext, opt invalidate: Bool) -> Void {
  wrappedMethod(context, invalidate);
  if IsDefined(this.bfsFuelIndicatorManager) {
    this.bfsFuelIndicatorManager.Ensure();
    this.bfsFuelIndicatorManager.Refresh();
  }
}

@wrapMethod(PlayerPuppet)
protected cb func OnTakeControl(resolver: EntityResolveComponentsInterface) -> Bool {
  let r = wrappedMethod(resolver);
  let uiSys: ref<UISystem> = GameInstance.GetUISystem(GetGameInstance());
  if IsDefined(uiSys) {
    if !IsDefined(uiSys.bfsFuelIndicatorManager) { uiSys.bfsFuelIndicatorManager = new FuelIndicatorManager(); }
    uiSys.bfsFuelIndicatorManager.OnNewWorld();
    uiSys.bfsFuelIndicatorManager.Ensure();
  }
  return r;
}
