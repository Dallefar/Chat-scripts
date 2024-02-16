local Tunnel = module("vrp", "lib/Tunnel")
local Proxy = module("vrp", "lib/Proxy")

vRP = Proxy.getInterface("vRP")
vRPclient = Tunnel.getInterface("vRP","Dallefar")



local cooldowns = {}  -- cooldown

-- Mobile pay command -- 

RegisterServerEvent('bank:transfer2')
AddEventHandler('bank:transfer2', function(target_id, amountt) -- Pass the user ID as the first parameter
    local user_id = vRP.getUserId({source})
    print("User ID: ".. user_id)
    local tsource = vRP.getUserSource({target_id})
    if tsource ~= nil then
        local balance = vRP.getBankMoney({user_id})
        local target_balance = vRP.getBankMoney({target_id})

        if tonumber(user_id) == tonumber(target_id) then
            print(("User %s attempted to transfer money to themselves"):format(user_id))
            TriggerClientEvent('chatMessage', source, "Du kan ikke selv overføre penge.")
        else
            if balance <= 0 or balance < tonumber(amountt) or tonumber(amountt) <= 0 then
                print(("User %s does not have sufficient funds to transfer %s"):format(user_id, amountt))
                TriggerClientEvent('chatMessage', source, "Du har ikke penge nok i banken.")
            else
                local user_bank = vRP.getBankMoney({user_id})
                user_bank = user_bank - amountt
                vRP.setBankMoney({user_id, user_bank})

                local target_bank = vRP.getBankMoney({target_id})
                target_bank = target_bank + amountt
                vRP.setBankMoney({target_id, target_bank})

                print(("User %s transferred %s to player ID %s"):format(user_id, amountt, target_id))
                
                -- Send a webhook notification
                local payload = {
                    content = string.format("**User %s transferred %s DKK to player ID %s**", user_id, amountt, target_id)
                }
                PerformHttpRequest(config.mobilepay, function(statusCode, response, headers) end, 'POST', json.encode(payload), { ['Content-Type'] = 'application/json' })
            end
        end
    else
        print(("Player ID %s is not connected"):format(target_id))
        TriggerClientEvent('chatMessage', source, "Spilleren er ikke tilsluttet.")
    end
end)



-- ooc -- 

if config.useooc == true then
    AddEventHandler('chatMessage', function(source, name, message)
        local splitmessage = stringsplit(message, " ")
    
        if string.lower(splitmessage[1]) == "/ooc" then
            table.remove(splitmessage, 1)
    
            local fullMessage = table.concat(splitmessage, " ")
    
            local steamName = GetPlayerName(source)
    
            local players = GetPlayers()
    
            for _, player in ipairs(players) do
                local targetSource = tonumber(player)
    
                -- Send the message to all online players
                TriggerClientEvent('chat:addMessage', targetSource, {
                    template = '<div style="display: inline-block; padding: 0.5vw; margin: 0.5vw; background-color: rgba(39, 34, 37, 0.8); border-radius: 3px;"><strong>OOC fra ' .. steamName .. '</strong><br>' .. fullMessage .. '<br></div>',
                    args = {}
                })
            end
    
            CancelEvent()
        end
    end)
    end

-- ool -- 

AddEventHandler('chatMessage', function(source, name, message)
    local splitmessage = stringsplit(message, " ")

    if string.lower(splitmessage[1]) == "/ool" then
        -- Remove the command from the message
        table.remove(splitmessage, 1)

        -- Concatenate the message parts into a single string
        local fullMessage = table.concat(splitmessage, " ")

        -- Get the player's Steam name
        local steamName = GetPlayerName(source)

        -- Get all online players
        local players = GetPlayers()

        -- Loop through players to check their distance
        for _, player in ipairs(players) do
            local targetSource = tonumber(player)
            local targetCoords = GetEntityCoords(GetPlayerPed(targetSource))

            -- Calculate distance between players
            local distance = #(GetEntityCoords(GetPlayerPed(source)) - targetCoords)

            -- Set the proximity range, adjust as needed
            local proximityRange = 20.0
            local userid = vRP.getUserId({source})

            -- Check if the player is within the proximity range
            if distance <= proximityRange then
                -- Send the message only to players within proximity
                TriggerClientEvent('chat:addMessage', targetSource, {
                    template = '<div style="display: inline-block; padding: 0.5vw; margin: 0.5vw; background-color: rgba(39, 34, 37, 0.8); border-radius: 3px;"><strong>OOC fra ' .. steamName .. ' | '.. userid ..'</strong><br>' .. fullMessage .. '<br></div>',
                    args = {}
                })
            end
        end

        -- Cancel the chat event to prevent the message from being sent twice
        CancelEvent()
    end
end)

-- Twitter -- 

