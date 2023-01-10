local QBCore = exports['qb-core']:GetCoreObject()
local instances = {}


QBCore.Commands.Add('cardev', 'Open Car Dev Menu (admin only)', {}, false, function(source, args)
    local src = source
    TriggerClientEvent("tu-cardevmenu:client:openMenu", src )
end, Config.permissionLevel)


RegisterServerEvent("tu-cardevmenu:server:set")
AddEventHandler("tu-cardevmenu:server:set", function(set)

    -- print('[INSTANCES] Instances now looked like this: ', json.encode(instances))
    local src = source

    TriggerClientEvent('DoTheBigRefreshYmaps', src)
    local instanceSource = 0
    if set then
        if set == 0 then
            for k,v in pairs(instances) do
                for k2,v2 in pairs(v) do
                    if v2 == src then
                        table.remove(v, k2)
                        if #v == 0 then
                            instances[k] = nil
                        end
                    end
                end
            end
        end
        instanceSource = set
    else

        instanceSource = math.random(1, 63)

        while instances[instanceSource] and #instances[instanceSource] >= 1 do
            instanceSource = math.random(1, 63)
            Citizen.Wait(1)
        end
    end

    print(instanceSource)

    if instanceSource ~= 0 then
        if not instances[instanceSource] then
            instances[instanceSource] = {}
        end

        table.insert(instances[instanceSource], src)
    end

    SetPlayerRoutingBucket(
        src --[[ string ]],
        instanceSource
    )
    -- print('[INSTANCES] Instances now looks like this: ', json.encode(instances))
end)

Namedinstances = {}


RegisterServerEvent("tu-cardevmenu:server:setNamed")
AddEventHandler("tu-cardevmenu:server:setNamed", function(setName)

    -- print('[INSTANCES] Named Instances looked like this: ', json.encode(Namedinstances))
    local src = source
    local instanceSource = nil

    TriggerClientEvent('DoTheBigRefreshYmaps', src)

    if setName == 0 then
            for k,v in pairs(Namedinstances) do
                for k2,v2 in pairs(v.people) do
                    if v2 == src then
                        table.remove(v.people, k2)
                    end
                end
                if #v.people == 0 then
                    Namedinstances[k] = nil
                end
            end
        instanceSource = setName

    else
        for k,v in pairs(Namedinstances) do
            if v.name == setName then
                instanceSource = k
            end
        end

        if instanceSource == nil then
            instanceSource = math.random(1, 63)

            while Namedinstances[instanceSource] and #Namedinstances[instanceSource] >= 1 do
                instanceSource = math.random(1, 63)
                Citizen.Wait(1)
            end
        end
    end

    if instanceSource ~= 0 then

        if not Namedinstances[instanceSource] then
            Namedinstances[instanceSource] = {
                name = setName,
                people = {}
            }
        end

        table.insert(Namedinstances[instanceSource].people, src)

    end

    SetPlayerRoutingBucket(
        src --[[ string ]],
        instanceSource
    )
    -- print('[INSTANCES] Named Instances now look like this: ', json.encode(Namedinstances))
end)