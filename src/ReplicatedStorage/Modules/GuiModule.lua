local GuiModule = {}

local TweenService = game:GetService("TweenService")

function GuiModule:ButtonEffect(ButtonFrame, Callback)
    local Button: TextButton = ButtonFrame.Button
    local OriginalPosition = Button.Position

    Button.MouseEnter:Connect(function()
        TweenService:Create(ButtonFrame, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(137, 87, 70)}):Play()
        TweenService:Create(Button, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(238, 152, 124)}):Play()
        TweenService:Create(Button.Internal, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(241, 115, 111)}):Play()
    end)

    Button.MouseLeave:Connect(function()
        TweenService:Create(ButtonFrame, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(89, 56, 45)}):Play()
        TweenService:Create(Button, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(214, 135, 108)}):Play()
        TweenService:Create(Button.Internal, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(214, 97, 93)}):Play()
    end)

    Button.MouseButton1Down:Connect(function()
        Button.Position = UDim2.fromScale(0, 0)
    end)

    Button.MouseButton1Up:Connect(function()
        Button.Position = OriginalPosition

        Callback()
    end)
end

return GuiModule