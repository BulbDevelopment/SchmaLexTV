ESX = exports['es_extended']:getSharedObject()

function OpenLifeinvader()
  ESX.TriggerServerCallback("bulbdev_custom_lifeinvader:getplrdata", function(plrdata) 
    ESX.TriggerServerCallback("bulbdev_custom_lifeinvader:gethistory", function(history)
      SetNuiFocus(true, true)
      SendNUIMessage({
        type = "open",
        plrdata = plrdata,
        messages = history,
        priceperword = Config.PricePerWord,
        baseprice = Config.BasePrice,
        maxletters = Config.MaxLetters,
      })
    end)
  end)
end

function Close()
  SendNUIMessage({
    type = "close"
  })
  SetNuiFocus(false, false)
end

RegisterNUICallback("close", function(data, cb)
  Close()
  cb({})
end)

RegisterNUICallback("send", function(data, cb)
  ESX.TriggerServerCallback("bulbdev_custom_lifeinvader:sendmessage", function(cb)
    if cb then
      ESX.ShowNotification("Du hast Erfolgreich eine Nachricht gesendet")
    elseif cb == "notenoughmoney" then
      ESX.ShowNotification("Du hast nicht genug Geld um eine Nachricht zu senden")
    end
  end, data)
  Close()
  cb({})
end)

Citizen.CreateThread(function()
  for k, v in pairs(Config.Lifeinvaders) do
    local blip = AddBlipForCoord(v.coords)
    SetBlipSprite(blip, v.blip.id)
    SetBlipDisplay(blip, 4)
    SetBlipScale(blip, v.blip.scale)
    SetBlipColour(blip, v.blip.color)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(v.blip.label)
    EndTextCommandSetBlipName(blip)

    local npc = v.npc
    local ped = GetHashKey(npc.ped)
    RequestModel(ped)
    while not HasModelLoaded(ped) do
      Wait(1)
    end

    local ped = CreatePed(4, ped, npc.coords.x, npc.coords.y, npc.coords.z, npc.coords.w, false, true)
    SetEntityHeading(ped, npc.coords.w) 
    FreezeEntityPosition(ped, true)
    SetEntityInvincible(ped, true)
    SetBlockingOfNonTemporaryEvents(ped, true)
  end
end)

Citizen.CreateThread(function()
  local sleep = 1000
  while true do
    for k, v in pairs(Config.Lifeinvaders) do
      local coords = GetEntityCoords(PlayerPedId())
      local distance = GetDistanceBetweenCoords(coords, v.coords, true)
      if distance < 5.0 then
        sleep = 5
        DrawMarker(v.marker.id, v.coords.x, v.coords.y, v.coords.z, v.marker.size.x, v.marker.size.y, v.marker.size.z, v.marker.color.x, v.marker.color.y, v.marker.color.z, v.marker.rotate, false, 0, false, false, false, false)
        if distance < 1 then
          sleep = 5
          ESX.ShowHelpNotification("Drücke ~INPUT_CONTEXT~ um den Lifeinvader zu öffnen.")
          if IsControlJustPressed(0, 38) then
            OpenLifeinvader()
          end
        end
      end
    end
    Citizen.Wait(sleep)
  end
end)