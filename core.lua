-- core.lua
local Players = game:GetService("Players")
local InsertService = game:GetService("InsertService")
local localPlayer = Players.LocalPlayer

return function(linksData)
	local character = localPlayer.Character
	if not character then return nil warn("Character not found!") end
	
	local humanoid = character:FindFirstChildWhichIsA("Humanoid")
	local animator = humanoid and (humanoid:FindFirstChildWhichIsA("Animator") or Instance.new("Animator", humanoid))
	local animateScript = character:FindFirstChild("Animate")

	--------------------------------------------------------------------
	-- MODE 1: SINGLE TRACK OBJECT PLAYBACK
	--------------------------------------------------------------------
	if type(linksData) == "string" or type(linksData) == "number" then
		if not animator then return nil warn("Animator engine not available!") end
		
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
					activeTrack = track -- Capture track reference to return it
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
			return activeTrack -- Returns the track object back to the GUI script
		end
		return nil
	end

	--------------------------------------------------------------------
	-- MODE 2: BUNDLE HOOK OVERRIDE
	--------------------------------------------------------------------
	if not animateScript then return nil warn("Character core Animate script not active!") end

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
	
	if humanoid then
		local currentSpeed = humanoid.WalkSpeed
		humanoid.WalkSpeed = currentSpeed + 0.1
		task.wait(0.05)
		humanoid.WalkSpeed = currentSpeed
	end
	return "bundle" -- Returns a string keyword signifying a system-wide movement swap
end
