local script_name = GetCurrentResourceName()

local function GetName(suffix)
    return script_name .. suffix
end

local function SendSecurityWebhook(source, payload)
    if not Config.Security or not Config.Security.Webhook then return end

    local webhook = Config.Security.Webhook
    if not webhook.Url or webhook.Url == '' then return end

    local playerName = GetPlayerName(source) or 'Unknown'
    local identifiers = GetPlayerIdentifiers(source)
    local steamHex = identifiers and identifiers[1] or 'N/A'

    local reason = payload.reason or 'unknown'
    local itemLabel = payload.label or payload.name or 'unknown'

    local embed = {
        {
            title = 'SSR ItemNotify Security Triggered',
            color = webhook.Color or 15158332,
            fields = {
                { name = 'Player', value = ('%s (ID: %s)'):format(playerName, source), inline = false },
                { name = 'Identifier', value = steamHex, inline = false },
                { name = 'Reason', value = reason, inline = true },
                { name = 'Item', value = itemLabel, inline = true },
                { name = 'Gain Amount', value = tostring(payload.amount or 0), inline = true },
                { name = 'Current Count', value = tostring(payload.current or 0), inline = true },
                { name = 'Events in Window', value = tostring(payload.eventCount or 0), inline = true },
                { name = 'Total in Window', value = tostring(payload.totalAmount or 0), inline = true }
            },
            footer = {
                text = ('Window: %ss'):format(tostring(payload.windowSeconds or (Config.Security.WindowSeconds or 10)))
            }
        }
    }

    PerformHttpRequest(webhook.Url, function() end, 'POST', json.encode({
        username = webhook.Name or 'SSR ItemNotify Security',
        avatar_url = webhook.AvatarUrl or '',
        embeds = embed
    }), { ['Content-Type'] = 'application/json' })
end

RegisterNetEvent(GetName(':server:security:flag'), function(payload)
    local src = source

    if not Config.Security or not Config.Security.Enabled then return end
    if type(payload) ~= 'table' then return end

    if Config.Security.Actions and Config.Security.Actions.SendWebhook then
        SendSecurityWebhook(src, payload)
    end

    if Config.Security.Actions and Config.Security.Actions.KickPlayer then
        local reason = Config.Security.KickReason or 'Security violation: abnormal item gain detected.'
        DropPlayer(src, reason)
    end
end)
