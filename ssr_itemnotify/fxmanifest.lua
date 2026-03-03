fx_version 'cerulean'
game 'gta5'

author 'Super Special Rare'
description 'Custom Script'
version '1.0.0'

lua54 'yes'

ui_page "html/ui.html"

client_scripts {
	"client/client.lua",
	"config/config.lua"
}

files {
	"html/*.html",
	"html/*.css",
	"html/*.js",
	"html/*.png"
}
server_scripts {
	"config/config.lua",
	"server.lua"
}
