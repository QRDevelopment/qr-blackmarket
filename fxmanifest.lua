fx_version 'cerulean'
game 'gta5'

description 'QR Blackmarket - A realistic blackmarket script for QBCore'
version '1.0.0'
author 'QR Development'

shared_scripts {
    'config.lua'
}

client_scripts {
    'client/main.lua'
}

server_scripts {
    'server/main.lua'
}

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/style.css',
    'html/script.js',
    'html/img/*.png',
    'html/img/*.jpg'
}

lua54 'yes'