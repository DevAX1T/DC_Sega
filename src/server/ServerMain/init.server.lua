--# selene: allow(global_usage)
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Common = require(ReplicatedStorage.Modules.Common)


local Controllers = {
    'CmdrController',
    'AnimationController',
    'CharacterController',
}

local SpawnedControllers = {}
for _, Identifier in pairs(Controllers) do
    table.insert(SpawnedControllers, Common.Concur.spawn(function()
        local Success, Error = pcall(function()
            local Controller = require(script.Controllers[Identifier])
            Controller.Init()
        end)
        if Success then
            -- Create a new logger class or whatever and output here later
        else
            error(('Fatal: Failed to initialize controller (%s): %s'):format(Identifier, Error))
        end
    end))
end

Common.Concur.all(SpawnedControllers):OnCompleted(function(err, values)
    for _, value in pairs(values) do
        if value[1] ~= nil then
            -- Log the error to Sentry and shutdown the server
            print(value)
            warn(('Fatal: Failed to initialize controllers: %s'):format(value[1]))
            local kickMessage = 'Server initialization error. Please join another server.'
            for _, player in pairs(Players:GetPlayers()) do
                player:Kick(kickMessage)
            end
            Players.PlayerAdded:Connect(function(player)
                player:Kick(kickMessage)
            end)
            return
        end
    end
    -- Set ServerReady
    local ServerReady = Instance.new('BoolValue')
    ServerReady.Name = 'ServerReady'
    ServerReady.Value = true
    ServerReady.Parent = ReplicatedStorage

    -- just empty-bind this so the infinite yield warning isn't shown
    Common.Network:BindEvents({
        ClientReady = function()

        end
    })
end)