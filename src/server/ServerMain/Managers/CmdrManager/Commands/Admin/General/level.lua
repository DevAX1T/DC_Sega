local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Shared = require(ReplicatedStorage.Modules.Shared)

return {
    Name = "level",
    Description = "View or modify a player's permission level.",
    Group = "Admin",
    Args = {
        {
            Type = 'playerIds',
            Name = 'players',
            Description = 'The players to view or modify the permission level of.',
        },
        {
            Type = 'levelOptions',
            Name = 'Options',
            Description = 'The option for the command.'
        },
        function(CommandContext)
            local argument = CommandContext.RawArguments[2]
            if argument == 'set' then
                return {
                    Type = 'level',
                    Name = 'Permission Level',
                    Description = 'The level to set for the player.'
                }
            end
        end
    },
    Data = function(CommandContext)
        local Level
        if Shared.IsServer then
            local CmdrController = require(ServerScriptService.Controllers.CmdrController)
            Level = CmdrController:GetData(CommandContext.Executor.UserId).Level
        else
            local CmdrController = require(ReplicatedStorage.Modules.Client.CmdrController)
            Level = CmdrController:GetLevel()
        end
        return Level
    end
}