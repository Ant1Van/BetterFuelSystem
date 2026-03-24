module BetterFuelSystem.Practices

import BetterFuelSystem.*
import BetterFuelSystem.Workbench.*
import BetterFuelSystem.Workbench.Practice
import BetterFuelSystem.Workbench.BTCallback
import Codeware.UI.*

public class ButtonBasics extends Practice {
	protected let m_top: wref<inkCompoundWidget>;
	protected let m_bottom: wref<inkCompoundWidget>;
	protected let m_regularButton: wref<CustomButton>;
	protected let m_premiumButton: wref<CustomButton>;
	protected let m_hubButton: wref<CustomButton>;
	protected let m_fuelSelected: Bool;

	protected cb func OnCreate() {
		let root = new inkCanvas();
		root.SetName(this.GetClassName());
		root.SetAnchor(inkEAnchor.Fill);
		
		let rows = new inkVerticalPanel();
		rows.SetName(n"rows");
		rows.SetFitToContent(true);
		rows.SetAnchor(inkEAnchor.Centered);
		rows.SetAnchorPoint(Vector2(0.5, 0.75));
		rows.SetChildMargin(inkMargin(0.0, 30.0, 0.0, 30.0));
		rows.Reparent(root);

		let top = new inkHorizontalPanel();
		top.SetFitToContent(true);
		top.SetHAlign(inkEHorizontalAlign.Center);
		top.SetChildMargin(inkMargin(20.0, 0.0, 20.0, 0.0));
		top.Reparent(rows);

		let bottom = new inkHorizontalPanel();
		bottom.SetFitToContent(true);
		bottom.SetHAlign(inkEHorizontalAlign.Center);
		bottom.SetChildMargin(inkMargin(20.0, 0.0, 20.0, 0.0));
		bottom.Reparent(rows);

		let buttonLeft = SimpleButton.Create();
		buttonLeft.SetName(n"LeftButton");
		buttonLeft.SetText(this.GetLocalizedText("BetterFuelSystem-Regular-Button"));
		buttonLeft.SetFlipped(true);
		buttonLeft.ToggleAnimations(true);
		buttonLeft.ToggleSounds(true);
		buttonLeft.Reparent(bottom);
		let leftRoot = buttonLeft.GetRootWidget();
		if IsDefined(leftRoot) {
			leftRoot.SetMargin(inkMargin(0.0, 120.0, 0.0, 0.0));
		}

		let buttonRight = SimpleButton.Create();
		buttonRight.SetName(n"RightButton");
		buttonRight.SetText(this.GetLocalizedText("BetterFuelSystem-Premium-Button"));
		buttonRight.ToggleAnimations(true);
		buttonRight.ToggleSounds(true);
		buttonRight.Reparent(bottom);
		let rightRoot = buttonRight.GetRootWidget();
		if IsDefined(rightRoot) {
			rightRoot.SetMargin(inkMargin(0.0, 120.0, 0.0, 0.0));
		}

		let buttonHub = HubLinkButton.Create();
		buttonHub.SetName(n"HubButton");
		buttonHub.SetText(this.GetLocalizedText("BetterFuelSystem-Hub-Button"));
		buttonHub.SetIcon(n"ico_deck_hub");
		buttonHub.ToggleAnimations(true);
		buttonHub.ToggleSounds(true);
		buttonHub.Reparent(top);
		let hubRoot = buttonHub.GetRootWidget();
		if IsDefined(hubRoot) {
			hubRoot.SetMargin(inkMargin(0.0, 30.0, 0.0, 170.0));
		}

		this.m_top = top;
		this.m_bottom = bottom;

		this.SetRootWidget(root);
	}

	protected cb func OnInitialize() {
		this.RegisterListeners(this.m_top);
		this.RegisterListeners(this.m_bottom);

		this.m_fuelSelected = false;
		this.SetHubButtonEnabled(false);

		this.UpdateButtonsStateFromFuelType();
	}

	protected func RegisterListeners(container: wref<inkCompoundWidget>) {
		let childIndex = 0;
		let numChildren = container.GetNumChildren();

		while childIndex < numChildren {
			let widget = container.GetWidgetByIndex(childIndex);
			let button = widget.GetController() as CustomButton;

			if IsDefined(button) {
				button.RegisterToCallback(n"OnBtnClick", this, n"OnClick");
				button.RegisterToCallback(n"OnRelease", this, n"OnRelease");
				button.RegisterToCallback(n"OnEnter", this, n"OnEnter");
				button.RegisterToCallback(n"OnLeave", this, n"OnLeave");

				if Equals(button.GetName(), n"HubButton") {
					this.m_hubButton = button;
					button.SetDisabled(true);
				}
				if Equals(button.GetName(), n"LeftButton") {
					this.m_regularButton = button;
				}
				if Equals(button.GetName(), n"RightButton") {
					this.m_premiumButton = button;
				}
			}

			childIndex += 1;
		}
	}

