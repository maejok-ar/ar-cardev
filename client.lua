local QBCore = exports['qb-core']:GetCoreObject()

--- DO NOT EDIT
local isDevMode = false
local spawnVehiclesModded = false
local manSpawnInput = false
local spawnedVehs = {}
local privateBucket = nil
local CurrentBucket = 'off'


-- MENUS
-- MAIN MENU
local menu_Main = MenuV:CreateMenu(Config.Menu.mainMenuTitle, 'Main Menu', Config.Menu.menuLocation, 220, 20, 60, Config.Menu.menuSize, Config.Menu.menuTexture, 'menuv', 'ns_m_main', Config.Menu.menuTheme)
-- VEHICLE MENU
local menu_Vehicles = MenuV:CreateMenu(Config.Menu.mainMenuTitle, 'Vehicles', Config.Menu.menuLocation, 220, 20, 60, Config.Menu.menuSize, Config.Menu.menuTexture, 'menuv', 'ns_m_veh', Config.Menu.menuTheme)
local menu_VehicleCategories = MenuV:CreateMenu(Config.Menu.mainMenuTitle, 'Vehicle Categories', Config.Menu.menuLocation, 220, 20, 60, Config.Menu.menuSize, Config.Menu.menuTexture, 'menuv', 'ns_m_veh_categories', Config.Menu.menuTheme)
local menu_VehicleModels = MenuV:CreateMenu(Config.Menu.mainMenuTitle, 'Vehicle Models', Config.Menu.menuLocation, 220, 20, 60, Config.Menu.menuSize, Config.Menu.menuTexture, 'menuv', 'ns_m_veh_models', Config.Menu.menuTheme)
-- EXTRAS/LIVERIES
local menu_VehicleExtras = MenuV:CreateMenu(Config.Menu.mainMenuTitle, 'Vehicle Extras', Config.Menu.menuLocation, 220, 20, 60, Config.Menu.menuSize, Config.Menu.menuTexture, 'menuv', 'ns_m_veh_extras', Config.Menu.menuTheme)
local menu_VehicleLiveries = MenuV:CreateMenu(Config.Menu.mainMenuTitle, 'Vehicle Liveries', Config.Menu.menuLocation, 220, 20, 60, Config.Menu.menuSize, Config.Menu.menuTexture, 'menuv', 'ns_m_veh_liveries', Config.Menu.menuTheme)

if Config.enableHotkey then menu_Main:OpenWith('KEYBOARD', 'F2') end

-- BUTTONS
-- MAIN MENU BUTTONS
-- DEV MODES
local sld_Bucket = menu_Main:AddSlider({ icon = '🌎', label = 'Dev Mode', value = 'off', values = {
    { label = 'Off', value = 'off', description = 'Exit Dev Mode' },
    { label = 'Public', value = 'public', description = 'A public bucket with other devs' },
    { label = 'Private', value = 'private', description = 'A private bucket by yourself' },
    { label = 'Custom', value = 'custom', description = 'Create or Join a private bucket' }
}})

-- FIX VEHICLE BUTTON
local btn_FixVehicle = menu_Main:AddButton({
    icon = '🔧',
    label = 'Fix Vehicle',
    disabled = true
})

-- DELETE VEHICLE BUTTON
local btn_DeleteVehicle = menu_Main:AddButton({
    icon = '🗑',
    label = 'Delete Vehicle',
    disabled = true
})

-- MAX MODS BUTTON
local btn_MaxMods = menu_Main:AddButton({
    icon = '⚡',
    label = 'Max Mods',
    disabled = true
})

-- VEHICLE SPAWNER MENU BUTTON
local btn_VehicleSpawnerMenu = menu_Main:AddButton({
    icon = '🚗',
    label = 'Spawner',
    value = menu_Vehicles,
    disabled = true
})


-- VEHICLE EXTRAS MENU BUTTON
local btn_VehicleExtrasMenu = menu_Main:AddButton({
    icon = '❌',
    label = 'No Extras Available',
    value = menu_VehicleExtras,
    disabled = true
})

-- VEHICLE LIVERIES MENU BUTTON
local btn_VehicleLiveriesMenu = menu_Main:AddButton({
    icon = '❌',
    label = 'No Liveries Available',
    value = menu_VehicleLiveries,
    disabled = true
})

