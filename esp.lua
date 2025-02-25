-- ESP Module for Lethality v4
local ESPModule = {}

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- ESP Settings
local ESPSettings = {
    Enabled = false,
    BoxesEnabled = true,
    NamesEnabled = true,
    DistanceEnabled = true,
    TracersEnabled = false,
    TeamCheck = true,
    TeamColor = false,
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

-- Function to create/update ESP objects
local function CreateESP(player)
    if player == LocalPlayer then return end
    
    -- Create ESP objects for this player if they don't exist
    if not ESPObjects[player] then
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
    Objects.Box.Visible = ESPSettings.Enabled and ESPSettings.BoxesEnabled
    
    -- Update Name
    Objects.Name.Font = 2
    Objects.Name.Size = ESPSettings.FontSize
    Objects.Name.Center = true
    Objects.Name.Outline = true
    Objects.Name.Color = ESPSettings.NameColor
    Objects.Name.ZIndex = 2
    Objects.Name.Visible = ESPSettings.Enabled and ESPSettings.NamesEnabled
    
    -- Update Distance
    Objects.Distance.Font = 2
    Objects.Distance.Size = ESPSettings.FontSize - 1
    Objects.Distance.Center = true
    Objects.Distance.Outline = true
    Objects.Distance.Color = ESPSettings.DistanceColor
    Objects.Distance.ZIndex = 2
    Objects.Distance.Visible = ESPSettings.Enabled and ESPSettings.DistanceEnabled
    
    -- Update Tracer
    Objects.Tracer.Thickness = 1
    Objects.Tracer.ZIndex = 1
    Objects.Tracer.Color = ESPSettings.TracerColor
    Objects.Tracer.Transparency = ESPSettings.TracerTransparency
    Objects.Tracer.Visible = ESPSettings.Enabled and ESPSettings.TracersEnabled
end

-- Function to remove ESP objects
local function RemoveESP(player)
    if ESPObjects[player] then
        for _, Object in pairs(ESPObjects[player]) do
            Object:Remove()
        end
        ESPObjects[player] = nil
    end
end

-- Function to update ESP objects visibility
local function UpdateESP()
    for player, Objects in pairs(ESPObjects) do
        if not player or not player:IsDescendantOf(Players) then
            RemoveESP(player)
            continue
        end
        
        local character = player.Character
        if not character or not character:FindFirstChild("HumanoidRootPart") or not character:FindFirstChildOfClass("Humanoid") then
            for _, Object in pairs(Objects) do
                Object.Visible = false
            end
            continue
        end
        
        -- Check if player is alive
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if not humanoid or humanoid.Health <= 0 then
            for _, Object in pairs(Objects) do
                Object.Visible = false
            end
            continue
        end
        
        -- Team check
        if ESPSettings.TeamCheck and player.Team == LocalPlayer.Team then
            for _, Object in pairs(Objects) do
                Object.Visible = false
            end
            continue
        end
        
        -- Get player's position and check if they're on screen
        local hrp = character:FindFirstChild("HumanoidRootPart")
        local position, onScreen = Camera:WorldToViewportPoint(hrp.Position)
        local distance = (hrp.Position - Camera.CFrame.Position).Magnitude
        
        -- Check if player is too far
        if distance > ESPSettings.MaxDisplayDistance then
            for _, Object in pairs(Objects) do
                Object.Visible = false
            end
            continue
        end
        
        -- Update visibility
        for _, Object in pairs(Objects) do
            Object.Visible = onScreen and 
                             ESPSettings.Enabled and 
                             (Object == Objects.Box and ESPSettings.BoxesEnabled or
                              Object == Objects.Name and ESPSettings.NamesEnabled or
                              Object == Objects.Distance and ESPSettings.DistanceEnabled or
                              Object == Objects.Tracer and ESPSettings.TracersEnabled)
        end
        
        if not onScreen then continue end
        
        -- Get player's size and position
        local height = 5
        local width = 3
        
        -- Try to get actual character size if possible
        if character:FindFirstChild("Head") then
            height = (Camera:WorldToViewportPoint(hrp.Position + Vector3.new(0, height/2, 0)).Y - 
                      Camera:WorldToViewportPoint(hrp.Position - Vector3.new(0, height/2, 0)).Y)
            width = height * 0.6
        end
        
        -- Color based on team
        local playerColor = ESPSettings.BoxColor
        if ESPSettings.TeamColor and player.Team then
            playerColor = player.TeamColor.Color
        end
        
        -- Update Box
        Objects.Box.Color = playerColor
        Objects.Box.Size = Vector2.new(width, height)
        Objects.Box.Position = Vector2.new(position.X - width/2, position.Y - height/2)
        
        -- Update Name
        Objects.Name.Text = player.Name
        Objects.Name.Position = Vector2.new(position.X, position.Y - height/2 - 16)
        
        -- Update Distance
        Objects.Distance.Text = string.format("%.1f m", distance)
        Objects.Distance.Position = Vector2.new(position.X, position.Y + height/2)
        
        -- Update Tracer
        Objects.Tracer.Color = playerColor
        Objects.Tracer.From = 
            ESPSettings.TracerOrigin == "Bottom" and Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y) or
            ESPSettings.TracerOrigin == "Center" and Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2) or
            ESPSettings.TracerOrigin == "Mouse" and Vector2.new(LocalPlayer:GetMouse().X, LocalPlayer:GetMouse().Y)
        Objects.Tracer.To = Vector2.new(position.X, position.Y)
    end
