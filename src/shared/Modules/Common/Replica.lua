local RunService = game:GetService('RunService')

local Network = require(script.Parent.Network)
local Promise = require(script.Parent.Promise)
local Signal = require(script.Parent.Signal)

local IsClient = RunService:IsClient()
local IsServer = RunService:IsServer()

--[[
    --> CLIENT
    local replica = Common.Replica.new('DataReplicator')

    replica.OnUpdate:Connect(function(name, object)
        print('Replicated object name is ' .. name)
        print('Replicated object is ' .. object)
    end)

    --> SERVER
    local replica = Common.Replica.new('DataReplicator', {
        Number = 5
    })

    replica:SetData({Number = 10}) -- auto updates



    replica:ReplicateToClient(`Player` client) --> Replicates the replica to the player (one time)
    @example replica:ReplicateToClient(Players.DevAX1T)

    replica:ReplicateToClients(`Tuple` Client<Player>) --> Replicates the replica to the player whenever Update() is used
    @example replica:ReplicateToClients(Players.DevAX1T, Players.DevAX2T)

    replica:StopReplicatingToPlayers(`Tuple` Client<Player>) --> Stops replicating the replica to the player whenever Update() is used

    replica.OnReplicate = function(`Replica` replica)
        print('Replica ' .. replica.object)
        print('Replicated object name' .. replica.name)
        replica:ReplicateToClient(player)
    end
]]
local Replica = {}
Replica.__index = Replica
-- Replica.OnReplicate = Signal.new() -- Used by the client to signify when a Replica provided has been replicated to the client. Two parameters: Replica name, replica type
Replica.OnUpdate = Signal.new()
Replica.Listeners = {} -- Dictionary indexed by thread
Replica.ReplicatedClients = {} -- Array<Player>

function Replica.new(name: string, replica: table)
    assert(typeof(name) == 'string', 'Replica object `name` must be a string.')
    if replica then
        assert(typeof(replica) == 'table', 'Replica.new: replica must be a table')
        assert(IsServer, 'Replica.new with an object can only be called by the server')
    end

    local self = setmetatable({}, Replica)
    self.name = name
    self.object = replica or {}
    return self
end

if IsServer then
    function Replica:SetData(data: table, overwrite: boolean)
        if data ~= false then
            if overwrite then
                -- completely replaces self.object
                self.object = data
            else
                local selfData = self:GetData()
                for index, value in pairs(data) do
                    selfData[index] = value
                end
                self.object = selfData
            end
        end
        -- now update all of the clients
        for client: Player, replicationNumber in pairs(self.ReplicatedClients) do
            if replicationNumber == 0 then
                --> First time replicating data, use ReplicaCreate
                self.ReplicatedClients[client] = 1
                Network:FireClient(client, 'ReplicaCreate', self.name, self.object)
            else
                --> Not the first time, use ReplicaUpdate
                Network:FireClient(client, 'ReplicaUpdate', self.name, self.object)
            end
        end
    end

    function Replica:ReplicateToClient(client: Player, autoLoadData: boolean)
        local replicatedClient = self.ReplicatedClients[client]
        if not replicatedClient then
            self.ReplicatedClients[client] = 0
            if autoLoadData then
                self.ReplicatedClients[client] = 1
                Network:FireClient(client, 'ReplicaCreate', self.name, self.object)
            end
        end
    end

    function Replica:ReplicateToClients(clients: Array<Player>, autoLoadData: boolean)
        for _, client in pairs(clients) do
            self:ReplicateToClient(client, autoLoadData)
        end
    end

    function Replica:StopReplicatingToClient(client: Player)
        local replicatedClient = self.ReplicatedClients[client]
        if replicatedClient then
            self.ReplicatedClients[client] = nil
        end
    end

    function Replica:StopReplicatingToClients(...)
        local clients: Array<Player> = {...}
        for _, client in pairs(clients) do
            self:StopReplicatingToClient(client)
        end
    end
end
function Replica:Await()
    assert(IsClient, 'Replica.Await() can only be used on the client')
    return Promise.new(function(resolve)
        Network:BindEvents({
            ReplicaCreate = function(name, object)
                if name == self.name then
                    self.object = object
                    resolve(self)
                end
            end,
            ReplicaUpdate = function(name, object)
                if name == self.name then
                    self.object = object
                    self.OnUpdate:Fire()
                    resolve(self)
                end
            end
        })
    end)
end
-- get whats inside
function Replica:GetData(): table
    return self.object
end


return Replica