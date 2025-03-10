Config = {}

-- Price range for orders
Config.MinOrderPrice = 1000
Config.MaxOrderPrice = 5000

-- Vehicle model for delivery (GTA Online Gun Van)
Config.VanModel = "speedo4" -- This is the Vapid Speedo Custom used as the gun van in GTA Online

-- Possible delivery locations
Config.DeliveryLocations = {
    vector4(-188.92, 171.23, 70.33, 4.37),
    vector4(516.33, -50.77, 88.86, 243.85),
}

-- Items available in the black market
Config.BlackMarketItems = {
    {item = "weapon_pistol", label = "Pistol", price = 1500, minAmount = 1, maxAmount = 1},
    {item = "weapon_smg", label = "SMG", price = 3000, minAmount = 1, maxAmount = 1},
    {item = "weapon_assaultrifle", label = "Assault Rifle", price = 5000, minAmount = 1, maxAmount = 1},
    {item = "pistol_ammo", label = "Pistol Ammo", price = 150, minAmount = 1, maxAmount = 5},
    {item = "smg_ammo", label = "SMG Ammo", price = 250, minAmount = 10, maxAmount = 5},
    {item = "rifle_ammo", label = "Rifle Ammo", price = 350, minAmount = 10, maxAmount = 5},
    {item = "armor", label = "Body Armor", price = 500, minAmount = 1, maxAmount = 2},
    {item = "lockpick", label = "Lockpick", price = 200, minAmount = 1, maxAmount = 3},
    {item = "advancedlockpick", label = "Advanced Lockpick", price = 500, minAmount = 1, maxAmount = 2},
    {item = "electronickit", label = "Electronic Kit", price = 800, minAmount = 1, maxAmount = 1},
    {item = "gatecrack", label = "Gate Cracking Device", price = 1000, minAmount = 1, maxAmount = 1},
    {item = "thermite", label = "Thermite", price = 1500, minAmount = 1, maxAmount = 3},
    {item = "trojan_usb", label = "Trojan USB", price = 2000, minAmount = 1, maxAmount = 1}
}
