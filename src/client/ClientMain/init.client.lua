local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Common = require(ReplicatedStorage.Modules.Common)

local Controllers = {
    'CharacterController'
}

local SpawnedControllers = {}
for _, Identifier in pairs(Controllers) do
    table.insert(SpawnedControllers, Common.Concur.spawn(function()
        local Success, Error = pcall(function()
            local Controller = require(script.Controllers[Identifier])
            if Controller.Init then
                Controller.Init()
            else
                error(("Controller '%s' has no initialize function"):format(Identifier))
            end
        end)
        if Success then
            -- create a client Logger class or sumn
        else
            error(Error)
            Common.Network:FireServer('ClientError', ('Fatal: ' .. Error), debug.traceback())
        end
    end))
end

Common.Concur.all(SpawnedControllers):OnCompleted(function(err, msg)
    if err ~= nil then
        Common.Network:FireServer('ClientError', msg, debug.traceback())
        Players.LocalPlayer:Kick('Client controller load error - please rejoin.')
    end
    local ClientReady = Instance.new('BoolValue')
    ClientReady.Name = 'ClientReady'
    ClientReady.Value = true
    ClientReady.Parent = ReplicatedStorage
    Common.Network:FireServer('ClientReady')
end)