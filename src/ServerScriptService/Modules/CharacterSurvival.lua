local CharacterSurvival = {}

local ServerStorage = game:GetService("ServerStorage")
local Players = game:GetService("Players")

local Modules = script.Parent
local DataModules = Modules.Parent.DataModules

local DataHandler = require(Modules.DataHandler)

local FoodInfo = require(DataModules.FoodInfo)
local MaterialInfo = require(DataModules.MaterialInfo)

local HungerInfo = {Amount = 1, HealthDecrease = 1}
local ThirstInfo = {Amount = 2, HealthDecrease = 1}

local TimeAmount = 10

function CharacterSurvival:Init()
    local function OnPlayerAdded(Player: Player)
        local DataObject = DataHandler:WaitForObject(Player)

        local function OnCharacterAdded(Character)
            local Humanoid: Humanoid = Character.Humanoid
            Humanoid.MaxHealth = DataObject.Data.Character.MaxHealth
            Humanoid.Health = DataObject.Data.Character.Health

            Humanoid.HealthChanged:Connect(function(NewHealth)
                DataObject.Data.Character.Health = NewHealth
            end)

            Humanoid.Died:Connect(function()
                for ItemName, Amount in DataObject.Data.Inventory do
                    DataObject.Data.Inventory[ItemName] = math.floor(Amount - (Amount * 10 / 100))
                end
            end)

            task.spawn(function()
                while Character and Character.PrimaryPart and Humanoid and Humanoid.Health > 0 do
                    task.wait(TimeAmount)

                    local CharacterData = DataObject.Data.Character
                    CharacterData.Hunger = math.max(0, CharacterData.Hunger - HungerInfo.Amount)
                   -- CharacterData.Thirst = math.max(0, CharacterData.Thirst - ThirstInfo.Amount)

                    local HealthDecrease = 0
                    if CharacterData.Hunger == 0 then HealthDecrease += HungerInfo.HealthDecrease end
                   -- if CharacterData.Thirst == 0 then HealthDecrease += ThirstInfo.HealthDecrease end

                    DataObject:UpdateData()

                    Humanoid:TakeDamage(HealthDecrease)
                end
            end)
        end

        if Player.Character then OnCharacterAdded(Player.Character) end
        Player.CharacterAdded:Connect(OnCharacterAdded)
    end

    for _, Player: Player in Players:GetPlayers() do OnPlayerAdded(Player) end
    Players.PlayerAdded:Connect(OnPlayerAdded)

    local function OnMaterialAdded(Material)
        local MaterialType = Material:GetAttribute("MaterialType")
        local Info = MaterialInfo[MaterialType]

        local Prompt = ServerStorage.Storage.DefaultPrompt:Clone()
        Prompt.Name = "Prompt"
        Prompt.Parent = Material.PrimaryPart

        Prompt.HoldDuration = Info.HoldDuration
        Prompt.ObjectText = MaterialType
        Prompt.Triggered:Connect(function(Player: Player)
            Prompt:Destroy()
            local Clone = Material:Clone()
            Material:Destroy()

            local DataObject = DataHandler:GetObject(Player)
            DataObject.Data.Inventory[MaterialType] += Info.GetAmount()
            DataObject:UpdateData()

            task.wait(Info.RespawnTime)
            Clone.Parent = workspace.WorldInfo.Materials
        end)
    end

    for _, Material in workspace.WorldInfo.Materials:GetChildren() do OnMaterialAdded(Material) end
    workspace.WorldInfo.Materials.ChildAdded:Connect(OnMaterialAdded)

    local function OnFoodAdded(Food)
        local FoodType = Food:GetAttribute("FoodType")
        local Info = FoodInfo[FoodType]

        local Prompt = ServerStorage.Storage.DefaultPrompt:Clone()
        Prompt.Name = "Prompt"
        Prompt.Parent = Food.PrimaryPart

        Prompt.HoldDuration = Info.HoldDuration
        Prompt.ObjectText = FoodType
        Prompt.Triggered:Connect(function(Player: Player)
            Prompt:Destroy()
            local Clone = Food:Clone()
            Food:Destroy()

            local DataObject = DataHandler:GetObject(Player)
            DataObject.Data.Character.Hunger = math.min(
                DataObject.Data.Character.MaxHunger, DataObject.Data.Character.Hunger + Info.GetHungerAdd())
            DataObject:UpdateData()

            task.wait(Info.RespawnTime)
            Clone.Parent = workspace.WorldInfo.Food
        end)
    end


    for _, Food in workspace.WorldInfo.Food:GetChildren() do OnFoodAdded(Food) end
    workspace.WorldInfo.Food.ChildAdded:Connect(OnFoodAdded)
end

return CharacterSurvival