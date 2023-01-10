fx_version 'cerulean'
game 'gta5'

description 'Car Dev Menu'
version '1.0.0'

lua54 'yes'

client_scripts {
    '@menuv/menuv.lua',
    'config.lua',
    'client.lua'
}

server_scripts {
    'config.lua',
    'server.lua'
}

dependencies {
    'qb-core',
    'menuv',
    'qb-vehiclekeys'
}
