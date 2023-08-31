local DataHandler = {}

local Players = game:GetService("Players")

local Modules = script.Parent
local DataObject = require(Modules.DataObject)

local ObjectContainer = {}

function DataHandler:GetObject(Player: Player)
    return ObjectContainer[Player.UserId]
end

function DataHandler:WaitForObject(Player: Player)
    local Object = self:GetObject(Player)
    if not Object then
        repeat task.wait() Object = self:GetObject(Player) until Object or not Player
    end

    return Object
end

function DataHandler:Init()
    local function OnPlayerAdded(Player: Player)
        local Object = DataObject.new(Player)
        if not Object then return end

        ObjectContainer[Player.UserId] = Object
    end

    local function OnPlayerRemoving(Player: Player)
        local Object = self:GetObject(Player)
        Object:Save()

        ObjectContainer[Player.UserId] = nil
    end

    for _, Player: Player in Players:GetPlayers() do OnPlayerAdded(Player) end
    Players.PlayerAdded:Connect(OnPlayerAdded)
    Players.PlayerRemoving:Connect(OnPlayerRemoving)
end

return DataHandler