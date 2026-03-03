script_name = GetCurrentResourceName()
GetName = function(a) return script_name .. a end;
RegisEvent = function(b, a, c)
    if b then RegisterNetEvent(a) end
    AddEventHandler(a, c)
end;
ESX = nil;
xZero = {}
xZero.Hooks = {}
_Inventory = {}
_Accounts = {}
_Money = nil;

_securityGains = {}

local function CleanupSecurityWindow(nowMs)
    local windowMs = (Config.Security.WindowSeconds or 10) * 1000
    while #_securityGains > 0 and (nowMs - _securityGains[1].time) > windowMs do
        table.remove(_securityGains, 1)
    end
end

local function CheckAbnormalGain(itemName, itemLabel, gainAmount, currentCount)
    if not Config.Security or not Config.Security.Enabled then return end
    if not gainAmount or gainAmount <= 0 then return end

    local nowMs = GetGameTimer()
    CleanupSecurityWindow(nowMs)

    if Config.Security.Checks and Config.Security.Checks.SingleGain and gainAmount >= (Config.Security.MaxSingleGain or 100) then
        TriggerServerEvent(GetName(':server:security:flag'), {
            reason = 'single_gain_limit',
            name = itemName,
            label = itemLabel,
            amount = gainAmount,
            current = currentCount,
            eventCount = 1,
            totalAmount = gainAmount,
            windowSeconds = Config.Security.WindowSeconds or 10
        })
        return
    end

    table.insert(_securityGains, {
        time = nowMs,
        amount = gainAmount,
        name = itemName,
        label = itemLabel
    })

    local eventCount = #_securityGains
    local totalAmount = 0
    for _, gain in ipairs(_securityGains) do
        totalAmount = totalAmount + gain.amount
    end

    local burstEventsTriggered = Config.Security.Checks and Config.Security.Checks.BurstEvents and eventCount >= (Config.Security.MaxGainEvents or 15)
    local burstAmountTriggered = Config.Security.Checks and Config.Security.Checks.BurstAmount and totalAmount >= (Config.Security.MaxGainAmount or 200)

    if burstEventsTriggered or burstAmountTriggered then
        TriggerServerEvent(GetName(':server:security:flag'), {
            reason = burstEventsTriggered and 'rapid_gain_events' or 'rapid_gain_amount',
            name = itemName,
            label = itemLabel,
            amount = gainAmount,
            current = currentCount,
            eventCount = eventCount,
            totalAmount = totalAmount,
            windowSeconds = Config.Security.WindowSeconds or 10
        })
    end
end




local function NormalizeWeaponData(weaponArg, ammoArg)
    local weaponName = weaponArg
    local ammo = ammoArg

    if type(weaponArg) == 'table' then
        weaponName = weaponArg.name or weaponArg.weaponName or weaponArg.weapon
        ammo = weaponArg.ammo or ammoArg or 0
    end

    if type(weaponName) ~= 'string' then
        weaponName = tostring(weaponName or 'unknown_weapon')
    end

    local weaponLabel = ESX.GetWeaponLabel(weaponName)
    if not weaponLabel then
        weaponLabel = weaponName
    end

    return weaponName, weaponLabel, ammo or 0
end

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
	while ESX.GetPlayerData() == nil do Wait(1) end
	while true do
		if ESX.GetPlayerData().inventory and #ESX.GetPlayerData().inventory >
			0 then break end
		Wait(1)
	end
	Run()
end)

