fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'basoken'
description 'Günlük Ödül Sistemi'
version '1.0.0'

ui_page 'nui/daily_rewards.html'

files {
    'nui/daily_rewards.html',
	'@oxmysql/lib/MySQL.lua',
}

client_scripts {
    'client.lua'
}

server_scripts {
    'server.lua'
}

shared_script {
    'config.lua'
}

escrow_ignore {
    'config.lua'
}
