-- ool -- 

RegisterNetEvent('esx_rpchat:sendProximityMessage')
AddEventHandler('esx_rpchat:sendProximityMessage', function(targetPlayerId, title, message)
    local player = source -- Get the source player ID
    local steamName = GetPlayerName(player)
    local target = GetPlayerFromServerId(targetPlayerId)
    
    local playerPed = PlayerPedId()
    local targetPed = GetPlayerPed(target)
    local playerCoords = GetEntityCoords(playerPed)
    local targetCoords = GetEntityCoords(targetPed)

    if target ~= nil then
        if target == player or #(playerCoords - targetCoords) < 20 then
            TriggerClientEvent('chat:addMessage', target, {
                template = '<div style="display: inline-block; padding: 0.5vw; margin: 0.5vw; background-color: rgba(0, 153, 204); border-radius: 3px;"><strong>Twitter fra ' .. steamName .. '</strong><br>' .. message .. '<br></div>',
                args = {}
            })  
        end
    end
end)



-- Bars -- 

CinematicCamCommand = "bars" 

CinematicCamMaxHeight = 0.4 


CinematicCamBool = false

w = 0

RegisterCommand(CinematicCamCommand, function()
    CinematicCamBool = not CinematicCamBool
    CinematicCamDisplay(CinematicCamBool)
end)


Citizen.CreateThread(function()

    minimap = RequestScaleformMovie("minimap")

    if not HasScaleformMovieLoaded(minimap) then
        RequestScaleformMovie(minimap)
        while not HasScaleformMovieLoaded(minimap) do 
            Wait(1)
        end
    end

    while true do
        Citizen.Wait(1)
        if w > 0 then
            DrawRects()
        end
        if CinematicCamBool then
            DESTROYHudComponents()
        end
    end
end)

function DESTROYHudComponents()
    for i = 0, 22, 1 do
        if IsHudComponentActive(i) then
            HideHudComponentThisFrame(i)
        end
    end
end

function DrawRects()
    DrawRect(0.0, 0.0, 2.0, w, 0, 0, 0, 255)
    DrawRect(0.0, 1.0, 2.0, w, 0, 0, 0, 255)
end

function DisplayHealthArmour(int)
    BeginScaleformMovieMethod(minimap, "SETUP_HEALTH_ARMOUR")
    ScaleformMovieMethodAddParamInt(int)
    EndScaleformMovieMethod()
end

function CinematicCamDisplay(bool)
    SetRadarBigmapEnabled(true, false)
    Wait(0)
    SetRadarBigmapEnabled(false, false)
    if bool then
        DisplayRadar(false)
        DisplayHealthArmour(3)
        for i = 0, CinematicCamMaxHeight, 0.01 do 
            Wait(10)
            w = i
        end
    else
        DisplayRadar(true)
        DisplayHealthArmour(0)
        for i = CinematicCamMaxHeight, 0, -0.01 do
            Wait(10)
            w = i
        end 
    end
end    

-- Clear chat -- 

RegisterCommand('clear', function(source, args)
    TriggerEvent('chat:clear')
end, false)