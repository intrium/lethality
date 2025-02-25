-- Triggerbot Module for Lethality v1.1
local TriggerbotModule = {}

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager") -- More reliable input simulation
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- Debug Logging (Reusing ESP's format for consistency)
local DebugSettings = {
    Enabled = false,
    LogLevel = 2, -- 1: Error only, 2: Warning+Error, 3: Info+Warning+Error, 4: Verbose
    LogToConsole = true,
    LogToGui = false,
    GuiOutput = nil -- Will be set during initialization if LogToGui is true
}

-- Triggerbot Settings
local TriggerbotSettings = {
    Enabled = false,
    TeamCheck = true,
    VisibilityCheck = true,
    TriggerDelay = 0.1, -- Delay in seconds before firing
    MaxDistance = 1000,
    HitboxExpansion = 0.1, -- Expands target hitbox by this factor (0.1 = 10%)
    HoldMode = false, -- If true, fires continuously while target is in crosshair
    HeadshotsOnly = false, -- If true, only triggers on headshots
    TriggerKey = Enum.KeyCode.E, -- Default trigger key
    UseKeybind = true, -- If false, triggerbot is always active when enabled
    IgnoreLocalPlayer = true, -- Don't trigger on self
    SafetyPause = 0.05 -- Safety pause between clicks in seconds
}

-- Runtime variables
local IsFiring = false
local LastTarget = nil
local DelayStartTime = 0
local TriggerState = false
local LastClickTime = 0
local MouseFunctions = {
    press = nil,
    release = nil
}

-- Debug logging function (same as in ESP module)
local function Log(level, message, ...)
    if not DebugSettings.Enabled then return end
    
    local levelNames = {
        [1] = "ERROR",
        [2] = "WARNING",
        [3] = "INFO",
        [4] = "DEBUG"
    }
    
    if level <= DebugSettings.LogLevel then
        local formattedMessage = string.format("[Lethality Triggerbot][%s] %s", levelNames[level], string.format(message, ...))
        
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

-- Function to check if a player is a valid target
local function IsValidTarget(player)
    -- Skip if it's the local player and we're ignoring self
    if player == LocalPlayer and TriggerbotSettings.IgnoreLocalPlayer then
        return false
    end
    
    -- Check if player still exists
    if not player or not player:IsDescendantOf(Players) then
        return false
    end
    
    -- Team check
    if TriggerbotSettings.TeamCheck and player.Team == LocalPlayer.Team and player ~= LocalPlayer then
        Log(4, "Player on same team, ignoring: %s", player.Name)
        return false
    end
    
    -- Character check
    local character = player.Character
    if not character then
        return false
    end
    
    -- Humanoid check (is player alive?)
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid or humanoid.Health <= 0 then
        return false
    end
    
    -- Get root part or head
    local targetPart = character:FindFirstChild(TriggerbotSettings.HeadshotsOnly and "Head" or "HumanoidRootPart")
    if not targetPart then
        -- Fallback to torso parts if normal parts aren't found
        targetPart = character:FindFirstChild("Torso") or 
                     character:FindFirstChild("UpperTorso") or 
                     character:FindFirstChild("Head")
        
        if not targetPart then
            return false
        end
    end
    
    -- Distance check
    local distance = (targetPart.Position - Camera.CFrame.Position).Magnitude
    if distance > TriggerbotSettings.MaxDistance then
        return false
    end
    
    -- Check if target is visible
    if TriggerbotSettings.VisibilityCheck then
        local ray = Ray.new(Camera.CFrame.Position, (targetPart.Position - Camera.CFrame.Position).Unit * distance)
        local hit, hitPos = workspace:FindPartOnRayWithIgnoreList(ray, {LocalPlayer.Character, Camera})
        
        if hit and hit:IsDescendantOf(character) then
            Log(4, "Visibility check passed for %s", player.Name)
        else
            Log(4, "Visibility check failed for %s", player.Name)
            return false
        end
    end
    
    return true, targetPart
end

-- Setup mouse functions
local function SetupMouseFunctions()
    -- Try to use standard functions if available
    if mouse1press and mouse1release then
        Log(3, "Using standard mouse functions")
        MouseFunctions.press = mouse1press
        MouseFunctions.release = mouse1release
        return true
    end
    
    -- Try to use VirtualInputManager as a backup
    if VirtualInputManager then
        Log(3, "Using VirtualInputManager for mouse input")
        MouseFunctions.press = function()
            VirtualInputManager:SendMouseButtonEvent(UserInputService:GetMouseLocation().X, UserInputService:GetMouseLocation().Y, 0, true, game, 0)
        end
        MouseFunctions.release = function()
            VirtualInputManager:SendMouseButtonEvent(UserInputService:GetMouseLocation().X, UserInputService:GetMouseLocation().Y, 0, false, game, 0)
        end
        return true
    end
    
    -- Last resort - try direct mouse simulation with VIM with different parameters
    Log(2, "WARNING: Standard mouse functions not available, trying alternative method")
    MouseFunctions.press = function()
        local mousePos = UserInputService:GetMouseLocation()
        VirtualInputManager:SendMouseButtonEvent(mousePos.X, mousePos.Y, 0, true, game, 1)
    end
    MouseFunctions.release = function()
        local mousePos = UserInputService:GetMouseLocation()
        VirtualInputManager:SendMouseButtonEvent(mousePos.X, mousePos.Y, 0, false, game, 1)
    end
    return true
end

-- Function to simulate mouse click
local function SimulateMouseClick()
    -- Safety check for mouse functions
    if not MouseFunctions.press or not MouseFunctions.release then
        Log(1, "Mouse functions not available")
        return
    end
    
    -- Safety timer to prevent too frequent clicks
    local currentTime = tick()
    if currentTime - LastClickTime < TriggerbotSettings.SafetyPause then
        return
    end
    LastClickTime = currentTime
    
    -- Only trigger if not currently firing
    if not IsFiring then
        IsFiring = true
        Log(3, "Simulating mouse down")
        
        -- Simulate mouse down
        pcall(function()
            MouseFunctions.press()
        end)
        
        -- If not in hold mode, release after a short delay
        if not TriggerbotSettings.HoldMode then
            task.delay(0.05, function()
                Log(3, "Simulating mouse up")
                pcall(function()
                    MouseFunctions.release()
                end)
                IsFiring = false
            end)
        end
    elseif TriggerbotSettings.HoldMode and not LastTarget then
        -- If in hold mode but no target, release mouse
        Log(3, "No target, simulating mouse up")
        pcall(function()
            MouseFunctions.release()
        end)
        IsFiring = false
    end
end

-- Function to release mouse if needed
local function ReleaseMouseIfNeeded()
    if IsFiring and MouseFunctions.release then
        Log(3, "Target lost, simulating mouse up")
        pcall(function()
            MouseFunctions.release()
        end)
        IsFiring = false
    end
end

-- Function to get the part under the crosshair
local function GetCrosshairTarget()
    local mousePos = UserInputService:GetMouseLocation()
    local viewportPointRay = Camera:ViewportPointToRay(mousePos.X, mousePos.Y)
    
    local ray = Ray.new(viewportPointRay.Origin, viewportPointRay.Direction * TriggerbotSettings.MaxDistance)
    local hit, hitPos, hitNormal = workspace:FindPartOnRayWithIgnoreList(ray, {LocalPlayer.Character, Camera})
    
    if hit then
        local model = hit:FindFirstAncestorOfClass("Model")
        if model then
            local player = Players:GetPlayerFromCharacter(model)
            if player then
                local isValid, targetPart = IsValidTarget(player)
                if isValid then
                    -- Check if we're targeting the head if headshots only is enabled
                    if TriggerbotSettings.HeadshotsOnly and hit.Name ~= "Head" then
                        Log(4, "Not a headshot, ignoring: %s (Hit part: %s)", player.Name, hit.Name)
                        return nil, nil
                    end
                    
                    Log(4, "Valid target detected: %s (Part: %s)", player.Name, hit.Name)
                    return player, hit
                end
            end
        end
    end
    
    return nil, nil
end

-- Function to check for closest valid target (alternative detection method)
local function GetClosestTarget()
    local closest = nil
    local closestDistance = TriggerbotSettings.MaxDistance
    local closestPart = nil
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer or not TriggerbotSettings.IgnoreLocalPlayer then
            local isValid, targetPart = IsValidTarget(player)
            if isValid and targetPart then
                local targetPos = targetPart.Position
                local screenPos, onScreen = Camera:WorldToViewportPoint(targetPos)
                
                if onScreen then
                    local mousePos = UserInputService:GetMouseLocation()
                    local distance2D = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                    
                    -- If the target is close to the crosshair (within 50 pixels)
                    if distance2D < 50 and screenPos.Z < closestDistance then
                        closest = player
                        closestDistance = screenPos.Z
                        closestPart = targetPart
                    end
                end
            end
        end
    end
    
    return closest, closestPart
end

-- Function to update the triggerbot
local function UpdateTriggerbot()
    -- Check if the triggerbot is enabled and appropriate key is pressed
    local shouldTrigger = TriggerbotSettings.Enabled and 
                         (not TriggerbotSettings.UseKeybind or TriggerState)
    
    if not shouldTrigger then
        ReleaseMouseIfNeeded()
        LastTarget = nil
        DelayStartTime = 0
        return
    end
    
    -- Try both detection methods
    local target, hitPart = GetCrosshairTarget()
    
    -- If the first method fails, try the alternative method
    if not target then
        target, hitPart = GetClosestTarget()
    end
    
    -- Update the last target
    LastTarget = target
    
    -- If there's a target, start the trigger delay
    if target then
        local currentTime = tick()
        
        -- If we haven't started the delay yet, start it
        if DelayStartTime == 0 then
            DelayStartTime = currentTime
            Log(3, "Target acquired: %s, starting delay of %.3fs", target.Name, TriggerbotSettings.TriggerDelay)
        end
        
        -- If the delay has elapsed, trigger
        if currentTime - DelayStartTime >= TriggerbotSettings.TriggerDelay then
            Log(3, "Delay elapsed, triggering on %s", target.Name)
            SimulateMouseClick()
        end
    else
        -- No target, reset the delay
        if DelayStartTime ~= 0 then
            Log(4, "Target lost, resetting delay")
            DelayStartTime = 0
        end
        
        ReleaseMouseIfNeeded()
    end
end

-- Initialize Triggerbot
function TriggerbotModule:Initialize(GUI)
    Log(3, "Initializing Triggerbot Module")
    
    -- Setup mouse functions
    if not SetupMouseFunctions() then
        Log(1, "Failed to set up mouse functions")
        return function() end -- Return empty destructor
    end
    
    -- Create Triggerbot Category
    local TriggerbotCategory = GUI:CreateCategory("Triggerbot")
    local DebugCategory = GUI:CreateCategory("Triggerbot Debug")
    
    -- Debug Toggle
    DebugCategory:AddToggle("Debug Logging", function(enabled)
        DebugSettings.Enabled = enabled
        Log(3, "Debug logging %s", enabled and "enabled" or "disabled")
    end, DebugSettings.Enabled)
    
    -- Debug Test Button
    DebugCategory:AddButton("Test Mouse Click", function()
        Log(2, "Testing mouse click")
        if MouseFunctions.press and MouseFunctions.release then
            pcall(function() 
                MouseFunctions.press() 
                task.wait(0.1)
                MouseFunctions.release()
            end)
            Log(3, "Mouse click test completed")
        else
            Log(1, "Mouse functions not available")
        end
    end)
    
    -- Main Toggle
    TriggerbotCategory:AddToggle("Triggerbot Enabled", function(enabled)
        TriggerbotSettings.Enabled = enabled
        Log(3, "Triggerbot %s", enabled and "enabled" or "disabled")
    end)
    
    -- Team Check
    TriggerbotCategory:AddToggle("Team Check", function(enabled)
        TriggerbotSettings.TeamCheck = enabled
        Log(3, "Team Check %s", enabled and "enabled" or "disabled")
    end, TriggerbotSettings.TeamCheck)
    
    -- Visibility Check
    TriggerbotCategory:AddToggle("Visibility Check", function(enabled)
        TriggerbotSettings.VisibilityCheck = enabled
        Log(3, "Visibility Check %s", enabled and "enabled" or "disabled")
    end, TriggerbotSettings.VisibilityCheck)
    
    -- Hold Mode
    TriggerbotCategory:AddToggle("Hold Fire Mode", function(enabled)
        TriggerbotSettings.HoldMode = enabled
        Log(3, "Hold Mode %s", enabled and "enabled" or "disabled")
    end, TriggerbotSettings.HoldMode)
    
    -- Headshots Only
    TriggerbotCategory:AddToggle("Headshots Only", function(enabled)
        TriggerbotSettings.HeadshotsOnly = enabled
        Log(3, "Headshots Only %s", enabled and "enabled" or "disabled")
    end, TriggerbotSettings.HeadshotsOnly)
    
    -- Use Keybind
    TriggerbotCategory:AddToggle("Use Keybind", function(enabled)
        TriggerbotSettings.UseKeybind = enabled
        Log(3, "Keybind Usage %s", enabled and "enabled" or "disabled")
    end, TriggerbotSettings.UseKeybind)
    
    -- Trigger Delay
    TriggerbotCategory:AddSlider("Trigger Delay", 0, 1, TriggerbotSettings.TriggerDelay, function(value)
        TriggerbotSettings.TriggerDelay = value
        Log(3, "Trigger Delay set to: %.3f seconds", value)
    end)
    
    -- Max Distance
    TriggerbotCategory:AddSlider("Max Distance", 100, 5000, TriggerbotSettings.MaxDistance, function(value)
        TriggerbotSettings.MaxDistance = value
        Log(3, "Max Distance set to: %.1f", value)
    end)
    
    -- Safety Pause
    TriggerbotCategory:AddSlider("Safety Pause", 0, 0.5, TriggerbotSettings.SafetyPause, function(value)
        TriggerbotSettings.SafetyPause = value
        Log(3, "Safety Pause set to: %.3f seconds", value)
    end)
    
    -- Keybind setup
    TriggerbotCategory:AddKeybind("Trigger Key", TriggerbotSettings.TriggerKey, function(key)
        TriggerbotSettings.TriggerKey = key
        Log(3, "Trigger Key set to: %s", tostring(key))
    end)
    
    -- Handle input detection for keybind
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        
        TriggerState = true
        Log(4, "Trigger key pressed")
    end)
    
    UserInputService.InputEnded:Connect(function(input, gameProcessed)
        TriggerState = false
        Log(4, "Trigger key released")
        
        -- If we were firing and not in hold mode, release mouse
        if IsFiring and not TriggerbotSettings.HoldMode then
            Log(3, "Key released, simulating mouse up")
            pcall(function() 
                MouseFunctions.release() 
            end)
            IsFiring = false
        end
    end)
    
    -- Update Triggerbot on each frame
    Log(3, "Binding Triggerbot update to RenderStep")
    RunService:BindToRenderStep("LethalityTriggerbot", 199, UpdateTriggerbot) -- Priority just below ESP
    
    -- Log successful initialization
    Log(2, "Triggerbot Module successfully initialized")
    
    -- Return destructor function
    return function()
        Log(2, "Triggerbot Module shutting down")
        RunService:UnbindFromRenderStep("LethalityTriggerbot")
        
        -- Ensure mouse is released
        if IsFiring and MouseFunctions.release then
            pcall(function() 
                MouseFunctions.release() 
            end)
            IsFiring = false
        end
    end
end

return TriggerbotModule
