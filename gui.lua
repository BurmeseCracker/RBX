local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")

return function(AnimationDatabase, CoreHookFunction)
    -- Protect against duplicate instances running simultaneously 
    if CoreGui:FindFirstChild("AnimBundleMenu") then CoreGui.AnimBundleMenu:Destroy() end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "AnimBundleMenu"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = CoreGui

    --------------------------------------------------------------------
    -- 1. FLOATING MENU ICON (Toggle Button)
    --------------------------------------------------------------------
    local MenuIcon = Instance.new("TextButton")
    MenuIcon.Name = "MenuIcon"
    MenuIcon.Size = UDim2.new(0, 45, 0, 45)
    MenuIcon.Position = UDim2.new(0.02, 0, 0.3, 0) -- Positioned safely on the left side
    MenuIcon.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    MenuIcon.Text = "🏃‍♂️" -- Running emoji icon
    MenuIcon.TextSize = 22
    MenuIcon.BorderSizePixel = 0
    MenuIcon.ZIndex = 5
    MenuIcon.Parent = ScreenGui

    local IconCorner = Instance.new("UICorner")
    IconCorner.CornerRadius = UDim.new(0, 12)
    IconCorner.Parent = MenuIcon

    -- Subtle hover effect for the icon
    MenuIcon.MouseEnter:Connect(function()
        TweenService:Create(MenuIcon, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(55, 55, 60)}):Play()
    end)
    MenuIcon.MouseLeave:Connect(function()
        TweenService:Create(MenuIcon, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(40, 40, 45)}):Play()
    end)

    --------------------------------------------------------------------
    -- 2. MAIN WINDOW CONTAINER
    --------------------------------------------------------------------
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 310, 0, 350)
    MainFrame.Position = UDim2.new(0.02, 55, 0.3, 0) -- Opens right next to the icon
    MainFrame.BackgroundColor3 = Color3.fromRGB(24, 24, 28)
    MainFrame.BorderSizePixel = 0
    MainFrame.Active = true
    MainFrame.Draggable = true 
    MainFrame.Visible = true -- Starts open, can be toggled via the icon
    MainFrame.Parent = ScreenGui

    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 10)
    UICorner.Parent = MainFrame

    -- Main Frame Header Title
    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, 0, 0, 45)
    Title.BackgroundTransparency = 1
    Title.Text = "ANIMATION BUNDLES"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 13
    Title.Parent = MainFrame

    -- Scrollable Container for the Packs
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

    --------------------------------------------------------------------
    -- 3. TOGGLE VISIBILITY LOGIC
    --------------------------------------------------------------------
    MenuIcon.MouseButton1Click:Connect(function()
        MainFrame.Visible = not MainFrame.Visible
    end)

    --------------------------------------------------------------------
    -- 4. DYNAMIC PACK ENTRIES (Label + Action Button Rows)
    --------------------------------------------------------------------
    for bundleName, bundleLinks in pairs(AnimationDatabase) do
        -- Row container for the distinct Pack Item
        local PackRow = Instance.new("Frame")
        PackRow.Size = UDim2.new(1, -6, 0, 45)
        PackRow.BackgroundColor3 = Color3.fromRGB(32, 32, 38)
        PackRow.BorderSizePixel = 0
        PackRow.Parent = ScrollFrame

        local RowCorner = Instance.new("UICorner")
        RowCorner.CornerRadius = UDim.new(0, 6)
        RowCorner.Parent = PackRow

        -- Left Side Label: Displays the name of the package
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

        -- Right Side Button: Executes the asset injection hook
        local ApplyButton = Instance.new("TextButton")
        ApplyButton.Size = UDim2.new(0.4, -10, 0, 30)
        ApplyButton.Position = UDim2.new(0.6, 5, 0.5, -15) -- Centered vertically
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

        -- Connect click events instantly to your backend core module logic
        ApplyButton.MouseButton1Click:Connect(function()
            ApplyButton.Text = "Loading..."
            ApplyButton.BackgroundColor3 = Color3.fromRGB(200, 140, 20)
            
            CoreHookFunction(bundleLinks)
            
            task.wait(0.4)
            ApplyButton.Text = "Active"
            ApplyButton.BackgroundColor3 = Color3.fromRGB(46, 204, 113) -- Changes green to show success
        end)
    end

    -- Handle dynamically scrolling bounds layout parameters safely
    ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y + 10)
    UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y + 10)
    end)
end
