local Character = {}
Character.__index = Character
Character.NetworkEvents = { 'EnchantressShield' }

function Character.new(player: Player)
    local self = setmetatable({}, Character)
    self.player = player

    return self
end

return Character