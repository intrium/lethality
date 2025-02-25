local LethalityGUI = {}
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Player = game:GetService("Players").LocalPlayer

-- Optimized config with darker theme and CS:GO style
local Config = {
    MainColor = Color3.fromRGB(15, 15, 15),         -- Darker main background
    SecondaryColor = Color3.fromRGB(25, 25, 25),    -- Darker secondary color
    AccentColor = Color3.fromRGB(65, 105, 225),     -- Royal blue accent
    TextColor = Color3.fromRGB(220, 220, 220),      -- Slightly off-white for text
    Font = Enum.Font.SpecialElite,                  -- More CS:GO-like font
    ToggleOnColor = Color3.fromRGB(65, 105, 225),   -- Accent color for toggle
    ToggleOffColor = Color3.fromRGB(40, 40, 40),    -- Darker toggle off
    ToggleKey = Enum.KeyCode.RightControl,          -- Default toggle key
    BorderRadius = 0                                -- Clean edges
}

-- Create Main GUI with cleaner structure
function LethalityGUI:Create()
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "LethalityV4"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.Parent = game.CoreGui

    -- Main Frame
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.BackgroundColor3 = Config.MainColor
    MainFrame.BorderSizePixel = 0
    MainFrame.Position = UDim2.new(0.2, 0, 0.2, 0)
    MainFrame.Size = UDim2.new(0, 480, 0, 320)
    MainFrame.Active = true
    MainFrame.Draggable = true
    MainFrame.Parent = ScreenGui

    -- Title Bar (slimmer and cleaner)
    local TitleBar = Instance.new("Frame")
    TitleBar.Name = "TitleBar"
    TitleBar.BackgroundColor3 = Config.AccentColor
    TitleBar.BorderSizePixel = 0
    TitleBar.Size = UDim2.new(1, 0, 0, 25)
    TitleBar.Parent = MainFrame

    -- Title Text (cleaner positioning)
    local TitleText = Instance.new("TextLabel")
    TitleText.Name = "TitleText"
    TitleText.BackgroundTransparency = 1
    TitleText.Position = UDim2.new(0, 10, 0, 0)
    TitleText.Size = UDim2.new(0, 200, 1, 0)
    TitleText.Font = Config.Font
    TitleText.Text = "LETHALITY"
    TitleText.TextColor3 = Config.TextColor
    TitleText.TextSize = 16
    TitleText.TextXAlignment = Enum.TextXAlignment.Left
    TitleText.Parent = TitleBar

    -- Close Button (cleaner X)
    local CloseButton = Instance.new("TextButton")
    CloseButton.Name = "CloseButton"
    CloseButton.BackgroundTransparency = 1
    CloseButton.Position = UDim2.new(1, -25, 0, 0)
    CloseButton.Size = UDim2.new(0, 25, 1, 0)
    CloseButton.Font = Config.Font
    CloseButton.Text = "×"
    CloseButton.TextColor3 = Config.TextColor
    CloseButton.TextSize = 20
    CloseButton.Parent = TitleBar
    CloseButton.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

    -- Slimmer Sidebar
    local Sidebar = Instance.new("Frame")
    Sidebar.Name = "Sidebar"
    Sidebar.BackgroundColor3 = Config.SecondaryColor
    Sidebar.BorderSizePixel = 0
    Sidebar.Position = UDim2.new(0, 0, 0, 25)
    Sidebar.Size = UDim2.new(0, 100, 1, -25)
    Sidebar.Parent = MainFrame

    -- Content Frame (adjusted for slimmer sidebar)
    local ContentFrame = Instance.new("Frame")
    ContentFrame.Name = "ContentFrame"
    ContentFrame.BackgroundColor3 = Config.MainColor
    ContentFrame.BorderSizePixel = 0
    ContentFrame.Position = UDim2.new(0, 100, 0, 25)
    ContentFrame.Size = UDim2.new(1, -100, 1, -25)
    ContentFrame.Parent = MainFrame

    -- Keybind indicator (cleaner)
    local KeybindIndicator = Instance.new("TextLabel")
    KeybindIndicator.Name = "KeybindIndicator"
    KeybindIndicator.BackgroundTransparency = 1
    KeybindIndicator.Position = UDim2.new(0, 0, 1, -18)
    KeybindIndicator.Size = UDim2.new(1, 0, 0, 18)
    KeybindIndicator.Font = Config.Font
    KeybindIndicator.Text = Config.ToggleKey.Name
    KeybindIndicator.TextColor3 = Config.TextColor
    KeybindIndicator.TextSize = 10
    KeybindIndicator.Parent = Sidebar

    -- Toggle GUI Function
    local function ToggleGUI() MainFrame.Visible = not MainFrame.Visible end
    UIS.InputBegan:Connect(function(input, gameProcessed)
        if not gameProcessed and input.KeyCode == Config.ToggleKey then ToggleGUI() end
    end)

    return {MainFrame = MainFrame, Sidebar = Sidebar, ContentFrame = ContentFrame, ScreenGui = ScreenGui}
