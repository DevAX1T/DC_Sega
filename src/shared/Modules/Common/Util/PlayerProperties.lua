local RunService = game:GetService("RunService")

local Signal = require(script.Parent.Parent.Signal)

local onChange = Signal.new()

local PlayerProperties = {}

-- todo: add descriptions for all functions
--[[
    Create properties for a player

        PlayerProperties:CreateProperties({
            Coins = {'IntValue', 0},
            Motto = {'StringValue', 'The great motto'}
        })
]]
function PlayerProperties:CreateProperties(player: Player, properties: table)
    local folder = player:FindFirstChild('PlayerProperties')
    if not folder then
        folder = Instance.new('Folder')
        folder.Name = 'PlayerProperties'
        folder.Parent = player
    end

    for key, value in pairs(properties) do
        local property = Instance.new(value[1])
        property.Name = key
        property.Value = value[2]
        property.Parent = folder
    end
end

function PlayerProperties:GetProperties(player: Player): table
	local folder = player:FindFirstChild('PlayerProperties')
	if not folder then
		return {}
	end

	local properties = {}
	for _, property in pairs(folder:GetChildren()) do
		properties[property.Name] = property.Value
	end

	return properties
end

function PlayerProperties:GetProperty(player: Player, key: string): any
	local folder = player:FindFirstChild('PlayerProperties')
	if not folder then
		return nil
	end

	local property = folder:FindFirstChild(key)
	if not property then
		return nil
	end

	return property.Value
end

function PlayerProperties:SetProperty(player: Player, key: string, newValue: any)
	if not RunService:IsServer() then
		return error("'SetProperty' can only be called from the server")
	end

	local folder = player:FindFirstChild('PlayerProperties')
	if not folder then
		folder = Instance.new('Folder')
		folder.Name = 'PlayerProperties'
		folder.Parent = player
	end

	local property = folder:FindFirstChild(key)
	if not property then return end
	property.Value = newValue

	onChange:Fire(player, key, newValue)
end

--[[
	PlayerProperties:GetPropertyChangedSignal('ClientReady'):Connect(function(player, oldValue, newValue)

	end)
]]
function PlayerProperties:GetPropertyChangedSignal(property: string)
	local propertyChangedSignal = Signal.new()

	onChange:Connect(function(player, _property, newValue)
		if _property == property then
			propertyChangedSignal:Fire(player, newValue)
		end
	end)
	return propertyChangedSignal
end

return PlayerProperties