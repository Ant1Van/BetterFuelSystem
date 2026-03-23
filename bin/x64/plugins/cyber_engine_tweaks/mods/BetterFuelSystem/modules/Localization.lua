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
    -- Сюда можно добавлять другие языки (de-de, fr-fr и т.д.)
}

-- Функция определения языка (Используем метод из рабочего мода с "OnScreen")
function Localization.getLang()
    -- Используем pcall для безопасности, чтобы игра не вылетела, если что-то пойдет не так
    local success, result = pcall(function()
        return Game.GetSettingsSystem():GetVar("/language", "OnScreen"):GetValue().value
    end)

    if success and result then
        return string.lower(result) -- Приводим к нижнему регистру (en-us)
    else
        return "en-us" -- Если не удалось определить, возвращаем английский
    end
end

-- Функция получения текста
function Localization.getText(key)
    local langKey = Localization.getLang()
    local textData = Localization.dict[langKey]

    -- Если для текущего языка нет переводов, берем английский
    if not textData then
        textData = Localization.dict["en-us"]
    end

    -- Если ключа нет, возвращаем сам ключ (чтобы видеть ошибку, но не крашить)
    return textData[key] or key
end

return Localization