Run = function()
    if ESX.GetPlayerData().inventory then
        for g, h in ipairs(ESX.GetPlayerData().inventory) do
            _Inventory[h.name] = {label = h.label, count = h.count}
        end
    else
        print('^1Cahce Inventory NULL^7')
    end
    if ESX.GetPlayerData().accounts then
        for g, h in ipairs(ESX.GetPlayerData().accounts) do
            _Accounts[h.name] = h.money
        end
    else
        print('^1Cahce Accounts NULL^7')
    end
    if Config.es_extended_old then
        _Money = ESX.GetPlayerData().money;
        xZero.Hooks.Accounts_Request()
    end

    RegisterNetEvent('esx:addWeapon')
    AddEventHandler('esx:addWeapon', function(weaponName, ammo)
        if not Config.WeaponAdd_Notify then return end

        local normalizedName, normalizedLabel, normalizedAmmo = NormalizeWeaponData(weaponName, ammo)
        NUI_Notify(normalizedLabel, normalizedName, tonumber(normalizedAmmo) or 1, 'added')
    end)

    RegisterNetEvent('esx:removeWeapon')
    AddEventHandler('esx:removeWeapon', function(weaponName, ammo)
        if not Config.WeaponRemove_Notify then return end

        local normalizedName, normalizedLabel, normalizedAmmo = NormalizeWeaponData(weaponName, ammo)
        local removedAmount = (ammo == nil) and 1 or (tonumber(normalizedAmmo) or 1)
        NUI_Notify(normalizedLabel, normalizedName, removedAmount, 'remove')
    end)

    RegisterNetEvent('esx:addWeaponItem')
    AddEventHandler('esx:addWeaponItem', function(weaponName, ammo)
        if not Config.WeaponAdd_Notify then return end

        local normalizedName, normalizedLabel, normalizedAmmo = NormalizeWeaponData(weaponName, ammo)
        NUI_Notify(normalizedLabel, normalizedName, tonumber(normalizedAmmo) or 1, 'added')
    end)

    RegisterNetEvent('esx:removeWeaponItem')
    AddEventHandler('esx:removeWeaponItem', function(weaponName, ammo)
        if not Config.WeaponRemove_Notify then return end

        local normalizedName, normalizedLabel, normalizedAmmo = NormalizeWeaponData(weaponName, ammo)
        local removedAmount = (ammo == nil) and 1 or (tonumber(normalizedAmmo) or 1)
        NUI_Notify(normalizedLabel, normalizedName, removedAmount, 'remove')
    end)
    RegisEvent(true, 'esx:addInventoryItem', function(l, m)
        if l then
            if type(l) == 'table' then
                m = l.count;
                l = l.name or nil
            end
            if _Inventory and _Inventory[l] then
                local n = _Inventory[l] or nil;
                local o = m - n.count;
                _Inventory[l].count = m;
                if o > 0 then
                    NUI_Notify(n.label, l, o, 'added', m)
                    CheckAbnormalGain(l, n.label, o, m)
                end
            end
        end
    end)
    RegisEvent(true, 'esx:removeInventoryItem', function(l, m)
        if l then
            if type(l) == 'table' then
                m = l.count;
                l = l.name or nil
            end
            if _Inventory and _Inventory[l] then
                local n = _Inventory[l]
                local o = n.count - m;
                _Inventory[l].count = m;
                if o > 0 then NUI_Notify(n.label, l, o, 'remove', m) end
            end
        end
    end)
    RegisEvent(true, 'esx:setAccountMoney', function(p)
        if _Accounts and _Accounts[p.name] then
            local _Money = _Accounts[p.name]
            local q = p.money > _Money and 'added' or 'remove'
            local o = q == 'added' and p.money - _Money or _Money - p.money;
            _Accounts[p.name] = p.money;
            if o > 0 then NUI_Notify(p.label, p.name, o, q, p.money) end
        else
            _Accounts[p.name] = p.money;
            print('^2Cache Add Account | ' .. p.name .. ' | ' .. p.money .. '^7')
        end
    end)
    if Config.es_extended_old then
        RegisEvent(true, 'es:activateMoney', function(r)
            if r and type(r) == 'number' and _Money ~= nil then
                local q = r > _Money and 'added' or 'remove'
                local o = q == 'added' and r - _Money or _Money - r;
                _Money = r;
                if o > 0 then NUI_Notify('Cash', 'cash', o, q, r) end
            end
        end)
    end

end
xZero.Hooks.Accounts_Request = function()
    RegisEvent(true, GetName(':client:Accounts:Receive'), function(w)
        if w then
            for g, h in ipairs(w) do _Accounts[h.name] = h.money end
            print(('^2Cache Account Receive:%s^7'):format(#w))
        end
    end)
    Wait(500)
    TriggerServerEvent(GetName(':server:Accounts:Request'))
end;
function NUI_Notify(x, l, y, type, remaining)
    SendNUIMessage({
        action = "notify",
        label = x,
        name = l,
        count = y,
        type = type,
        remaining = remaining
    })
end
