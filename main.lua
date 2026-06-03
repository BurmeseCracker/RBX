-- main.lua
local GithubBase = "https://raw.githubusercontent.com/BurmeseCracker/RBX/refs/heads/main/"

local function getGitHubFile(fileName)
	local fileUrl = GithubBase .. fileName
	
	local success, content = pcall(function()
		return game:HttpGet(fileUrl)
	end)
	
	if not success or not content or content == "404: Not Found" or content:find("404") then
		error("\n[Loader Error]: Failed to download '" .. fileName .. "'\nChecked URL: " .. fileUrl)
	end
	
	local executableCode, compileError = loadstring(content)
	if not executableCode then
		error("\n[Syntax Error] Failed to compile code inside '" .. fileName .. "': " .. tostring(compileError))
	end
	
	return executableCode()
end

local AnimationDatabase = getGitHubFile("anims.lua")
local CoreHookFunction  = getGitHubFile("core.lua")
local InitializeGui     = getGitHubFile("gui.lua")

InitializeGui(AnimationDatabase, CoreHookFunction)
print("[Success]: Ecosystem running perfectly!")
