--# selene: allow(global_usage)
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Common = require(ReplicatedStorage.Modules.Common)


local Managers = {
    'CmdrManager',
    'AnimationManager',
    'CharacterManager',
}

local SpawnedManagers = {}
for _, Identifier in pairs(Managers) do
    table.insert(SpawnedManagers, Common.Concur.spawn(function()
        local Success, Error = pcall(function()
            local Manager = require(script.Managers[Identifier])
            Manager.Init()
        end)
        if Success then
            -- Create a new logger class or whatever and output here later
        else
            error(('Fatal: Failed to initialize Manager (%s): %s'):format(Identifier, Error))
        end
    end))
end

Common.Concur.all(SpawnedManagers):OnCompleted(function(err, values)
    for _, value in pairs(values) do
        if value[1] ~= nil then
            -- Log the error to Sentry and shutdown the server
            warn(('Fatal: Failed to initialize Managers: %s'):format(value[1]))
            local kickMessage = 'Server initialization error. Please join another server.'
            for _, player in pairs(Players:GetPlayers()) do
                -- player:Kick(kickMessage)
            end
            Players.PlayerAdded:Connect(function(player)
                -- player:Kick(kickMessage)
            end)
            return
        end
    end
    -- Set ServerReady
    local ServerReady = Instance.new('BoolValue')
    ServerReady.Name = 'ServerReady'
    ServerReady.Value = true
    ServerReady.Parent = ReplicatedStorage

    -- Common.PlayerProperties:GetPropertyChangedSignal('ClientReady'):Connect(function(player, newValue)
    --     print(('[%s] %s'):format(player.Name, tostring(newValue)))
    -- end)
    -- no reason to use this (at the moment)
    Common.Network:BindEvents({
        ClientReady = function(client)
            Common.PlayerProperties:CreateProperties(client, {
                ClientReady = { 'BoolValue', false }
            })
            Common.PlayerProperties:SetProperty(client, 'ClientReady', true)
        end
    })
end)