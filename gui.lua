-- gui.lua
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

return function(AnimationDatabase, CoreHookFunction)
    if CoreGui:FindFirstChild("AnimBundleMenu") then 
        CoreGui.AnimBundleMenu:Destroy() 
    end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "AnimBundleMenu"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = CoreGui

    -- Helper function to make ANY UI element smoothly draggable anywhere on screen
    local function makeDraggable(frame)
        local dragging, dragInput, dragStart, startPos

        local function update(input)
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end

        frame.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                dragStart = input.Position
                startPos = frame.Position

                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then
                        dragging = false
                    end
                end)
            end
        end)

        frame.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                dragInput = input
            end
        end)

        UserInputService.InputChanged:Connect(function(input)
            if input == dragInput and dragging then
                update(input)
            end
        end)
    end

    --------------------------------------------------------------------
    -- 1. ROUND "EMOTE" MENU ICON (Draggable Anywhere)
    --------------------------------------------------------------------
    local MenuIcon = Instance.new("TextButton")
    MenuIcon.Name = "MenuIcon"
    MenuIcon.Size = UDim2.new(0, 60, 0, 60) -- Perfect square for aspect ratio rounding
    MenuIcon.Position = UDim2.new(0.02, 0, 0.3, 0)
    MenuIcon.BackgroundColor3 = Color3.fromRGB(0, 162, 255)
    MenuIcon.Text = "Emote"
    MenuIcon.TextColor3 = Color3.fromRGB(255, 255, 255)
    MenuIcon.Font = Enum.Font.GothamBold
    MenuIcon.TextSize = 13
    MenuIcon.BorderSizePixel = 0
    MenuIcon.ZIndex = 5
    MenuIcon.Parent = ScreenGui

    local IconCorner = Instance.new("UICorner")
    IconCorner.CornerRadius = UDim.new(1, 0) -- Pure circle constraint
    IconCorner.Parent = MenuIcon

    makeDraggable(MenuIcon) -- Enable dragging for the icon

    -- Smooth Hover Tweens for the Emote Button
    MenuIcon.MouseEnter:Connect(function()
        TweenService:Create(MenuIcon, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(0, 130, 210)}):Play()
    end)
    MenuIcon.MouseLeave:Connect(function()
        TweenService:Create(MenuIcon, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(0, 162, 255)}):Play()
    end)

    --------------------------------------------------------------------
    -- 2. MAIN WINDOW CONTAINER (Draggable Anywhere)
    --------------------------------------------------------------------
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 310, 0, 350)
    MainFrame.Position = UDim2.new(0.02, 70, 0.3, 0) -- Opens cleanly adjacent to the button
    MainFrame.BackgroundColor3 = Color3.fromRGB(24, 24, 28)
    MainFrame.BorderSizePixel = 0
    MainFrame.Active = true
    MainFrame.Visible = true
    MainFrame.Parent = ScreenGui

    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 10)
    UICorner.Parent = MainFrame

    makeDraggable(MainFrame) -- Enable dragging for the main frame window

    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, 0, 0, 45)
    Title.BackgroundTransparency = 1
    Title.Text = "ANIMATION BUNDLES"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 13
    Title.Parent = MainFrame

    local ScrollFrame = Instance.new("ScrollingFrame")
    ScrollFrame.Size = UDim2.new(1, -20, 1, -55)
    ScrollFrame.Position = UDim2.new(0, 10, 0, 45)
    ScrollFrame.BackgroundTransparency = 1
    ScrollFrame.ScrollBarThickness = 4
    ScrollFrame.ScrollBarImageColor3 = Color3.fromRGB(60, 60, 65)
    ScrollFrame.Parent = MainFrame

    local UIListLayout = Instance.new("UIListLayout")
    UIListLayout.Padding = UDim.new(0, 8)
    UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    UIListLayout.Parent = ScrollFrame

    -- Open/Close visibility toggle logic
    local dragThreshold = false
    MenuIcon.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragThreshold = false
        end
    end)
    MenuIcon.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragThreshold = true -- Prevents the menu from opening/closing while dragging it
        end
    end)
    MenuIcon.MouseButton1Click:Connect(function()
        if not dragThreshold then
            MainFrame.Visible = not MainFrame.Visible
        end
    end)

    --------------------------------------------------------------------
    -- 3. DYNAMIC PACK ENTRIES (Label + Button Rows)
    --------------------------------------------------------------------
    for bundleName, bundleLinks in pairs(AnimationDatabase) do
        local PackRow = Instance.new("Frame")
        PackRow.Size = UDim2.new(1, -6, 0, 45)
        PackRow.BackgroundColor3 = Color3.fromRGB(32, 32, 38)
        PackRow.BorderSizePixel = 0
        PackRow.Parent = ScrollFrame

        local RowCorner = Instance.new("UICorner")
        RowCorner.CornerRadius = UDim.new(0, 6)
        RowCorner.Parent = PackRow

        local PackLabel = Instance.new("TextLabel")
        PackLabel.Size = UDim2.new(0.6, -10, 1, 0)
        PackLabel.Position = UDim2.new(0, 10, 0, 0)
        PackLabel.BackgroundTransparency = 1
        PackLabel.Text = bundleName
        PackLabel.TextColor3 = Color3.fromRGB(235, 235, 235)
        PackLabel.Font = Enum.Font.GothamMedium
        PackLabel.TextSize = 13
        PackLabel.TextXAlignment = Enum.TextXAlignment.Left
        PackLabel.Parent = PackRow

        local ApplyButton = Instance.new("TextButton")
        ApplyButton.Size = UDim2.new(0.4, -10, 0, 30)
        ApplyButton.Position = UDim2.new(0.6, 5, 0.5, -15)
        ApplyButton.BackgroundColor3 = Color3.fromRGB(0, 162, 255)
        ApplyButton.BorderSizePixel = 0
        ApplyButton.Text = "Equip"
        ApplyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        ApplyButton.Font = Enum.Font.GothamBold
        ApplyButton.TextSize = 11
        ApplyButton.Parent = PackRow

        local BtnCorner = Instance.new("UICorner")
        BtnCorner.CornerRadius = UDim.new(0, 4)
        BtnCorner.Parent = ApplyButton

        local isProcessing = false
        ApplyButton.MouseButton1Click:Connect(function()
            if isProcessing then return end
            isProcessing = true
            
            ApplyButton.Text = "Loading..."
            ApplyButton.BackgroundColor3 = Color3.fromRGB(200, 140, 20)
            
            CoreHookFunction(bundleLinks)
            
            task.wait(0.4)
            ApplyButton.Text = "Active"
            ApplyButton.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
            isProcessing = false
        end)
    end

    -- Canvas auto-scaling configurations
    ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y + 10)
    UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y + 10)
    end)
end
