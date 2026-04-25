-- EXE6 Main Entry (paste cái này vào executor)
-- Thay BASE_URL bằng raw GitHub URL của repo bạn

local BASE_URL = "https://github.com/Therealtobu/Exe6/tree/main"

local function load(file)
	local ok, result = pcall(function()
		return loadstring(game:HttpGet(BASE_URL .. file))()
	end)
	if not ok then
		warn("[EXE6] Failed to load " .. file .. ": " .. tostring(result))
	end
end

-- 1. Build UI trước
load("loader.lua")

-- 2. Đợi UI render xong
task.wait(0.5)

-- 3. Load các handler theo thứ tự
load("handlers/interface_handler.lua")
load("handlers/modal_handler.lua")
load("handlers/navigation_handler.lua")
load("handlers/screen_handler.lua")
load("handlers/default_commands.lua")

print("[EXE6] Loaded successfully!")
