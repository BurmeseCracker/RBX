-- core.lua
local Players = game:GetService("Players")
local InsertService = game:GetService("InsertService")
local localPlayer = Players.LocalPlayer

return function(linksData)
	local character = localPlayer.Character
	if not character then 
		warn("Character not found!")
		return nil 
	end
	
	local humanoid = character:FindFirstChildWhichIsA("Humanoid")
	local animator = humanoid and (humanoid:FindFirstChildWhichIsA("Animator") or Instance.new("Animator", humanoid))
	local animateScript = character:FindFirstChild("Animate")

	--------------------------------------------------------------------
	-- MODE 1: STANDALONE EMOTES & RANDOM DANCES (Table, String, or Number)
	--------------------------------------------------------------------
	-- Array / Table ဖြင့် Dance IDs များ ပေးပို့လာလျှင် Table ထဲမှ Random ၁ ခုကို ရွေးယူမည်
	if type(linksData) == "table" and #linksData > 0 and (type(linksData[1]) == "string" or type(linksData[1]) == "number") then
		linksData = linksData[math.random(1, #linksData)]
	end

	if type(linksData) == "string" or type(linksData) == "number" then
		if not animator then 
			warn("Animator engine not available!")
			return nil 
		end
		
		-- Raw ID အဖြစ် စစ်ထုတ်ခြင်း
		local rawId = tostring(linksData):match("%d+")
		if not rawId then
			warn("Invalid Animation ID format!")
			return nil
		end
		local assetUrl = "rbxassetid://" .. rawId
		
		local activeTrack = nil

		-- နည်းလမ်း ၁ - GetObjects သုံးပြီး Asset ထဲမှ Animation ရှာဖွေခြင်း
		local objects = nil
		local success = pcall(function() objects = game:GetObjects(assetUrl) end)
		
		if success and objects then
			local function playFirstAnimation(instance)
				if instance:IsA("Animation") then
					local track = animator:LoadAnimation(instance)
					track.Priority = Enum.AnimationPriority.Action
					track.Looped = true
					track:Play()
					activeTrack = track 
					print("Successfully playing standalone track via GetObjects: " .. tostring(instance.Name))
					return true
				end
				for _, child in ipairs(instance:GetChildren()) do
					if playFirstAnimation(child) then return true end
				end
				return false
			end
			
			for _, obj in ipairs(objects) do
				if playFirstAnimation(obj) then break end
			end
		end

		-- နည်းလမ်း ၂ - (FALLBACK) GetObjects မရပါက Direct Animation Instance ဆောက်၍ ပွင့်စေခြင်း (နမူနာ code နည်းလမ်း)
		if not activeTrack then
			local directAnim = Instance.new("Animation")
			directAnim.AnimationId = assetUrl
			
			local successLoad, track = pcall(function()
				return animator:LoadAnimation(directAnim)
			end)

			if successLoad and track then
				track.Priority = Enum.AnimationPriority.Action
				track.Looped = true
				track:Play()
				activeTrack = track
				print("Successfully playing standalone track via Direct Load: " .. rawId)
			end
		end
		
		if activeTrack then
			-- Stop button callback for standalone emotes
			return function()
				activeTrack:Stop()
				activeTrack:Destroy()
			end
		else
			warn("Failed to load animation ID: " .. rawId)
		end
		return nil
	end

	--------------------------------------------------------------------
	-- MODE 2: MOVEMENT BUNDLES (AdidasAura Pack, etc.)
	--------------------------------------------------------------------
	if not animateScript then 
		warn("Character core Animate script not active!")
		return nil 
	end

	-- Back up original animations before changing them
	local originalBackup = {}
	for stateName, _ in pairs(linksData) do
		local targetFolder = animateScript:FindFirstChild(stateName)
		if targetFolder then
			originalBackup[stateName] = {}
			for _, child in ipairs(targetFolder:GetChildren()) do
				if child:IsA("Animation") then
					originalBackup[stateName][child.Name] = {
						AnimationId = child.AnimationId,
						Weight = child:FindFirstChild("Weight") and child.Weight.Value or 1
					}
				end
			end
		end
	end

	-- Overwrite character animation states
	for stateName, assetUrl in pairs(linksData) do
		local targetFolder = animateScript:FindFirstChild(stateName)
		if targetFolder then
			local rawId = tostring(assetUrl):match("%d+")
			local formattedId = rawId and ("rbxassetid://" .. rawId) or assetUrl
			
			local animationFound = false
			local objects = nil
			local success = pcall(function() objects = game:GetObjects(formattedId) end)
			
			if not success or not objects then
				pcall(function()
					if rawId then
						local container = InsertService:LoadAsset(tonumber(rawId))
						objects = container:GetChildren()
					end
				end)
			end
			
			if objects then
				local function searchForAnimations(instance)
					if instance:IsA("Animation") then
						targetFolder:ClearAllChildren()
						
						local newAnim = Instance.new("Animation")
						newAnim.AnimationId = instance.AnimationId
						newAnim.Name = (stateName == "idle") and "Animation1" or (stateName:sub(1,1):upper() .. stateName:sub(2) .. "Anim")
						
						local weightValue = Instance.new("NumberValue")
						weightValue.Name = "Weight"
						weightValue.Value = 1
						weightValue.Parent = newAnim
						
						newAnim.Parent = targetFolder
						return true
					end
					for _, child in ipairs(instance:GetChildren()) do
						if searchForAnimations(child) then return true end
					end
					return false
				end

				for _, obj in ipairs(objects) do
					if searchForAnimations(obj) then 
						animationFound = true
						break 
					end
				end
			end

			-- Bundle အတွက်လည်း Asset ရှာမတွေ့ခဲ့လျှင် ID ကို တိုက်ရိုက် Folder ထဲ ထည့်ပေးခြင်း
			if not animationFound and rawId then
				targetFolder:ClearAllChildren()
				
				local newAnim = Instance.new("Animation")
				newAnim.AnimationId = formattedId
				newAnim.Name = (stateName == "idle") and "Animation1" or (stateName:sub(1,1):upper() .. stateName:sub(2) .. "Anim")
				
				local weightValue = Instance.new("NumberValue")
				weightValue.Name = "Weight"
				weightValue.Value = 1
				weightValue.Parent = newAnim
				
				newAnim.Parent = targetFolder
			end
		end
	end
	
	local function refreshAnimate()
		if humanoid then
			local currentSpeed = humanoid.WalkSpeed
			humanoid.WalkSpeed = currentSpeed + 0.1
			task.wait(0.05)
			humanoid.WalkSpeed = currentSpeed
		end
	end
	refreshAnimate()

	-- Stop button callback for bundles: fully restores backup defaults instantly
	return function()
		if not animateScript or not animateScript.Parent then return end
		for stateName, savedAnims in pairs(originalBackup) do
			local targetFolder = animateScript:FindFirstChild(stateName)
			if targetFolder then
				targetFolder:ClearAllChildren()
				for animName, data in pairs(savedAnims) do
					local restoredAnim = Instance.new("Animation")
					restoredAnim.Name = animName
					restoredAnim.AnimationId = data.AnimationId
					
					local weightValue = Instance.new("NumberValue")
					weightValue.Name = "Weight"
					weightValue.Value = data.Weight
					weightValue.Parent = restoredAnim
					
					restoredAnim.Parent = targetFolder
				end
			end
		end
		refreshAnimate()
	end
end

