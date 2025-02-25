-- Watermark Module for Lethality v1.0
local WatermarkModule = {}

-- Services
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local HttpService = game:GetService("HttpService")
local TextService = game:GetService("TextService")

-- Debug Logging (Reusing format for consistency)
local DebugSettings = {
    Enabled = false,
    LogLevel = 2, -- 1: Error only, 2: Warning+Error, 3: Info+Warning+Error, 4: Verbose
    LogToConsole = true,
    LogToGui = false,
    GuiOutput = nil -- Will be set during initialization if LogToGui is true
}

-- Debug logging function
local function Log(level, message, ...)
    if not DebugSettings.Enabled then return end
    
    local levelNames = {
        [1] = "ERROR",
        [2] = "WARNING",
        [3] = "INFO",
        [4] = "DEBUG"
    }
    
    if level <= DebugSettings.LogLevel then
        local formattedMessage = string.format("[Lethality Watermark][%s] %s", levelNames[level], string.format(message, ...))
        
        if DebugSettings.LogToConsole then
            print(formattedMessage)
        end
        
        if DebugSettings.LogToGui and DebugSettings.GuiOutput then
            DebugSettings.GuiOutput.Text = string.format("%s\n%s", formattedMessage, DebugSettings.GuiOutput.Text)
            -- Trim log if it gets too long
            if #DebugSettings.GuiOutput.Text > 5000 then
                DebugSettings.GuiOutput.Text = string.sub(DebugSettings.GuiOutput.Text, 1, 5000) .. "..."
            end
        end
    end
end

-- Watermark Settings
local WatermarkSettings = {
    Enabled = true,
    DisplayName = "lethaity", -- Default display name
    Position = UDim2.new(1, -10, 0, 10), -- Default position: top-right with 10px margin
    ShowFPS = true,
    ShowTime = true,
    ShowPing = true,
    ShowUsername = true,
    ShowServer = true,
    Theme = { -- Default color theme (Skeet/Gamesense green style)
        Background = Color3.fromRGB(0, 0, 0),
        Border = Color3.fromRGB(40, 40, 40),
        Text = Color3.fromRGB(255, 255, 255),
        Accent = Color3.fromRGB(124, 255, 124), -- Typical gamesense green
        Transparency = 0.8 -- Background transparency
    },
    RainbowBorder = false,
    RainbowSpeed = 1,
    UpdateInterval = 0.5, -- How often to update dynamic content (seconds)
    Format = "{displayname} | {time} | {fps} fps | {ping} ms | {username} | {server}"
}

-- Runtime variables
local Watermark = {
    Container = nil,
    Background = nil,
    Border = nil,
    Label = nil,
    RainbowConnection = nil,
    UpdateConnection = nil,
    LastUpdateTime = 0,
    LastFPSUpdateTime = 0,
    FrameCount = 0,
    CurrentFPS = 0
}

-- Helper functions
local function FormatTime()
    local time = os.date("*t")
    return string.format("%02d:%02d:%02d", time.hour, time.min, time.sec)
end

local function GetPing()
    local ping = LocalPlayer:GetNetworkPing() * 1000
    return math.floor(ping)
end

local function GetServerID()
    local jobId = game.JobId
    if jobId and #jobId > 0 then
        return string.sub(jobId, -8) -- Return last 8 chars of JobId
    else
        return "N/A"
    end
end

