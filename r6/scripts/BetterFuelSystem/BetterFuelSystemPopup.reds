//:: ========================================================================================== :://
//::                                                                                            :://
//::   █████╗  ███╗   ██╗ ████████╗  ██╗  ██╗   ██╗  █████╗  ███╗   ██╗     [ SYSTEM ]        :://
//::  ██╔══██╗ ████╗  ██║ ╚══██╔══╝  ██║  ██║   ██║ ██╔══██╗ ████╗  ██║     [ ONLINE ]        :://
//::  ███████║ ██╔██╗ ██║    ██║     ██║  ██║   ██║ ███████║ ██╔██╗ ██║     [ REDSCRIPT ]     :://
//::  ██╔══██║ ██║╚██╗██║    ██║     ██║  ╚██╗ ██╔╝ ██╔══██║ ██║╚██╗██║     v. 1.0.0          :://
//::  ██║  ██║ ██║ ╚████║    ██║     ██║   ╚████╔╝  ██║  ██║ ██║ ╚████║                       :://
//::  ╚═╝  ╚═╝ ╚═╝  ╚═══╝    ╚═╝     ╚═╝    ╚═══╝   ╚═╝  ╚═╝ ╚═╝  ╚═══╝                       :://
//::                                                                                            :://
//:: __________________________________________________________________________________________ :://
//::                                                                                            :://
//::  Copyright (C) 2025, Ant1Van. All rights reserved.                                         :://
//::  This mod is under the MIT License.                                                        :://
//::  https://opensource.org/licenses/mit-license.php                                           :://
//:: ========================================================================================== :://

module BetterFuelSystem

import BetterFuelSystem.Workbench.*
import BetterFuelSystem.Practices.*
import Codeware.Localization.*
import Codeware.UI.*

@wrapMethod(UIInGameNotificationQueue)
protected cb func OnUINotification(evt: ref<UIInGameNotificationEvent>) -> Bool {
	return wrappedMethod(evt);
}

public class BetterFuelSystemPopup extends InGamePopup {

	protected let m_header: ref<InGamePopupHeader>;
	protected let m_footer: ref<InGamePopupFooter>;
	protected let m_content: ref<InGamePopupContent>;
	protected let m_workbench: ref<Workbench>;
	protected let m_translator: ref<LocalizationSystem>;

    protected cb func OnCreate() {

    	super.OnCreate();

      	this.m_translator = LocalizationSystem.GetInstance(this.GetGame());
      	this.m_container.SetHeight(1140.0);

      	// Header
      	this.m_header = InGamePopupHeader.Create();
      	this.m_header.SetTitle(this.m_translator.GetText("BetterFuelSystem-Title"));
      	this.m_header.SetFluffRight(this.m_translator.GetText("BetterFuelSystem-Fluff-Right"));
      	this.m_header.Reparent(this);

      	// Footer
      	this.m_footer = InGamePopupFooter.Create();
      	this.m_footer.SetFluffIcon(n"fluff_triangle2");
      	this.m_footer.SetFluffText(this.m_translator.GetText("BetterFuelSystem-Fluff-Bottom"));
      	this.m_footer.Reparent(this);

      	// Content
      	this.m_content = InGamePopupContent.Create();
      	this.m_content.Reparent(this);

      	this.m_workbench = Workbench.Create();
		this.m_workbench.SetSize(this.m_content.GetSize());
	    this.m_workbench.SetTranslator(this.m_translator);
	    this.m_workbench.Reparent(this.m_content);

        
        // 1. Buttons (Regular/Premium)
		this.m_workbench.AddPractice(new ButtonBasics());
		
		// 2. FuelSlider
		this.m_workbench.AddPractice(new FuelSlider());
		
        // 3. CursorState
        this.m_workbench.AddPractice(new CursorState());

        // 4. Button "About"
	    this.m_workbench.AddPractice(new InnerPopup());
    }

  	protected cb func OnInitialize() {
  		super.OnInitialize();
		this.m_workbench.SetHints(this.m_footer.GetHints());
	}

  	public func UseCursor() -> Bool {
		return true;
	}

	public static func Show(requester: ref<inkGameController>) {
		let popup = new BetterFuelSystemPopup();
		popup.Open(requester);
	}
}