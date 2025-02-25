local SpeedModule = {}

-- Services
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local RootPart = Character:WaitForChild("HumanoidRootPart")
local Camera = workspace.CurrentCamera

-- Settings
local SpeedSettings = {
    Enabled = false,
    StrafeSpeed = 35,  -- Speed of strafing (higher = faster)
    JumpStrength = 100, -- Jump strength (higher = more height)
    HoldKey = Enum.KeyCode.Space, -- Key to hold for the effect
}

-- Debug Logging
local function Log(message)
    if SpeedSettings.Enabled then
        print("[SpeedModule]: " .. message)
    end
end

-- Variables
local IsJumping = false
local Velocity = Vector3.new(0, 0, 0)

-- Update Speed Module
local function UpdateSpeedModule()
    -- Check if SpeedModule is enabled
    if not SpeedSettings.Enabled then return end

-- Check if the spacebar is held down (for jumping/strafe movement)
    -- Apply strafe movement
    local moveDirection = Vector3.new(0, 0, 0)

    -- Move forward or backward (W/S keys)
    if UserInputService:IsKeyDown(Enum.KeyCode.W) then
        moveDirection = moveDirection + Camera.CFrame.LookVector
    elseif UserInputService:IsKeyDown(Enum.KeyCode.S) then
        moveDirection = moveDirection - Camera.CFrame.LookVector
    end

    -- Move left or right (A/D keys)
    if UserInputService:IsKeyDown(Enum.KeyCode.A) then
        moveDirection = moveDirection - Camera.CFrame.RightVector
    elseif UserInputService:IsKeyDown(Enum.KeyCode.D) then
        moveDirection = moveDirection + Camera.CFrame.RightVector
    end

    -- Normalize the direction and apply speed
    if moveDirection.Magnitude > 0 then
        moveDirection = moveDirection.Unit * SpeedSettings.StrafeSpeed
        RootPart.Velocity = Vector3.new(moveDirection.X, RootPart.Velocity.Y, moveDirection.Z)
    end

    -- Apply jump (forceful upwards movement)
    if not IsJumping and Humanoid:GetState() == Enum.HumanoidStateType.Physics and not Humanoid:GetPropertyChangedSignal("Jumping"):Wait() then
        IsJumping = true
        Humanoid:ChangeState(Enum.HumanoidStateType.Physics)
        Humanoid:Move(Vector3.new(0, SpeedSettings.JumpStrength, 0)) -- apply jump force
        Log("Jumping with strength: " .. SpeedSettings.JumpStrength)
    end
end

-- Enable/Disable SpeedModule
function SpeedModule:Toggle(enabled)
    SpeedSettings.Enabled = enabled
    Log(SpeedSettings.Enabled and "SpeedModule Enabled" or "SpeedModule Disabled")
end

-- Initialize SpeedModule
function SpeedModule:Initialize(GUI)
    -- Create Speed Category in the GUI
    local SpeedCategory = GUI:CreateCategory("SpeedModule")

    -- Add Toggle Button for Speed
    SpeedCategory:AddToggle("Enable Speed", function(enabled)
        SpeedSettings.Enabled = enabled
        Log(SpeedSettings.Enabled and "SpeedModule Enabled" or "SpeedModule Disabled")
    end, SpeedSettings.Enabled)

    -- Add Strafe Speed Slider
    SpeedCategory:AddSlider("Strafe Speed", 0, 200, SpeedSettings.StrafeSpeed, function(value)
        SpeedSettings.StrafeSpeed = value
        Log("Strafe Speed set to: " .. value)
    end)

    -- Add Jump Strength Slider
    SpeedCategory:AddSlider("Jump Strength", 0, 200, SpeedSettings.JumpStrength, function(value)
        SpeedSettings.JumpStrength = value
        Log("Jump Strength set to: " .. value)
    end)

    -- Add Keybind for Speed Toggle
    SpeedCategory:AddKeybind("Speed Keybind", SpeedSettings.HoldKey, function(key)
        SpeedSettings.HoldKey = key
        Log("Speed Keybind set to: " .. tostring(key))
    end)

    -- Bind the UpdateSpeedModule to the render step to keep it running
    RunService.RenderStepped:Connect(UpdateSpeedModule)
    Log("SpeedModule Initialized")
end

return SpeedModule