-- VEHICLE SPAWN MENU BUTTONS
-- SPAWN WITH MAX MODS TOGGLE
local chk_SpawnVehicleModded = menu_Vehicles:AddCheckbox({
    icon = '⚡',
    label = 'Spawn Modded',
    value = false,
    saveOnUpdate = true,
-- disabled = true
})
-- MANUAL MODEL ENTRY
local btn_ManualSpawn = menu_Vehicles:AddButton({
    icon = '✏',
    label = 'Enter Model',
    select = function(_)
        DisplayOnscreenKeyboard(1, "FMMC_MPM_NA", "", "", "", "", "", 30)
        while (UpdateOnscreenKeyboard() == 0) do
            DisableAllControlActions(0);
            Wait(0);
        end
        if (GetOnscreenKeyboardResult()) then
            local model = GetOnscreenKeyboardResult()
            if string.len(model) > 0 then
                SpawnCar(model)
            end
        end
    end,
})
-- VEHICLE CATEGORIES MENU BUTTON
local btn_VehicleCategories = menu_Vehicles:AddButton({
    icon = '🚗',
    label = 'Vehicle Categories',
    value = menu_VehicleCategories,
-- disabled = true
})

--- EVENTS


-- BUCKET SELECTION
sld_Bucket:On('select', function(item, value)
    if value == 'custom' then
        isDevMode = true
        DisplayOnscreenKeyboard(1, "FMMC_MPM_NA", "", "", "", "", "", 30)
        while (UpdateOnscreenKeyboard() == 0) do
            DisableAllControlActions(0);
            Wait(0);
        end
        if (GetOnscreenKeyboardResult()) then
            local value = tostring(GetOnscreenKeyboardResult())
            if string.len(value) > 0 then
                EnterBucket(value)
                QBCore.Functions.Notify('You have entered the custom bucket: '..value..'.', 'success', 3000)
            end
        end

    elseif value == 'public' then
        isDevMode = true
        EnterBucket(value)
        QBCore.Functions.Notify('You have entered a public bucket', 'success', 3000)

    elseif value == 'private' then
        isDevMode = true
        EnterBucket()
        QBCore.Functions.Notify('You have entered a private bucket', 'success', 3000)

    elseif value == 'off' then
        ExitBuckets()
        isDevMode = false
        CurrentBucket = 'off'
    end

    btn_VehicleSpawnerMenu.Disabled = not isDevMode
    btn_FixVehicle.Disabled = not isDevMode
    btn_DeleteVehicle.Disabled = not isDevMode
    btn_MaxMods.Disabled = not isDevMode
    btn_VehicleExtrasMenu.Disabled = not isDevMode
    btn_VehicleLiveriesMenu.Disabled = not isDevMode
    MenuV:Refresh()
end)



-- VEHICLE SPAWN MODDED
chk_SpawnVehicleModded:On('change', function(item, newValue, oldValue)
    spawnVehiclesModded = newValue
end)



-- VEHICLE SPAWNER
local vehicles = {}
for k, v in pairs(QBCore.Shared.Vehicles) do
    local category = v["category"]
    if vehicles[category] == nil then
        vehicles[category] = {}
    end
    vehicles[category][k] = v
end

local function OpenCarModelsMenu(category)
    menu_VehicleModels:ClearItems()
    MenuV:OpenMenu(menu_VehicleModels)
    for k, v in pairs(category) do
        menu_VehicleModels:AddButton({
            label = v["name"] .. ' (' .. v["model"] .. ')',
            value = k,
            description = 'Spawn ' .. v["name"] .. ' (' .. v["model"] .. ')',
            select = function(_)
                SpawnCar(k)
            end
        })
    end
end

-- category > model > vehicleData
-- VEHICLE CATEGORIES
btn_VehicleCategories:On('Select', function(_)
    menu_VehicleCategories:ClearItems()
    for k, v in pairs(vehicles) do
        menu_VehicleCategories:AddButton({
            label = QBCore.Shared.FirstToUpper(k),
            value = v,
            saveOnUpdate = true,
            select = function(btn)
                local select = btn.Value
                OpenCarModelsMenu(select)
            end
        })
    end
end)

