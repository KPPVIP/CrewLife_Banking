--================================================================================================--
--==                                VARIABLES - DO NOT EDIT                                     ==--
--================================================================================================--
ESX                         = nil
inMenu                      = true
local atbank = false
local bankMenu = true


local atms = {
	[1] = {"prop_atm_01"},
	[2] = {"prop_atm_02"},
	[3] = {"prop_atm_03"},
	[4] = {"prop_fleeca_atm"},
}

local banks = {
	{name="Bank", closed = false, id=108, x=150.266, y=-1040.203, z=29.374},
	{name="Bank", closed = false, id=108, x=-1212.980, y=-330.841, z=37.787},
	{name="Bank", closed = false, id=108, x=-2962.582, y=482.627, z=15.703},
	{name="Bank", closed = false, id=108, x=-112.202, y=6469.295, z=31.626},
	{name="Bank", closed = false, id=108, x=314.187, y=-278.621, z=54.170},
	{name="Bank", closed = false, id=108, x=-351.534, y=-49.529, z=49.042},
	{name="Staatsbank", closed = false, id=108, x=241.727, y=220.706, z=106.286, principal = true},
	{name="Bank", closed = false, id=108, x=1175.0643310547, y=2706.6435546875, z=38.094036102295}
}	

function InitBlips()
	for k,v in ipairs(banks)do
		local blip = AddBlipForCoord(v.x, v.y, v.z)
		SetBlipSprite(blip, v.id)
		SetBlipScale(blip, 0.7)
		SetBlipAsShortRange(blip, true)
		if v.principal ~= nil and v.principal then
			SetBlipColour(blip, 24)
		else
			SetBlipColour(blip, 25)
		end
		BeginTextCommandSetBlipName("STRING")
		AddTextComponentString(tostring(v.name))
		EndTextCommandSetBlipName(blip)
	end
end


local keys = {
	["ESC"] = 322, ["F1"] = 288, ["F2"] = 289, ["F3"] = 170, ["F5"] = 166, ["F6"] = 167, ["F7"] = 168, ["F8"] = 169, ["F9"] = 56, ["F10"] = 57, 
	["~"] = 243, ["1"] = 157, ["2"] = 158, ["3"] = 160, ["4"] = 164, ["5"] = 165, ["6"] = 159, ["7"] = 161, ["8"] = 162, ["9"] = 163, ["-"] = 84, ["="] = 83, ["BACKSPACE"] = 177, 
	["TAB"] = 37, ["Q"] = 44, ["W"] = 32, ["E"] = 38, ["R"] = 45, ["T"] = 245, ["Y"] = 246, ["U"] = 303, ["P"] = 199, ["["] = 39, ["]"] = 40, ["ENTER"] = 18,
	["CAPS"] = 137, ["A"] = 34, ["S"] = 8, ["D"] = 9, ["F"] = 23, ["G"] = 47, ["H"] = 74, ["K"] = 311, ["L"] = 182,
	["LEFTSHIFT"] = 21, ["Z"] = 20, ["X"] = 73, ["C"] = 26, ["V"] = 0, ["B"] = 29, ["N"] = 249, ["M"] = 244, [","] = 82, ["."] = 81,
	["LEFTCTRL"] = 36, ["LEFTALT"] = 19, ["SPACE"] = 22, ["RIGHTCTRL"] = 70, 
	["HOME"] = 213, ["PAGEUP"] = 10, ["PAGEDOWN"] = 11, ["DELETE"] = 178,
	["LEFT"] = 174, ["RIGHT"] = 175, ["TOP"] = 27, ["DOWN"] = 173,
	["NENTER"] = 201, ["N4"] = 108, ["N5"] = 60, ["N6"] = 107, ["N+"] = 96, ["N-"] = 97, ["N7"] = 117, ["N8"] = 61, ["N9"] = 118
}

function playAnim(animDict, animName, duration)
	RequestAnimDict(animDict)
	while not HasAnimDictLoaded(animDict) do Citizen.Wait(0) end
	TaskPlayAnim(PlayerPedId(), animDict, animName, 1.0, -1.0, duration, 49, 1, false, false, false)
	RemoveAnimDict(animDict)
end

--================================================================================================
--==                                THREADING - DO NOT EDIT                                     ==
--================================================================================================

--===============================================
--==           Base ESX Threading              ==
--===============================================
Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
end)

--===============================================
--==             Core Threading                ==
--===============================================
local closestAtm

Citizen.CreateThread(function()
	Wait(1000)
	InitBlips()
	
	while true do
		Wait(0)

		local playerCoords = GetEntityCoords(PlayerPedId())
		local canSleep = true

		for a,b in pairs(atms) do
			closestAtm = GetClosestObjectOfType(playerCoords.x, playerCoords.y, playerCoords.z,1.5,GetHashKey(b[1]),false, false, true)
			
			if (DoesEntityExist(closestAtm)) and IsNuiFocused() == false then
				local objPos = GetEntityCoords(closestAtm)
				local distance = #(playerCoords - objPos)
				
				if (distance <= 2.0) then
					canSleep = false

					DisplayHelpText("Drücke ~g~E ~s~um auf die Bank zuzugreifen")

					if IsControlJustPressed(1, keys["E"]) then
						openUI()
						TriggerServerEvent('bank:balance')
					end
				end
			end
		end

		if canSleep then 
			Wait(500)
		end
	end
end)

