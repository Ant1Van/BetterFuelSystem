-- Подключаем модуль локализации
local Localization = require("modules/Localization")

local Money = {}

Money.prices = {
    Regular = 10,  -- eddies per liter
    Premium = 18
}

local function getTransactionSystem()
    return Game.GetTransactionSystem()
end

local function getPlayer()
    return Game.GetPlayer()
end

local function getMoneyItemID()
    if gameItemID ~= nil and gameItemID.FromTDBID ~= nil then
        return gameItemID.FromTDBID(TweakDBID.new("Items.money"))
    end

    if ItemID ~= nil and ItemID.new ~= nil then
        local tid = TweakDBID.new("Items.money")
        return ItemID.new(tid)
    end

    return nil
end

function Money.getPricePerLiter(fuelType)
    if not fuelType then
        return Money.prices.Regular
    end

    local normalized = string.lower(fuelType)
    if normalized == "premium" then
        return Money.prices.Premium
    end

    return Money.prices.Regular
end

function Money.calculateCost(fuelType, liters)
    liters = liters or 0
    if liters <= 0 then
        return 0
    end

    local rate = Money.getPricePerLiter(fuelType)
    return math.max(0, math.ceil(liters * rate))
end

function Money.getBalance()
    local ts = getTransactionSystem()
    local player = getPlayer()
    local moneyId = getMoneyItemID()

    if not ts or not player or not ts.GetItemQuantity or not moneyId then
        return 0
    end

    local ok, qty = pcall(function()
        return ts:GetItemQuantity(player, moneyId)
    end)

    if ok then
        return qty or 0
    end

    return 0
end

function Money.canAfford(amount)
    if amount <= 0 then
        return true
    end

    local balance = Money.getBalance()
    return balance >= amount
end

function Money.trySpend(amount)
    if amount <= 0 then
        return true
    end

    local ts = getTransactionSystem()
    local player = getPlayer()
    local moneyId = getMoneyItemID()

    if not ts or not player or not moneyId then
        return false
    end

    if ts.GetItemQuantity then
        local ok, qty = pcall(function()
            return ts:GetItemQuantity(player, moneyId)
        end)

        if ok and qty and qty < amount then
            return false
        end
    end

    local success = pcall(function()
        ts:RemoveItem(player, moneyId, amount)
    end)

    return success
end

function Money.formatCurrency(amount)
    return string.format("%d E$", amount)
end

function Money.notify(message)
    local player = getPlayer()
    if player and player.SetWarningMessage then
        player:SetWarningMessage(message)
    else
        print("[BetterFuelSystem] " .. message)
    end
end

-- Уведомления через Localization
function Money.notifyInsufficient(amount)
    local msg = Localization.getText("InsufficientFunds")
    msg = string.gsub(msg, "{AMOUNT}", Money.formatCurrency(amount))
    Money.notify(msg)
end

function Money.notifyTankFull()
    Money.notify(Localization.getText("TankFull"))
end

function Money.notifyPurchase(liters, amount, fuelType)
    local labelKey = "TypeRegular"
    if fuelType and string.lower(fuelType) == "premium" then
        labelKey = "TypePremium"
    end
    local label = Localization.getText(labelKey)
    
    local litersText = string.format("%.1f", liters or 0)
    local costText = Money.formatCurrency(amount)
    
    local msg = Localization.getText("Refueled")
    msg = string.gsub(msg, "{LITERS}", litersText)
    msg = string.gsub(msg, "{TYPE}", label)
    msg = string.gsub(msg, "{COST}", costText)
    
    Money.notify(msg)
end

return Money