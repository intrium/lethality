
local GUI = loadstring(game:HttpGet("https://pastebin.com/raw/UzWgkFfK"))()
GUI:Initialize()

-- modules
local ESP = loadstring(game:HttpGet("https://raw.githubusercontent.com/intrium/lethality/refs/heads/main/esp.lua"))()
local Trigger = loadstring(game:HttpGet("https://raw.githubusercontent.com/intrium/lethality/refs/heads/main/trigger.lua"))()
local Watermark  = loadstring(game:HttpGet("https://raw.githubusercontent.com/intrium/lethality/refs/heads/main/watermark.lua"))()

local destroyESP = ESP:Initialize(GUI)
local destroyTrigger = Trigger:Initialize(GUI)
local destroyWatermark = Watermark:Initialize(GUI)

-- destroyESP()
