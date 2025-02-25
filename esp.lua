-- ESP Module for Lethality v4
local ESPModule = {}

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- Debug Logging
local DebugSettings = {
    Enabled = false,
    LogLevel = 2, -- 1: Error only, 2: Warning+Error, 3: Info+Warning+Error, 4: Verbose
    LogToConsole = true,
    LogToGui = false,
    GuiOutput = nil -- Will be set during initialization if LogToGui is true
}

-- ESP Settings
local ESPSettings = {
    Enabled = false,
    BoxesEnabled = true,
    NamesEnabled = true,
    DistanceEnabled = true,
    TracersEnabled = false,
    TeamCheck = true,
    TeamColor = false,
    ShowLocalPlayer = false, -- Added boolean for local player rendering
    BoxColor = Color3.fromRGB(255, 0, 0),
    BoxTransparency = 0.5,
    NameColor = Color3.fromRGB(255, 255, 255),
    DistanceColor = Color3.fromRGB(200, 200, 200),
    TracerColor = Color3.fromRGB(255, 0, 0),
    TracerTransparency = 0.5,
    TracerOrigin = "Bottom", -- "Bottom", "Center", "Mouse"
    FontSize = 14,
    MaxDisplayDistance = 1000
}

-- ESP Objects
local ESPObjects = {}

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
        local formattedMessage = string.format("[Lethality ESP][%s] %s", levelNames[level], string.format(message, ...))
        
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

-- Function to create/update ESP objects
local function CreateESP(player)
    -- Skip if it's the local player and we don't want to show them
    if player == LocalPlayer and not ESPSettings.ShowLocalPlayer then 
        Log(3, "Skipping ESP creation for LocalPlayer (ShowLocalPlayer is disabled)")
        return 
    end
    
    -- Create ESP objects for this player if they don't exist
    if not ESPObjects[player] then
        Log(3, "Creating new ESP objects for player: %s", player.Name)
        ESPObjects[player] = {
            Box = Drawing.new("Square"),
            Name = Drawing.new("Text"),
            Distance = Drawing.new("Text"),
            Tracer = Drawing.new("Line")
        }
    end
    
    -- Get ESP objects for this player
    local Objects = ESPObjects[player]
    
    -- Update Box
    Objects.Box.Thickness = 1
    Objects.Box.Filled = false
    Objects.Box.ZIndex = 1
    Objects.Box.Color = ESPSettings.BoxColor
    Objects.Box.Transparency = ESPSettings.BoxTransparency
    Objects.Box.Visible = false -- Will be updated in UpdateESP
    
    -- Update Name
    Objects.Name.Font = 2
    Objects.Name.Size = ESPSettings.FontSize
    Objects.Name.Center = true
    Objects.Name.Outline = true
    Objects.Name.Color = ESPSettings.NameColor
    Objects.Name.ZIndex = 2
    Objects.Name.Visible = false -- Will be updated in UpdateESP
    
    -- Update Distance
    Objects.Distance.Font = 2
    Objects.Distance.Size = ESPSettings.FontSize - 1
    Objects.Distance.Center = true
    Objects.Distance.Outline = true
    Objects.Distance.Color = ESPSettings.DistanceColor
    Objects.Distance.ZIndex = 2
    Objects.Distance.Visible = false -- Will be updated in UpdateESP
    
    -- Update Tracer
    Objects.Tracer.Thickness = 1
    Objects.Tracer.ZIndex = 1
    Objects.Tracer.Color = ESPSettings.TracerColor
    Objects.Tracer.Transparency = ESPSettings.TracerTransparency
    Objects.Tracer.Visible = false -- Will be updated in UpdateESP
    
    Log(4, "ESP objects updated for player: %s", player.Name)
end

-- Function to remove ESP objects
local function RemoveESP(player)
    if ESPObjects[player] then
        Log(3, "Removing ESP objects for player: %s", player.Name)
        for _, Object in pairs(ESPObjects[player]) do
            Object:Remove()
        end
        ESPObjects[player] = nil
    end
end

-- Function to get character parts
local function GetCharacterParts(character)
    local head = character:FindFirstChild("Head")
    local rootPart = character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("Torso") or character:FindFirstChild("UpperTorso")
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    
    if not rootPart then
        Log(2, "Could not find root part for character")
    end
    if not humanoid then
        Log(2, "Could not find humanoid for character")
    end
    
    return head, rootPart, humanoid
end

