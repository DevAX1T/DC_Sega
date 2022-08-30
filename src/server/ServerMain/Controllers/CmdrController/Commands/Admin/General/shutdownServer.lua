local Players = game:GetService('Players')
local ServerScriptService = game:GetService('ServerScriptService')

local SoftShutdownController = require(ServerScriptService.Controllers.SoftShutdownController)

return function (context, doSoftShutdown)
    if doSoftShutdown then
        SoftShutdownController:ShutdownServer()
    else
        for _, player in pairs(Players:GetPlayers()) do
            player:Kick('Server is shutting down')
        end
    end
end