-- VEHICLE EXTRAS
btn_VehicleExtrasMenu:On('Select', function(_)
    menu_VehicleExtras:ClearItems()
    local ped = PlayerPedId()
    local veh = GetVehiclePedIsIn(ped, false)

    if veh ~= 0 then
        local extras = QBCore.Functions.GetVehicleProperties(veh).extras
        local num_extras = tablelength(QBCore.Functions.GetVehicleProperties(veh).extras)
        if num_extras >= 1 then
            for i = 1, 13, 1 do
                if extras[tostring(i)] ~= nil then
                    menu_VehicleExtras:AddCheckbox({
                        label = 'Extra ' .. tostring(i),
                        value = tostring(extras[tostring(i)]),
                        saveOnUpdate = true,
                        change = function(item, newValue, oldValue)
                            if GetPedInVehicleSeat(veh, -1) == ped then
                                SetVehicleAutoRepairDisabled(veh, true)
                                QBCore.Shared.ChangeVehicleExtra(veh, tonumber(i), newValue)
                            else
                                QBCore.Functions.Notify("Must be driver", 'error', 2500)
                            end
                        end
                    })
                end
            end
        end
    else
        menu_VehicleExtras:AddButton({
            icon = '❌',
            label = 'No Extras Available',
            disabled = true
        })
    end
end)


-- VEHICLE LIVERIES MENU
btn_VehicleLiveriesMenu:On('Select', function(_)
    menu_VehicleLiveries:ClearItems()
    local ped = PlayerPedId()
    local veh = GetVehiclePedIsIn(ped, false)
    local liveryCount = GetVehicleLiveryCount(veh)

    if not veh then
        QBCore.Functions.Notify("Not in a vehicle!", 'error', 2500)
        menu_VehicleExtras:AddButton({
            icon = '❌',
            label = 'No Liveries Available',
            disabled = true
        })
        return
    end

    if liveryCount > 1 then
        local liveryItems = {}
        local s = 1

        for i = 1, liveryCount do
            table.insert(liveryItems, s, i)
        end

        local rng_Liveries = menu_VehicleLiveries:AddRange({
            label = 'Livery',
            min = 1,
            max = GetVehicleLiveryCount(veh),
            value = GetVehicleLivery(veh),
            saveOnUpdate = true
        })

        rng_Liveries:On('change', function(item, newValue, oldValue)
            SetVehicleLivery(veh, newValue)
        end)
    elseif liveryCount <= 1 then
        local liveries = menu_VehicleLiveries:AddButton({
            icon = '❌',
            label = 'No Liveries Available',
            disabled = true
        })
    end
end)




btn_FixVehicle:On('Select', function(_)
    TriggerServerEvent('QBCore:CallCommand', "fix", {})
end)

btn_DeleteVehicle:On('Select', function(_)
    TriggerServerEvent('QBCore:CallCommand', "dv", {})
end)

btn_MaxMods:On('Select', function(_)
    local ped = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(ped, false)
    SetMaxMods(vehicle)
end)

menu_Main:On('open', function(menu)
    local ped = PlayerPedId()
    local veh = GetVehiclePedIsIn(ped, false)
    local num_extras = 0
    local num_liveries = 1

    if veh ~= 0 then
        num_extras = tablelength(QBCore.Functions.GetVehicleProperties(veh).extras)
        num_liveries = GetVehicleLiveryCount(veh)

        if num_extras > 0 then
            btn_VehicleExtrasMenu.Icon = '➕'
            btn_VehicleExtrasMenu.Label = 'Extras (' .. num_extras .. ')'
        else
            btn_VehicleExtrasMenu.Icon = '❌'
            btn_VehicleExtrasMenu.Label = 'No Extras Available'
        end

        if num_liveries > 1 then
            btn_VehicleLiveriesMenu.Icon = '🖼'
            btn_VehicleLiveriesMenu.Label = 'Liveries (' .. num_liveries .. ')'
        else
            btn_VehicleLiveriesMenu.Icon = '❌'
            btn_VehicleLiveriesMenu.Label = 'No Liveries Available'
        end
    end

    MenuV:Refresh()
end)





---------------------



