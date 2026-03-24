local Localization = {}

-- Словарь переводов
Localization.dict = {
    ["en-us"] = {
        LowFuelWarning = "Low Fuel Warning!",
        FuelTankEmpty = "Fuel Tank Empty!",
        InsufficientFunds = "Not enough eddies ({AMOUNT}).",
        Refueled = "Refueled {LITERS}L ({TYPE}) for {COST}.",
        TankFull = "Fuel tank is already full.",
        TypeRegular = "Regular",
        TypePremium = "Premium"
    },
    ["ru-ru"] = {
        LowFuelWarning = "Мало топлива! Требуется заправка!",
        FuelTankEmpty = "Бак пуст! Двигатель остановлен.",
        InsufficientFunds = "Недостаточно средств ({AMOUNT}).",
        Refueled = "Заправлено {LITERS}л ({TYPE}) за {COST}.",
        TankFull = "Топливный бак уже полон.",
        TypeRegular = "Обычный",
        TypePremium = "Премиум"
    },
}

function Localization.getLang()
    local success, result = pcall(function()
        return Game.GetSettingsSystem():GetVar("/language", "OnScreen"):GetValue().value
    end)

    if success and result then
        return string.lower(result)
    else
        return "en-us"
    end
end

function Localization.getText(key)
    local langKey = Localization.getLang()
    local textData = Localization.dict[langKey]

    if not textData then
        textData = Localization.dict["en-us"]
    end

    return textData[key] or key
end

return Localization