

ESX = nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)


Config = {}
Config.Bounties = {}

Citizen.CreateThread(function()

    local data = MySQL.Sync.fetchAll('SELECT * FROM bounties', {
		['@name'] = name
	})
    for k,v in pairs(data) do
        v.hunters = json.decode(v.hunters)
    end
    print(data)
    Config.Bounties = data;
    Citizen.Wait(500)
    TriggerClientEvent('lucid-bounty:updateBounty', -1, Config.Bounties)
end)


RegisterServerEvent('lucid-bounty:sendBounty')
AddEventHandler("lucid-bounty:sendBounty", function(formInputs)
    local now = os.time()
    local src = source
    local ply = ESX.GetPlayerFromId(src)

    
    local datab = MySQL.Sync.fetchAll('SELECT * FROM bounties WHERE owner = @owner', {
		['@owner'] = ply.identifier
	})
    if #datab <= 3 then
        formInputs.bountyReward = tonumber(formInputs.bountyReward)
        if ply.getMoney() >= formInputs.bountyReward then
            
            ply.removeMoney(formInputs.bountyReward)
            local res =  MySQL.Sync.fetchAll('INSERT INTO bounties (owner, target, target_name, bountyReward, reason, createdAt) VALUES (@owner, @target, @target_name, @bountyReward, @reason, @createdAt)', {
                ['@owner'] = ply.identifier,
                ['@target'] = formInputs.player.identifier,
                ['@target_name'] = formInputs.player.firstname,
                ['@bountyReward'] = formInputs.bountyReward,
                ['@reason'] = formInputs.reason,
                ['@createdAt'] = now
            })
            
            formInputs.owner = ply.identifier
            formInputs.hunters = {}
            formInputs.id = res.insertId
            table.insert(Config.Bounties, { id = formInputs.id, owner =  formInputs.owner, reason = formInputs.reason,   target = formInputs.player.identifier, bountyReward = formInputs.bountyReward, createdAt = now, hunters = formInputs.hunters, target_name = formInputs.player.firstname})
            TriggerClientEvent('lucid-bounty:updateBounty', -1, Config.Bounties)
           -- TriggerClientEvent("lucid-bounty:newBountyAdded",-1, formInputs)     
        else
            TriggerClientEvent('esx:showNotification', src, "You don't have enough money") 
        end
    else
        TriggerClientEvent('esx:showNotification', src, "You have reached your limit") 
    end
    
end)


RegisterServerEvent('lucid-bounty:sendBountyWithCommand')
AddEventHandler("lucid-bounty:sendBountyWithCommand", function(formInputs)
    local now = os.time()
    local src = source
    local ply = ESX.GetPlayerFromId(src)
    local target = ESX.GetPlayerFromId(formInputs.targetId)
    if src == formInputs.targetId then
        TriggerClientEvent('esx:showNotification', src, "You can't put bounty to yourself") 
        return
    end

    if target == nil then

        TriggerClientEvent('esx:showNotification', src, "Player is not online") 
        return
    end
    local datab = MySQL.Sync.fetchAll('SELECT * FROM bounties WHERE owner = @owner', {
		['@owner'] = ply.identifier
	})

    if #datab <= 3 then
        formInputs.bountyReward = tonumber(formInputs.bountyReward)
        if ply.getMoney() >= formInputs.bountyReward then
            
            ply.removeMoney(formInputs.bountyReward)
            local res =  MySQL.Sync.fetchAll('INSERT INTO bounties (owner, target, target_name, bountyReward, reason, createdAt) VALUES (@owner, @target, @target_name, @bountyReward, @reason, @createdAt)', {
                ['@owner'] = ply.identifier,
                ['@target'] = target.identifier,
                ['@target_name'] = target.firstname,
                ['@bountyReward'] = formInputs.bountyReward,
                ['@reason'] = formInputs.reason,
                ['@createdAt'] = now
            })
            
            formInputs.owner = ply.identifier
            formInputs.hunters = {}
            formInputs.id = res.insertId
            table.insert(Config.Bounties, { id = formInputs.id, owner =  formInputs.owner, reason = formInputs.reason,   target = target.identifier, bountyReward = formInputs.bountyReward, createdAt = now, hunters = formInputs.hunters, target_name = target.firstname})
            TriggerClientEvent('lucid-bounty:updateBounty', -1, Config.Bounties)
           -- TriggerClientEvent("lucid-bounty:newBountyAdded",-1, formInputs)     
        else
            TriggerClientEvent('esx:showNotification', src, "You don't have enough money") 
        end
    else
        TriggerClientEvent('esx:showNotification', src, "You have reached your limit") 
    end
    
end)