function tablelength(T)
    local count = 0
    for _ in pairs(T) do count = count + 1 end
    return count
end

ShowBucketInfo = function()
    Citizen.CreateThread(function()
        repeat
            local msg = 'Current Bucket: ' .. string.upper(CurrentBucket)
            ShowDebugText(msg, 0)
            Citizen.Wait(5)
        until not isDevMode
    end)
end

SpawnCar = function(car)
    local ped = PlayerPedId()
    local hash = GetHashKey(car)
    local veh = GetVehiclePedIsUsing(ped)
    if not IsModelInCdimage(hash) then return end
    RequestModel(hash)
    while not HasModelLoaded(hash) do
        Wait(0)
    end

    if IsPedInAnyVehicle(ped) then
        DeleteVehicle(veh)
    end

    local vehicle = CreateVehicle(hash, GetEntityCoords(ped), GetEntityHeading(ped), true, false)
    table.insert(spawnedVehs, vehicle)
    TaskWarpPedIntoVehicle(ped, vehicle, -1)
    SetVehicleFuelLevel(vehicle, 100.0)
    SetVehicleDirtLevel(vehicle, 0.0)
    SetModelAsNoLongerNeeded(hash)
    if spawnVehiclesModded then SetMaxMods(vehicle) end
    TriggerEvent("vehiclekeys:client:SetOwner", QBCore.Functions.GetPlate(vehicle))
end

GiveKeys = function(plate)

end

DeleteSpawnedVehs = function()
    for k,veh in pairs(spawnedVehs) do
        if veh ~= 0 then
            SetEntityAsMissionEntity(veh, true, true)
            DeleteVehicle(veh)
        end
        spawnedVehs[k] = nil
    end
end

ExitBuckets = function()
    privateBucket = nil
    if not CurrentBucket == 'off' then DeleteSpawnedVehs() end
    TriggerServerEvent('tu-cardevmenu:server:setNamed', 0)
end

EnterBucket = function(name)
    ExitBuckets(name)
    if not name then
        local privateBucket = tostring(QBCore.Shared.RandomStr(2) .. QBCore.Shared.RandomInt(3) .. QBCore.Shared.RandomStr(1) .. QBCore.Shared.RandomInt(2) .. QBCore.Shared.RandomStr(3) .. QBCore.Shared.RandomInt(4))
        TriggerServerEvent('tu-cardevmenu:server:setNamed', privateBucket)
    else
        TriggerServerEvent('tu-cardevmenu:server:setNamed', tostring(name))
    end
    CurrentBucket = lib.callback('tu-cardevmenu:callback:getBucket', false)
    ShowBucketInfo()
end

local performanceModIndices = { 11, 12, 13, 15, 16 }
function SetMaxMods(vehicle, customWheels)
    customWheels = customWheels or false
    local max
    if DoesEntityExist(vehicle) and IsEntityAVehicle(vehicle) then
        SetVehicleModKit(vehicle, 0)
        for _, modType in ipairs(performanceModIndices) do
            max = GetNumVehicleMods(vehicle, tonumber(modType)) - 1
            SetVehicleMod(vehicle, modType, max, customWheels)
        end
        ToggleVehicleMod(vehicle, 18, true)ensure =
	SetVehicleFixed(vehicle)
    end
end

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        DeleteSpawnedVehs()
        TriggerServerEvent('tu-cardevmenu:server:setNamed', 0)
    end
end)

AddEventHandler('tu-cardevmenu:client:openMenu')
RegisterNetEvent('tu-cardevmenu:client:openMenu', function(data)
    -- MenuV:OpenMenu(menu_Main)
    menu_Main:Open()
end)


-------------  DEBUGGING  --------------
local n = 0
function ShowDebugText(text, margin)
    text = text or "No Data"
    margin = 0.12*margin or 0

    SetTextFont(0)
    SetTextProportional(1)
    SetTextScale(0.0, 0.3)
    SetTextColour(255, 50, 50, 255)
    SetTextDropshadow(0, 0, 0, 0, 255)
    SetTextEdge(1, 0, 0, 0, 255)
    SetTextDropShadow()
    SetTextOutline()
    SetTextEntry("STRING")
    AddTextComponentString(text)
    DrawText(0.005, 0.06+margin)
end


