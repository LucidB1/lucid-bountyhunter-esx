ESX = nil

local ply = nil
local players = nil
Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
end)

Config = {}
Config.Bounties = {}
Config.board_locations = { {coords = vector3(-205.83, -775.73, 30.45), obj = nil, heading = 249.56 }, {coords = vector3(-202.09, -771.87, 30.45), obj = nil, heading = 350.0 }}

RegisterNetEvent('lucid-bounty:updateBounty')
AddEventHandler('lucid-bounty:updateBounty', function(new)
	Config.Bounties = new
	SendNUIMessage({action="update", data=Config.Bounties })

end)

RegisterNetEvent("lucid-bounty:newBountyAdded")
AddEventHandler("lucid-bounty:newBountyAdded", function(formInputs)
	SendNUIMessage({action="newDataAdded", data=formInputs})
end)






local openedcam = false
local cameras = {}
function createCamera(ent)
	print('ent ',ent)
	DoScreenFadeOut(500)
	Citizen.Wait(500)

    local pedCoords = GetEntityCoords(PlayerPedId(), true)
    local coordsCam = GetOffsetFromEntityInWorldCoords(ent, 0.0, -4.5, 0.65)
    local entity = GetEntityCoords(ent)
    local cam1 = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", (coordsCam.x), (coordsCam.y ), (coordsCam.z ), 0.00, 0.00, 10.00, 50.0, false, 2)
    cameras = {
        ['ped'] = cam1,
    }
    PointCamAtCoord(cameras.ped, entity.x, entity.y, (entity.z + 0.65))
    openedcam = true
    SetCamActive(cameras.ped, true)
    RenderScriptCams(true, true, 500, true, true)
    SetEntityVisible(PlayerPedId(), false)
	Citizen.Wait(500)
	DoScreenFadeIn(100)
end



function closeCam()
    if openedcam then

		DoScreenFadeOut(100)
		Citizen.Wait(750)


        SetCamActive(cameras['ped'], false)
        DestroyCam(cameras['ped'], true)
        RenderScriptCams(false, false, 1, true, true)
        FreezeEntityPosition(PlayerPedId(), false)
    	SetEntityVisible(PlayerPedId(), true)
        openedcam = false
		Citizen.Wait(200)
		DoScreenFadeIn(100)
    end
end


RegisterNUICallback('close', function()
	SetNuiFocus(false, false)

	closeCam()
end)


local function TableToString(tab)
	local str = ""
	for i = 1, #tab do
		if i > 2 then
			str = str .. " " .. tab[i]
		end
	end
	return str
end

RegisterCommand('bounty', function(source, args)
	local target_id = args[1]

	if (target_id == nil) then
		ESX.ShowNotification("Player id can't be empty /bounty [target_id] [bounty_amount] [reason]")
		return
	end
	local bounty_reward = args[2]
	if(bounty_reward == nil) then
		ESX.ShowNotification("Bounty amount can't be empty /bounty [target_id] [bounty_amount] [reason]")
		return
	end
	local reason = TableToString(args)
	if (reason == nil) then
		
		ESX.ShowNotification("Reason can't be empty /bounty [target_id] [bounty_amount] [reason]")
		return
	end

	TriggerServerEvent('lucid-bounty:sendBountyWithCommand', {targetId = tonumber(target_id), bountyReward = bounty_reward, reason = reason})
end)

RegisterCommand('bounties', function()
	ESX.TriggerServerCallback('lucid-bounty:getPlayers', function(cb) 
		players = cb
		SendNUIMessage({
			action = "updatePlayers",
			players = players,
		})

		SendNUIMessage({
			action = "displayDetailsPage",
			data = true,
		})
		SetNuiFocus(true, true)
	end)	
end)

Citizen.CreateThread(function()

	while true do
		Citizen.Wait(0)
		local entCoords = GetEntityCoords(ply, true)
		for k,v in pairs(Config.board_locations) do
			if v.obj ~= nil then

				if GetDistanceBetweenCoords(entCoords, v.coords, true) < 3.0 then
		
					if IsControlJustPressed(0, 38) then
						createCamera(v.obj)
						SetNuiFocus(true, true)
						Citizen.Wait(1000)
						local coordsss = GetEntityCoords(v.obj, true)
						local onScreen, xxx, yyy = GetHudScreenPositionFromWorldPosition(coordsss.x - 1.0, coordsss.y , coordsss.z + 0.8)
						Citizen.Wait(300)
						SendNUIMessage({action="show", show=true, coords = {top = yyy , left = xxx}, players = players})
			
					end
				end
			end
		end
	end
end)

