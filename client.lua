local QBCore = exports['qb-core']:GetCoreObject()

-- Functions

local function comma_value(amount)
    local formatted = amount
    while true do
        formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
        if (k == 0) then
            break
        end
    end
    return formatted
end

local function RegisterBusiness()
    QBCore.Functions.TriggerCallback('qb-laundering:server:getBusiness', function(business)
        if business then
            exports['qb-menu']:openMenu({
                { header = business.business..' | Value: $'..comma_value(business.worth), isMenuHeader = true},
                {
                    header = 'Invest',
                    params = {
                        event = 'qb-laundering:client:invest',
                        args = {}
                    }
                },
                {
                    header = 'Sell',
                    params = {
                        isServer = true,
                        event = 'qb-laundering:server:sell',
                        args = {}
                    }
                }
            })
        else
            local dialog = exports['qb-input']:ShowInput({
                header = 'Register LLC',
                submitText = 'Submit',
                inputs = {
                    {
                        type = 'text',
                        isRequired = true,
                        name = 'name',
                        text = 'Business Name'
                    },
                    {
                        type = 'number',
                        isRequired = true,
                        name = 'amount',
                        text = 'Minimum $'..Config.StartupFee
                    }
                }
            })
            if dialog then
                if not dialog.name then return end
                if not dialog.amount then return end
                if tonumber(dialog.amount) < Config.StartupFee then return QBCore.Functions.Notify('Didn\'t meet minimum', 'error') end
                TriggerServerEvent('qb-laundering:server:register', dialog.name, dialog.amount)
            end
        end
    end)
end

local function CleanMoney()
    QBCore.Functions.TriggerCallback('qb-laundering:server:getBusiness', function(business)
        if business then
            local dialog = exports['qb-input']:ShowInput({
                header = 'Wash Money',
                submitText = 'Submit',
                inputs = {
                    {
                        type = 'number',
                        isRequired = true,
                        name = 'amount',
                        text = 'Maximum $'..business.worth
                    }
                }
            })
            if dialog then
                if not dialog.amount then return end
                if tonumber(dialog.amount) > business.worth then return QBCore.Functions.Notify('Can\'t clean that much', 'error') end
                TriggerServerEvent('qb-laundering:server:clean', dialog.amount)
            end
        end
    end)
end

-- Events

RegisterNetEvent('qb-laundering:client:invest', function()
    local dialog = exports['qb-input']:ShowInput({
        header = 'Investment Amount',
        submitText = 'Submit',
        inputs = {
            {
                type = 'number',
                isRequired = true,
                name = 'amount',
                text = 'Amount ($)'
            }
        }
    })
    if dialog then
        if not dialog.amount then return end
        TriggerServerEvent('qb-laundering:server:invest', dialog.amount)
    end
end)

-- Threads

CreateThread(function()
    for k,v in pairs(Config.Locations) do
        if k == 'cityhall' then
            exports['qb-target']:AddBoxZone(v.name, v.coords, v.length, v.width, {
                name = v.name,
                debugPoly = v.debugPoly,
                minZ = v.coords.z - 2,
                maxZ = v.coords.z + 2,
            }, {
                options = {
                    {
                        icon = 'fa-solid fa-briefcase',
                        label = 'Register/Manage LLC',
                        action = function ()
                            RegisterBusiness()
                        end
                    },
                },
                distance = 1.5
            })
        end
        if k == 'washing' then
            exports['qb-target']:AddBoxZone(v.name, v.coords, v.length, v.width, {
                name = v.name,
                debugPoly = v.debugPoly,
                minZ = v.coords.z - 2,
                maxZ = v.coords.z + 2,
            }, {
                options = {
                    {
                        icon = 'fa-solid fa-sack-dollar',
                        label = 'Clean Money',
                        action = function ()
                            CleanMoney()
                        end
                    },
                },
                distance = 1.5
            })
        end
    end
end)