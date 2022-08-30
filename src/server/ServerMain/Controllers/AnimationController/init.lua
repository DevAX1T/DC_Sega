local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Common = require(ReplicatedStorage.Modules.Common)


type AnimationData = {
    AnimationType: EnumItem,
    Animation: string; -- The animation to play
    Player: Player?; -- The player to play the animation for (if AnimationType is `Player`)
    NPC: Model?; -- The NPC to play the animation for (if AnimationType is `NPC`)
    Object: BasePart?; -- The object to play the animation for (if AnimationType is `Object`)
    CompletedCallback: thread?; -- The thread to call when an animation has been completed
}

local AnimationType = Common.Enums.AnimationType
local AnimationsFolder = ReplicatedStorage.Animations

local Animations = {}
local AnimationsData = {}
local CharacterMaids = {}
local PlayerMaids = {}

local Controller = {}

function Controller.Init()
    Players.PlayerAdded:Connect(function(player)
        PlayerMaids[player] = Common.Maid.new()
        PlayerMaids[player]:Mark(player.CharacterAdded:Connect(function(character)
            CharacterMaids[character] = Common.Maid.new()
            Animations[player.UserId] = {}

            local Animator = Common:GetHumanoid(player):WaitForChild('Animator')
            print(Animator.Name)
            repeat task.wait() until character.Parent == workspace; -- if we dont do this we get "Cannot load the AnimationClipProvider Service." error

            for _, Animation in pairs(ReplicatedStorage.Animations.Player:GetDescendants()) do
                if Animation:IsA('Animation') then
                    table.insert(Animations[player.UserId], { Animation, Animator:LoadAnimation(Animation) })
                end
            end
        end))

        PlayerMaids[player]:Mark(player.CharacterRemoving:Connect(function(character)
            if Animations[player.UserId] then
                for _, AnimationTrack in pairs(Animations[player.UserId]) do
                    AnimationTrack[2]:Destroy()
                end
                Animations[player.UserId] = nil
            end
            if CharacterMaids[character] then
                CharacterMaids[character]:Sweep()
                CharacterMaids[character] = nil
            end
        end))
    end)
    Players.PlayerRemoving:Connect(function(player)
        PlayerMaids[player]:Sweep()
        PlayerMaids[player] = nil
    end)

    -- Enable once a need is found
    -- Common.Network:BindEvents({
    --     PlayAnimation = function(client, data)

    --     end
    -- })
end

-- return option 1. string, option 2. Model
function Controller:GetAnimationPath(path): (string, ModuleScript, boolean)
    local split = string.split(path, '/')
    local animation
    local Success = pcall(function()
        animation = AnimationsFolder.Player[split[1]]
        if #split > 1 then
            for i = 2, #split do
                animation = animation[split[i]]
            end
        end
    end)
    if not Success then
        warn('Invalid path provided - AnimationController')
        return false, 'Invalid animation path'
    end
    return animation
end
function Controller:PlayAnimation(data: AnimationData)
    if data.AnimationType == AnimationType.Player then
        -- get the path (Enchantress/Idle), etc
        local animation = self:GetAnimationPath(data.Animation)
        if not animation then return false, 'Animation path is invalid' end

        local result = Common.Array.find(Animations[data.Player.UserId], function(element)
            return element[1] == animation
        end)
        if not result then return false, 'Animation not found (ElementLoop)' end
        -- print(result[2].Animation:GetFullName())
        result[2]:Play()
        if data.CompletedCallback then
            result[2].Completed:Connect(data.CompletedCallback)
        end
    else
        error(('AnimationType \'%s\' passed into AnimationController, not a supported type; traceback: '):format(data.AnimationType.Name or data.AnimationType, debug.traceback()))
    end
end

function Controller:StopAnimation(data: AnimationData)
    if data.AnimationType == AnimationType.Player then
        local humanoid = Common:GetHumanoid(data.Player)
        if not humanoid then return end
        -- resolve the animation path
        local animation = self:GetAnimationPath(data.Animation)

        for _, AnimationTrack: AnimationTrack in pairs(humanoid.Animator:GetPlayingAnimationTracks()) do
            if AnimationTrack.Animation == animation then
                AnimationTrack:Stop()
            end
        end
    else
        error(('AnimationType \'%s\' passed into AnimationController, not a supported type; traceback: '):format(data.AnimationType.Name or data.AnimationType, debug.traceback()))
    end
end

-- Players.PlayerAdded:Connect(function()
--     task.wait(7)
--     Controller:PlayAnimation({
--         AnimationType = Common.Enums.AnimationType.Player,
--         Player = Players.m_t3l,
--         Animation = 'Enchantress/Shield'
--     })
-- end)


return Controller




-- Controller:PlayAnimation({
--     AnimationType = Common.Enums.AnimationType.Player,
--     Player = Players.DevAX1T,
--     Animation = 'Shield'
-- })

-- Controller:PlayAnimation({
--     AnimationType = Common.Enums.AnimationType.Player,
--     Player = Players.DevAX1T,
--     Animation = 'Enchantress/Shield/ShieldHold'
-- })

-- Controller:PlayAnimation({
--     AnimationType = Common.Enums.AnimationType.NPC,
--     NPC = workspace.Dummy,
--     Animation = 'Enchantress/Shield'
-- })

-- Controller:PlayAnimation({
--     AnimationType = Common.Enums.AnimationType.Object,
--     Object = workspace.Cup,
--     Animation = 'Cups/CoffeePour' -- great examples
-- })