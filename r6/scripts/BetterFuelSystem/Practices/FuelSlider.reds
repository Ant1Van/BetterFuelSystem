module BetterFuelSystem.Practices

import BetterFuelSystem.*
import BetterFuelSystem.Workbench.Practice
import BetterFuelSystem.Workbench.BTCallback
import Codeware.UI.*


public class FuelSlider extends Practice {
	protected let m_sliderWidget: wref<inkWidget>;
	protected let m_sliderController: wref<inkSliderController>;
	protected let m_valueText: wref<inkText>;
	protected let m_currentValue: Float;
	protected let m_minValue: Float;
	protected let m_maxValue: Float;
	protected let m_stepValue: Float;
	protected let m_isEnabled: Bool;

	protected cb func OnCreate() {
		let root = new inkCanvas();
		root.SetName(this.GetClassName());
		root.SetAnchor(inkEAnchor.Fill);
		
		let container = new inkVerticalPanel();
		container.SetName(n"container");
		container.SetFitToContent(true);
		container.SetAnchor(inkEAnchor.Centered);
		container.SetAnchorPoint(Vector2(0.5, 0.5));
		container.SetChildMargin(inkMargin(0.0, 20.0, 0.0, 20.0));
		container.Reparent(root);

		let labelText = new inkText();
		labelText.SetName(n"labelText");
		labelText.SetText(this.GetLocalizedText("BetterFuelSystem-Fuel-Amount"));
		labelText.SetFontFamily("base\\gameplay\\gui\\fonts\\raj\\raj.inkfontfamily");
		labelText.SetFontSize(42);
		labelText.SetFontStyle(n"Medium");
		labelText.SetTintColor(ThemeColors.Bittersweet());
		labelText.SetHorizontalAlignment(textHorizontalAlignment.Center);
		labelText.SetVerticalAlignment(textVerticalAlignment.Center);
		labelText.SetFitToContent(true);
		labelText.Reparent(container);
		
		let sliderRoot = new inkCanvas();
		sliderRoot.SetName(n"fuelslider");
		sliderRoot.SetSize(Vector2(900.0, 80.0));
		sliderRoot.SetMargin(inkMargin(0.0, 0.0, 0.0, 180.0));
		sliderRoot.SetInteractive(true);
		
		let rootBk = new inkImage();
		rootBk.SetName(n"bk");
		rootBk.SetAnchor(inkEAnchor.Fill);
		rootBk.SetAnchorPoint(Vector2(0.5, 0.5));
		rootBk.SetHAlign(inkEHorizontalAlign.Left);
		rootBk.SetVAlign(inkEVerticalAlign.Top);
		rootBk.SetOpacity(0.02);
		rootBk.SetTintColor(ThemeColors.ElectricBlue());
		rootBk.SetSize(Vector2(900.0, 80.0));
		rootBk.SetAtlasResource(r"base\\gameplay\\gui\\common\\shadow_blobs.inkatlas");
		rootBk.SetTexturePart(n"shadowBlobSquare_small");
		rootBk.SetNineSliceScale(true);
		rootBk.Reparent(sliderRoot);
		
		let layout = new inkHorizontalPanel();
		layout.SetName(n"layout");
		layout.SetInteractive(true);
		layout.SetHAlign(inkEHorizontalAlign.Left);
		layout.SetVAlign(inkEVerticalAlign.Top);
		layout.Reparent(sliderRoot);
		
		let sliderContainer = new inkCanvas();
		sliderContainer.SetName(n"container");
		sliderContainer.SetHAlign(inkEHorizontalAlign.Right);
		sliderContainer.SetSizeRule(inkESizeRule.Stretch);
		sliderContainer.SetSize(Vector2(900.0, 80.0));
		sliderContainer.SetInteractive(true);
		sliderContainer.Reparent(layout);
		
		let bkFill = new inkImage();
		bkFill.SetName(n"bkFill");
		bkFill.SetFitToContent(true);
		bkFill.SetAnchor(inkEAnchor.Fill);
		bkFill.SetAnchorPoint(Vector2(0.5, 0.5));
		bkFill.SetHAlign(inkEHorizontalAlign.Center);
		bkFill.SetVAlign(inkEVerticalAlign.Center);
		bkFill.SetOpacity(0.55);
		bkFill.SetTintColor(ThemeColors.BlackPearl());
		bkFill.SetSize(Vector2(32.0, 32.0));
		bkFill.SetAtlasResource(r"base\\gameplay\\gui\\common\\shapes\\atlas_shapes_sync.inkatlas");
		bkFill.SetTexturePart(n"cell_bg");
		bkFill.SetNineSliceScale(true);
		bkFill.Reparent(sliderContainer);
		
		let bkFrame = new inkImage();
		bkFrame.SetName(n"bk");
		bkFrame.SetFitToContent(true);
		bkFrame.SetAnchor(inkEAnchor.Fill);
		bkFrame.SetAnchorPoint(Vector2(0.5, 0.5));
		bkFrame.SetHAlign(inkEHorizontalAlign.Center);
		bkFrame.SetVAlign(inkEVerticalAlign.Center);
		bkFrame.SetOpacity(0.3);
		bkFrame.SetTintColor(ThemeColors.Bittersweet());
		bkFrame.SetSize(Vector2(32.0, 32.0));
		bkFrame.SetAtlasResource(r"base\\gameplay\\gui\\common\\shapes\\atlas_shapes_sync.inkatlas");
		bkFrame.SetTexturePart(n"cell_fg");
		bkFrame.SetNineSliceScale(true);
		bkFrame.Reparent(sliderContainer);
		
		let slidingArea = new inkCanvas();
		slidingArea.SetName(n"slidingArea");
		slidingArea.SetInteractive(true);
		slidingArea.SetAnchor(inkEAnchor.Fill);
		slidingArea.SetMargin(inkMargin(160.0, 0.0, 160.0, 0.0));
		slidingArea.SetSize(Vector2(550.0, 400.0));
		slidingArea.SetChildOrder(inkEChildOrder.Backward);
		slidingArea.Reparent(sliderContainer);
		
		let knob = new inkCanvas();
		knob.SetName(n"knob");
		knob.SetAnchor(inkEAnchor.LeftFillVerticaly);
		knob.SetMargin(inkMargin(0.0, 6.0, 0.0, 12.0));
		knob.SetPadding(inkMargin(10.0, 10.0, 10.0, 10.0));
		knob.SetSize(Vector2(160.0, 32.0));
		knob.SetChildOrder(inkEChildOrder.Backward);
		knob.Reparent(slidingArea);
		
		let handle = new inkImage();
		handle.SetName(n"handle");
		handle.SetAnchor(inkEAnchor.Fill);
		handle.SetHAlign(inkEHorizontalAlign.Center);
		handle.SetVAlign(inkEVerticalAlign.Center);
		handle.SetOpacity(0.9);

		let knobBgColor: HDRColor;
		knobBgColor.Red = 0.282353;
		knobBgColor.Green = 0.113725;
		knobBgColor.Blue = 0.137255;
		knobBgColor.Alpha = 1.0;
		handle.SetTintColor(knobBgColor);
		handle.SetSize(Vector2(80.0, 32.0));
		handle.SetAtlasResource(r"base\\gameplay\\gui\\common\\shapes\\atlas_shapes_sync.inkatlas");
		handle.SetTexturePart(n"cell_bg");
		handle.SetNineSliceScale(true);
		handle.Reparent(knob);
		
		let txtValue = new inkText();
		txtValue.SetName(n"txtValue");
		txtValue.SetText("50");
		txtValue.SetFontFamily("base\\gameplay\\gui\\fonts\\raj\\raj.inkfontfamily");
		txtValue.SetFontSize(42);
		txtValue.SetFontStyle(n"Medium");
		txtValue.SetTintColor(ThemeColors.ElectricBlue());
		txtValue.SetAnchor(inkEAnchor.Centered);
		txtValue.SetAnchorPoint(Vector2(0.5, 0.5));
		txtValue.SetSize(Vector2(100.0, 32.0));
		txtValue.SetHorizontalAlignment(textHorizontalAlignment.Center);
		txtValue.SetVerticalAlignment(textVerticalAlignment.Center);
		txtValue.SetTracking(2);
		txtValue.Reparent(knob);
		this.m_valueText = txtValue;
		
		let handleBorder = new inkImage();
		handleBorder.SetName(n"handleBorder");
		handleBorder.SetInteractive(true);
		handleBorder.SetAnchor(inkEAnchor.Fill);
		handleBorder.SetHAlign(inkEHorizontalAlign.Center);
		handleBorder.SetVAlign(inkEVerticalAlign.Center);
		handleBorder.SetOpacity(0.5);
		handleBorder.SetTintColor(ThemeColors.Bittersweet());
		handleBorder.SetSize(Vector2(80.0, 32.0));
		handleBorder.SetAtlasResource(r"base\\gameplay\\gui\\common\\shapes\\atlas_shapes_sync.inkatlas");
		handleBorder.SetTexturePart(n"cell_fg");
		handleBorder.SetNineSliceScale(true);
		handleBorder.Reparent(knob);
		
		let background = new inkRectangle();
		background.SetName(n"background");
		background.SetAnchor(inkEAnchor.CenterFillHorizontaly);
		background.SetAnchorPoint(Vector2(0.0, 0.5));
		background.SetOpacity(0.06);
		background.SetTintColor(ThemeColors.Bittersweet());
		background.SetSize(Vector2(64.0, 5.0));
		background.Reparent(slidingArea);
		
		let btnLeft = new inkCanvas();
		btnLeft.SetName(n"btnLeft");
		btnLeft.SetInteractive(true);
		btnLeft.SetMargin(inkMargin(-18.0, 0.0, 0.0, 0.0));
		btnLeft.SetSize(Vector2(175.0, 75.0));
		
		let btnLeftController = new inkButtonController();
		btnLeftController.autoUpdateWidgetState = true;
		btnLeft.AttachController(btnLeftController, true);
		
		btnLeft.Reparent(sliderContainer);
		
		let arrowLeft = new inkImage();
		arrowLeft.SetName(n"arrow");
		arrowLeft.SetFitToContent(true);
		arrowLeft.SetAnchor(inkEAnchor.CenterLeft);
		arrowLeft.SetAnchorPoint(Vector2(0.5, 0.5));
		arrowLeft.SetMargin(inkMargin(60.0, 0.0, 0.0, 0.0));
		arrowLeft.SetHAlign(inkEHorizontalAlign.Center);
		arrowLeft.SetVAlign(inkEVerticalAlign.Center);
		arrowLeft.SetSize(Vector2(32.0, 32.0));
		arrowLeft.SetAtlasResource(r"base\\gameplay\\gui\\common\\shapes\\atlas_shapes_sync.inkatlas");
		arrowLeft.SetTexturePart(n"arrow_rect_fg");
		arrowLeft.SetTintColor(ThemeColors.ElectricBlue());
		arrowLeft.Reparent(btnLeft);
		
		let arrowLeftFilled = new inkImage();
		arrowLeftFilled.SetName(n"arrowFilled");
		arrowLeftFilled.SetFitToContent(true);
		arrowLeftFilled.SetAnchor(inkEAnchor.CenterLeft);
		arrowLeftFilled.SetAnchorPoint(Vector2(0.5, 0.5));
		arrowLeftFilled.SetMargin(inkMargin(60.0, 0.0, 0.0, 0.0));
		arrowLeftFilled.SetHAlign(inkEHorizontalAlign.Center);
		arrowLeftFilled.SetVAlign(inkEVerticalAlign.Center);
		arrowLeftFilled.SetSize(Vector2(32.0, 32.0));
		arrowLeftFilled.SetAtlasResource(r"base\\gameplay\\gui\\common\\shapes\\atlas_shapes_sync.inkatlas");
		arrowLeftFilled.SetTexturePart(n"arrow_rect_bg");
		arrowLeftFilled.SetTintColor(ThemeColors.ElectricBlue());
		arrowLeftFilled.Reparent(btnLeft);
		
		let btnRight = new inkCanvas();
		btnRight.SetName(n"btnRight");
		btnRight.SetInteractive(true);
		btnRight.SetAnchor(inkEAnchor.TopRight);
		btnRight.SetAnchorPoint(Vector2(1.0, 0.0));
		btnRight.SetMargin(inkMargin(0.0, 0.0, -18.0, 0.0));
		btnRight.SetSize(Vector2(175.0, 75.0));
		
		let btnRightController = new inkButtonController();
		btnRightController.autoUpdateWidgetState = true;
		btnRight.AttachController(btnRightController, true);
		
		btnRight.Reparent(sliderContainer);
		
		let arrowRight = new inkImage();
		arrowRight.SetName(n"arrow");
		arrowRight.SetFitToContent(true);
		arrowRight.SetAnchor(inkEAnchor.CenterRight);
		arrowRight.SetAnchorPoint(Vector2(0.5, 0.5));
		arrowRight.SetMargin(inkMargin(0.0, 0.0, 60.0, 0.0));
		arrowRight.SetHAlign(inkEHorizontalAlign.Center);
		arrowRight.SetVAlign(inkEVerticalAlign.Center);
		arrowRight.SetSize(Vector2(32.0, 32.0));
		arrowRight.SetAtlasResource(r"base\\gameplay\\gui\\common\\shapes\\atlas_shapes_sync.inkatlas");
		arrowRight.SetTexturePart(n"arrow_rect_fg");
		arrowRight.SetTintColor(ThemeColors.ElectricBlue());
		arrowRight.Reparent(btnRight);
		
		let arrowRightFilled = new inkImage();
		arrowRightFilled.SetName(n"arrowFilled");
		arrowRightFilled.SetFitToContent(true);
		arrowRightFilled.SetAnchor(inkEAnchor.CenterRight);
		arrowRightFilled.SetAnchorPoint(Vector2(0.5, 0.5));
		arrowRightFilled.SetMargin(inkMargin(0.0, 0.0, 60.0, 0.0));
		arrowRightFilled.SetHAlign(inkEHorizontalAlign.Center);
		arrowRightFilled.SetVAlign(inkEVerticalAlign.Center);
		arrowRightFilled.SetSize(Vector2(32.0, 32.0));
		arrowRightFilled.SetAtlasResource(r"base\\gameplay\\gui\\common\\shapes\\atlas_shapes_sync.inkatlas");
		arrowRightFilled.SetTexturePart(n"arrow_rect_bg");
		arrowRightFilled.SetTintColor(ThemeColors.ElectricBlue());
		arrowRightFilled.Reparent(btnRight);
		
		let sliderController = new inkSliderController();
		
		sliderController.slidingAreaRef = inkWidgetRef.Create(slidingArea);
		sliderController.handleRef = inkWidgetRef.Create(knob);
		sliderController.nextRef = inkWidgetRef.Create(btnRight);
		sliderController.priorRef = inkWidgetRef.Create(btnLeft);
		sliderController.direction = inkESliderDirection.Horizontal;
		
		sliderContainer.AttachController(sliderController, true);
		
		this.m_minValue = 0.0;
		this.m_maxValue = 1.0; 
		this.m_stepValue = 1.0;
		this.m_currentValue = 0.0;
		this.m_isEnabled = false;
		
		sliderController.Setup(
			this.m_minValue,
			this.m_maxValue,
			this.m_currentValue,
			this.m_stepValue
		);
		
		sliderController.RegisterToCallback(
			n"OnSliderValueChanged",
			this,
			n"OnSliderValueChanged"
		);
		sliderController.RegisterToCallback(
			n"OnSliderHandleReleased",
			this,
			n"OnHandleReleased"
		);
		
		this.m_sliderWidget = sliderRoot;
		this.m_sliderController = sliderController;
		
		sliderRoot.Reparent(container);

		this.SetRootWidget(root);
	}

