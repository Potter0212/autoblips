local isRadarExtended = false
local showblip = false
local showsprite = false
local block_run = false

vRP = Proxy.getInterface("vRP")

RegisterNetEvent("Blips:On")
AddEventHandler("Blips:On",function()
		showblip = not showblip
		if showblip then
			showsprite = true
		else
			showsprite = false
		end
	end
)

Citizen.CreateThread(
	function()
		while true do
			Wait(1)
			local mped = GetPlayerPed(-1)
			for _, id in ipairs(GetActivePlayers()) do
				if GetPlayerPed(id) ~= mped then
					local ped = GetPlayerPed(id)
					local blip = GetBlipFromEntity(ped)
					local headId = Citizen.InvokeNative(0xBFEFE3321A3F5015, ped, GetPlayerName(id), false, false, "", false)
					local wantedLvl = GetPlayerWantedLevel(id)

					if showsprite and IsEntityVisible(ped) and GetEntityAlpha(ped) > 60 then
						Citizen.InvokeNative(0x63BB75ABEDC1F6A0, headId, 0, true) -- Add player name sprite

						-- Wanted level display
						if wantedLvl then
							Citizen.InvokeNative(0x63BB75ABEDC1F6A0, headId, 7, true) -- Add wanted sprite
							Citizen.InvokeNative(0xCF228E2AA03099C3, headId, wantedLvl) -- Set wanted number
						else
							Citizen.InvokeNative(0x63BB75ABEDC1F6A0, headId, 7, false) -- Remove wanted sprite
						end

						-- Speaking display
						if NetworkIsPlayerTalking(id) then
							Citizen.InvokeNative(0x63BB75ABEDC1F6A0, headId, 9, true) -- Add speaking sprite
						else
							Citizen.InvokeNative(0x63BB75ABEDC1F6A0, headId, 9, false) -- Remove speaking sprite
						end
					else
						Citizen.InvokeNative(0x63BB75ABEDC1F6A0, headId, 7, false) -- Remove wanted sprite
						Citizen.InvokeNative(0x63BB75ABEDC1F6A0, headId, 9, false) -- Remove speaking sprite
						Citizen.InvokeNative(0x63BB75ABEDC1F6A0, headId, 0, false) -- Remove player name sprite
					end

					if showblip and IsEntityVisible(ped) and GetEntityAlpha(ped) > 60 then
						if not DoesBlipExist(blip) then -- Add blip and create head display on player
							blip = AddBlipForEntity(ped)
							SetBlipSprite(blip, 1)
							Citizen.InvokeNative(0x5FBCA48327B914DF, blip, true) -- Player Blip indicator
						else -- update blip
							veh = GetVehiclePedIsIn(ped, false)
							blipSprite = GetBlipSprite(blip)

							if not GetEntityHealth(ped) then -- dead
								if blipSprite ~= 274 then
									SetBlipSprite(blip, 274)
									Citizen.InvokeNative(0x5FBCA48327B914DF, blip, false) -- Player Blip indicator
								end
							elseif veh then
								vehClass = GetVehicleClass(veh)
								vehModel = GetEntityModel(veh)

								if vehClass == 15 then -- jet
									if blipSprite ~= 422 then
										SetBlipSprite(blip, 422)
										Citizen.InvokeNative(0x5FBCA48327B914DF, blip, false) -- Player Blip indicator
									end
								elseif vehClass == 16 then -- plane
									if vehModel == GetHashKey("besra") or vehModel == GetHashKey("hydra") or vehModel == GetHashKey("lazer") then -- jet
										if blipSprite ~= 424 then
											SetBlipSprite(blip, 424)
											Citizen.InvokeNative(0x5FBCA48327B914DF, blip, false) -- Player Blip indicator
										end
									elseif blipSprite ~= 423 then
										SetBlipSprite(blip, 423)
										Citizen.InvokeNative(0x5FBCA48327B914DF, blip, false) -- Player Blip indicator
									end
								elseif vehClass == 14 then -- boat
									if blipSprite ~= 427 then
										SetBlipSprite(blip, 427)
										Citizen.InvokeNative(0x5FBCA48327B914DF, blip, false) -- Player Blip indicator
									end
								elseif vehModel == GetHashKey("insurgent") or vehModel == GetHashKey("insurgent2") or vehModel == GetHashKey("limo2") then -- insurgent (+ turreted limo cuz limo blip wont work)
									if blipSprite ~= 426 then
										SetBlipSprite(blip, 426)
										Citizen.InvokeNative(0x5FBCA48327B914DF, blip, false) -- Player Blip indicator
									end
								elseif vehModel == GetHashKey("rhino") then -- tank
									if blipSprite ~= 421 then
										SetBlipSprite(blip, 421)
										Citizen.InvokeNative(0x5FBCA48327B914DF, blip, false) -- Player Blip indicator
									end
								elseif blipSprite ~= 1 then -- default blip
									SetBlipSprite(blip, 1)
									Citizen.InvokeNative(0x5FBCA48327B914DF, blip, true) -- Player Blip indicator
								end

								-- Show number in case of passangers
								passengers = GetVehicleNumberOfPassengers(veh)

								if passengers then
									if not IsVehicleSeatFree(veh, -1) then
										passengers = passengers + 1
									end

									ShowNumberOnBlip(blip, passengers)
								else
									HideNumberOnBlip(blip)
								end
							else
								-- Remove leftover number
								HideNumberOnBlip(blip)

								if blipSprite ~= 1 then -- default blip
									SetBlipSprite(blip, 1)
									Citizen.InvokeNative(0x5FBCA48327B914DF, blip, true) -- Player Blip indicator
								end
							end

							SetBlipRotation(blip, math.ceil(GetEntityHeading(veh))) -- update rotation
							SetBlipNameToPlayerName(blip, id) -- update blip name
							SetBlipScale(blip, 0.85) -- set scale

							-- set player alpha
							if IsPauseMenuActive() then
								SetBlipAlpha(blip, 255)
							else
								x1, y1 = table.unpack(GetEntityCoords(mped, true))
								x2, y2 = table.unpack(GetEntityCoords(GetPlayerPed(id), true))
								distance = (math.floor(math.abs(math.sqrt((x1 - x2) * (x1 - x2) + (y1 - y2) * (y1 - y2))) / -1)) + 900
								-- Probably a way easier way to do this but whatever im an idiot

								if distance < 0 then
									distance = 0
								elseif distance > 255 then
									distance = 255
								end

								SetBlipAlpha(blip, distance)
							end
						end
					else
						RemoveBlip(blip)
					end
				end
			end
		end
	end
)


