local Players = game:GetService("Players")
local SocialService = game:GetService("SocialService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local GuiModule = require(ReplicatedStorage.Modules.GuiModule)

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui", math.huge)
local MainGui = PlayerGui:WaitForChild("MainGui", math.huge)

local function canSendGameInvite(sendingPlayer)
    local success, canSend = pcall(function()
        return SocialService:CanSendGameInviteAsync(sendingPlayer)
    end)
    return success and canSend
end

local IsInventoryOpened = false

local ButtonFunctions = {
    ["Inventory"] = function()
        if IsInventoryOpened then
            IsInventoryOpened = false

            TweenService:Create(MainGui.Inventory, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.InOut), 
                {Position = UDim2.fromScale(0.5, -0.5)}):Play()
        else
            IsInventoryOpened = true
            TweenService:Create(MainGui.Inventory, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), 
            {Position = UDim2.fromScale(0.5, 0.5)}):Play()
        end
    end,
    ["Invite"] = function()
        local canInvite = canSendGameInvite(Player)
        if canInvite then
            local success, errorMessage = pcall(function()
                SocialService:PromptGameInvite(Player)
            end)
        end
    end    
}

for _, Button in MainGui.Buttons:GetChildren() do
    if not Button:IsA("Frame") then continue end
    local ButtonName = Button.Name

    GuiModule:ButtonEffect(Button, ButtonFunctions[ButtonName])
end