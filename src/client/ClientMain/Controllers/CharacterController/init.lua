local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ContextActionService = game:GetService('ContextActionService')

local Common = require(ReplicatedStorage.Modules.Common)
local PlayerModule = require(Players.LocalPlayer.PlayerScripts:WaitForChild('PlayerModule'))

local CharacterList = {}
for _, module in pairs(script.Characters:GetChildren()) do
    CharacterList[module.Name] = require(module)
end

local Controller = {}
Controller.Character = Common.Character.new(Players.LocalPlayer)
Controller.Characters = CharacterList
Controller.AssignedCharacter = nil



function Controller.Init()
    Common.Network:BindEvents({
        AssignCharacter = function(character)
            Controller:AssignCharacter(character)
        end,
        ToggleControls = function(isEnabled)
            local controls = PlayerModule:GetControls()
            if isEnabled then
                controls:Enable()
            else
                controls:Disable()
            end
        end
    })

    Controller.Character.OnSpawn:Connect(function()
        local controls = PlayerModule:GetControls()
        controls:Enable() -- we need to like enable them just incase
        Controller.Character:GetHumanoid().WalkSpeed = 12
    end)

    ContextActionService:BindAction('Sprint', Controller.Sprint, false, unpack(Common:GetDatabase('Keybinds').Sprint))
end

-- function Controller.Init2()
--     -- setup a character selection system later on 
--     -- BUT INSCE WE DONT HAVE ONE, WE SHALL JUST DO STUFF WITH NO TRUST CHECKS!!!

--     local function toggleShield(_, inputState: Enum.UserInputState)
--         if inputState == Enum.UserInputState.Begin then
--             Common.Network:FireServer('EnchantressShield', 'test1', 'test2')
--         end
--     end

--     ContextActionService:BindAction('EnchantressShield', toggleShield, false, table.unpack(Common:GetDatabase('Keybinds').Enchantress.Shield))

--     -- UserInputService.InputBegan:Connect(function(input, isText)
--     --     if not isText then
--     --         local keybinds = Common:GetDatabase('Keybinds')
--     --         if Common.Array.includes(keybinds.Enchantress.Shield, input.KeyCode) then
--     --             warn('Enable shield')
--     --         end
--     --         -- if input.KeyCode == Common:GetDatabase().Enchantress
--     --     end
--     -- end)

--     local function mouseMovement(_, _, inputObject)
--         local mouse = Players.LocalPlayer:GetMouse()
--         local mousePos = mouse.Hit
--         local root = Players.LocalPlayer.Character.HumanoidRootPart
--         local _, y, _ = mousePos:ToOrientation()

--         -- CAMERA MANIPULATION IS A PAIN
--         root.CFrame = CFrame.new(root.Position) * CFrame.Angles(0, y, 0)
--     end
--     Common.Network:BindEvents({
--         EnchantressShieldToggle = function(isEnabled)
--             local controls = playerModule:GetControls()
--             if isEnabled then
--                 controls:Disable()
--                 ContextActionService:BindAction('MouseMovement', mouseMovement, false, Enum.UserInputType.MouseMovement)
--             else
--                 controls:Enable()
--                 ContextActionService:UnbindAction('MouseMovement')
--             end
--         end
--     })
-- end

function Controller:AssignCharacter(character: string)
    local Character = self.Characters[character]
    if Controller.ActiveCharacter then
        Controller.ActiveCharacter:Destroy()
    end
    Controller.AssignedCharacter = Character.new(self)
end

function Controller.Sprint(_, _, inputObject: InputObject)
    if inputObject.UserInputState == Enum.UserInputState.Begin then
        -- sprint
        Controller.Character:GetHumanoid().WalkSpeed = 23
    elseif inputObject.UserInputState == Enum.UserInputState.End then
        -- end sprint
        Controller.Character:GetHumanoid().WalkSpeed = 12
    end
end

return Controller