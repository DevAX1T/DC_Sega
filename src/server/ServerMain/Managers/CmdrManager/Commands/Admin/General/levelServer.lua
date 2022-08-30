local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local CmdrController = require(ServerScriptService.Controllers.CmdrController)

local Constants = require(ReplicatedStorage.Modules.Shared.Data.Constants)
local Permissions = require(ReplicatedStorage.Modules.Shared.System.Cmdr.Permissions)
local Shared = require(ReplicatedStorage.Modules.Shared)

local Enum = Shared.Enums

return function(CommandContext, playerIds, optionType, NewLevel)
    local ExecutorLevel = CommandContext:GetData()

    for _, playerId: number in pairs(playerIds) do
        if optionType == 'view' then
            CmdrController:GetData(playerId):andThen(function(data)
                local level = Permissions:GetLevel(data.Level)
                Shared:GetUsernameFromUserId(playerId):andThen(function(username)
                    CommandContext:Reply(('%s (%d) has level \'%s\'.'):format(username, playerId, level))
                end):catch(function()
                    CommandContext:Reply(('%d has level \'%s\'.'):format(playerId, level))
                end)
            end):catch(function()
                Shared:GetUsernameFromUserId(playerId):andThen(function(username)
                    CommandContext:Reply(('Failed to get data for %s (%d).'):format(username, playerId), Constants.CmdrColors.Error)
                end):catch(function()
                    CommandContext:Reply(('Failed to get data for %d.'):format(playerId), Constants.CmdrColors.Error)
                end)
            end)
        elseif optionType == 'set' then
            CmdrController:GetData(playerId):andThen(function(playerData)
                -- Check if the user has permission to set the level (as in they aren't modifying someone with a higher or equal level)

                local sufficientLevel = ExecutorLevel > (Enum.PermissionLevel[NewLevel]) and ExecutorLevel > playerData.Level

                if sufficientLevel or ExecutorLevel == Enum.PermissionLevel.Operator then
                    CmdrController:UpdateLevel(playerId, Enum.PermissionLevel[NewLevel]):andThen(function()
                        Shared:GetUsernameFromUserId(playerId):andThen(function(username)
                            CommandContext:Reply(('Successfully modified level for %s (%s).'):format(username, playerId))
                        end):catch(function()
                            CommandContext:Reply(('Successfully modified level for %d.'):format(playerId))
                        end)
                    end):catch(function()
                        Shared:GetUsernameFromUserId(playerId):andThen(function(username)
                            CommandContext:Reply(('Failed to modify level for %s (%s); internal error.'):format(username, playerId), Constants.CmdrColors.Error)
                        end):catch(function()
                            CommandContext:Reply(('Failed to modify level for %d; internal error.'):format(playerId), Constants.CmdrColors.Error)
                        end)
                    end)
                else
                    Shared:GetUsernameFromUserId(playerId):andThen(function(username)
                        CommandContext:Reply(('Cannot modify level of %s (%s); missing permission \'Operator\'.'):format(username, playerId), Constants.CmdrColors.Error)
                    end):catch(function()
                        CommandContext:Reply(('Cannot modify level for %d; missing permissions \'Operator\'.'):format(playerId), Constants.CmdrColors.Error)
                    end)
                end

            end):catch(function()
                Shared:GetUsernameFromUserId(playerId):andThen(function(username)
                    CommandContext:Reply(('Failed to get data for %s (%d).'):format(username, playerId), Constants.CmdrColors.Error)
                end):catch(function()
                    CommandContext:Reply(('Failed to get data for %d.'):format(playerId), Constants.CmdrColors.Error)
                end)

            end)
        end
    end
    return ''
end