-- Function to update ESP objects visibility
local function UpdateESP()
    local activePlayers = 0
    local visibleESP = 0
    
    for player, Objects in pairs(ESPObjects) do
        -- Check if player still exists
        if not player or not player:IsDescendantOf(Players) then
            Log(3, "Player no longer exists, removing ESP: %s", player and player.Name or "Unknown")
            RemoveESP(player)
            continue
        end
        
        activePlayers = activePlayers + 1
        
        -- Hide ESP for local player if not enabled
        if player == LocalPlayer and not ESPSettings.ShowLocalPlayer then
            for _, Object in pairs(Objects) do
                Object.Visible = false
            end
            Log(4, "LocalPlayer ESP hidden (ShowLocalPlayer is disabled)")
            continue
        end
        
        -- Get character and its parts
        local character = player.Character
        if not character then
            for _, Object in pairs(Objects) do
                Object.Visible = false
            end
            Log(4, "No character found for player: %s", player.Name)
            continue
        end
        
        local head, rootPart, humanoid = GetCharacterParts(character)
        
        -- Check if character has necessary parts and is alive
        if not rootPart or not humanoid or humanoid.Health <= 0 then
            for _, Object in pairs(Objects) do
                Object.Visible = false
            end
            if not rootPart then
                Log(4, "No root part found for player: %s", player.Name)
            elseif not humanoid then
                Log(4, "No humanoid found for player: %s", player.Name)
            elseif humanoid.Health <= 0 then
                Log(4, "Player is dead: %s (Health: %.1f)", player.Name, humanoid.Health)
            end
            continue
        end
        
        -- Team check
        if ESPSettings.TeamCheck and player.Team == LocalPlayer.Team and player ~= LocalPlayer then
            for _, Object in pairs(Objects) do
                Object.Visible = false
            end
            Log(4, "Player on same team, ESP hidden: %s (Team: %s)", player.Name, player.Team and player.Team.Name or "None")
            continue
        end
        
        -- Get player's position and check if they're on screen
        local position, onScreen = Camera:WorldToViewportPoint(rootPart.Position)
        local distance = (rootPart.Position - Camera.CFrame.Position).Magnitude
        
        -- Check if player is too far
        if distance > ESPSettings.MaxDisplayDistance then
            for _, Object in pairs(Objects) do
                Object.Visible = false
            end
            Log(4, "Player too far, ESP hidden: %s (Distance: %.1f, Max: %.1f)", player.Name, distance, ESPSettings.MaxDisplayDistance)
            continue
        end
        
        -- Set base visibility condition
        local baseVisibility = onScreen and ESPSettings.Enabled
        
        -- If not on screen or ESP not enabled, hide everything
        if not baseVisibility then
            for _, Object in pairs(Objects) do
                Object.Visible = false
            end
            if not onScreen then
                Log(4, "Player not on screen, ESP hidden: %s", player.Name)
            elseif not ESPSettings.Enabled then
                Log(4, "ESP disabled globally, ESP hidden: %s", player.Name)
            end
            continue
        end
        
        -- Calculate character dimensions
        local topPosition = rootPart.Position + Vector3.new(0, humanoid.HipHeight * 2, 0)
        local bottomPosition = rootPart.Position - Vector3.new(0, humanoid.HipHeight, 0)
        
        local topScreenPosition = Camera:WorldToViewportPoint(topPosition)
        local bottomScreenPosition = Camera:WorldToViewportPoint(bottomPosition)
        
        local height = math.abs(topScreenPosition.Y - bottomScreenPosition.Y)
        local width = height * 0.6
        
        -- Calculate box position
        local boxPosition = Vector2.new(position.X - width/2, position.Y - height/2)
        local boxSize = Vector2.new(width, height)
        
        -- Set color based on team settings
        local playerColor = ESPSettings.BoxColor
        if ESPSettings.TeamColor and player.Team then
            playerColor = player.TeamColor.Color
            Log(4, "Using team color for player: %s (Team: %s, Color: %.2f, %.2f, %.2f)", 
                player.Name, player.Team.Name, playerColor.R, playerColor.G, playerColor.B)
        end
        
        -- Update Box
        Objects.Box.Color = playerColor
        Objects.Box.Size = boxSize
        Objects.Box.Position = boxPosition
        Objects.Box.Visible = baseVisibility and ESPSettings.BoxesEnabled
        
        -- Update Name
        Objects.Name.Text = player.Name
        Objects.Name.Position = Vector2.new(position.X, boxPosition.Y - 18)
        Objects.Name.Visible = baseVisibility and ESPSettings.NamesEnabled
        
        -- Update Distance
        Objects.Distance.Text = string.format("%.1f m", distance)
        Objects.Distance.Position = Vector2.new(position.X, boxPosition.Y + boxSize.Y + 8)
        Objects.Distance.Visible = baseVisibility and ESPSettings.DistanceEnabled
        
        -- Update Tracer
        local tracerOrigin = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
        if ESPSettings.TracerOrigin == "Center" then
            tracerOrigin = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
        elseif ESPSettings.TracerOrigin == "Mouse" then
            local mouse = game:GetService("UserInputService"):GetMouseLocation()
            tracerOrigin = Vector2.new(mouse.X, mouse.Y)
        end
        
        Objects.Tracer.Color = playerColor
        Objects.Tracer.From = tracerOrigin
        Objects.Tracer.To = Vector2.new(position.X, position.Y)
        Objects.Tracer.Visible = baseVisibility and ESPSettings.TracersEnabled
        
        visibleESP = visibleESP + 1
        Log(4, "ESP updated for player: %s (Distance: %.1f, Box: %.1fx%.1f)", 
            player.Name, distance, boxSize.X, boxSize.Y)
    end
    
    -- Log ESP stats periodically (every 5 seconds)
    if os.time() % 5 == 0 then
        Log(3, "ESP Stats: %d/%d players visible, ESP %s", 
            visibleESP, activePlayers, ESPSettings.Enabled and "Enabled" or "Disabled")
    end
