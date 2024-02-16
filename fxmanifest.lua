fx_version 'cerulean'
games { 'gta5' }
lua54 'yes'

author 'dallefar - discord'
description 'Twitter script til vrp'
version '1.0.0'

dependency 'vrp'

shared_scripts {
	"config.lua",
	'@ox_lib/init.lua'
}

client_scripts {
	"client/main.lua"
}

server_scripts {
	'@vrp/lib/utils.lua',
	'server/main.lua'
}