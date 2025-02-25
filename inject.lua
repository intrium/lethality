
local GUI = loadstring(game:HttpGet("https://bin.bloerg.net/EPKjFc?fmt=raw"))()
GUI:Initialize()

-- modules
local ESP = loadstring(game:HttpGet("https://raw.githubusercontent.com/intrium/lethality/refs/heads/main/esp.lua"))()
local Speed = loadstring(game:HttpGet("https://bin.bloerg.net/ciNVka?fmt=raw"))()
local Trigger = loadstring(game:HttpGet("https://bin.bloerg.net/Q-5-eb?fmt=raw"))()
local Watermark = loadstring(game:HttpGet("https://pastes.io/raw/c-21333-21"))()
local Hitboxes = loadstring(game:HttpGet("https://bin.bloerg.net/UzpOQa?fmt=raw"))()

local destroyESP = ESP:Initialize(GUI)
local destroySpeed = Speed:Initialize(GUI)
local destroyTrigger = Trigger:Initialize(GUI)
local destroyWatermark = Watermark:Initialize(GUI)
local destroyHitboxes = Hitboxes:Initialize(GUI)