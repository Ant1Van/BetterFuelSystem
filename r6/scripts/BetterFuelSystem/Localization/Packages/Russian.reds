module BetterFuelSystem.Localization.Packages
import Codeware.Localization.*

public class Russian extends ModLocalizationPackage {
    protected func DefineTexts() {
        this.Text("BetterFuelSystem-Title", "PETROCHEM");
        this.Text("BetterFuelSystem-Fluff-Right", "PETROCHEM");
        this.Text("BetterFuelSystem-Fluff-Bottom", "Ant1Van");

		this.Text("BetterFuelSystem-Regular-Button", "Обычный");
		this.Text("BetterFuelSystem-Premium-Button", "Премиум");
		this.Text("BetterFuelSystem-Hub-Button", "Заправить");
		this.Text("BetterFuelSystem-Interaction-Hint-Click", "Нажать");
		this.Text("BetterFuelSystem-InnerPopup-Description", "Для заправки сначала выберите Обычный или Премиум. После выбора типа топлива активируется слайдер, на котором можно выбрать количество топлива для заправки. Затем нажмите кнопку «Заправить». Премиум-транспорт принимает только премиум-топливо, обычный — обычное.");
		
        this.Text("Mod-BFS-FuelStation-Marker", "Заправка");
        this.Text("Mod-BFS-FuelStation-Marker-Description", "Удобное место для заправки вашего транспорта.");
        this.Text("BetterFuelSystem-Fuel-Amount", "Количество топлива");
    }
}
