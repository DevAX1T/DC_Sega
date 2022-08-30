local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")

local Common = require(ReplicatedStorage.Modules.Common)
local AnimationManager = require(ServerScriptService.ServerMain.Managers.AnimationManager)
local Util = Common:GetModule('Util', true)



function middleware(resolve, player, ...)
    if Common.PlayerProperties:GetProperty(player, 'Character') == 'Enchantress' and Common:GetHumanoid(player).Health > 0 then
        resolve(player, ...)
    end
end

local CharacterList = {}

local Particles = ServerStorage.Particles.Enchantress

local Character = {}
Character.__index = Character
Character.Replicas = {}

function Character.Init()
    Players.PlayerAdded:Connect(function(player)
        Common.PlayerProperties:CreateProperties(player, {
            IsEnchantressShieldEnabled = { 'BoolValue', false }
        })
    end)
    Players.PlayerRemoving:Connect(function(player)
        Character:Dismiss(player)
    end)
    Common.Network:BindEvents(middleware, {
        EnchantressShield = function(player)
            Character:ToggleShield(player)
        end
    })

end

function Character:Assign(player: Player)
    Common.PlayerProperties:SetProperty(player, 'Character', 'Enchantress')
    Common.Network:FireClient(player, 'AssignCharacter', 'Enchantress')

    CharacterList[player] = Common.Character.new(player)
    CharacterList[player].OnRemove:Connect(function()
        Common.PlayerProperties:SetProperty(player, 'IsEnchantressShieldEnabled', false)
    end)
end

function Character:Dismiss(player: Player)
    CharacterList[player]:Destroy()
    CharacterList[player] = nil
end


-- Abilities
function Character:ToggleShield(player: Player)
    local isEnabled = Common.PlayerProperties:GetProperty(player, 'IsEnchantressShieldEnabled')
    local root = Common:GetRoot(player)
    local character = root.Parent

    if isEnabled then
        Common.PlayerProperties:SetProperty(player, 'IsEnchantressShieldEnabled', false)

        -- Disable the shield
        character.Shield:Destroy()
        character.ShieldHandRight:Destroy()
        character.ShieldHandLeft:Destroy()
        AnimationManager:StopAnimation({
            Animation = 'Enchantress/Shield',
            AnimationType = Common.Enums.AnimationType.Player,
            Player = player
        })
        Common.Network:FireClient(player, 'ToggleControls', true)
    else
        Common.PlayerProperties:SetProperty(player, 'IsEnchantressShieldEnabled', true)

        -- Enable the shield
        local Shield = Particles.Shield:Clone() :: BasePart
        local RightHand = Particles.GlowingHand:Clone()
        local LeftHand = Particles.GlowingHand:Clone()
        RightHand.Name = 'ShieldHandRight'
        LeftHand.Name = 'ShieldHandLeft'

        Shield.Position = root.Position
        Shield.Orientation = root.Orientation

        LeftHand.CFrame = character.LeftHand.CFrame:ToWorldSpace(CFrame.new(0.05, -0.08, 0))
        RightHand.CFrame = character.RightHand.CFrame:ToWorldSpace(CFrame.new(-0.05, -0.08, 0))

        Util:CreateWeld(Shield, root)
        Util:CreateWeld(LeftHand, character.LeftHand)
        Util:CreateWeld(RightHand, character.RightHand)

        Shield.Parent = character
        LeftHand.Parent = character
        RightHand.Parent = character
        Shield:SetNetworkOwner(player)

        AnimationManager:PlayAnimation({
            Animation = 'Enchantress/Shield',
            AnimationType = Common.Enums.AnimationType.Player,
            Player = player
        })

        Common.Network:FireClient(player, 'ToggleControls', false)
    end
end

return Character