ESX = exports['es_extended']:getSharedObject()

local messagehistory = {}
local plrdiscordpfps = {}
local cooldown = 0

function GetPhoneNumberFromId(id)
  local xPlayer = ESX.GetPlayerFromId(id)
  local identifier = xPlayer.getIdentifier()
  MySQL.Async.fetchAll('SELECT * FROM users WHERE identifier = @identifier', {
    ['@identifier'] = identifier      
  }, function(result)
    if result[1] ~= nil then
      return result[1].phone_number
    else
      return nil
    end
  end)
end

function getDiscordPFP(id)
    local discordid = GetDiscordIDFromid(id)
    if not discordid then return "https://cdn.discordapp.com/attachments/1023950935355031602/1116443954670473357/B_Logo_with_BG2.png" end
    if plrdiscordpfps[discordid] then
      return plrdiscordpfps[discordid]
    else
      local url = "https://discord.com/api/v10/users/" .. discordid
  
      PerformHttpRequest(url, function(statusCode, responseText, headers)
          if statusCode == 200 then
              local responseData = json.decode(responseText)
              responseData = json.decode(responseText)
              local avatarHash = responseData.avatar
              local avatarUrlPNG = "https://cdn.discordapp.com/avatars/" .. discordid .. "/" .. avatarHash .. ".png"
              plrdiscordpfps[discordid] = avatarUrlPNG
          else
              print("Error Fetching Discord Avatar: " .. statusCode)
              plrdiscordpfps[discordid] = s_Config.PlaceholderAvatar
          end
      end, "GET", "", { ["Authorization"] = "Bot " .. s_Config.Bottoken })
      return plrdiscordpfps[discordid]
    end
end

function GetDiscordIDFromid(id)
    local identifiers = GetPlayerIdentifiers(id)
    for _, v in pairs(identifiers) do
        if string.find(v, "discord:") then
            local dcid = string.gsub(v, "discord:", "")
            return dcid
        end
    end

    return nil
end

function getDiscordServerPFPS()
  local players = ESX.GetPlayers()
  for _, v in pairs(players) do
    local xPlayer = ESX.GetPlayerFromId(v)
    getDiscordPFP(xPlayer.source)	
  end
end  

AddEventHandler("onResourceStart", function(resource)
    if resource == GetCurrentResourceName() then
        getDiscordServerPFPS()  
        local history = LoadResourceFile(GetCurrentResourceName(), "messages.json")
        if history then
            messagehistory = json.decode(history)
        else 
            messagehistory = {}
        end
    end
end)

AddEventHandler("onResourceStop", function(resource)
    if resource == GetCurrentResourceName() then
        SaveResourceFile(GetCurrentResourceName(), "messages.json", json.encode(messagehistory), -1)
    end
end)

ESX.RegisterServerCallback("bulbdev_custom_lifeinvader:gethistory", function(src, cb)
    cb(messagehistory)
end)

ESX.RegisterServerCallback("bulbdev_custom_lifeinvader:getplrdata", function(src, cb)
  local xPlayer = ESX.GetPlayerFromId(src)
  local data = {}
  data.name = xPlayer.getName()
  data.money = xPlayer.getMoney()
  data.pfp = getDiscordPFP(src)
  cb(data)
end)

ESX.RegisterServerCallback("bulbdev_custom_lifeinvader:sendmessage", function(src, cb, data)
  local xPlayer = ESX.GetPlayerFromId(src)
  local price = bulbdev_Config.PricePerWord * #data.content + bulbdev_Config.BasePrice
  if cooldown > 0 then
    TriggerClientEvent('esx:showNotification', src, "Du musst noch ~r~" .. cooldown .. " Sekunden warten!")
    cb(false)
    return
  end
  if xPlayer.getMoney() >= price then
    xPlayer.removeMoney(price)
    local phonenumber = GetPhoneNumberFromId(xPlayer.source)
    if phonenumber == nil then phonenumber = "Unbekannt" end
    if data.messagemode == "anon" then
      Announce("Unbekannt", data.content)
      table.insert(messagehistory, {name = "Unbekannt", content = data.content, date = os.date("%d/%m/%Y"), time = os.date("%H:%M"), phone = 'Unbekannt'}) 
      LogtoDiscord(xPlayer.source, "Unbekannt", data.content)
    else
      Announce(xPlayer.getName(), data.content)
      table.insert(messagehistory, {name = xPlayer.getName(), content = data.content, date = os.date("%d/%m/%Y"), time = os.date("%H:%M"), phone = phonenumber})
      LogtoDiscord(xPlayer.source, xPlayer.getName(), data.content)
    end
    StartCooldown()
    cb(true)
  else
    cb("notenoughmoney")
  end
end)

function StartCooldown()
  cooldown = bulbdev_Config.Cooldown
  while cooldown > 0 do
    Citizen.Wait(1000)
    cooldown = cooldown - 1
  end
end

function LogtoDiscord(id, name, text)
  local xPlayer = ESX.GetPlayerFromId(id)
  PerformHttpRequest(s_Config.Webhook.url, function(err, text, headers) end, 'POST', json.encode({username = s_Config.Webhook.name, embeds = {{["title"] = s_Config.Webhook.title, ["description"] = "Der Spieler ``" .. name .. "`` hat eine Werbung geschaltet: ``" .. text .."``", ["type"] = "rich", ["color"] = s_Config.Webhook.color, ["footer"] = {["text"] = s_Config.Webhook.footer, ["icon_url"] = s_Config.Webhook.footerimage}, ["thumbnail"] = {["url"] = getDiscordPFP(id)}}}}), { ['Content-Type'] = 'application/json' })
end