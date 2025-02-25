-- Watermark Module for Lethality v3 (Skeet/GameSense Style)
local WatermarkModule = {}

-- Services
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")

-- Watermark Settings
local WatermarkSettings = {
    Enabled = true,
    Text = "lethality.cc",
    Position = UDim2.new(0, 10, 0, 10),
    Font = Enum.Font.Code,
    Rainbow = false,
    RainbowSpeed = 0.5,
    Transparency = 0.6,
    RainbowBar = true
}

-- UI Elements
local Watermark = {
    Container = nil,
    TextLabel = nil,
    Background = nil,
    RainbowBar = nil
}

-- Rainbow Color Function
local function GetRainbowColor()
    local hue = tick() * WatermarkSettings.RainbowSpeed % 1
    return Color3.fromHSV(hue, 0.65, 1)
end

-- Typing Animation Function
local function StartTypingAnimation()
    local baseText = "lethality.cc"
    local delayTime = 0.1
    while true do
        for i = 1, #baseText do
            Watermark.TextLabel.Text = string.sub(baseText, 1, i)
            task.wait(delayTime)
        end
        task.wait(1)
        for i = #baseText, 1, -1 do
            Watermark.TextLabel.Text = string.sub(baseText, 1, i)
            task.wait(delayTime)
        end
        task.wait(1)
    end
end

-- FPS Counter Function
local lastUpdate = tick()
local fps = 0
RunService.RenderStepped:Connect(function()
    local now = tick()
    fps = math.floor(1 / (now - lastUpdate))
    lastUpdate = now
end)

-- Create Watermark UI
local function CreateWatermarkUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "LethalityWatermark"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.Parent = CoreGui
    
    local container = Instance.new("Frame")
    container.Name = "WatermarkContainer"
    container.BackgroundTransparency = 1
    container.Position = WatermarkSettings.Position
    container.Parent = screenGui
    Watermark.Container = container
    
    local background = Instance.new("Frame")
    background.Name = "WatermarkBackground"
    background.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    background.BorderSizePixel = 1
    background.BorderColor3 = Color3.fromRGB(100, 100, 100)
    background.Parent = container
    Watermark.Background = background
    
    local rainbowBar = Instance.new("Frame")
    rainbowBar.Name = "WatermarkRainbowBar"
    rainbowBar.BackgroundColor3 = GetRainbowColor()
    rainbowBar.Size = UDim2.new(1, 0, 0, 2)
    rainbowBar.Position = UDim2.new(0, 0, 0, -2)
    rainbowBar.Parent = container
    Watermark.RainbowBar = rainbowBar
    
    local textLabel = Instance.new("TextLabel")
    textLabel.Name = "WatermarkText"
    textLabel.BackgroundTransparency = 1
    textLabel.Font = WatermarkSettings.Font
    textLabel.TextSize = 16
    textLabel.TextColor3 = WatermarkSettings.Rainbow and GetRainbowColor() or Color3.fromRGB(255, 255, 255)
    textLabel.TextXAlignment = Enum.TextXAlignment.Left
    textLabel.Parent = container
    Watermark.TextLabel = textLabel
    
    RunService.RenderStepped:Connect(function()
        textLabel.Text = string.format("%s | FPS: %d | User: %s", WatermarkSettings.Text, fps, Players.LocalPlayer.Name)
        textLabel.Size = UDim2.new(0, textLabel.TextBounds.X + 10, 0, textLabel.TextBounds.Y + 4)
        container.Size = textLabel.Size
        background.Size = textLabel.Size
    end)
    
    task.spawn(StartTypingAnimation)
    
    return screenGui
end

-- Drag Functionality
local dragging, dragStart, startPos
local function OnInputBegan(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = Watermark.Container.Position
    end
end

local function OnInputChanged(input)
    if dragging then
        local delta = input.Position - dragStart
        Watermark.Container.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end

local function OnInputEnded(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end

-- Initialize Watermark Module
function WatermarkModule:Initialize()
    local watermarkGui = CreateWatermarkUI()
    
    Watermark.Container.InputBegan:Connect(OnInputBegan)
    Watermark.Container.InputChanged:Connect(OnInputChanged)
    Watermark.Container.InputEnded:Connect(OnInputEnded)
    
    RunService.RenderStepped:Connect(function()
        if WatermarkSettings.Rainbow then
            Watermark.TextLabel.TextColor3 = GetRainbowColor()
        end
        if WatermarkSettings.RainbowBar then
            Watermark.RainbowBar.BackgroundColor3 = GetRainbowColor()
        end
    end)
    
    return function()
        watermarkGui:Destroy()
    end
end

return WatermarkModule