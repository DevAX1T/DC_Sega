local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ContextActionService = game:GetService('ContextActionService')
local UserInputService = game:GetService('UserInputService')

local Common = require(ReplicatedStorage.Modules.Common)
local playerModule = require(Players.LocalPlayer.PlayerScripts:WaitForChild('PlayerModule'))

local Controller = {}


function Controller.Init()
    -- setup a character selection system later on 
    -- BUT INSCE WE DONT HAVE ONE, WE SHALL JUST DO STUFF WITH NO TRUST CHECKS!!!

    local function toggleShield(_, inputState: Enum.UserInputState)
        if inputState == Enum.UserInputState.Begin then
            Common.Network:FireServer('EnchantressShield')
        end
    end

    ContextActionService:BindAction('EnchantressShield', toggleShield, false, table.unpack(Common:GetDatabase('Keybinds').Enchantress.Shield))

    -- UserInputService.InputBegan:Connect(function(input, isText)
    --     if not isText then
    --         local keybinds = Common:GetDatabase('Keybinds')
    --         if Common.Array.includes(keybinds.Enchantress.Shield, input.KeyCode) then
    --             warn('Enable shield')
    --         end
    --         -- if input.KeyCode == Common:GetDatabase().Enchantress
    --     end
    -- end)

    local function mouseMovement(_, _, inputObject)
        local mouse = Players.LocalPlayer:GetMouse()
        local mousePos = mouse.Hit
        local root = Players.LocalPlayer.Character.HumanoidRootPart
        local _, y, _ = mousePos:ToOrientation()

        -- CAMERA MANIPULATION IS A PAIN
        root.CFrame = CFrame.new(root.Position) * CFrame.Angles(0, y, 0)
    end
    Common.Network:BindEvents({
        EnchantressShieldToggle = function(isEnabled)
            local controls = playerModule:GetControls()
            if isEnabled then
                controls:Disable()
                ContextActionService:BindAction('MouseMovement', mouseMovement, false, Enum.UserInputType.MouseMovement)
            else
                controls:Enable()
                ContextActionService:UnbindAction('MouseMovement')
            end
        end
    })
end

return Controller