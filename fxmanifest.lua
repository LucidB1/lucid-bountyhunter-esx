fx_version 'adamant'
game 'gta5'

client_scripts {'client.lua'}
server_scripts {    
    '@mysql-async/lib/MySQL.lua',
    'server.lua'}
ui_page {'html/index.html'}

files {

    'html/index.html', 'html/app.js', 
    'html/*.jpg',   'html/*.png',
    'html/css/style.css',
}
