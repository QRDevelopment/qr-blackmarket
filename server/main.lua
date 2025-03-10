local QBCore = exports['qb-core']:GetCoreObject()

-- Register usable item
QBCore.Functions.CreateUseableItem("blackpaper", function(source)
    local Player = QBCore.Functions.GetPlayer(source)
    if Player.Functions.RemoveItem("blackpaper", 1) then
        TriggerClientEvent('qr-blackmarket:client:openBlackMarket', source)
    end
end)

-- Give items to player after collecting order
RegisterNetEvent('qr-blackmarket:server:giveItems', function(orderedItems, orderTotal)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)

    if not Player then return end

    -- Check if player has enough money
    if Player.Functions.GetMoney('cash') < orderTotal then
        TriggerClientEvent('QBCore:Notify', src, "You don't have enough cash", "error")
        return
    end

    -- Take payment
    Player.Functions.RemoveMoney("cash", orderTotal, "blackmarket-purchase")

    -- Give ordered items to player
    for _, item in ipairs(orderedItems) do
        Player.Functions.AddItem(item.id, item.quantity)
        TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[item.id], 'add', item.quantity)
    end

    TriggerClientEvent('QBCore:Notify', src, "You paid $" .. orderTotal .. " for your items", "success")
end)
