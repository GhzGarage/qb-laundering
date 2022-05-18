Config = {}

Config.TaxRate = 0.10 -- percentage
Config.StartupFee = 75000 -- Minimum required to start business
Config.Cooldown = 24 -- hours

Config.animDict = 'anim@amb@business@cfm@cfm_drying_notes@' -- https://alexguirre.github.io/animations-list/
Config.anim = 'loading_v3_worker'
Config.animTime = 5000 -- milliseconds

Config.Locations = {
    ['cityhall'] = { -- Where you can register/invest/sell
        coords = vector3(-1272.65, -590.1, 37.61),
        heading = 310,
        length = 1,
        width = 1,
        name = "regbus",
        debugPoly = false
    },
    ['washing'] = { -- Where you wash the money
        coords = vector3(4913.21, -5271.71, -1.38),
        heading = 271,
        length = 3,
        width = 16,
        name = "moneywash",
        debugPoly = false
    }
}