RegisterNUICallback("sendBounty", function(data,cb)
	local formInputs = data.formInputs;
	TriggerServerEvent("lucid-bounty:sendBounty", formInputs)
end)


RegisterNUICallback("takeBounty", function(data,cb)
	local bounty = data.data;
	TriggerServerEvent("lucid-bounty:takeBounty", bounty)
end)

RegisterCommand("getbounties", function()
	SendNUIMessage({action="update", data=Config.Bounties})
end)


local cooldown = false

function createBlips(coords)
	local blip = AddBlipForCoord(coords.x, coords.y, coords.z)
	SetBlipAsShortRange(blip, true)
	SetBlipDisplay(blip, 4)
	SetBlipScale(blip, 0.6)
    SetBlipSprite(blip, 84)
	SetBlipColour(blip, 49)
	SetBlipShowCone(blip, true)
	BeginTextCommandSetBlipName("STRING")
	AddTextComponentString('BOUNTY')
	EndTextCommandSetBlipName(blip)
	SetBlipCategory(blip, 1)
	ESX.ShowNotification('Location of player is display on map')
	cooldown = true

	N_0x82cedc33687e1f50(false)
	Citizen.Wait(10000)
	RemoveBlip(blip)
end



Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		if cooldown then
			Citizen.Wait(600000) -- 10 Minutes
			cooldown = false
		end
 	end

end)

RegisterNetEvent('lucid-bountyhunter:createblips')
AddEventHandler('lucid-bountyhunter:createblips', function(coords)
	createBlips(coords)
end)

RegisterCommand('hunterblip', function()
	if not cooldown then
		local activeJobs = getPlayerActiveJobs()
		TriggerServerEvent('lucid-bountyhunter:server:createblips', activeJobs)
	else
		ESX.ShowNotification('You need to wait for use this command')
	end
end)

function getPlayerActiveJobs()
	local player = ESX.GetPlayerData()
	local jobs = {}

	for k,v in pairs(Config.Bounties) do
		for _, hunter in pairs(v.hunters) do
			if hunter == player.identifier then
				table.insert(jobs, v)
			end
		end
	end
	return jobs
end


Citizen.CreateThread(function()
	while true do
		Citizen.Wait(4000)
		for k,v in pairs(Config.board_locations) do
			local dist = #(GetEntityCoords(PlayerPedId(), true) - v.coords)
			if dist < 70.0 then
				if v.obj == nil then
					local model = GetHashKey('prop_w_board_blank')
					RequestModel(model)
					while not HasModelLoaded(model) do
						Citizen.Wait(0)
					end
					
					ply = PlayerPedId()
					ESX.TriggerServerCallback('lucid-bounty:getbounties', function(cb) 
						SendNUIMessage({action="update", data=cb})
					end)
					ESX.TriggerServerCallback('lucid-bounty:getPlayers', function(cb) 
						players = cb
					end)
					v.obj =  CreateObject(model, v.coords.x, v.coords.y, v.coords.z-1.0, false, 0, true)
					SetEntityHeading(v.obj, v.heading)
				end
			else
				if v.obj ~= nil then
					if DoesEntityExist(v.obj) then
						DeleteEntity(v.obj)
						v.obj = nil
					end
				end
			end
		end
	end
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(playerData)
	loadObject()
end)

 RegisterCommand("loadbounty", function()
 	loadObject()
end)

function loadObject()

	ply = PlayerPedId()

	ESX.TriggerServerCallback('lucid-bounty:getbounties', function(cb) 
		SendNUIMessage({action="update", data=cb})
	end)
	ESX.TriggerServerCallback('lucid-bounty:getPlayers', function(cb) 
		players = cb

	end)	



end

AddEventHandler('onResourceStop', function (resource)
	if resource == GetCurrentResourceName() then

		for k,v in pairs(Config.board_locations) do
			if v.obj ~= nil then
			 	DeleteObject(v.obj)	
			end
		end
	end
end)




