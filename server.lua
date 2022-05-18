local QBCore = exports['qb-core']:GetCoreObject()

RegisterNetEvent('qb-laundering:server:register', function(name, amount)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return end
    local amount = tonumber(amount)
    local citizenid = Player.PlayerData.citizenid
    local tax = math.floor(amount * Config.TaxRate)
    local startAmount = math.floor(amount - tax)
    -- You can send the tax somewhere here if you want
    if Player.Functions.RemoveMoney('cash', amount) then
        MySQL.query('INSERT INTO qb_laundering (owner, business, worth) VALUES (@citizenid, @name, @startAmount)', {
            ['@citizenid'] = citizenid,
            ['@name'] = name,
            ['@startAmount'] = startAmount,
        }, function() end)
        TriggerClientEvent('QBCore:Notify', source, 'Successfully registered business', 'success')
    elseif Player.Functions.RemoveMoney('bank', amount) then
        MySQL.query('INSERT INTO qb_laundering (owner, business, worth) VALUES (@citizenid, @name, @startAmount)', {
            ['@citizenid'] = citizenid,
            ['@name'] = name,
            ['@startAmount'] = startAmount,
        }, function() end)
        TriggerClientEvent('QBCore:Notify', source, 'Successfully registered business', 'success')
    else
        TriggerClientEvent('QBCore:Notify', source, 'error', 'You do not have enough money')
    end
end)

RegisterNetEvent('qb-laundering:server:invest', function(amount)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return end
    local amount = tonumber(amount)
    local tax = math.floor(amount * Config.TaxRate)
    local newAmount = math.floor(amount - tax)
    local citizenid = Player.PlayerData.citizenid
    if Player.Functions.RemoveMoney('cash', amount) then
        -- You can send the tax somewhere here if you want
        MySQL.query('UPDATE qb_laundering SET worth = worth + '..newAmount..' WHERE owner = ?', {citizenid})
        TriggerClientEvent('QBCore:Notify', source, 'Successfully invested $'..newAmount, 'success')
    elseif Player.Functions.RemoveMoney('bank', amount) then
        -- You can send the tax somewhere here if you want
        MySQL.query('UPDATE qb_laundering SET worth = worth + '..newAmount..' WHERE owner = ?', {citizenid})
        TriggerClientEvent('QBCore:Notify', source, 'Successfully invested $'..newAmount, 'success')
    else
        TriggerClientEvent('QBCore:Notify', source, 'You do not have enough money', 'error')
    end
end)

RegisterNetEvent('qb-laundering:server:clean', function(amount)
    local src = source
    local ped = GetPlayerPed(src)
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    local amount = tonumber(amount)
    local businessWorth = MySQL.scalar.await('SELECT worth FROM qb_laundering WHERE owner = ?', {Player.PlayerData.citizenid})
    if businessWorth < amount then return TriggerClientEvent('QBCore:Notify', src, 'Not enough business funds', 'error') end
    local hasItem = Player.Functions.GetItemByName('markedbills')
    if not hasItem then return TriggerClientEvent('QBCore:Notify', src, 'No marked bills', 'error') end
    local worth = hasItem.info.worth
    if worth < amount then return TriggerClientEvent('QBCore:Notify', src, 'Bills not worth enough', 'error') end
    local washDate = MySQL.scalar.await('SELECT last_washed FROM qb_laundering WHERE owner = ?', {Player.PlayerData.citizenid})
    if not washDate then return TriggerClientEvent('QBCore:Notify', src, 'No business to launder through', 'error') end
    local diff = os.time() - (washDate / 1000)
    local reqDiff = Config.Cooldown * 60 * 60 * 1000
    if diff >= reqDiff then
        local itemSlot = hasItem.slot
        local newWorth = tonumber(worth - amount)
        if newWorth <= 0 then
            TaskPlayAnim(ped, Config.animDict, Config.anim, 1.0, 1.0, Config.animTime, 1, 0, 0, 0, 0)
            Wait(Config.animTime)
            Player.Functions.RemoveItem('markedbills', 1)
            Player.Functions.AddMoney('cash', amount)
            MySQL.query('UPDATE qb_laundering SET last_washed = CURRENT_TIMESTAMP() WHERE owner = ?', {Player.PlayerData.citizenid})
        else
            TaskPlayAnim(ped, Config.animDict, Config.anim, 1.0, 1.0, Config.animTime, 1, 0, 0, 0, 0)
            Wait(Config.animTime)
            Player.PlayerData.items[itemSlot].info.worth = newWorth
            Player.Functions.SetInventory(Player.PlayerData.items, true)
            Player.Functions.AddMoney('cash', amount)
            MySQL.query('UPDATE qb_laundering SET last_washed = CURRENT_TIMESTAMP() WHERE owner = ?', {Player.PlayerData.citizenid})
        end
    else
        TriggerClientEvent('QBCore:Notify', src, 'You can only clean once every '..Config.Cooldown..' hours', 'error')
    end
end)

RegisterNetEvent('qb-laundering:server:sell', function()
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return end
    local citizenid = Player.PlayerData.citizenid
    MySQL.query('DELETE FROM qb_laundering WHERE owner = ?', {citizenid})
    TriggerClientEvent('QBCore:Notify', source, 'Successfully sold business', 'success')
end)

QBCore.Functions.CreateCallback('qb-laundering:server:getBusiness', function (source, cb)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return end
    local sql = MySQL.query.await('SELECT * FROM qb_laundering WHERE owner = ?', {Player.PlayerData.citizenid})
    if sql then cb(sql[1]) end
    cb(false)
end)