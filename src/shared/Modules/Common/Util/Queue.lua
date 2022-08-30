-- https://github.com/surfdev7/atlas/blob/main/src/Model.ts
--[[
    type entry = {
	player: Player;
	item: string;
};

// set up.
const sellQueue = new Queue<entry>((offer) => {
    const player = purchase.player;
    const item = purchase.item;
    // check if player has the item, otherwise do nothing.
});

// add purchase
function playerSelling(player, item) {
     sellQueue.push({
        player: player,
        item: item
    });
}

// processor
while (true) {
    if (sellQueue.size() > 0) {
        sellQueue.process();
    }
}
]]
local Queue = {}
Queue.__index = Queue

function Queue.new(processor: thread)
    local self = setmetatable({}, Queue)
    self.processor = processor
    self.list = {}
    return self
end

function Queue:process()
    local entry = self.list[1]
    if entry then
        self.processor(entry)
        table.remove(self.list, 1)
    end
end

function Queue:push(value)
    table.insert(self.list, value)
end

function Queue:size(): number
    return #self.list
end

return Queue