	protected cb func OnInitialize() {
		if IsDefined(this.m_sliderWidget) {
			this.SetEnabled(false);
		}
		this.UpdateValueText();
	}

	protected cb func OnSliderValueChanged(
		sliderController: wref<inkSliderController>,
		progress: Float,
		value: Float
	) -> Bool {
		this.m_currentValue = value;
		this.UpdateValueText();
		return true;
	}

	protected cb func OnHandleReleased() -> Bool {
		return true;
	}

	protected func UpdateValueText() -> Void {
		if IsDefined(this.m_valueText) {
			let valueStr = FloatToStringPrec(this.m_currentValue, 1);
			this.m_valueText.SetText(valueStr);
		}
	}

	public func SetValue(value: Float) -> Void {
		this.m_currentValue = ClampF(value, this.m_minValue, this.m_maxValue);
		if IsDefined(this.m_sliderController) {
			this.m_sliderController.ChangeValue(this.m_currentValue);
		}
		this.UpdateValueText();
	}

	public func GetValue() -> Float {
		return this.m_currentValue;
	}

	public func SetRange(min: Float, max: Float, step: Float) -> Void {
		this.m_minValue = min;
		this.m_maxValue = max;
		this.m_stepValue = step;
		if IsDefined(this.m_sliderController) {
			this.m_sliderController.Setup(
				this.m_minValue,
				this.m_maxValue,
				this.m_currentValue,
				this.m_stepValue
			);
		}
	}
	
