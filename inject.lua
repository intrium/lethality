-- First load the GUI
local GUI = loadstring(game:HttpGet("YOUR_GUI_SCRIPT_URL"))()

-- Then load the ESP module
local ESPModule = loadstring(game:HttpGet("YOUR_ESP_SCRIPT_URL"))()

-- Initialize the ESP with your GUI
local destroyESP = ESPModule:Initialize(GUI)

-- If you ever need to disable the ESP completely
-- destroyESP()
