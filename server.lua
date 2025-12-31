local QBCore = exports['qb-core']:GetCoreObject()
local playerData = {}
local playerLock = {}
local claimDebounce = {}

AddEventHandler('QBCore:Server:PlayerLoaded', function(Player)
    local src = Player.PlayerData.source
    local identifier = Player.PlayerData.citizenid
    if not identifier then
        return
    end
    playerLock[src] = false
    exports.oxmysql:fetch('SELECT day, lastClaim FROM daily_rewards WHERE identifier = ?', {identifier}, function(result)
        if not result or #result == 0 then
            exports.oxmysql:insert('INSERT INTO daily_rewards (identifier, day, lastClaim) VALUES (?, ?, ?)', {identifier, 1, 0}, function(insertId)
                if insertId then
                    playerData[src] = { day = 1, lastClaim = 0 }
                else
                    TriggerClientEvent("QBCore:Notify", src, "Veri yükleme hatası", "error")
                end
            end)
        else
            playerData[src] = { day = result[1].day, lastClaim = result[1].lastClaim }
        end
    end)
end)

RegisterNetEvent("daily_rewards:requestOpenUI", function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then
        TriggerClientEvent("QBCore:Notify", src, "Oturum bulunamadı", "error")
        return
    end
    if playerData[src] then
        TriggerClientEvent("daily_rewards:openUI", src, {day = playerData[src].day,lastClaim = playerData[src].lastClaim})
    else
        TriggerClientEvent("daily_rewards:openUI", src, { day = 1, lastClaim = 0 })
    end
end)

RegisterNetEvent("daily_rewards:claimReward", function()
    local src = source
    local now = os.time()
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then
        TriggerClientEvent("QBCore:Notify", src, "Oyuncu bulunamadı", "error")
        return
    end
    local identifier = Player.PlayerData.citizenid
    if not identifier then
        TriggerClientEvent("QBCore:Notify", src, "Kimlik doğrulaması başarısız", "error")
        return
    end
    if playerLock[src] then
        TriggerClientEvent("QBCore:Notify", src, "Lütfen bekleyin", "error")
        return
    end
    if claimDebounce[src] and (now - claimDebounce[src]) < 2 then
        TriggerClientEvent("QBCore:Notify", src, "Çok hızlı denediniz", "error")
        return
    end
    claimDebounce[src] = now
    local p = playerData[src]
    if not p then
        TriggerClientEvent("QBCore:Notify", src, "Veriler yüklenmedi", "error")
        return
    end
    local diff = now - (p.lastClaim or 0)
    local cooldown = Config.DailyRewards.Cooldowns[p.day] or (24 * 60 * 60)
    if diff < cooldown then
        local remainingHours = math.ceil((cooldown - diff) / 3600)
        TriggerClientEvent("QBCore:Notify", src, remainingHours .. " saat sonra tekrar deneyebilirsiniz", "error")
        TriggerClientEvent("daily_rewards:updateUI", src, p)
        return
    end
    playerLock[src] = true
    local rewardAmount = Config.DailyRewards.Rewards[p.day] or Config.DailyRewards.Rewards[1]
    Player.Functions.AddMoney("cash", rewardAmount, "Günlük ödül")
    p.lastClaim = now
    p.day = p.day + 1
    if p.day > 7 then p.day = 1 end
    exports.oxmysql:execute('UPDATE daily_rewards SET day = ?, lastClaim = ? WHERE identifier = ?',{p.day, p.lastClaim, identifier},
        function(rowsChanged)
            playerLock[src] = false
            if not rowsChanged or rowsChanged == 0 then
                Player.Functions.RemoveMoney("cash", rewardAmount, "Günlük ödül iptal")
                p.lastClaim = now - cooldown
                p.day = p.day - 1
                if p.day < 1 then p.day = 7 end
                TriggerClientEvent("QBCore:Notify", src, "İşlem başarısız, tekrar deneyin", "error")
                return
            end
            TriggerClientEvent("QBCore:Notify", src, "Ödül alındı! +" .. rewardAmount .. "$", "success")
            TriggerClientEvent("daily_rewards:updateUI", src, p)
        end
    )
end)

RegisterNetEvent("daily_rewards:checkTime", function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then
        return
    end
    if playerData[src] then
        TriggerClientEvent("daily_rewards:updateUI", src, playerData[src])
    end
end)

AddEventHandler('playerDropped', function()
    local src = source
    playerData[src] = nil
    playerLock[src] = nil
    claimDebounce[src] = nil
end)