	public func SetEnabled(enabled: Bool) -> Void {
		this.m_isEnabled = enabled;
		if IsDefined(this.m_sliderWidget) {
			this.m_sliderWidget.SetInteractive(enabled);
			if enabled {
				this.m_sliderWidget.SetOpacity(1.0);
			} else {
				this.m_sliderWidget.SetOpacity(0.5);
			}
		}
	}
	
	public func UpdateFromFuelData() -> Void {
		let service = GetBetterFuelSystemServiceInstance();
		if !IsDefined(service) {
			return;
		}
		
		let fuelData = service.GetCurrentVehicleFuelData();
		if !IsDefined(fuelData) {
			return;
		}
		
		let currentFuel = fuelData.currentFuel;
		let tankCapacity = fuelData.tankCapacity;
		let availableSpace = tankCapacity - currentFuel;
		
		if availableSpace <= 0.0 {
			this.m_minValue = 0.0;
			this.m_maxValue = 1.0;
			this.m_currentValue = 0.0;
		} else {
			this.m_minValue = 0.0;
			this.m_maxValue = availableSpace;
			this.m_stepValue = 1.0;
			this.m_currentValue = 0.0;
		}
		
		if IsDefined(this.m_sliderController) {
			this.m_sliderController.Setup(
				this.m_minValue,
				this.m_maxValue,
				this.m_currentValue,
				this.m_stepValue
			);
		}
		
		if IsDefined(this.m_sliderWidget) {
			this.m_sliderWidget.SetInteractive(this.m_isEnabled);
			if this.m_isEnabled {
				this.m_sliderWidget.SetOpacity(1.0);
			} else {
				this.m_sliderWidget.SetOpacity(0.5);
			}
		}
		
		this.UpdateValueText();
	}
}