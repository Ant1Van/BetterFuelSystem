module BetterFuelSystem.Practices
import BetterFuelSystem.Workbench.Practice
import Codeware.UI.*
import Codeware.Localization.*

public class InnerPopup extends Practice {
	protected cb func OnCreate() {
		let root = new inkCanvas();
		root.SetName(this.GetClassName());
		root.SetAnchor(inkEAnchor.Fill);

		let group = new inkVerticalPanel();
		group.SetAnchor(inkEAnchor.BottomCenter);
		group.SetAnchorPoint(new Vector2(0.5, 1.0));
		group.SetMargin(new inkMargin(8.0, 0.0, 8.0, 100.0));
		group.Reparent(root);
		
		let button = PopupButton.Create();
		button.SetText("About mod");
		button.RegisterToCallback(n"OnBtnClick", this, n"OnOpenPopup");
		button.Reparent(group);

		this.SetRootWidget(root);
	}

	protected cb func OnOpenPopup(widget: wref<inkWidget>) {
		let popup = ConfirmationPopup.Show(this.GetGameController());
		popup.RegisterToCallback(n"OnClose", this, n"OnClosePopup");

	}

	protected cb func OnClosePopup(widget: wref<inkWidget>) {
	    let popup = widget.GetController() as ConfirmationPopup;

	}
}

public class ConfirmationPopup extends InMenuPopup {
	protected cb func OnCreate() {
		super.OnCreate();

		let content = InMenuPopupContent.Create();
		content.SetTitle("About mod");
		content.Reparent(this);

		let text = new inkText();
        let localization = LocalizationSystem.GetInstance(this.GetGame());
        if IsDefined(localization) {
            text.SetText(localization.GetText("BetterFuelSystem-InnerPopup-Description"));
        } else {
            text.SetText("To refuel, select Regular or Premium first, then press Refuel.");
        }
        text.SetWrapping(true, 700.0);
        text.SetFitToContent(true);
        text.SetFontFamily("base\\gameplay\\gui\\fonts\\raj\\raj.inkfontfamily");
        text.SetStyle(r"base\\gameplay\\gui\\common\\main_colors.inkstyle");
        text.BindProperty(n"tintColor", n"MainColors.Red");
        text.BindProperty(n"fontWeight", n"MainColors.BodyFontWeight");
        text.BindProperty(n"fontSize", n"MainColors.ReadableSmall");
        text.Reparent(content.GetContainerWidget());

		let footer = InMenuPopupFooter.Create();
		footer.Reparent(this);

		let confirmBtn = PopupButton.Create();
		confirmBtn.SetText(GetLocalizedText("LocKey#23123"));
		confirmBtn.SetInputAction(n"system_notification_confirm");
		confirmBtn.Reparent(footer);

		let cancelBtn = PopupButton.Create();
		cancelBtn.SetText(GetLocalizedText("LocKey#22175"));
		cancelBtn.SetInputAction(n"back");
		cancelBtn.Reparent(footer);
	}

	public static func Show(requester: ref<inkGameController>) -> ref<ConfirmationPopup> {
		let popup = new ConfirmationPopup();
		popup.Open(requester);
		return popup;
	}
}
