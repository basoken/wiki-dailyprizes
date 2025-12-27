local QBCore = exports['qb-core']:GetCoreObject()
local playerData = {}

AddEventHandler('QBCore:Server:PlayerLoaded', function(Player)
    local src = Player.PlayerData.source
    local identifier = Player.PlayerData.citizenid
    if not identifier then
        return
    end
    exports.oxmysql:fetch('SELECT day, lastClaim FROM daily_rewards WHERE identifier = ?', {identifier}, function(result)
        local day, lastClaim
        if result[1] then
            day = result[1].day
            lastClaim = result[1].lastClaim
        else
            day = 1
            lastClaim = 0
            exports.oxmysql:insert('INSERT INTO daily_rewards (identifier, day, lastClaim) VALUES (?, ?, ?)', {identifier, 1, 0})
        end

        playerData[src] = { day = day, lastClaim = lastClaim }
    end)
end)

RegisterNetEvent("daily_rewards:requestOpenUI", function()
    local src = source
    if playerData[src] then
        TriggerClientEvent("daily_rewards:openUI", src, playerData[src])
    else
        TriggerClientEvent("daily_rewards:openUI", src, { day = 1, lastClaim = 0 })
    end
end)

RegisterNetEvent("daily_rewards:claimReward", function()
    local src = source
    local p = playerData[src]
    if not p then return end
    local now = os.time()
    local diff = now - (p.lastClaim or 0)
    local cooldown = Config.DailyRewards.Cooldowns[p.day] or (24 * 60 * 60)
    if diff < cooldown then
        local remainingHours = math.ceil((cooldown - diff) / 3600)
        TriggerClientEvent("daily_rewards:notify", src, remainingHours .. " saat kaldı", "error")
        TriggerClientEvent("daily_rewards:updateUI", src, p)
        return
    end
    local Player = QBCore.Functions.GetPlayer(src)
    local amount = Config.DailyRewards.Rewards[p.day] or 2500
    Player.Functions.AddMoney("cash", amount, "Günlük ödül")
    p.lastClaim = now
    p.day = p.day + 1
    if p.day > 7 then p.day = 1 end
    local identifier = Player.PlayerData.citizenid
    if identifier then
        exports.oxmysql:execute(
            'UPDATE daily_rewards SET day = ?, lastClaim = ? WHERE identifier = ?',
            {p.day, p.lastClaim, identifier}
        )
    end
    TriggerClientEvent("daily_rewards:notify", src, "Ödül alındı! +" .. amount .. "$", "success")
    TriggerClientEvent("daily_rewards:updateUI", src, p)
end)
