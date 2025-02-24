author 'Sir Gang Shit'
description 'New Carolina Network F6 Menu'
fx_version 'adamant'
lua54 'yes'

game 'gta5'

client_script '@natives/client.lua'

dependencies {
    'NativeUI',
}

client_script {
	'@NativeUI/NativeUI.lua',
	'Client/Preload.lua',
	'Config.lua',
	'Categories.lua',
	'Client/Client.lua',
}

server_script {
	'Server/Server.lua',
}
