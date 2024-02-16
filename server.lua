local Tunnel = module("vrp", "lib/Tunnel")
local Proxy = module("vrp", "lib/Proxy")

vRP = Proxy.getInterface("vRP")
vRPclient = Tunnel.getInterface("vRP","Dallefar")



local cooldowns = {}  -- cooldown

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

            -- Check if the player is within the proximity range
            if distance <= proximityRange then
                -- Send the message only to players within proximity
                TriggerClientEvent('chat:addMessage', targetSource, {
                    template = '<div style="display: inline-block; padding: 0.5vw; margin: 0.5vw; background-color: rgba(39, 34, 37, 0.8); border-radius: 3px;"><strong>OOC fra ' .. steamName .. '</strong><br>' .. fullMessage .. '<br></div>',
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

        vRP.getUserIdentity({user_id, function(identity)  -- Fix here
            if identity then
                local playerName = identity.firstname .. " " .. identity.name  -- Get player name correctly

                local currentTime = os.time() - 3 -- 3 sek

                if cooldowns[user_id] == nil or currentTime - cooldowns[user_id] >= 3 then
                    cooldowns[user_id] = currentTime  -- Update cooldown tid

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
                        text = 'Du skal vente med at sende en bedsked mere',
                        type = "info",
                        position = "top-right"
                    })
                end
            end
        end})
    end
end, false)


