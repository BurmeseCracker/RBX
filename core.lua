local Players = game:GetService("Players")
local InsertService = game:GetService("InsertService")
local localPlayer = Players.LocalPlayer

return function(linksData)
    local character = localPlayer.Character
    local animateScript = character and character:FindFirstChild("Animate")
    if not animateScript then return warn("Character core Animate script not active!") end

    for stateName, assetUrl in pairs(linksData) do
        local targetFolder = animateScript:FindFirstChild(stateName)
        if targetFolder then
            local objects = nil
            
            -- Try GetObjects via Executor permissions
            local success = pcall(function() objects = game:GetObjects(assetUrl) end)
            
            -- Fallback to InsertService if needed (using numeric ID parsing)
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
    
    -- Force-refresh character animation state machine
    local humanoid = character:FindFirstChildWhichIsA("Humanoid")
    if humanoid then
        local currentSpeed = humanoid.WalkSpeed
        humanoid.WalkSpeed = currentSpeed + 0.1
        task.wait(0.05)
        humanoid.WalkSpeed = currentSpeed
    end
end