end

-- Initialize ESP
function ESPModule:Initialize(GUI)
    -- Create ESP Category
    local ESPCategory = GUI:CreateCategory("ESP")
    
    -- Main Toggle
    ESPCategory:AddToggle("ESP Enabled", function(enabled)
        ESPSettings.Enabled = enabled
    end)
    
    -- Box ESP
    ESPCategory:AddToggle("Show Boxes", function(enabled)
        ESPSettings.BoxesEnabled = enabled
    end)
    
    -- Name ESP
    ESPCategory:AddToggle("Show Names", function(enabled)
        ESPSettings.NamesEnabled = enabled
    end)
    
    -- Distance ESP
    ESPCategory:AddToggle("Show Distance", function(enabled)
        ESPSettings.DistanceEnabled = enabled
    end)
    
    -- Tracer ESP
    ESPCategory:AddToggle("Show Tracers", function(enabled)
        ESPSettings.TracersEnabled = enabled
    end)
    
    -- Team Check
    ESPCategory:AddToggle("Team Check", function(enabled)
        ESPSettings.TeamCheck = enabled
    end)
    
    -- Team Color
    ESPCategory:AddToggle("Use Team Colors", function(enabled)
        ESPSettings.TeamColor = enabled
    end)
    
    -- Max Distance
    ESPCategory:AddSlider("Max Distance", 100, 5000, 1000, function(value)
        ESPSettings.MaxDisplayDistance = value
    end)
    
    -- Tracer Origin
    ESPCategory:AddDropdown("Tracer Origin", {"Bottom", "Center", "Mouse"}, function(selected)
        ESPSettings.TracerOrigin = selected
    end)
    
    -- Start ESP
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            CreateESP(player)
        end
    end
    
    -- Handle new players
    Players.PlayerAdded:Connect(function(player)
        CreateESP(player)
    end)
    
    -- Handle players leaving
    Players.PlayerRemoving:Connect(function(player)
        RemoveESP(player)
    end)
    
    -- Update ESP on each frame
    RunService:BindToRenderStep("LethalityESP", 200, UpdateESP)
    
    -- Return destructor function
    return function()
        RunService:UnbindFromRenderStep("LethalityESP")
        for player, _ in pairs(ESPObjects) do
            RemoveESP(player)
        end
    end
end

return ESPModule