RegisterNetEvent('block:run')
AddEventHandler('block:run', function()
	if block_run == false then
      block_run = true
      end
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
    local playerPed = GetPlayerPed(-1)
		if GetDistanceBetweenCoords(1689.693, 2586.405, 51.2557, GetEntityCoords(playerPed)) < 195.0 then
      if showblip == false and block_run == false then
     -- TriggerServerEvent('blips:checkper')
      TriggerServerEvent('block:checkper')
      Citizen.Wait(1000)
  end
else
  if showblip == true then
      showsprite = false
      showblip = false
      vRP.notify({"~r~[ ????????? ?????? ]~w~\n??????????????? ~r~????????????~w~ ???????????????."})
  end
  if block_run == true then
    block_run = false
    vRP.notify({"~g~[ ????????? ?????? ]~w~\n????????? ~g~?????????~w~ ???????????????."})
    end
end
end
end)

function help_message(msg)
    SetTextComponentFormat("STRING")
    AddTextComponentString(msg)
    DisplayHelpTextFromStringLabel(0,0,1,-1)
end

Citizen.CreateThread(
  function()
    while true do
      if block_run == true then
          DisableControlAction(0, 22, true)
          DisableControlAction(0, 166, true)
          DisableControlAction(0, 167, true)
          DisableControlAction(0, 168, true)
       end
      Citizen.Wait(0)
    end
  end
)

--MADE IN REALWORLD 2020 MODERATOR @EUNYUL