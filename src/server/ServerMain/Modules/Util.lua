local Util = {}

function Util:CreateWeld(part0: BasePart, part1: BasePart, noFunction: boolean?)
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

return Util