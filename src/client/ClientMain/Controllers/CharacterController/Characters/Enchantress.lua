local ContextActionService = game:GetService('ContextActionService')
local Players = game:GetService('Players')
local ReplicatedStorage = game:GetService('ReplicatedStorage')

local Common = require(ReplicatedStorage.Modules.Common)

local Maid = Common.Maid.new()
local Controller

local Character = {}
Character.__index = Character
Character.Icons = {
    Shield = 10718627168,
    Telekinesis = 10760833535,
    Bolts = 10760963670
}

function Character.new(CharacterController)
    local self = setmetatable({}, Character)
    if not Controller then
        Controller = CharacterController
    end

    ContextActionService:BindAction('EnchantressShield', self.ToggleShield, false, unpack(Common:GetDatabase('Keybinds').Enchantress.Shield))

    return self
end

function Character.ToggleShield(_, _, InputObject: InputObject)
    if InputObject.UserInputState == Enum.UserInputState.Begin then
        Common.Network:FireServer('EnchantressShield')
        local isEnabled = Common.PlayerProperties:GetProperty(Players.LocalPlayer, 'IsEnchantressShieldEnabled')
        if isEnabled then
            ContextActionService:UnbindAction('EnchantressShieldMouseMovement')
            Maid:Sweep()
        else
            local function OnMouseMovement()
                local root = Common:GetRoot(Players.LocalPlayer)
                if root then
                    local mouse = Players.LocalPlayer:GetMouse()
                    local mousePos = mouse.Hit
                    local _, y, _ = mousePos:ToOrientation()

                    root.CFrame = CFrame.new(root.Position) * CFrame.Angles(0, y, 0)
                end
            end
            Maid:Mark(Controller.Character.OnDeath:Connect(function()
                ContextActionService:UnbindAction('EnchantressShieldMouseMovement')
            end))
            ContextActionService:BindAction('EnchantressShieldMouseMovement', OnMouseMovement, false, Enum.UserInputType.MouseMovement)
        end
    end
end


function Character:Destroy()

end

return Character