Citizen.CreateThread(function()
	Wait(1000)
	InitBlips()
	
	while true do
		Wait(0)

		local playerCoords = GetEntityCoords(PlayerPedId())
		local canSleep = true

		for a,b in pairs(banks) do
			local distance = #(playerCoords - vector3(b.v, b.y, b.z))
			
			if (distance <= 2.0) then
				canSleep = false

				DisplayHelpText("Drücke ~g~E ~s~um auf die Bank zuzugreifen")

				if IsControlJustPressed(1, keys["E"]) then
					openUI()
					TriggerServerEvent('bank:balance')
				end
			end
		end

		if canSleep then 
			Wait(500)
		end
	end
end)



--===============================================
--==             Map Blips	                   ==
--===============================================




--===============================================
--==           Deposit Event                   ==
--===============================================
RegisterNetEvent('currentbalance1')
AddEventHandler('currentbalance1', function(balance)
	local id = PlayerId()
	local playerName = GetPlayerName(id)

	SendNUIMessage({
		type = "balanceHUD",
		balance = balance,
		player = playerName
		})
end)
--===============================================
--==           Deposit Event                   ==
--===============================================
RegisterNUICallback('deposit', function(data)
	TriggerServerEvent('bank:deposit', tonumber(data.amount))
	TriggerServerEvent('bank:balance')
end)

--===============================================
--==          Withdraw Event                   ==
--===============================================
RegisterNUICallback('withdrawl', function(data)
	TriggerServerEvent('bank:withdraw', tonumber(data.amountw))
	TriggerServerEvent('bank:balance')
end)

--===============================================
--==         Balance Event                     ==
--===============================================
RegisterNUICallback('balance', function()
	TriggerServerEvent('bank:balance')
end)

RegisterNetEvent('balance:back')
AddEventHandler('balance:back', function(balance)
	SendNUIMessage({type = 'balanceReturn', bal = balance})
end)


--===============================================
--==         Transfer Event                    ==
--===============================================
RegisterNUICallback('transfer', function(data)
	TriggerServerEvent('bank:transfer', data.to, data.amountt)
	TriggerServerEvent('bank:balance')
end)

--===============================================
--==         Result   Event                    ==
--===============================================
RegisterNetEvent('bank:result')
AddEventHandler('bank:result', function(type, message)
	SendNUIMessage({type = 'result', m = message, t = type})
end)


--===============================================
--==         ESX Invest Event                  ==
--===============================================
RegisterNUICallback('esx_invest', function()
	if(inMenu) then
		inMenu = false
		SetNuiFocus(false, false)
		SendNUIMessage({type = 'closeAll'})
		exports.esx_invest:openUI()
	end
end)

--===============================================
--==               NUIFocusoff                 ==
--===============================================
RegisterNUICallback('NUIFocusOff', function()
	closeUI()
end)

AddEventHandler('onResourceStop', function (resourceName)
	if (GetCurrentResourceName() ~= resourceName) then
	  return
	end
	closeUI()
end)

AddEventHandler('onResourceStart', function (resourceName)
	if(GetCurrentResourceName() ~= resourceName) then
		return
	end
	closeUI()
end)

function IsNearATM()

end

function RotationToDirection(rotation)
	local adjustedRotation =
	{
		x = (math.pi / 180) * rotation.x,
		y = (math.pi / 180) * rotation.y,
		z = (math.pi / 180) * rotation.z
	}
	local direction =
	{
		x = -math.sin(adjustedRotation.z) * math.abs(math.cos(adjustedRotation.x)),
		y = math.cos(adjustedRotation.z) * math.abs(math.cos(adjustedRotation.x)),
		z = math.sin(adjustedRotation.x)
	}
	return direction
end

function RayCastGamePlayCamera(distance)
    local cameraRotation = GetGameplayCamRot()
	local cameraCoord = GetGameplayCamCoord()
	local direction = RotationToDirection(cameraRotation)
	local destination =
	{
		x = cameraCoord.x + direction.x * distance,
		y = cameraCoord.y + direction.y * distance,
		z = cameraCoord.z + direction.z * distance
	}
	local a, b, c, d, e = GetShapeTestResult(StartShapeTestRay(cameraCoord.x, cameraCoord.y, cameraCoord.z, destination.x, destination.y, destination.z, -1, PlayerPedId(), 0))
	return b, c, e
end

-- function nearATM()
-- 	local player = PlayerPedId()
-- 	local playerloc = GetEntityCoords(player, 0)
-- 	local canSleep = true

-- 	for _, search in pairs(Config.ATM) do
-- 		local distance = #(playerloc - vector3(search.x, search.y, search.z))

-- 		if distance <= 2 then
-- 			canSleep = false
-- 			return true
-- 		end
-- 	end
	
-- 	if canSleep then 
-- 		Citizen.Wait(500)
-- 	end
-- end


function closeUI()
	inMenu = false
	SetNuiFocus(false, false)
	if Config.Animation.Active then 
		playAnim('mp_common', 'givetake1_a', Config.Animation.Time)
		Citizen.Wait(Config.Animation.Time)
	end
	SendNUIMessage({type = 'closeAll'})
end

function openUI()
	if Config.Animation.Active then 
		playAnim('mp_common', 'givetake1_a', Config.Animation.Time)
		Citizen.Wait(Config.Animation.Time)
	end
	inMenu = true
	SetNuiFocus(true, true)
	SendNUIMessage({type = 'openGeneral'})
	TriggerServerEvent('bank:balance')
end


function DisplayHelpText(str)
	SetTextComponentFormat("STRING")
	AddTextComponentString(str)
	DisplayHelpTextFromStringLabel(0, 0, 1, -1)
end
