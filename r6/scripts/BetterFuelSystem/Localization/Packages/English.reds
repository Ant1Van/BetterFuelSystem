module BetterFuelSystem.Localization.Packages
import Codeware.Localization.*

public class English extends ModLocalizationPackage {
    protected func DefineTexts() {
        this.Text("BetterFuelSystem-Title", "Fuel System");
        this.Text("BetterFuelSystem-Fluff-Right", "PETROCHEM");
        this.Text("BetterFuelSystem-Fluff-Bottom", "Ant1Van");

		this.Text("BetterFuelSystem-Regular-Button", "Regular");
		this.Text("BetterFuelSystem-Premium-Button", "Premium");
		this.Text("BetterFuelSystem-Hub-Button", "Refuel Button");
		this.Text("BetterFuelSystem-Interaction-Hint-Click", "Interact");
		this.Text("BetterFuelSystem-InnerPopup-Description", "To refuel, pick Regular or Premium first. After choosing a fuel type, a slider will activate allowing you to select the amount of fuel to refuel. Then press the Refuel button. Premium vehicles only accept Premium fuel, Regular vehicles accept Regular fuel.");

        this.Text("Mod-BFS-FuelStation-Marker", "Fuel Station");
        this.Text("Mod-BFS-FuelStation-Marker-Description", "A convenient place to refuel your vehicle.");
        this.Text("BetterFuelSystem-Fuel-Amount", "Fuel amount");
    }
}
