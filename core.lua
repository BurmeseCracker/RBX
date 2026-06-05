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
	-- MODE 1: SINGLE TRACK OBJECT PLAYBACK
	--------------------------------------------------------------------
	if type(linksData) == "string" or type(linksData) == "number" then
		if not animator then 
			warn("Animator engine not available!")
			return nil 
		end
		
		local assetUrl = tostring(linksData)
		if not assetUrl:find("rbxassetid://") then
			assetUrl = "rbxassetid://" .. assetUrl
		end
		
		local objects = nil
		local success = pcall(function() objects = game:GetObjects(assetUrl) end)
		
		if success and objects then
			local activeTrack = nil
			local function playFirstAnimation(instance)
				if instance:IsA("Animation") then
					local track = animator:LoadAnimation(instance)
					track.Priority = Enum.AnimationPriority.Action
					track:Play()
					activeTrack = track 
					print("Successfully playing standalone track: " .. tostring(instance.Name))
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
			
			if activeTrack then
				-- Return a cleanup function for the standalone track
				return function()
					activeTrack:Stop()
				end
			end
		end
		return nil
	end

	--------------------------------------------------------------------
	-- MODE 2: BUNDLE HOOK OVERRIDE (WITH BACKUP)
	--------------------------------------------------------------------
	if not animateScript then 
		warn("Character core Animate script not active!")
		return nil 
	end

	-- Back up the original animation configuration
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

	-- Apply new pack animations
	for stateName, assetUrl in pairs(linksData) do
		local targetFolder = animateScript:FindFirstChild(stateName)
		if targetFolder then
			local objects = nil
			local success = pcall(function() objects = game:GetObjects(assetUrl) end)
			
			if not success or not objects then
				pcall(function()
					local idNum = tonumber(string.match(assetUrl, "%d+"))
					if idNum then
						local container = InsertService:LoadAsset(idNum)
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
					if searchForAnimations(obj) then break end
				end
			end
		end
	end
	
	-- Refresh animations smoothly
	local function refreshAnimate()
		if humanoid then
			local currentSpeed = humanoid.WalkSpeed
			humanoid.WalkSpeed = currentSpeed + 0.1
			task.wait(0.05)
			humanoid.WalkSpeed = currentSpeed
		end
	end
	refreshAnimate()

	-- Return a cleanup function that fully restores original movement settings
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
