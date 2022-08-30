local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")

local Common = require(ReplicatedStorage.Modules.Common)
local Util = Common:GetModule('Util', true)

local AnimationManager = require(ServerScriptService.ServerMain.Managers.AnimationManager)

--todo: add characters under this script to manage specific character abilities
-- also have bindevents emit a Signal event or whatever instead of binding all events in this script
local Particles = ServerStorage.Particles.Enchantress

local CharacterList = {}

for _, module in pairs(script:GetChildren()) do
    CharacterList[module.Name] = require(module)
    -- hope it doesnt error lol
    CharacterList[module.Name].Init()
end

local Manager = {}
Manager.Characters = CharacterList
Manager.AssignedCharacters = {}





function Manager.Init()
    Players.PlayerAdded:Connect(function(player)
        Common.PlayerProperties:CreateProperties(player, {
            Character = { 'StringValue', 'Default' }
        })
        task.delay(1, function()
            Manager:AssignCharacter(player, 'Enchantress')
        end)
    end)
    Players.PlayerRemoving:Connect(function(player)
        task.delay(10, function() -- just incase
            Manager.AssignedCharacters[player] = {}
        end)
    end)
end

-- function Manager.Init2()
--     Players.PlayerAdded:Connect(function(player)
--         Common.PlayerProperties:CreateProperties(player, {
--             IsEnchantressShieldEnabled = { 'BoolValue', false }
--         })
--     end)
--     Common.Network:BindEvents({
--         EnchantressShield = function(player)
--             local isShieldEnabled = Common.PlayerProperties:GetProperty(player, 'IsEnchantressShieldEnabled')
--             if isShieldEnabled then
--                 local root = Common:GetRoot(player)
--                 local character = root.Parent

--                 root.Anchored = false
--                 character.Shield:Destroy()
--                 character.ShieldHandsLeft:Destroy()
--                 character.ShieldHandsRight:Destroy()
--                 AnimationManager:StopAnimation({
--                     AnimationType = Common.Enums.AnimationType.Player,
--                     Player = player,
--                     Animation = 'Enchantress/Shield'
--                 })
--                 -- root['Shield>>HumanoidRootPart']:Destroy()

--                 Common.PlayerProperties:SetProperty(player, 'IsEnchantressShieldEnabled', false)
--                 Common.Network:FireClient(player, 'EnchantressShieldToggle', false)
--             else
--                 Common.PlayerProperties:SetProperty(player, 'IsEnchantressShieldEnabled', true)
--                 warn('Turn shield on')
--                 local root = Common:GetRoot(player)
--                 local character = root.Parent

--                 local shield: BasePart = Particles.Shield:Clone()
--                 local leftHand: BasePart = Particles.ShieldHands:Clone()
--                 local rightHand: BasePart = Particles.ShieldHands:Clone()
--                 leftHand.Name = leftHand.Name .. 'Left'
--                 rightHand.Name = rightHand.Name .. 'Right'

--                 shield.Position = root.Position
--                 shield.Orientation = root.Orientation

--                 -- weld the shield to humanoidrootpart
--                 local leftOffset = CFrame.new(0.05, -0.08, 0)
--                 local rightOffset = CFrame.new(-0.05, -0.08, 0)

--                 leftHand.CFrame = character.LeftHand.CFrame:ToWorldSpace(leftOffset)
--                 rightHand.CFrame = character.RightHand.CFrame:ToWorldSpace(rightOffset)

--                 Util:CreateWeld(shield, root)
--                 Util:CreateWeld(leftHand, character.LeftHand)
--                 Util:CreateWeld(rightHand, character.RightHand)

--                 shield.Parent = character
--                 leftHand.Parent = character
--                 rightHand.Parent = character
--                 shield:SetNetworkOwner(player)

--                 -- play the annoying animation
--                 AnimationManager:PlayAnimation({
--                     Animation = 'Enchantress/Shield',
--                     AnimationType = Common.Enums.AnimationType.Player,
--                     Player = player,
--                 })
--                 Common.Network:FireClient(player, 'EnchantressShieldToggle', true)
--             end
--         end
--     })
-- end

function Manager:GetCharacter(player: Player)
    return self.AssignedCharacters[player]
end

function Manager:AssignCharacter(player: Player, character: string)
    assert(self.Characters[character], 'Character does not exist')
    if not self.AssignedCharacters[player] then
        self.AssignedCharacters[player] = {}
    end
    local Character = self.Characters[character]
    self.AssignedCharacters[player] = Character:Assign(player)
end

return Manager