	protected cb func OnClick(widget: wref<inkWidget>) -> Bool {
		let button = widget.GetController() as CustomButton;

		if Equals(button.GetName(), n"HubButton") {
			if button.IsDisabled() {
				return false;
			}
		let fuelAmount = this.GetFuelSliderValue();
		let service = GetBetterFuelSystemServiceInstance();
		if IsDefined(service) {
			service.SetPendingRefuelAmount(fuelAmount);
		}
		BTCallback.RequestRefuelFromLua();
		} else {
			if button.IsDisabled() {
				return false;
			}
			this.HandleFuelSelection(button);
		}
		return false;
	}

	protected cb func OnRelease(evt: ref<inkPointerEvent>) -> Bool {
		return false;
	}

	protected func ToggleButtonState(button: ref<CustomButton>) {
		if !IsDefined(button) {
			return;
		}

		button.SetDisabled(!button.IsDisabled());

		this.UpdateHints(button);

		this.PlaySound(n"MapPin", n"OnCreate");
	}

	protected cb func OnEnter(evt: ref<inkPointerEvent>) -> Bool {
		let button = evt.GetTarget().GetController() as CustomButton;

		this.UpdateHints(button);
	}

	protected cb func OnLeave(evt: ref<inkPointerEvent>) -> Bool {
		this.RemoveHints();
	}

	protected func UpdateHints(button: ref<CustomButton>) {
		this.UpdateHint(
			n"click",
			this.GetLocalizedText("BetterFuelSystem-Interaction-Hint-Click"),
			button.IsEnabled()
		);
	}

	protected func RemoveHints() {
		this.RemoveHint(n"click");
	}

	protected func HandleFuelSelection(button: ref<CustomButton>) {
		if !this.m_fuelSelected {
			this.m_fuelSelected = true;
			this.SetHubButtonEnabled(true);
			this.ActivateFuelSlider();
		}
	}
	
	protected func FindFuelSlider() -> wref<FuelSlider> {
		if !IsDefined(this.m_workbench) {
			return null;
		}
		let container = this.m_workbench.GetContainer();
		if !IsDefined(container) {
			return null;
		}
		let numChildren = container.GetNumChildren();
		let i = 0;
		while i < numChildren {
			let child = container.GetWidgetByIndex(i);
			if IsDefined(child) {
				let widgetName = child.GetName();
				if Equals(widgetName, n"BetterFuelSystem.Practices.FuelSlider") {
					let fuelSlider = child.GetController() as FuelSlider;
					if IsDefined(fuelSlider) {
						return fuelSlider;
					}
				}
			}
			i += 1;
		}
		return null;
	}
	
	protected func ActivateFuelSlider() -> Void {
		let fuelSlider = this.FindFuelSlider();
		if !IsDefined(fuelSlider) {
			return;
		}
		fuelSlider.SetEnabled(true);
		fuelSlider.UpdateFromFuelData();
	}
	
	protected func GetFuelSliderValue() -> Float {
		let fuelSlider = this.FindFuelSlider();
		if !IsDefined(fuelSlider) {
			return 0.0;
		}
		return fuelSlider.GetValue();
	}

	protected func SetHubButtonEnabled(enabled: Bool) {
		if IsDefined(this.m_hubButton) {
			this.m_hubButton.SetDisabled(!enabled);
		}
	}

	protected func UpdateButtonsStateFromFuelType() {
		let service = GetBetterFuelSystemServiceInstance();
		if !IsDefined(service) {
			return;
		}

		let fuelData = service.GetCurrentVehicleFuelData();
		let fuelType = "";

		if fuelData == null {
			let syncSuccess = BTCallback.RequestFuelDataSync();
			if !syncSuccess {
				fuelType = BTCallback.GetFuelType();
			} else {
				fuelData = service.GetCurrentVehicleFuelData();
				if fuelData == null {
					fuelType = BTCallback.GetFuelType();
				}
			}
		} else {
			fuelType = fuelData.fuelType;
		}

		if StrLen(fuelType) == 0 && fuelData != null {
			fuelType = fuelData.fuelType;
		}

		if StrLen(fuelType) == 0 {
			return;
		}

		let normalizedFuelType = StrLower(fuelType);

		let isPremium = Equals(normalizedFuelType, "premium");
		let isRegular = Equals(normalizedFuelType, "regular");

		if IsDefined(this.m_regularButton) {
			this.m_regularButton.SetDisabled(isPremium);
		}

		if IsDefined(this.m_premiumButton) {
			this.m_premiumButton.SetDisabled(isRegular);
		}
	}
}
