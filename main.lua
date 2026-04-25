local BASE_URL = "https://raw.githubusercontent.com/Therealtobu/Exe6/main/"

local function load(file)
    local content = game:HttpGet(BASE_URL .. file)
    local fn, err = loadstring(content)
    if not fn then
        warn("[EXE6] Compile error in " .. file .. ": " .. tostring(err))
        return
    end
    local ok, result = pcall(fn)
    if not ok then
        warn("[EXE6] Runtime error in " .. file .. ": " .. tostring(result))
    end
end

load("loader.lua")
task.wait(0.5)
load("handlers/interface_handler.lua")
load("handlers/modal_handler.lua")
load("handlers/navigation_handler.lua")
load("handlers/screen_handler.lua")
load("handlers/default_commands.lua")

print("[EXE6] Loaded successfully!")