--[[ -- Job bedskeder -- 

AddEventHandler('chatMessage', function(source, name, message)
        splitmessage = stringsplit(message, " ");

        if string.lower(splitmessage[1]) == "/pa" then
            local user_id = vRP.getUserId({source})

            CancelEvent()

            local playerName = GetPlayerName(source)

        if vRP.hasGroup({user_id,"Politi-Job"}) then
            TriggerClientEvent('chat:addMessage', -1, {
                template = '<div style="font-family:Courier New; padding: 0.5vw; margin: 0.5vw; background-color: rgba(7, 85, 188, 0.6); border-radius: 3px;"></i><strong>👮 Besked fra Politiet</strong><br> '.. string.sub(message,string.len(splitmessage[1])+1)..'<br></div>',
                args = { fal, msg }
            })

        
            local payload = {
                embeds = {{
                    title = "Politi bedskeder Logs",
                    description = string.format("**ID:%s**  \n\n**Skrev en besked som Politi:**%s", user_id, string.sub(message, string.len(splitmessage[1]) + 1)),
                    color = 3447003,

                }}
            }
            
            
            PerformHttpRequest(config.Politi, function(err, text, headers) end, 'POST', json.encode(payload), { ['Content-Type'] = 'application/json' })
        else
            TriggerClientEvent("pNotify:SendNotification", source,{
                text = 'Du er ikke Politi',
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
            --TriggerClientEvent('mythic_notify:client:SendAlert', source, { type = 'error', text = 'Du er ikke Politi', length = 2500})
            end
        end
    end, false)

        AddEventHandler('chatMessage', function(source, name, message)
            splitmessage = stringsplit(message, " ");

            if string.lower(splitmessage[1]) == "/ems" then
                local user_id = vRP.getUserId({source})
                CancelEvent()
            local playerName = GetPlayerName(source)
        if vRP.hasGroup({user_id,"EMS-Job"}) then
            TriggerClientEvent('chat:addMessage', -1, {
                template = '<div style="padding: 0.5vw; margin: 0.5vw; background-color: rgba(246, 246, 63, 0.6); border-radius: 3px;"></i><strong>👨‍⚕️ Besked fra Sundhedsvæsenet</strong><br> '.. string.sub(message,string.len(splitmessage[1])+1)..'<br></div>',
                args = { fal, msg }
            })

            local payload = {
                embeds = {{
                    title = "Læge bedskeder Logs",
                    description = string.format("**ID:%s**  \n\n**skrev en EMS besked:**%s", user_id, string.sub(message, string.len(splitmessage[1]) + 1)),
                    color = 16776960,

                }}
            }
            
            
            PerformHttpRequest(config.ems, function(err, text, headers) end, 'POST', json.encode(payload), { ['Content-Type'] = 'application/json' })
        else
            TriggerClientEvent("pNotify:SendNotification", source,{
                text = 'Du er ikke Læge',
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
            --TriggerClientEvent('mythic_notify:client:SendAlert', source, { type = 'error', text = 'Du er ikke EMS', length = 2500})
            end
        end
        end, false)

        AddEventHandler('chatMessage', function(source, name, message)
            splitmessage = stringsplit(message, " ");

            if string.lower(splitmessage[1]) == "/staffa" then
                local user_id = vRP.getUserId({source})
                CancelEvent()
            local playerName = GetPlayerName(source)
        if vRP.hasGroup({user_id,"ledelse"}) then
            TriggerClientEvent('chat:addMessage', -1, {
                template = '<div style="padding: 0.5vw; margin: 0.5vw; background-color: rgba(255, 0, 0, 0.6); border-radius: 3px;"></i><strong>💂‍♂️ Besked fra Staff</strong><br> '.. string.sub(message,string.len(splitmessage[1])+1)..'<br></div>',
                args = { fal, msg }
            })

            local payload = {
                embeds = {{
                    title = "Staff bedskeder Logs",
                    description = string.format("**ID:%s**  \n\n**skrev en Staff besked:**%s", user_id, string.sub(message, string.len(splitmessage[1]) + 1)),
                    color = 15548997,

                }}
            }
            
            
            PerformHttpRequest(config.Staff, function(err, text, headers) end, 'POST', json.encode(payload), { ['Content-Type'] = 'application/json' })
        else
            TriggerClientEvent("pNotify:SendNotification", source,{
                text = 'Du er ikke Staff',
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
            --TriggerClientEvent('mythic_notify:client:SendAlert', source, { type = 'error', text = 'Du er ikke Staff', length = 2500})
            end
        end
        end, false)

AddEventHandler('chatMessage', function(source, name, message)
    splitmessage = stringsplit(message, " ");

    if string.lower(splitmessage[1]) == "/bil" then
        local user_id = vRP.getUserId({source})
        CancelEvent()
    local playerName = GetPlayerName(source)
   if vRP.hasGroup({user_id,"Bilforhandler"}) then
    TriggerClientEvent('chat:addMessage', -1, {
        template = '<div style="padding: 0.5vw; margin: 0.5vw; background-color: rgba(255, 0, 255, 1); border-radius: 3px;"></i><strong>🚗 Besked fra bilforhandler</strong><br> '.. string.sub(message,string.len(splitmessage[1])+1)..'<br></div>',
        args = { fal, msg }
    })

    local payload = {
        embeds = {{
            title = "Bilforhandler bedskeder Logs",
            description = string.format("**ID:%s**  \n\n**skrev en Bilforhandler besked:**%s", user_id, string.sub(message, string.len(splitmessage[1]) + 1)),
            color = 10038562,

        }}
    }
    
    
    PerformHttpRequest(config.Bilforhandler, function(err, text, headers) end, 'POST', json.encode(payload), { ['Content-Type'] = 'application/json' })
else
    TriggerClientEvent("pNotify:SendNotification", source,{
        text = 'Du er ikke Bilforhandler',
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
    --TriggerClientEvent('mythic_notify:client:SendAlert', source, { type = 'error', text = 'Du er ikke Bilforhandler', length = 2500})
      end
   end
end, false)

        AddEventHandler('chatMessage', function(source, name, message)
            splitmessage = stringsplit(message, " ");

            if string.lower(splitmessage[1]) == "/mek" then
                local user_id = vRP.getUserId({source})
                CancelEvent()
            local playerName = GetPlayerName(source)
        if vRP.hasGroup({user_id,"Mekaniker"}) then
            TriggerClientEvent('chat:addMessage', -1, {
                template = '<div style="padding: 0.5vw; margin: 0.5vw; background-color: rgba(0, 255, 255, 0.8); border-radius: 3px;"></i><strong>👨‍🔧 Besked fra Mekaniker</strong><br> '.. string.sub(message,string.len(splitmessage[1])+1)..'<br></div>',
                args = { fal, msg }
            })

            local payload = {
                embeds = {{
                    title = "Mekaniker bedskeder Logs",
                    description = string.format("**ID:%s**  \n\n**skrev en Mekaniker besked:**%s", user_id, string.sub(message, string.len(splitmessage[1]) + 1)),
                    color = 11027200,
        
                }}
            }
            
            
            PerformHttpRequest(config.Mekaniker, function(err, text, headers) end, 'POST', json.encode(payload), { ['Content-Type'] = 'application/json' })
        else
            TriggerClientEvent("pNotify:SendNotification", source,{
                text = 'Du er ikke Mekaniker',
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
            --TriggerClientEvent('mythic_notify:client:SendAlert', source, { type = 'error', text = 'Du er ikke Mekaniker', length = 2500})
            end
        end
        end, false) ]]

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


