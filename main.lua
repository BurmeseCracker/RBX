-- CENTRAL EXECUTION ENVIRONMENT HANDLER
local GithubBase = "https://raw.githubusercontent.com/BurmeseCracker/RBX/new/main"

local function getGitHubFile(fileName)
    local success, content = pcall(function()
        return game:HttpGet(GithubBase .. fileName)
    end)
    
    if not success or not content then
        error("Critical Error: Failed to download '" .. fileName .. "' from GitHub. Verify URL parameters.")
    end
    
    local executableCode, compileError = loadstring(content)
    if not executableCode then
        error("Syntax Compile Error inside '" .. fileName .. "': " .. tostring(compileError))
    end
    
    return executableCode()
end

-- Assemble distributed script modules safely
local AnimationDatabase = getGitHubFile("anims.lua")
local CoreHookFunction  = getGitHubFile("core.lua")
local InitializeGui     = getGitHubFile("gui.lua")

-- Mount configuration environment
InitializeGui(AnimationDatabase, CoreHookFunction)
print("Project ecosystem assembled without any script warnings!")
