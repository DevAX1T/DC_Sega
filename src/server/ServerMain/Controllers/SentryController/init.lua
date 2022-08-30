local LogService = game:GetService("LogService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ScriptContext = game:GetService("ScriptContext")
local ServerStorage = game:GetService("ServerStorage")

local Common = require(ReplicatedStorage.Modules.Common)
local Sentry = require(script.Sentry)
local Secrets = require(ServerStorage.Secure.Databases.Secrets)

print(Common.Enums)
local Controller = {}
Controller.Sentry = Sentry.new({
    Environment = 'production', -- add a 'if testing' then function
    OrganizationName = 'DC Sega',
    ProjectName = 'DCSega',
    BearerToken = Secrets.Sentry.BearerToken,
    DSN = Secrets.Sentry.DSN
})
-- TODO // a

function Controller.Init()
    ScriptContext.Error:Connect(function(message, stack, _script)
        Controller:LogError('server', {
            message = message,
            stack = stack,
            trace = if _script then _script:GetFullName() else 'No traceback'
        })
    end)

    LogService.MessageOut:Connect(function(message, messageType)
        if RunService:IsStudio() then return end
        if messageType == Enum.MessageType.MessageError or messageType == Enum.MessageType.MessageOutput then return end
        local level = if messageType == Enum.MessageType.MessageInfo then Controller.Sentry.Enums.EventLevel.Info else Controller.Sentry.Enums.EventLevel.Warning
        local event = Controller.Sentry.Event.new()
            :AddTag('type', 'server')
            :AddTag('version', tostring(Common.Version))
            :SetLevel(level)
            :SetMessage(message)

        Controller.Sentry:submitEvent(event)
    end)

    Common.Network:BindEvents({
        ClientError = function(player, message, stack)
            if type(message) ~="string" then return end
            if type(stack) ~= "string" then return end

            --! disable until proper throttling is implemented
            -- Controller:LogError('client', {
            --     player = player,
            --     message = message,
            --     stack = stack,
            -- })
        end
    })
end

function Controller:LogError(errorType, context)
    if Common.IsStudio then return end
    local isFatal = string.find(string.lower(context.message), 'fatal')
    local event = self.Sentry.Event.new()
        :AddTag('type', errorType)
        :AddTag('version', Common.Version)
        :SetLevel(if isFatal then self.Sentry.Enums.EventLevel.Fatal else self.Sentry.Enums.EventLevel.Error)
        :AddException('Error', context.message, context.stack)

    if errorType == 'client' then
        if string.find(context.message, 'Failed to load sound') or string.find(context.stack, 'Failed to load sound') then return end
        event:SetUser(context.player)
    end
    return self.Sentry:submitEvent(event)
end

-- return Controller