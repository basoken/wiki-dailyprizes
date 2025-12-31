local QBCore = exports['qb-core']:GetCoreObject()

RegisterNetEvent("daily_rewards:openUI", function(data)
    SetNuiFocus(true, true)
    local safeData = {
        day = data.day,
        lastClaim = data.lastClaim
    }
    SendNUIMessage({ action = "openUI", rewardData = safeData })
end)

RegisterNetEvent("daily_rewards:updateUI", function(data)
    local safeData = {
        day = data.day,
        lastClaim = data.lastClaim
    }
    SendNUIMessage({ action = "updateUI", rewardData = safeData })
end)

RegisterNUICallback("claimReward", function(_, cb)
    TriggerServerEvent("daily_rewards:claimReward")
    cb("ok")
end)

RegisterNUICallback("checkTime", function(_, cb)
    TriggerServerEvent("daily_rewards:checkTime")
    cb("ok")
end)

RegisterNUICallback("close", function(_, cb)
    SetNuiFocus(false, false)
    cb("ok")
end)

RegisterNetEvent("daily_rewards:notify", function(msg, type)
    TriggerEvent("QBCore:Notify", msg, type or "primary")
end)

RegisterCommand("gunlukodul", function()
    TriggerServerEvent("daily_rewards:requestOpenUI")
end)