end

-- Initialize ESP
function ESPModule:Initialize(GUI)
    Log(3, "Initializing ESP Module")
    
    -- Create ESP Category
    local ESPCategory = GUI:CreateCategory("ESP")
    
    -- Create Debug Category
    local DebugCategory = GUI:CreateCategory("ESP Debug")
    
    -- Debug Toggle
    DebugCategory:AddToggle("Debug Logging", function(enabled)
        DebugSettings.Enabled = enabled
        Log(3, "Debug logging %s", enabled and "enabled" or "disabled")
    end, DebugSettings.Enabled)
    
    -- Debug Log Level
    DebugCategory:AddDropdown("Log Level", {"Errors Only", "Warnings", "Info", "Verbose"}, function(selected)
        if selected == "Errors Only" then DebugSettings.LogLevel = 1
        elseif selected == "Warnings" then DebugSettings.LogLevel = 2
        elseif selected == "Info" then DebugSettings.LogLevel = 3
        else DebugSettings.LogLevel = 4 end
        
        Log(3, "Log level set to: %s (%d)", selected, DebugSettings.LogLevel)
    end)
    
    -- Debug Console Toggle
    DebugCategory:AddToggle("Log to Console", function(enabled)
        DebugSettings.LogToConsole = enabled
        Log(3, "Console logging %s", enabled and "enabled" or "disabled")
    end, DebugSettings.LogToConsole)
    
    -- Debug GUI Toggle
    DebugCategory:AddToggle("Log to GUI", function(enabled)
        DebugSettings.LogToGui = enabled
        
        if enabled and not DebugSettings.GuiOutput then
            -- Create debug output frame if it doesn't exist
            local screenGui = Instance.new("ScreenGui")
            screenGui.Name = "LethalityESPDebug"
            screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
            
            local frame = Instance.new("Frame")
            frame.Name = "DebugFrame"
            frame.Size = UDim2.new(0, 400, 0, 200)
            frame.Position = UDim2.new(0, 10, 0, 10)
            frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
            frame.BackgroundTransparency = 0.5
            frame.BorderSizePixel = 1
            frame.Parent = screenGui
            
            local textBox = Instance.new("TextLabel")
            textBox.Name = "DebugOutput"
            textBox.Size = UDim2.new(1, -10, 1, -10)
            textBox.Position = UDim2.new(0, 5, 0, 5)
            textBox.BackgroundTransparency = 1
            textBox.TextColor3 = Color3.fromRGB(255, 255, 255)
            textBox.TextSize = 14
            textBox.TextXAlignment = Enum.TextXAlignment.Left
            textBox.TextYAlignment = Enum.TextYAlignment.Top
            textBox.TextWrapped = true
            textBox.Text = "[Lethality ESP] Debug output initialized"
            textBox.Parent = frame
            
            screenGui.Parent = game:GetService("CoreGui")
            DebugSettings.GuiOutput = textBox
            
            Log(3, "GUI debug output created and enabled")
        elseif not enabled and DebugSettings.GuiOutput then
            -- Try to remove the GUI if it exists
            pcall(function()
                DebugSettings.GuiOutput.Parent.Parent:Destroy()
            end)
            DebugSettings.GuiOutput = nil
            Log(3, "GUI debug output removed")
        end
    end, DebugSettings.LogToGui)
    
    -- Main Toggle
    ESPCategory:AddToggle("ESP Enabled", function(enabled)
        ESPSettings.Enabled = enabled
        Log(3, "ESP %s", enabled and "enabled" or "disabled")
    end)
    
    -- Box ESP
    ESPCategory:AddToggle("Show Boxes", function(enabled)
        ESPSettings.BoxesEnabled = enabled
        Log(3, "Box ESP %s", enabled and "enabled" or "disabled")
    end, ESPSettings.BoxesEnabled)
    
    -- Name ESP
    ESPCategory:AddToggle("Show Names", function(enabled)
        ESPSettings.NamesEnabled = enabled
        Log(3, "Name ESP %s", enabled and "enabled" or "disabled")
    end, ESPSettings.NamesEnabled)
    
    -- Distance ESP
    ESPCategory:AddToggle("Show Distance", function(enabled)
        ESPSettings.DistanceEnabled = enabled
        Log(3, "Distance ESP %s", enabled and "enabled" or "disabled")
    end, ESPSettings.DistanceEnabled)
    
    -- Tracer ESP
    ESPCategory:AddToggle("Show Tracers", function(enabled)
        ESPSettings.TracersEnabled = enabled
        Log(3, "Tracer ESP %s", enabled and "enabled" or "disabled")
    end, ESPSettings.TracersEnabled)
    
    -- Team Check
    ESPCategory:AddToggle("Team Check", function(enabled)
        ESPSettings.TeamCheck = enabled
        Log(3, "Team Check %s", enabled and "enabled" or "disabled")
    end, ESPSettings.TeamCheck)
    
    -- Team Color
    ESPCategory:AddToggle("Use Team Colors", function(enabled)
        ESPSettings.TeamColor = enabled
        Log(3, "Team Colors %s", enabled and "enabled" or "disabled")
    end, ESPSettings.TeamColor)
    
    -- Show Local Player
    ESPCategory:AddToggle("Show Local Player", function(enabled)
        ESPSettings.ShowLocalPlayer = enabled
        Log(3, "Local Player ESP %s", enabled and "enabled" or "disabled")
        
        -- If enabled, create ESP for local player if it doesn't exist
        if enabled and not ESPObjects[LocalPlayer] then
            CreateESP(LocalPlayer)
        end
    end, ESPSettings.ShowLocalPlayer)
    
    -- Debug Button to report active ESPs
    DebugCategory:AddButton("Log ESP Status", function()
        local activeESP = 0
        local visibleESP = 0
        
        for player, objects in pairs(ESPObjects) do
            activeESP = activeESP + 1
            if objects.Box.Visible or objects.Name.Visible or objects.Distance.Visible or objects.Tracer.Visible then
                visibleESP = visibleESP + 1
            end
            
            Log(3, "Player: %s, Team: %s, Visible: %s, Box: %s, Name: %s, Distance: %s, Tracer: %s",
                player.Name,
                player.Team and player.Team.Name or "None",
                objects.Box.Visible or objects.Name.Visible or objects.Distance.Visible or objects.Tracer.Visible,
                objects.Box.Visible,
                objects.Name.Visible,
                objects.Distance.Visible,
                objects.Tracer.Visible)
        end
        
        Log(2, "ESP Status: %d active, %d visible, %d total players", 
            activeESP, visibleESP, #Players:GetPlayers())
    end)
    
    -- Max Distance
    ESPCategory:AddSlider("Max Distance", 100, 5000, ESPSettings.MaxDisplayDistance, function(value)
        ESPSettings.MaxDisplayDistance = value
        Log(3, "Max Display Distance set to: %.1f", value)
    end)
    
    -- Tracer Origin
    ESPCategory:AddDropdown("Tracer Origin", {"Bottom", "Center", "Mouse"}, function(selected)
        ESPSettings.TracerOrigin = selected
        Log(3, "Tracer Origin set to: %s", selected)
    end)
    
    Log(3, "Creating ESP objects for existing players (%d)", #Players:GetPlayers())
    
    -- Create ESP objects for all existing players
    for _, player in pairs(Players:GetPlayers()) do
        CreateESP(player)
    end
    
    -- Handle new players
    Players.PlayerAdded:Connect(function(player)
        Log(3, "New player joined: %s", player.Name)
        CreateESP(player)
    end)
    
    -- Handle players leaving
    Players.PlayerRemoving:Connect(function(player)
        Log(3, "Player leaving: %s", player.Name)
        RemoveESP(player)
    end)
    
    -- Update ESP on each frame
    Log(3, "Binding ESP update to RenderStep")
    RunService:BindToRenderStep("LethalityESP", 200, UpdateESP)
    
    -- Log successful initialization
    Log(2, "ESP Module successfully initialized with %d players", #Players:GetPlayers())
    
    -- Return destructor function
    return function()
        Log(2, "ESP Module shutting down")
        RunService:UnbindFromRenderStep("LethalityESP")
        for player, _ in pairs(ESPObjects) do
            RemoveESP(player)
        end
        
        -- Clean up debug GUI if it exists
        if DebugSettings.GuiOutput then
            pcall(function()
                DebugSettings.GuiOutput.Parent.Parent:Destroy()
            end)
            DebugSettings.GuiOutput = nil
        end
    end
end

return ESPModule
