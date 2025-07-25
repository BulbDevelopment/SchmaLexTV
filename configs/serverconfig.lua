s_Config = {}
s_Config.Bottoken = "" -- Dicord Bottoken
s_Config.PlaceholderAvatar = "https://cdn.discordapp.com/attachments/1023950935355031602/1116443954670473357/Logo.png"
s_Config.Webhook = {
  ["url"] = "",-- webhook
  ["name"] = "Lifeinvader",
  ["image"] = "https://cdn.discordapp.com/attachments/1023950935355031602/1116443954670473357/Logo.png",-- PlaceHolder
  ["title"] = "Lifeinvader",
  ["color"] = 16711680,
  ["footer"] = "Lifeinvader",
  ["footerimage"] = "https://cdn.discordapp.com/attachments/1023950935355031602/1116443954670473357/Logo.png"-- PlaceHolder
}

function Announce(name, message)
  TriggerClientEvent('esx:showAdvancedNotification', -1, 'Lifeinvader', 'Von : ~y~' .. name, message, 'CHAR_LIFEINVADER', 1)
end