RegisterServerEvent('lucid-bountyhunter:server:createblips')
AddEventHandler('lucid-bountyhunter:server:createblips', function(playerActiveJobs)
    local src = source
    local created = false
    for k,v in pairs(playerActiveJobs) do
        local player = ESX.GetPlayerFromIdentifier(v.target)
        if player ~= nil then
            created = true
            TriggerClientEvent('lucid-bountyhunter:createblips', src, GetEntityCoords(GetPlayerPed(player.source), true))
        end
    end

    if not created and next(playerActiveJobs) ~= nil then
        TriggerClientEvent('esx:showNotification', src, "There is no active player in your jobs") 
    end

    if next(playerActiveJobs) == nil then
        TriggerClientEvent('esx:showNotification', src, "You don't have any active job") 
    end
end)


ESX.RegisterServerCallback('lucid-bounty:getbounties',function(source,cb)
    local bounties = MySQL.Sync.fetchAll('SELECT * FROM bounties')
    cb(bounties)  
end)

ESX.RegisterServerCallback('lucid-bounty:getPlayers',function(source, cb)
    local users = MySQL.Sync.fetchAll('SELECT firstname,lastname,identifier FROM users')
    cb(users)
end)


RegisterServerEvent('lucid-bounty:takeBounty')
AddEventHandler('lucid-bounty:takeBounty', function(data)
    local bounty = data
    local src = source
    local ply = ESX.GetPlayerFromId(src)
    local result = MySQL.Sync.fetchAll('SELECT * FROM bounties')
    for k,v in pairs(result) do
        if(v.id == bounty.id) then
            if v.target ~= ply.identifier and v.owner ~= ply.identifier then
                v.hunters = json.decode(v.hunters)
                for k,v in pairs(v.hunters) do
                    if v == ply.identifier then
                        TriggerClientEvent('esx:showNotification', src, 'You have already take this job')
                        return
                    end
                end
                for _,ilan in pairs(Config.Bounties) do
                    if v.id == ilan.id then
                        table.insert(Config.Bounties[_].hunters, ply.identifier)
                    end
                end
                TriggerClientEvent('esx:showNotification', src, ' You take a bounty for '..v.target_name)
                table.insert(v.hunters, ply.identifier)
                MySQL.Sync.fetchAll('UPDATE bounties SET hunters = @hunters WHERE id = @id', {
                    ['@hunters'] = json.encode(v.hunters),
                    ['@id'] = v.id
                })
                TriggerClientEvent('lucid-bounty:updateBounty', -1, Config.Bounties)
            else
                TriggerClientEvent('esx:showNotification', src, " You can't take this job")

            end
        end
    end

end)


RegisterServerEvent('baseevents:onPlayerKilled')
AddEventHandler('baseevents:onPlayerKilled', function(plyid)
    local killer = ESX.GetPlayerFromId(plyid)
    local ply = ESX.GetPlayerFromId(source)
    for k,v in pairs(Config.Bounties) do
        if v.target == ply.identifier then
            for _,hunter in pairs(v.hunters) do
                if killer.identifier == hunter then
                    TriggerClientEvent('esx:showNotification', killer.source, "You killed your target and you reward ".. v.bountyReward .. "$")
                    ply.addMoney(v.bountyReward)
                    local result =  MySQL.Sync.fetchAll('SELECT * FROM bounties')
                    for index, bounty in pairs(result) do
                        if bounty.id == v.id then
                            MySQL.Sync.fetchAll('DELETE FROM bounties WHERE id=@id', {['@id'] = v.id})
                            table.remove(Config.Bounties, k)
                            TriggerClientEvent('lucid-bounty:updateBounty', -1, Config.Bounties)
                        end
                    end
                end
            end
        end
    end
end)



function deletebounty()
    local oneDaySecond = 72 * 60 * 60
    local dateNow = os.time()
    local result =  MySQL.Sync.fetchAll('SELECT * FROM bounties')

    for k,v in pairs(result) do
        if os.difftime(dateNow , v.createdAt) > oneDaySecond then

            MySQL.Sync.fetchAll('DELETE FROM bounties WHERE id=@id', {['@id'] = v.id})

            for _,ilan in pairs(Config.Bounties) do
                if v.id == ilan.id then
                    table.remove(Config.Bounties, _)
                    TriggerClientEvent('lucid-bounty:updateBounty', -1, Config.Bounties)
                end
            end
        end
    end
end

TriggerEvent('cron:runAt', 12, 00, deletebounty)
TriggerEvent('cron:runAt', 22, 00, deletebounty)