local function UpdateWatermarkText()
    if not Watermark.Label then return end
    
    -- Prepare template values
    local values = {
        displayname = WatermarkSettings.DisplayName,
        time = WatermarkSettings.ShowTime and FormatTime() or "",
        fps = WatermarkSettings.ShowFPS and tostring(Watermark.CurrentFPS) or "",
        ping = WatermarkSettings.ShowPing and tostring(GetPing()) or "",
        username = WatermarkSettings.ShowUsername and LocalPlayer.Name or "",
        server = WatermarkSettings.ShowServer and GetServerID() or ""
    }
    
    -- Apply template
    local text = WatermarkSettings.Format
    for key, value in pairs(values) do
        text = string.gsub(text, "{" .. key .. "}", value)
    end
    
    -- Remove unnecessary separators
    text = string.gsub(text, " | | ", " | ")
    text = string.gsub(text, "| | ", "| ")
    text = string.gsub(text, " | |", " |")
    text = string.gsub(text, "^| ", "")
    text = string.gsub(text, " |$", "")
    
    Watermark.Label.Text = text
    
    -- Calculate size required for text to auto-resize the background
    local textSize = TextService:GetTextSize(
        text,
        Watermark.Label.TextSize,
        Watermark.Label.Font,
        Vector2.new(1000, 100)
    )
    
    -- Update background size with padding
    local padding = 12 -- 6px padding on each side
    Watermark.Background.Size = UDim2.new(0, textSize.X + padding, 0, 28)
    
    -- Update border size to match
    Watermark.Border.Size = UDim2.new(1, 2, 1, 2)
    Watermark.Border.Position = UDim2.new(0, -1, 0, -1)
end

local function UpdateFPS()
    Watermark.FrameCount = Watermark.FrameCount + 1
    
    local currentTime = tick()
    local elapsed = currentTime - Watermark.LastFPSUpdateTime
    
    if elapsed >= 0.5 then -- Update FPS every 0.5 seconds
        Watermark.CurrentFPS = math.floor(Watermark.FrameCount / elapsed)
        Watermark.FrameCount = 0
        Watermark.LastFPSUpdateTime = currentTime
    end
end

local function UpdateRainbowBorder()
    if not WatermarkSettings.RainbowBorder or not Watermark.Border then return end
    
    local hue = (tick() * WatermarkSettings.RainbowSpeed) % 1
    Watermark.Border.BorderColor3 = Color3.fromHSV(hue, 1, 1)
end

local function CreateWatermark()
    -- Clean up any existing watermark
    if Watermark.Container then
        Watermark.Container:Destroy()
    end
    
    -- Create ScreenGui container
    Watermark.Container = Instance.new("ScreenGui")
    Watermark.Container.Name = "LethalityWatermark"
    Watermark.Container.ResetOnSpawn = false
    Watermark.Container.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    -- Create background frame
    Watermark.Background = Instance.new("Frame")
    Watermark.Background.Name = "Background"
    Watermark.Background.Size = UDim2.new(0, 300, 0, 28) -- Initial size, will be adjusted
    Watermark.Background.Position = WatermarkSettings.Position
    Watermark.Background.AnchorPoint = Vector2.new(1, 0) -- Anchored to top-right
    Watermark.Background.BackgroundColor3 = WatermarkSettings.Theme.Background
    Watermark.Background.BackgroundTransparency = WatermarkSettings.Theme.Transparency
    Watermark.Background.BorderSizePixel = 0
    Watermark.Background.Parent = Watermark.Container
    
    -- Create border frame
    Watermark.Border = Instance.new("Frame")
    Watermark.Border.Name = "Border"
    Watermark.Border.Size = UDim2.new(1, 2, 1, 2)
    Watermark.Border.Position = UDim2.new(0, -1, 0, -1)
    Watermark.Border.BackgroundTransparency = 1
    Watermark.Border.BorderSizePixel = 1
    Watermark.Border.BorderColor3 = WatermarkSettings.Theme.Border
    Watermark.Border.ZIndex = 0
    Watermark.Border.Parent = Watermark.Background
    
    -- Create text label
    Watermark.Label = Instance.new("TextLabel")
    Watermark.Label.Name = "WatermarkText"
    Watermark.Label.Size = UDim2.new(1, 0, 1, 0)
    Watermark.Label.BackgroundTransparency = 1
    Watermark.Label.Text = "lethaity"
    Watermark.Label.Font = Enum.Font.Code
    Watermark.Label.TextSize = 14
    Watermark.Label.TextColor3 = WatermarkSettings.Theme.Text
    Watermark.Label.Parent = Watermark.Background
    
    -- Make UI draggable
    local dragging = false
    local dragStart
    local startPos
    
    Watermark.Background.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = Watermark.Background.Position
        end
    end)
    
    Watermark.Background.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    Watermark.Container.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            Watermark.Background.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
            WatermarkSettings.Position = Watermark.Background.Position
        end
    end)
    
    -- Update initial text
    UpdateWatermarkText()
    
    -- Parent the ScreenGui to the appropriate place
    if game:GetService("RunService"):IsStudio() then
        Watermark.Container.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
    else
        Watermark.Container.Parent = game.CoreGui
    end
    
    -- Set up connections
    if Watermark.UpdateConnection then
        Watermark.UpdateConnection:Disconnect()
    end
    
    Watermark.UpdateConnection = RunService.RenderStepped:Connect(function()
        -- Update FPS counter
        UpdateFPS()
        
        -- Update watermark content periodically
        local currentTime = tick()
        if currentTime - Watermark.LastUpdateTime >= WatermarkSettings.UpdateInterval then
            UpdateWatermarkText()
            Watermark.LastUpdateTime = currentTime
        end
        
        -- Update rainbow border if enabled
        UpdateRainbowBorder()
    end)
    
    Log(3, "Watermark created successfully")
