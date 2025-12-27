local QBCore = exports['qb-core']:GetCoreObject()

RegisterNetEvent("daily_rewards:openUI", function(data)
    SetNuiFocus(true, true)
    SendNUIMessage({ action = "openUI", rewardData = data })
end)

RegisterNetEvent("daily_rewards:updateUI", function(data)
    SendNUIMessage({ action = "updateUI", rewardData = data })
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