end

-- Optimized category creation
function LethalityGUI:CreateCategory(name, gui)
    local TabContent = {}
    local Sidebar, ContentFrame = gui.Sidebar, gui.ContentFrame

    -- Category Button
    local CategoryButton = Instance.new("TextButton")
    CategoryButton.Name = name.."Button"
    CategoryButton.BackgroundColor3 = Config.SecondaryColor
    CategoryButton.BorderSizePixel = 0
    CategoryButton.Size = UDim2.new(1, 0, 0, 30)
    CategoryButton.Font = Config.Font
    CategoryButton.Text = name:upper()
    CategoryButton.TextColor3 = Config.TextColor
    CategoryButton.TextSize = 12
    
    -- Position based on existing buttons
    local yPos = 0
    for _, child in pairs(Sidebar:GetChildren()) do
        if child:IsA("TextButton") and child ~= CategoryButton then yPos = yPos + 30 end
    end
    CategoryButton.Position = UDim2.new(0, 0, 0, yPos)
    CategoryButton.Parent = Sidebar
    
    -- Content Page
    local ContentPage = Instance.new("ScrollingFrame")
    ContentPage.Name = name.."Page"
    ContentPage.BackgroundTransparency = 1
    ContentPage.BorderSizePixel = 0
    ContentPage.Size = UDim2.new(1, 0, 1, 0)
    ContentPage.CanvasSize = UDim2.new(0, 0, 0, 0)
    ContentPage.ScrollBarThickness = 2
    ContentPage.Visible = false
    ContentPage.Parent = ContentFrame
    
    TabContent[name] = ContentPage
    
    -- Show this page when button is clicked
    CategoryButton.MouseButton1Click:Connect(function()
        for _, page in pairs(TabContent) do page.Visible = false end
        ContentPage.Visible = true
        
        -- Highlight selected button
        for _, button in pairs(Sidebar:GetChildren()) do
            if button:IsA("TextButton") then button.BackgroundColor3 = Config.SecondaryColor end
        end
        CategoryButton.BackgroundColor3 = Config.AccentColor
    end)
    
    -- Show first page by default
    if yPos == 0 then
        ContentPage.Visible = true
        CategoryButton.BackgroundColor3 = Config.AccentColor
    end
    
    -- Category API
    local Category = {}
    
    -- Optimized Toggle Function
    function Category:AddToggle(toggleName, callback)
        local ToggleFrame = Instance.new("Frame")
        ToggleFrame.Name = toggleName.."Frame"
        ToggleFrame.BackgroundTransparency = 1
        ToggleFrame.Size = UDim2.new(1, -16, 0, 28)
        
        -- Position based on existing elements
        local yPos = 8
        for _, child in pairs(ContentPage:GetChildren()) do
            if child ~= ToggleFrame and child:IsA("Frame") then yPos = yPos + child.Size.Y.Offset + 4 end
        end
        ToggleFrame.Position = UDim2.new(0, 8, 0, yPos)
        ToggleFrame.Parent = ContentPage
        
        -- Update canvas size
        ContentPage.CanvasSize = UDim2.new(0, 0, 0, yPos + 32)
        
        -- Toggle Text
        local ToggleText = Instance.new("TextLabel")
        ToggleText.BackgroundTransparency = 1
        ToggleText.Position = UDim2.new(0, 0, 0, 0)
        ToggleText.Size = UDim2.new(1, -32, 1, 0)
        ToggleText.Font = Config.Font
        ToggleText.Text = toggleName
        ToggleText.TextColor3 = Config.TextColor
        ToggleText.TextSize = 12
        ToggleText.TextXAlignment = Enum.TextXAlignment.Left
        ToggleText.Parent = ToggleFrame
        
        -- Toggle Button
        local ToggleButton = Instance.new("Frame")
        ToggleButton.BackgroundColor3 = Config.ToggleOffColor
        ToggleButton.BorderSizePixel = 0
        ToggleButton.Position = UDim2.new(1, -24, 0.5, -8)
        ToggleButton.Size = UDim2.new(0, 16, 0, 16)
        ToggleButton.Parent = ToggleFrame
        
        -- Toggle Status
        local enabled = false
        
        -- Toggle Function
        local function updateToggle()
            enabled = not enabled
            ToggleButton.BackgroundColor3 = enabled and Config.ToggleOnColor or Config.ToggleOffColor
            if callback then callback(enabled) end
        end
        
        -- Make button clickable
        ToggleButton.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then updateToggle() end
        end)
        
        ToggleText.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then updateToggle() end
        end)
        
        return {
            Set = function(value) if enabled ~= value then updateToggle() end end,
            Get = function() return enabled end
        }
    end
    
    -- Optimized Button Function
    function Category:AddButton(buttonName, callback)
        local ButtonFrame = Instance.new("Frame")
        ButtonFrame.BackgroundTransparency = 1
        ButtonFrame.Size = UDim2.new(1, -16, 0, 28)
        
        -- Position based on existing elements
        local yPos = 8
        for _, child in pairs(ContentPage:GetChildren()) do
            if child ~= ButtonFrame and child:IsA("Frame") then yPos = yPos + child.Size.Y.Offset + 4 end
        end
        ButtonFrame.Position = UDim2.new(0, 8, 0, yPos)
        ButtonFrame.Parent = ContentPage
        
        -- Update canvas size
        ContentPage.CanvasSize = UDim2.new(0, 0, 0, yPos + 32)
        
        -- Button
        local Button = Instance.new("TextButton")
        Button.BackgroundColor3 = Config.SecondaryColor
        Button.BorderSizePixel = 0
        Button.Size = UDim2.new(1, 0, 1, 0)
        Button.Font = Config.Font
        Button.Text = buttonName
        Button.TextColor3 = Config.TextColor
        Button.TextSize = 12
        Button.Parent = ButtonFrame
        
        -- Click Effect with TweenService for optimization
        local clickTween = TweenService:Create(Button, TweenInfo.new(0.1), {BackgroundColor3 = Config.AccentColor})
        local resetTween = TweenService:Create(Button, TweenInfo.new(0.1), {BackgroundColor3 = Config.SecondaryColor})
        
        Button.MouseButton1Down:Connect(function() clickTween:Play() end)
        Button.MouseButton1Up:Connect(function() resetTween:Play() end)
        Button.MouseLeave:Connect(function() resetTween:Play() end)
        
        Button.MouseButton1Click:Connect(function() if callback then callback() end end)
    end
    
    -- Optimized Slider Function
    function Category:AddSlider(sliderName, min, max, default, callback)
        local SliderFrame = Instance.new("Frame")
        SliderFrame.BackgroundTransparency = 1
        SliderFrame.Size = UDim2.new(1, -16, 0, 40)
        
        -- Position based on existing elements
        local yPos = 8
        for _, child in pairs(ContentPage:GetChildren()) do
            if child ~= SliderFrame and child:IsA("Frame") then yPos = yPos + child.Size.Y.Offset + 4 end
        end
        SliderFrame.Position = UDim2.new(0, 8, 0, yPos)
        SliderFrame.Parent = ContentPage
        
        -- Update canvas size
        ContentPage.CanvasSize = UDim2.new(0, 0, 0, yPos + 44)
        
        -- Slider Text and Value in one row
        local TextLayout = Instance.new("Frame")
        TextLayout.BackgroundTransparency = 1
        TextLayout.Size = UDim2.new(1, 0, 0, 16)
        TextLayout.Parent = SliderFrame
        
        local SliderText = Instance.new("TextLabel")
        SliderText.BackgroundTransparency = 1
        SliderText.Position = UDim2.new(0, 0, 0, 0)
        SliderText.Size = UDim2.new(1, -30, 1, 0)
        SliderText.Font = Config.Font
        SliderText.Text = sliderName
        SliderText.TextColor3 = Config.TextColor
        SliderText.TextSize = 12
        SliderText.TextXAlignment = Enum.TextXAlignment.Left
        SliderText.Parent = TextLayout
        
        local ValueText = Instance.new("TextLabel")
        ValueText.BackgroundTransparency = 1
        ValueText.Position = UDim2.new(1, -30, 0, 0)
        ValueText.Size = UDim2.new(0, 30, 1, 0)
        ValueText.Font = Config.Font
        ValueText.Text = tostring(default)
        ValueText.TextColor3 = Config.TextColor
        ValueText.TextSize = 12
        ValueText.TextXAlignment = Enum.TextXAlignment.Right
        ValueText.Parent = TextLayout
        
        -- Slider Background
        local SliderBG = Instance.new("Frame")
        SliderBG.BackgroundColor3 = Config.SecondaryColor
        SliderBG.BorderSizePixel = 0
        SliderBG.Position = UDim2.new(0, 0, 0, 20)
        SliderBG.Size = UDim2.new(1, 0, 0, 4)
        SliderBG.Parent = SliderFrame
        
        -- Slider Fill
        local SliderFill = Instance.new("Frame")
        SliderFill.BackgroundColor3 = Config.AccentColor
        SliderFill.BorderSizePixel = 0
        SliderFill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
        SliderFill.Parent = SliderBG
        
        -- Slider Knob for better UX
        local SliderKnob = Instance.new("Frame")
        SliderKnob.BackgroundColor3 = Config.TextColor
        SliderKnob.BorderSizePixel = 0
        SliderKnob.Position = UDim2.new((default - min) / (max - min), -4, 0.5, -4)
        SliderKnob.Size = UDim2.new(0, 8, 0, 8)
        SliderKnob.ZIndex = 2
        SliderKnob.Parent = SliderBG
        
        -- Slider Logic
        local value = default
        local dragging = false
        
        local function updateSlider(input)
            local pos = math.clamp((input.Position.X - SliderBG.AbsolutePosition.X) / SliderBG.AbsoluteSize.X, 0, 1)
            SliderFill.Size = UDim2.new(pos, 0, 1, 0)
            SliderKnob.Position = UDim2.new(pos, -4, 0.5, -4)
            
            value = math.floor(min + ((max - min) * pos))
            ValueText.Text = tostring(value)
            
            if callback then callback(value) end
        end
        
        SliderBG.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
                updateSlider(input)
            end
        end)
        
        SliderBG.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
        end)
        
        UIS.InputChanged:Connect(function(input)
            if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then updateSlider(input) end
        end)
        
        return {
            Set = function(newValue)
                value = math.clamp(newValue, min, max)
                local pos = (value - min) / (max - min)
                SliderFill.Size = UDim2.new(pos, 0, 1, 0)
                SliderKnob.Position = UDim2.new(pos, -4, 0.5, -4)
                ValueText.Text = tostring(value)
                if callback then callback(value) end
            end,
            Get = function() return value end
        }
    end
    
    return Category
end

-- Initialize function (simplified)
function LethalityGUI:Initialize()
    local gui = self:Create()
    local SettingsCategory = self:CreateCategory("Settings", gui)
    
    -- Add toggle key binding
    SettingsCategory:AddKeybind("Toggle GUI", Config.ToggleKey, function(newKey)
        Config.ToggleKey = newKey
        gui.Sidebar.KeybindIndicator.Text = newKey.Name
    end)
    
    return self
end

return LethalityGUI
