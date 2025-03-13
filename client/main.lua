local QBCore = exports['qb-core']:GetCoreObject()
local PlayerData = {}
local orderPlaced = false
local deliveryCoords = nil
local deliveryBlip = nil
local orderedItems = {}
local orderTotal = 0
local gunDealerPed = nil
local deliveryVehicle = nil

-- Initialize
RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    PlayerData = QBCore.Functions.GetPlayerData()
end)

RegisterNetEvent('QBCore:Client:OnPlayerUnload', function()
    PlayerData = {}
end)

RegisterNetEvent('QBCore:Client:OnJobUpdate', function(JobInfo)
    PlayerData.job = JobInfo
end)

-- Open NUI when using blackpaper item
RegisterNetEvent('qr-blackmarket:client:openBlackMarket', function()
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = "open"
    })
end)

-- Close NUI
RegisterNUICallback('closeMenu', function()
    SetNuiFocus(false, false)
end)

-- Handle order placement
RegisterNUICallback('placeOrder', function(data, cb)
    if orderPlaced then
        cb({success = false, message = "You already have a pending order"})
        return
    end

    -- Store ordered items and total
    orderedItems = data.items
    orderTotal = data.total

    if #orderedItems == 0 then
        cb({success = false, message = "You need to select at least one item"})
        return
    end

    orderPlaced = true

    -- Notify player that order is being processed
    QBCore.Functions.Notify("Order placed. Coordinates will be sent to your phone shortly...", "success", 5000)

    -- Close the NUI
    SetNuiFocus(false, false)

    -- Wait 10 seconds before sending coordinates
    SetTimeout(10000, function()
        -- Generate random delivery location
        local locations = Config.DeliveryLocations
        local randomLocation = locations[math.random(#locations)]
        deliveryCoords = randomLocation

        -- Send phone notification with coordinates
        TriggerEvent('qb-phone:client:CustomNotification',
            'BLACKMARKET',
            'Pickup location has been marked on your GPS',
            'fas fa-skull',
            '#000000',
            7500
        )

        -- Create blip for delivery location
        CreateDeliveryBlip(deliveryCoords)

        -- Add target to the van when player arrives
        local modelHash = GetHashKey(Config.VanModel)
        RequestModel(modelHash)
        while not HasModelLoaded(modelHash) do
            Wait(1)
        end

        -- Spawn the van
        local vehicle = CreateVehicle(modelHash, deliveryCoords.x, deliveryCoords.y, deliveryCoords.z, deliveryCoords.w, false, false)
        SetEntityAsMissionEntity(vehicle, true, true)
        SetVehicleDoorsLocked(vehicle, 2) -- Lock the vehicle
        deliveryVehicle = vehicle

        -- Set the vehicle livery to match the gun van from GTA Online (no livery)
        SetVehicleLivery(vehicle, 0) -- No livery

        -- Add some customization to make it look more like the gun van
        SetVehicleColours(vehicle, 0, 0) -- Black primary and secondary colors
        SetVehicleExtraColours(vehicle, 0, 0) -- Black pearl and wheel colors
        SetVehicleMod(vehicle, 0, -1, false) -- No Spoiler
        SetVehicleMod(vehicle, 1, -1, false) -- No Front Bumper
        SetVehicleMod(vehicle, 2, -1, false) -- No Rear Bumper
        SetVehicleMod(vehicle, 3, -1, false) -- No Skirt
        SetVehicleMod(vehicle, 4, -1, false) -- No Exhaust
        SetVehicleMod(vehicle, 5, -1, false) -- No Chassis
        SetVehicleMod(vehicle, 6, -1, false) -- No Grille
        SetVehicleMod(vehicle, 7, -1, false) -- No Hood
        SetVehicleMod(vehicle, 10, -1, false) -- No Roof
        SetVehicleMod(vehicle, 11, 3, false) -- Engine Level 4
        SetVehicleMod(vehicle, 12, 2, false) -- Brakes Level 3
        SetVehicleMod(vehicle, 13, 2, false) -- Transmission Level 3
        SetVehicleMod(vehicle, 14, -1, false) -- No Horn
        SetVehicleMod(vehicle, 15, 3, false) -- Suspension Level 4
        SetVehicleMod(vehicle, 16, 4, false) -- Armor Level 5
        SetVehicleWindowTint(vehicle, 1) -- Tinted windows

        -- Open the back doors to show the interior like in the GTA Online gun van
        SetVehicleDoorOpen(vehicle, 2, false, false) -- Left rear door
        SetVehicleDoorOpen(vehicle, 3, false, false) -- Right rear door

        -- Spawn the gun dealer NPC
        local dealerModel = GetHashKey("ig_old_man2")
        RequestModel(dealerModel)
        while not HasModelLoaded(dealerModel) do
            Wait(1)
        end

        -- Calculate position for the dealer (sitting in the back of the van)
        local vehCoords = GetEntityCoords(vehicle)
        local vehHeading = GetEntityHeading(vehicle)
        local offsetX = -1.2 -- Adjust these values to position the dealer correctly
        local offsetY = 0.0
        local offsetZ = 0.0

        -- Calculate the position based on the vehicle's orientation
        local rad = math.rad(vehHeading)
        local newX = vehCoords.x - (math.sin(rad) * offsetY) - (math.cos(rad) * offsetX)
        local newY = vehCoords.y + (math.cos(rad) * offsetY) - (math.sin(rad) * offsetX)
        local newZ = vehCoords.z + offsetZ

        -- Add target to the van based on config setting
        AddTargetToVehicle(vehicle)

        cb({success = true})
    end)
end)

-- Function to add target to vehicle based on config setting
function AddTargetToVehicle(vehicle)
    if Config.UseOxTarget then
        -- ox_target implementation
        exports.ox_target:addEntity(vehicle, {
            {
                name = 'blackmarket_collect_order',
                icon = 'fas fa-box',
                label = 'Collect Order',
                canInteract = function()
                    return orderPlaced and deliveryCoords ~= nil
                end,
                onSelect = function()
                    TriggerEvent('qr-blackmarket:client:collectOrder')
                end,
                distance = 2.5
            }
        })
    else
        -- qb-target implementation
        exports['qb-target']:AddTargetEntity(vehicle, {
            options = {
                {
                    type = "client",
                    event = "qr-blackmarket:client:collectOrder",
                    icon = "fas fa-box",
                    label = "Collect Order",
                    canInteract = function()
                        return orderPlaced and deliveryCoords ~= nil
                    end,
                }
            },
            distance = 2.5,
        })
    end
end

-- Create blip for delivery location
function CreateDeliveryBlip(coords)
    if deliveryBlip then
        RemoveBlip(deliveryBlip)
    end

    deliveryBlip = AddBlipForCoord(coords.x, coords.y, coords.z)
    SetBlipSprite(deliveryBlip, 501) -- Blip sprite (van)
    SetBlipDisplay(deliveryBlip, 4)
    SetBlipScale(deliveryBlip, 0.8)
    SetBlipColour(deliveryBlip, 1) -- Red
    SetBlipAsShortRange(deliveryBlip, false)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Delivery Location")
    EndTextCommandSetBlipName(deliveryBlip)
    SetBlipRoute(deliveryBlip, true)
end

-- Collect order from van
RegisterNetEvent('qr-blackmarket:client:collectOrder', function()
    if not orderPlaced or not deliveryCoords then
        QBCore.Functions.Notify("You don't have any pending orders", "error")
        return
    end

    -- Play animation
    TaskStartScenarioInPlace(PlayerPedId(), "PROP_HUMAN_BUM_BIN", 0, true)
    QBCore.Functions.Progressbar("collect_order", "Collecting order...", 5000, false, true, {
        disableMovement = true,
        disableCarMovement = true,
        disableMouse = false,
        disableCombat = true,
    }, {}, {}, {}, function() -- Done
        ClearPedTasks(PlayerPedId())

        -- Give items to player
        TriggerServerEvent('qr-blackmarket:server:giveItems', orderedItems, orderTotal)

        -- Reset order status
        orderPlaced = false
        deliveryCoords = nil
        orderedItems = {}
        orderTotal = 0

        -- Remove blip
        if deliveryBlip then
            RemoveBlip(deliveryBlip)
            deliveryBlip = nil
        end

        -- Remove target based on config setting
        if deliveryVehicle then
            if Config.UseOxTarget then
                exports.ox_target:removeEntity(deliveryVehicle, {'blackmarket_collect_order'})
            else
                exports['qb-target']:RemoveTargetEntity(deliveryVehicle)
            end
        end

        QBCore.Functions.Notify("You've collected your order", "success")

        -- Delete the dealer ped and vehicle after 10 seconds
        SetTimeout(10000, function()
            if gunDealerPed then
                DeletePed(gunDealerPed)
                gunDealerPed = nil
            end

            if deliveryVehicle then
                DeleteVehicle(deliveryVehicle)
                deliveryVehicle = nil
            end
        end)
    end, function() -- Cancel
        ClearPedTasks(PlayerPedId())
        QBCore.Functions.Notify("Cancelled", "error")
    end)
end)

-- Command for testing (remove in production)
RegisterCommand('testblackmarket', function()
    TriggerEvent('qr-blackmarket:client:openBlackMarket')
end)