end

function WatermarkModule:Initialize(GUI)
    Log(3, "Initializing Watermark Module")
    
    -- Create Watermark Category
    local WatermarkCategory = GUI:CreateCategory("Watermark")
    local DebugCategory = GUI:CreateCategory("Watermark Debug")
    
    -- Debug Toggle
    DebugCategory:AddToggle("Debug Logging", function(enabled)
        DebugSettings.Enabled = enabled
        Log(3, "Debug logging %s", enabled and "enabled" or "disabled")
    end, DebugSettings.Enabled)
    
    -- Main Toggle
    WatermarkCategory:AddToggle("Watermark Enabled", function(enabled)
        WatermarkSettings.Enabled = enabled
        Log(3, "Watermark %s", enabled and "enabled" or "disabled")
        
        if Watermark.Container then
            Watermark.Container.Enabled = enabled
        end
        
        if enabled and not Watermark.Container then
            CreateWatermark()
        end
    end, WatermarkSettings.Enabled)
    
    -- Watermark Text
    WatermarkCategory:AddTextbox("Display Name", WatermarkSettings.DisplayName, function(text)
        WatermarkSettings.DisplayName = text
        Log(3, "Display Name set to: %s", text)
        UpdateWatermarkText()
    end)
    
    -- Format String
    WatermarkCategory:AddTextbox("Format", WatermarkSettings.Format, function(text)
        WatermarkSettings.Format = text
        Log(3, "Format set to: %s", text)
        UpdateWatermarkText()
    end)
    
    -- Display Toggles
    WatermarkCategory:AddToggle("Show FPS", function(enabled)
        WatermarkSettings.ShowFPS = enabled
        Log(3, "Show FPS %s", enabled and "enabled" or "disabled")
        UpdateWatermarkText()
    end, WatermarkSettings.ShowFPS)
    
    WatermarkCategory:AddToggle("Show Time", function(enabled)
        WatermarkSettings.ShowTime = enabled
        Log(3, "Show Time %s", enabled and "enabled" or "disabled")
        UpdateWatermarkText()
    end, WatermarkSettings.ShowTime)
    
    WatermarkCategory:AddToggle("Show Ping", function(enabled)
        WatermarkSettings.ShowPing = enabled
        Log(3, "Show Ping %s", enabled and "enabled" or "disabled")
        UpdateWatermarkText()
    end, WatermarkSettings.ShowPing)
    
    WatermarkCategory:AddToggle("Show Username", function(enabled)
        WatermarkSettings.ShowUsername = enabled
        Log(3, "Show Username %s", enabled and "enabled" or "disabled")
        UpdateWatermarkText()
    end, WatermarkSettings.ShowUsername)
    
    WatermarkCategory:AddToggle("Show Server ID", function(enabled)
        WatermarkSettings.ShowServer = enabled
        Log(3, "Show Server ID %s", enabled and "enabled" or "disabled")
        UpdateWatermarkText()
    end, WatermarkSettings.ShowServer)
    
    -- Rainbow Border
    WatermarkCategory:AddToggle("Rainbow Border", function(enabled)
        WatermarkSettings.RainbowBorder = enabled
        Log(3, "Rainbow Border %s", enabled and "enabled" or "disabled")
        
        if not enabled and Watermark.Border then
            Watermark.Border.BorderColor3 = WatermarkSettings.Theme.Border
        end
    end, WatermarkSettings.RainbowBorder)
    
    -- Rainbow Speed
    WatermarkCategory:AddSlider("Rainbow Speed", 0.1, 5, WatermarkSettings.RainbowSpeed, function(value)
        WatermarkSettings.RainbowSpeed = value
        Log(3, "Rainbow Speed set to: %.2f", value)
    end)
    
    -- Background Transparency
    WatermarkCategory:AddSlider("Transparency", 0, 1, WatermarkSettings.Theme.Transparency, function(value)
        WatermarkSettings.Theme.Transparency = value
        Log(3, "Transparency set to: %.2f", value)
        
        if Watermark.Background then
            Watermark.Background.BackgroundTransparency = value
        end
    end)
    
    -- Color Pickers
    WatermarkCategory:AddColorPicker("Background Color", WatermarkSettings.Theme.Background, function(color)
        WatermarkSettings.Theme.Background = color
        Log(3, "Background Color updated")
        
        if Watermark.Background then
            Watermark.Background.BackgroundColor3 = color
        end
    end)
    
    WatermarkCategory:AddColorPicker("Border Color", WatermarkSettings.Theme.Border, function(color)
        WatermarkSettings.Theme.Border = color
        Log(3, "Border Color updated")
        
        if Watermark.Border and not WatermarkSettings.RainbowBorder then
            Watermark.Border.BorderColor3 = color
        end
    end)
    
    WatermarkCategory:AddColorPicker("Text Color", WatermarkSettings.Theme.Text, function(color)
        WatermarkSettings.Theme.Text = color
        Log(3, "Text Color updated")
        
        if Watermark.Label then
            Watermark.Label.TextColor3 = color
        end
    end)
    
    WatermarkCategory:AddColorPicker("Accent Color", WatermarkSettings.Theme.Accent, function(color)
        WatermarkSettings.Theme.Accent = color
        Log(3, "Accent Color updated")
        -- Accent color can be used for highlighting specific parts of the watermark
    end)
    
    -- Update Interval
    WatermarkCategory:AddSlider("Update Interval", 0.1, 2, WatermarkSettings.UpdateInterval, function(value)
        WatermarkSettings.UpdateInterval = value
        Log(3, "Update Interval set to: %.2f seconds", value)
    end)
    
    -- Reset Position Button
    WatermarkCategory:AddButton("Reset Position", function()
        WatermarkSettings.Position = UDim2.new(1, -10, 0, 10)
        Log(3, "Position reset to default")
        
        if Watermark.Background then
            Watermark.Background.Position = WatermarkSettings.Position
        end
    end)
    
    -- Create initial watermark if enabled
    if WatermarkSettings.Enabled then
        CreateWatermark()
    end
    
    -- Log successful initialization
    Log(2, "Watermark Module successfully initialized")
    
    -- Return destructor function
    return function()
        Log(2, "Watermark Module shutting down")
        
        if Watermark.UpdateConnection then
            Watermark.UpdateConnection:Disconnect()
            Watermark.UpdateConnection = nil
        end
        
        if Watermark.Container then
            Watermark.Container:Destroy()
            Watermark.Container = nil
        end
    end
end

return WatermarkModule
