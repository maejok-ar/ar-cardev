fx_version 'cerulean'
game 'gta5'

author 'MAEJOK <https://github.com/maej20>'
description 'Car Dev Menu'
version '1.0.0'

client_scripts {
    '@ox_lib/init.lua',
    '@menuv/menuv.lua',
    'config.lua',
    'client.lua'
}

server_scripts {
    '@ox_lib/init.lua',
    'config.lua',
    'server.lua'
}

dependencies {
    'ox_lib',
    'qb-core',
    'menuv',
    'qb-vehiclekeys'
}

lua54 'yes'