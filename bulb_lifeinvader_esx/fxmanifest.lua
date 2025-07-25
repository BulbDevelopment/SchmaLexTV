fx_version 'cerulean'
game 'gta5'

author 'BulbDev x SchmaLexTV'
description 'Lifeinvader ESX | https://discord.gg/VBfhV8425Q '

version '1.0.0'
lua54 'yes'

client_scripts {
  'client/main.lua',
  'configs/config.lua'
}

server_scripts {
  '@mysql-async/lib/MySQL.lua',
  'server/main.lua',
  'configs/*.lua'
}

ui_page 'ui/index.html'

files {
  'ui/**/*'
}

escrow_ignore {
  'configs/*.lua'
}