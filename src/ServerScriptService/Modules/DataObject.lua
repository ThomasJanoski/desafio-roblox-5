local DataObject = {}
DataObject.__index = DataObject

local DataStoreService = game:GetService("DataStoreService")
local DataStore = DataStoreService:GetDataStore("Main Data")

function DataObject.new(Player: Player)
    local Object = setmetatable({}, DataObject)
    Object.ID = Player.UserId
    Object.Player = Player

    local Success = Object:Load()
    if not Success then return end

    return Object
end

local function GetDefaultData()
    return {
        Inventory = {
            Wood = 0,
            Stone = 0,
            Copper = 0
        },

        Gold = 0,
        Exp = 0,
        Level = 1,
        HouseLevel = 0,

        Character = {
            MaxHunger = 100,
            MaxThirst = 100,
            MaxHealth = 100,

            Hunger = 100,
            Thirst = 100,
            Health = 100
        }
    }
end

function DataObject:Load()
    local function Load()
        return DataStore:GetAsync(self.ID)
    end

    local Success, Result = pcall(Load)
    if not Success then
        for i = 1, 3 do
            task.wait(6)

            Success, Result = pcall(Load)
            if Success then break end
        end

        if not Success then 
            self.Player:Kick("Error loading data: " .. Result)
            warn("[" .. self.Player.Name .. "] Error loading data: " .. Result) 
            return 
        end
    end

    self.Data = Result or GetDefaultData()
    self:Autosave()

    return true
end

function DataObject:UpdateData()
    local leaderstats = self.Player:FindFirstChild("leaderstats")
    if not leaderstats then
        leaderstats = Instance.new("Folder")
        leaderstats.Name = "leaderstats"
        leaderstats.Parent = self.Player

        local Gold = Instance.new("NumberValue")
        Gold.Name = "Gold"
        Gold.Parent = leaderstats

        local Level = Instance.new("NumberValue")
        Level.Name = "Level"
        Level.Parent = leaderstats
    end

    leaderstats.Gold.Value = self.Data.Gold
    leaderstats.Level.Value = self.Data.Level

    local PlayerGui = self.Player:FindFirstChild("PlayerGui")
    local MainGui = PlayerGui and PlayerGui:FindFirstChild("MainGui")
    if not MainGui then return end

    for ItemName, Amount in self.Data.Inventory do
        local Frame = MainGui.Inventory.Button.ItemsList[ItemName]
        Frame.Button.Amount.Text = Amount
    end

    if self.Player.Character and self.Player.Character.PrimaryPart then
        local Humanoid: Humanoid = self.Player.Character.Humanoid

        MainGui.PlayerInfo.Health.BarContainer.Bar:TweenSize(
            UDim2.new(Humanoid.Health / Humanoid.MaxHealth, -4, 0.95, 0), nil, nil, 0.3, true)
        MainGui.PlayerInfo.Hunger.BarContainer.Bar:TweenSize(
            UDim2.new(self.Data.Character.Hunger / self.Data.Character.MaxHunger, -4, 0.95, 0), nil, nil, 0.3, true)
        MainGui.PlayerInfo.Thirst.BarContainer.Bar:TweenSize(
            UDim2.new(self.Data.Character.Thirst / self.Data.Character.MaxThirst, -4, 0.95, 0), nil, nil, 0.3, true)
    end
end

function DataObject:Save()
    local function Save()
        DataStore:SetAsync(self.ID, self.Data)    
    end

    local Success, Result = pcall(Save)
    if not Success then
        for i = 1, 3 do
            task.wait(6)

            Success, Result = pcall(Save)
            if Success then break end
        end

        if not Success then 
            warn("[" .. self.Player.Name .. "] Error saving data: " .. Result) 
            return 
        end
    end

    return true
end

function DataObject:Autosave()
    task.spawn(function()
        while self and self.ID and self.Data do
            task.wait(120)

            if not self or not self.ID or not self.Data then break end
            self:Save()
        end
    end)
end

return DataObject