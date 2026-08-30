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

	-- Universal Smooth Draggable Module Engine
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
					if input.UserInputState == Enum.UserInputState.End then dragging = false end
				end)
			end
		end)
		frame.InputChanged:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end
		end)
		UserInputService.InputChanged:Connect(function(input)
			if input == dragInput and dragging then update(input) end
		end)
	end

	--------------------------------------------------------------------
	-- 1. FLOATING ROUND "EMOTE" ICON
	--------------------------------------------------------------------
	local MenuIcon = Instance.new("TextButton")
	MenuIcon.Name = "MenuIcon"
	MenuIcon.Size = UDim2.new(0, 60, 0, 60)
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
	IconCorner.CornerRadius = UDim.new(1, 0)
	IconCorner.Parent = MenuIcon

	makeDraggable(MenuIcon)

	--------------------------------------------------------------------
	-- 2. MAIN WINDOW CONTAINER
	--------------------------------------------------------------------
	local MainFrame = Instance.new("Frame")
	MainFrame.Name = "MainFrame"
	MainFrame.Size = UDim2.new(0, 310, 0, 360)
	MainFrame.Position = UDim2.new(0.02, 70, 0.3, 0)
	MainFrame.BackgroundColor3 = Color3.fromRGB(24, 24, 28)
	MainFrame.BorderSizePixel = 0
	MainFrame.Active = true
	MainFrame.Visible = true
	MainFrame.Parent = ScreenGui

	local UICorner = Instance.new("UICorner")
	UICorner.CornerRadius = UDim.new(0, 10)
	UICorner.Parent = MainFrame

	makeDraggable(MainFrame)

	-- MENU TITLE
	local Title = Instance.new("TextLabel")
	Title.Size = UDim2.new(1, 0, 0, 40)
	Title.BackgroundTransparency = 1
	Title.Text = "Animation Pack"
	Title.TextColor3 = Color3.fromRGB(255, 255, 255)
	Title.Font = Enum.Font.GothamBold
	Title.TextSize = 15
	Title.Parent = MainFrame

	--------------------------------------------------------------------
	-- SUBTITLE TABS: Emote Titles & Dance Titles
	--------------------------------------------------------------------
	local TabContainer = Instance.new("Frame")
	TabContainer.Size = UDim2.new(1, -20, 0, 30)
	TabContainer.Position = UDim2.new(0, 10, 0, 40)
	TabContainer.BackgroundTransparency = 1
	TabContainer.Parent = MainFrame

	local EmoteTabBtn = Instance.new("TextButton")
	EmoteTabBtn.Size = UDim2.new(0.5, -4, 1, 0)
	EmoteTabBtn.BackgroundColor3 = Color3.fromRGB(0, 162, 255) -- Default active
	EmoteTabBtn.Text = "Emote Titles"
	EmoteTabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	EmoteTabBtn.Font = Enum.Font.GothamBold
	EmoteTabBtn.TextSize = 12
	EmoteTabBtn.BorderSizePixel = 0
	EmoteTabBtn.Parent = TabContainer

	local EmoteCorner = Instance.new("UICorner")
	EmoteCorner.CornerRadius = UDim.new(0, 5)
	EmoteCorner.Parent = EmoteTabBtn

	local DanceTabBtn = Instance.new("TextButton")
	DanceTabBtn.Size = UDim2.new(0.5, -4, 1, 0)
	DanceTabBtn.Position = UDim2.new(0.5, 4, 0, 0)
	DanceTabBtn.BackgroundColor3 = Color3.fromRGB(36, 36, 42)
	DanceTabBtn.Text = "Dance Titles"
	DanceTabBtn.TextColor3 = Color3.fromRGB(180, 180, 185)
	DanceTabBtn.Font = Enum.Font.GothamBold
	DanceTabBtn.TextSize = 12
	DanceTabBtn.BorderSizePixel = 0
	DanceTabBtn.Parent = TabContainer

	local DanceCorner = Instance.new("UICorner")
	DanceCorner.CornerRadius = UDim.new(0, 5)
	DanceCorner.Parent = DanceTabBtn

	--------------------------------------------------------------------
	-- SCROLL CONTAINERS
	--------------------------------------------------------------------
	local EmoteScroll = Instance.new("ScrollingFrame")
	EmoteScroll.Size = UDim2.new(1, -20, 1, -85)
	EmoteScroll.Position = UDim2.new(0, 10, 0, 75)
	EmoteScroll.BackgroundTransparency = 1
	EmoteScroll.ScrollBarThickness = 4
	EmoteScroll.ScrollBarImageColor3 = Color3.fromRGB(60, 60, 65)
	EmoteScroll.Visible = true
	EmoteScroll.Parent = MainFrame

	local UIList1 = Instance.new("UIListLayout")
	UIList1.Padding = UDim.new(0, 8)
	UIList1.SortOrder = Enum.SortOrder.Name
	UIList1.Parent = EmoteScroll

	local DanceScroll = Instance.new("ScrollingFrame")
	DanceScroll.Size = UDim2.new(1, -20, 1, -85)
	DanceScroll.Position = UDim2.new(0, 10, 0, 75)
	DanceScroll.BackgroundTransparency = 1
	DanceScroll.ScrollBarThickness = 4
	DanceScroll.ScrollBarImageColor3 = Color3.fromRGB(60, 60, 65)
	DanceScroll.Visible = false
	DanceScroll.Parent = MainFrame

	local UIList2 = Instance.new("UIListLayout")
	UIList2.Padding = UDim.new(0, 8)
	UIList2.SortOrder = Enum.SortOrder.Name
	UIList2.Parent = DanceScroll

	-- Toggle Open/Close Menu
	local dragThreshold = false
	MenuIcon.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragThreshold = false end
	end)
	MenuIcon.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragThreshold = true end
	end)
	MenuIcon.MouseButton1Click:Connect(function()
		if not dragThreshold then MainFrame.Visible = not MainFrame.Visible end
	end)

	--------------------------------------------------------------------
	-- 3. STOP BUTTON CONTROLLER
	--------------------------------------------------------------------
	local currentStopCallback = nil

	local function showStopButton()
		MenuIcon.Visible = false
		MainFrame.Visible = false
		
		local StopButton = Instance.new("TextButton")
		StopButton.Name = "StopAnimButton"
		StopButton.Size = UDim2.new(0, 60, 0, 60)
		StopButton.Position = MenuIcon.Position 
		StopButton.BackgroundColor3 = Color3.fromRGB(231, 76, 60)
		StopButton.Text = "🛑 Stop"
		StopButton.TextColor3 = Color3.fromRGB(255, 255, 255)
		StopButton.Font = Enum.Font.GothamBold
		StopButton.TextSize = 12
		StopButton.BorderSizePixel = 0
		StopButton.ZIndex = 6
		StopButton.Parent = ScreenGui

		local StopCorner = Instance.new("UICorner")
		StopCorner.CornerRadius = UDim.new(1, 0)
		StopCorner.Parent = StopButton

		makeDraggable(StopButton)

		StopButton.MouseButton1Click:Connect(function()
			if type(currentStopCallback) == "function" then
				pcall(currentStopCallback)
			end
			currentStopCallback = nil
			
			StopButton:Destroy()
			MenuIcon.Visible = true
			MainFrame.Visible = true
		end)
	end

	--------------------------------------------------------------------
	-- 4. ROW CREATOR TOOL
	--------------------------------------------------------------------
	local function createItemRow(name, links, targetContainer)
		local PackRow = Instance.new("Frame")
		PackRow.Name = tostring(name)
		PackRow.Size = UDim2.new(1, 0, 0, 45)
		PackRow.BackgroundColor3 = Color3.fromRGB(32, 32, 38)
		PackRow.BorderSizePixel = 0
		PackRow.Parent = targetContainer

		local RowCorner = Instance.new("UICorner")
		RowCorner.CornerRadius = UDim.new(0, 6)
		RowCorner.Parent = PackRow

		local PackLabel = Instance.new("TextLabel")
		PackLabel.Size = UDim2.new(0.6, -10, 1, 0)
		PackLabel.Position = UDim2.new(0, 10, 0, 0)
		PackLabel.BackgroundTransparency = 1
		PackLabel.Text = tostring(name)
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
			
			local stopCallback = CoreHookFunction(links)
			task.wait(0.4)
			
			ApplyButton.Text = "Equip"
			ApplyButton.BackgroundColor3 = Color3.fromRGB(0, 162, 255)
			isProcessing = false
			
			if stopCallback then
				currentStopCallback = stopCallback
				showStopButton()
			end
		end)
	end

	--------------------------------------------------------------------
	-- 5. FILTERING LOGIC
	--------------------------------------------------------------------
	for bundleName, bundleLinks in pairs(AnimationDatabase) do
		local lowerName = string.lower(bundleName)
		
		if string.find(lowerName, "dance") then
			createItemRow(bundleName, bundleLinks, DanceScroll)
		else
			createItemRow(bundleName, bundleLinks, EmoteScroll)
		end
	end

	--------------------------------------------------------------------
	-- TAB NAVIGATION SWITCH SYSTEM
	--------------------------------------------------------------------
	EmoteTabBtn.MouseButton1Click:Connect(function()
		EmoteTabBtn.BackgroundColor3 = Color3.fromRGB(0, 162, 255)
		EmoteTabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
		DanceTabBtn.BackgroundColor3 = Color3.fromRGB(36, 36, 42)
		DanceTabBtn.TextColor3 = Color3.fromRGB(180, 180, 185)
		
		EmoteScroll.Visible = true
		DanceScroll.Visible = false
	end)

	DanceTabBtn.MouseButton1Click:Connect(function()
		DanceTabBtn.BackgroundColor3 = Color3.fromRGB(0, 162, 255)
		DanceTabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
		EmoteTabBtn.BackgroundColor3 = Color3.fromRGB(36, 36, 42)
		EmoteTabBtn.TextColor3 = Color3.fromRGB(180, 180, 185)
		
		DanceScroll.Visible = true
		EmoteScroll.Visible = false
	end)

	--------------------------------------------------------------------
	-- 6. AUTO SCROLL CANVAS RESIZER (OPTIMIZED)
	--------------------------------------------------------------------
	local function updateScrollSizes()
		task.defer(function()
			EmoteScroll.CanvasSize = UDim2.new(0, 0, 0, UIList1.AbsoluteContentSize.Y + 15)
			DanceScroll.CanvasSize = UDim2.new(0, 0, 0, UIList2.AbsoluteContentSize.Y + 15)
		end)
	end
	
	UIList1:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateScrollSizes)
	UIList2:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateScrollSizes)
	updateScrollSizes()
end
