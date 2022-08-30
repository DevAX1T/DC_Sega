local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")

local Common = require(ReplicatedStorage.Modules.Common)

local AnimationController = require(ServerScriptService.ServerMain.Controllers.AnimationController)

--todo: add characters under this script to manage specific character abilities
-- also have bindevents emit a Signal event or whatever instead of binding all events in this script
local Particles = ServerStorage.Particles.Enchantress
local Controller = {}

Controller.Characters = {}

function createWeld(part0: BasePart, part1: BasePart, noFunction: boolean?)
    local weld = Instance.new('WeldConstraint')
    weld.Part0 = part0
    weld.Part1 = part1
    weld.Name = part0.Name .. '>>' .. part1.Name
    weld.Parent = part1
    if not noFunction then
        local conn
        conn = part0.Destroying:Connect(function()
            conn:Disconnect()
            weld:Destroy()
        end)
    end
    return weld
end



function Controller.Init()
    Players.PlayerAdded:Connect(function(player)
        Common.PlayerProperties:CreateProperties(player, {
            IsEnchantressShieldEnabled = { 'BoolValue', false }
        })
    end)
    Common.Network:BindEvents({
        EnchantressShield = function(player)
            local isShieldEnabled = Common.PlayerProperties:GetProperty(player, 'IsEnchantressShieldEnabled')
            if isShieldEnabled then
                local root = Common:GetRoot(player)
                local character = root.Parent

                root.Anchored = false
                character.Shield:Destroy()
                character.ShieldHandsLeft:Destroy()
                character.ShieldHandsRight:Destroy()
                AnimationController:StopAnimation({
                    AnimationType = Common.Enums.AnimationType.Player,
                    Player = player,
                    Animation = 'Enchantress/Shield'
                })
                -- root['Shield>>HumanoidRootPart']:Destroy()

                Common.PlayerProperties:SetProperty(player, 'IsEnchantressShieldEnabled', false)
                Common.Network:FireClient(player, 'EnchantressShieldToggle', false)
            else
                Common.PlayerProperties:SetProperty(player, 'IsEnchantressShieldEnabled', true)
                warn('Turn shield on')
                local root = Common:GetRoot(player)
                local character = root.Parent

                local shield: BasePart = Particles.Shield:Clone()
                local leftHand: BasePart = Particles.ShieldHands:Clone()
                local rightHand: BasePart = Particles.ShieldHands:Clone()
                leftHand.Name = leftHand.Name .. 'Left'
                rightHand.Name = rightHand.Name .. 'Right'

                shield.Position = root.Position
                shield.Orientation = root.Orientation

                -- weld the shield to humanoidrootpart
                local leftOffset = CFrame.new(0.05, -0.08, 0)
                local rightOffset = CFrame.new(-0.05, -0.08, 0)

                leftHand.CFrame = character.LeftHand.CFrame:ToWorldSpace(leftOffset)
                rightHand.CFrame = character.RightHand.CFrame:ToWorldSpace(rightOffset)

                createWeld(shield, root)
                createWeld(leftHand, character.LeftHand)
                createWeld(rightHand, character.RightHand)

                shield.Parent = character
                leftHand.Parent = character
                rightHand.Parent = character
                shield:SetNetworkOwner(player)

                -- play the annoying animation
                AnimationController:PlayAnimation({
                    Animation = 'Enchantress/Shield',
                    AnimationType = Common.Enums.AnimationType.Player,
                    Player = player,
                })
                Common.Network:FireClient(player, 'EnchantressShieldToggle', true)
            end
        end
    })
end

function Controller:GetCharacter(player: Player)
    warn('Make this work later')
    -- todo: make this work later lol
end

return Controller