AddEventHandler('chatMessage', function(source, name, message)
    local splitmessage = stringsplit(message, " ");

    if string.lower(splitmessage[1]) == "/twt" then
        local user_id = vRP.getUserId({source})
        CancelEvent()

        vRP.getUserIdentity({user_id, function(identity)
            if identity then
                local playerName = identity.firstname .. " " .. identity.name

                if playerName ~= "Skift Dit Navn" then
                    local currentTime = os.time() - 3 -- 3 sek

                    if cooldowns[user_id] == nil or currentTime - cooldowns[user_id] >= 3 then
                        if #message > string.len(splitmessage[1]) + 1 then
                            cooldowns[user_id] = currentTime

                            TriggerClientEvent('chat:addMessage', -1, {
                                template = '<div style="display: inline-block; padding: 0.5vw; margin: 0.5vw; background-color: rgba(0, 153, 204); border-radius: 3px;"><strong>Twitter fra ' .. playerName .. '</strong><br>' .. string.sub(message, string.len(splitmessage[1]) + 1) .. '<br></div>',
                                args = {}
                            })

                            local payload = {
                                embeds = {{
                                    title = "Twitter Logs",
                                    description = string.format("**ID:%s**  \n\n**Skrev en besked i Twitter:**%s", user_id, string.sub(message, string.len(splitmessage[1]) + 1)),
                                    color = 1752220,
                                }}
                            }

                            PerformHttpRequest(config.Twitter, function(err, text, headers) end, 'POST', json.encode(payload), { ['Content-Type'] = 'application/json' })
                        else
                            TriggerClientEvent("pNotify:SendNotification", source,{
                                title = "Twitter",
                                text = 'Du kan ikke sende en tom besked',
                                type = "error",
                                position = "top-right"
                            })
                        end
                    else
                        TriggerClientEvent("pNotify:SendNotification", source,{
                            title = "Twitter",
                            text = 'Du skal vente med at sende en besked mere',
                            type = "info",
                            position = "top-right"
                        })
                    end
                else
                    TriggerClientEvent("pNotify:SendNotification", source,{
                        title = "Twitter",
                        text = 'Du skal skift navn få at bruge twitter',
                        type = "error",
                        position = "top-right"
                    })
                end
            end
        end})
    end
end, false)

-- Job bedskeder -- 

AddEventHandler('chatMessage', function(source, name, message)
    local splitmessage = stringsplit(message, " ")

    for _, command in ipairs(config.jobscmd) do
        if string.lower(splitmessage[1]) == command.cmd then
            local user_id = vRP.getUserId({source})

            CancelEvent()

            local playerName = GetPlayerName(source)

            -- Check if the user belongs to the specified job for this command
            if vRP.hasGroup({user_id, command.job}) then
                TriggerClientEvent('chat:addMessage', -1, {
                    template = string.format('<div style="display: inline-block; padding: 0.5vw; margin: 0.5vw; background-color: %s; border-radius: 3px;"></i><strong>%s</strong><br> %s<br></div>', command.color, command.chattext, string.sub(message, string.len(splitmessage[1]) + 1)),
                    args = {}
                })

                local payload = {
                    embeds = {{
                        title = command.webhookname .. " bedskeder Logs",
                        description = string.format("**ID:%s**  \n\n**Skrev en besked som %s:**%s", user_id, command.job, string.sub(message, string.len(splitmessage[1]) + 1)),
                        color = 3447003,
                    }}
                }

                PerformHttpRequest(command.webhook, function(err, text, headers) end, 'POST', json.encode(payload), { ['Content-Type'] = 'application/json' })
            else
                TriggerClientEvent("pNotify:SendNotification", source, {
                    text = 'Du er ikke ' .. command.job,
                    type = "info",
                    timeout = 7000,
                    layout = "bottomright",
                    queue = "global",
                    animation = {open = "gta_effects_fade_in", close = "gta_effects_fade_out"},
                    sounds = {
                        sources = {sound},
                        volume = volume,
                        conditions = {"docVisible"}
                    }
                })
            end
            break -- Exit the loop once a command is found
        end
    end
end, false)

 

-- Test navne scirpt -- 

--[[ AddEventHandler('chatMessage', function(source, name, message)
    local splitmessage = stringsplit(message, " ");

    local user_id = vRP.getUserId({source})
    if string.lower(splitmessage[1]) == "/navn" then
        vRP.getUserIdentity({user_id, function(identity)
            if identity then
                print(identity.firstname .. " " .. identity.name)
            else
                print("kan ikke finde navn")
            end
        end})   
    end
end, false)
 ]]
-- vRP.getUserIdentity({source, function(identity)

function stringsplit(inputstr, sep)
    if sep == nil then
        sep = "%s"
    end
    local t={} ; i=1
    for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
        t[i] = str
        i = i + 1
    end
    return t
end
