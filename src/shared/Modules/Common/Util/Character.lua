local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local Maid = require(script.Parent.Parent.Maid)
local Signal = require(script.Parent.Parent.Signal)

local Maids = {}

-- No signals fire when the character is removed using Character:LoadCharacter()
local Character = {}
Character.__index = Character
Character.OnDeath = Signal.new() -- No arguments
Character.OnSpawn = Signal.new() -- No arguments
Character.OnRemove = Signal.new() -- No arguments
Character.OnStateChanged = Signal.new() -- Returns the exact same arguments as Humanoid.StateChanged

function Character.new(player: Player)
    if RunService:IsServer() then
        assert(not not player, "Character.new() was called with no player")
    else
        -- client
        if not player then
            player = Players.LocalPlayer
        end
    end
    local self = setmetatable({}, Character)
    Maids[player] = Maid.new()
    local function setup(character)
        Maids[character] = Maid.new()
        local humanoid: Humanoid = character:WaitForChild('Humanoid')
        Maids[character]:Mark(humanoid.Died:Connect(function()
            self.OnDeath:Fire()
        end))
        Maids[character]:Mark(humanoid.StateChanged:Connect(function(...)
            self.OnStateChanged:Fire(...)
        end))
        self.OnSpawn:Fire()
    end

    if player.Character then
        setup(player.Character)
    end
    Maids[player]:Mark(player.CharacterAdded:Connect(function(character)
        setup(character)
    end))
    Maids[player]:Mark(player.CharacterRemoving:Connect(function(character)
        if Maids[character] then
            Maids[character]:Sweep()
            Maids[character] = nil
        end
        self.OnRemove:Fire()
    end))
    return self
end

-- Disconnects all maids
function Character:Destroy()
    for _, maid in pairs(Maids) do
        maid:Sweep()
    end
end
return Character