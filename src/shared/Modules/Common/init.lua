local HttpService = game:GetService('HttpService')
local Players = game:GetService('Players')
local RunService = game:GetService('RunService')

local Common = {
    Version = 'v1.0.0-dev',
    IsServer = RunService:IsServer(),
    IsClient = RunService:IsClient(),
    IsStudio = RunService:IsStudio(),

    CmdrColors = {
        Info = Color3.fromRGB(77, 189, 255),
        Success = Color3.fromRGB(38, 217, 101),
        Warning = Color3.fromRGB(255, 223, 93),
        Error = Color3.fromRGB(255, 73, 73),  
    },

    -- Modules
    Array = require(script.Util.Array),
    Character = require(script.Util.Character),
    Concur = require(script.Concur),
    Conversion = require(script.Util.Conversion),
    EnumList = require(script.Util.EnumList),
    Format = require(script.Util.Format),
    Maid = require(script.Maid),
    Network = require(script.Network),
    Object = require(script.Util.Object),
    PlayerProperties = require(script.Util.PlayerProperties),
    Promise = require(script.Promise),
    Queue = require(script.Util.Queue),
    Replica = require(script.Replica),
    Signal = require(script.Signal),
    Timer = require(script.Util.Timer)
}

function Common:JSONEncode(data): string
    return HttpService:JSONEncode(data)
end

function Common:JSONDecode(data): table
    return HttpService:JSONDecode(data)
end

function Common:GetRoot(player: Player, ignoreDeadCheck: boolean): BasePart
    if not player.Character then return end
    if not ignoreDeadCheck then
        if player.Character.Humanoid.Health < 0 then return end
    end
    return player.Character.HumanoidRootPart
end
--[[
    Returns the player's humanoid. If `ignoreDeadCheck` is true, then it will return the humanoid regardless of if the player is dead or not.
]]
function Common:GetHumanoid(player: Player, ignoreDeadCheck: boolean): Humanoid
    local root = self:GetRoot(player, ignoreDeadCheck)
    if root then
        return root.Parent.Humanoid
    end
end

function Common:NewUUID(useDashes: boolean): string
    local uuid = string.lower(HttpService:GenerateGUID(false))
    return (if useDashes then uuid else string.gsub(uuid, '-', ''))
end

function Common:NewSymbol(name: string?)
    local symbol = newproxy(true)
    getmetatable(symbol).__tostring = function()
        return  'Symbol' .. (if name then (' (' .. name .. ')') else '')
    end
    return symbol
end

function Common:GetDatabase(...: string)
    local result = {}
    local request = { ... }
    local databases = script.Databases

    for _, dbName in pairs(request) do
        if databases[dbName] then
            table.insert(result, { dbName, require(databases[dbName]) })
        end
    end

    if #result == 1 then
        return result[1][2]
    else
        local dbTable = {}
        for _, db in pairs(result) do
            dbTable[db[1]] = db[2]
        end
        return dbTable
    end
end

function Common:OnClientLoaded(player: Player?)
    return self.Promise.new(function(resolve)
        if self.IsClient then
            player = Players.LocalPlayer
        end
        if player:FindFirstChild('ClientLoaded') then
            return resolve()
        end

        local maid = self.Maid.new()

        maid:Mark(player.ChildAdded:Connect(function(child)
            if child.Name == 'ClientLoaded' then
                maid:Sweep()
                resolve()
            end
        end))
    end)
end
Common.Enums = {}
local EnumDB = Common:GetDatabase('Enums')

for enum, values in pairs(EnumDB) do
    Common.Enums[enum] = Common.EnumList.new(enum, values)
end

return Common