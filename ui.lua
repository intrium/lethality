local LethalityGUI = {}
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Player = game:GetService("Players").LocalPlayer
local Mouse = Player:GetMouse()

-- GUI Colors and Settings
local Config = {
    MainColor = Color3.fromRGB(30, 30, 30),
    SecondaryColor = Color3.fromRGB(45, 45, 45),
    AccentColor = Color3.fromRGB(60, 60, 60),
    TextColor = Color3.fromRGB(255, 255, 255),
    Font = Enum.Font.Code,
    ToggleOnColor = Color3.fromRGB(73, 33, 103),
    ToggleOffColor = Color3.fromRGB(60, 60, 60),
    ToggleKey = Enum.KeyCode.RightControl -- Default toggle key
}

-- Create Main GUI
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
MainFrame.Size = UDim2.new(0, 500, 0, 350)
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

-- Title Bar
local TitleBar = Instance.new("Frame")
TitleBar.Name = "TitleBar"
TitleBar.BackgroundColor3 = Config.AccentColor
TitleBar.BorderSizePixel = 0
TitleBar.Size = UDim2.new(1, 0, 0, 30)
TitleBar.Parent = MainFrame

-- Title Text
local TitleText = Instance.new("TextLabel")
TitleText.Name = "TitleText"
TitleText.BackgroundTransparency = 1
TitleText.Position = UDim2.new(0, 10, 0, 0)
TitleText.Size = UDim2.new(0, 200, 1, 0)
TitleText.Font = Config.Font
TitleText.Text = "Lethality v4"
TitleText.TextColor3 = Config.TextColor
TitleText.TextSize = 18
TitleText.TextXAlignment = Enum.TextXAlignment.Left
TitleText.Parent = TitleBar

-- Close Button
local CloseButton = Instance.new("TextButton")
CloseButton.Name = "CloseButton"
CloseButton.BackgroundTransparency = 1
CloseButton.Position = UDim2.new(1, -30, 0, 0)
CloseButton.Size = UDim2.new(0, 30, 1, 0)
CloseButton.Font = Config.Font
CloseButton.Text = "X"
CloseButton.TextColor3 = Config.TextColor
CloseButton.TextSize = 18
CloseButton.Parent = TitleBar
CloseButton.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- Sidebar
local Sidebar = Instance.new("Frame")
Sidebar.Name = "Sidebar"
Sidebar.BackgroundColor3 = Config.SecondaryColor
Sidebar.BorderSizePixel = 0
Sidebar.Position = UDim2.new(0, 0, 0, 30)
Sidebar.Size = UDim2.new(0, 120, 1, -30)
Sidebar.Parent = MainFrame

-- Content Frame
local ContentFrame = Instance.new("Frame")
ContentFrame.Name = "ContentFrame"
ContentFrame.BackgroundColor3 = Config.MainColor
ContentFrame.BorderSizePixel = 0
ContentFrame.Position = UDim2.new(0, 120, 0, 30)
ContentFrame.Size = UDim2.new(1, -120, 1, -30)
ContentFrame.Parent = MainFrame

-- Add keybind indicator at the bottom of the sidebar
local KeybindIndicator = Instance.new("TextLabel")
KeybindIndicator.Name = "KeybindIndicator"
KeybindIndicator.BackgroundTransparency = 1
KeybindIndicator.Position = UDim2.new(0, 0, 1, -20)
KeybindIndicator.Size = UDim2.new(1, 0, 0, 20)
KeybindIndicator.Font = Config.Font
KeybindIndicator.Text = "Toggle: " .. Config.ToggleKey.Name
KeybindIndicator.TextColor3 = Config.TextColor
KeybindIndicator.TextSize = 12
KeybindIndicator.Parent = Sidebar

-- Tab Container Setup
local TabContent = {}

-- Toggle GUI Function
local function ToggleGUI()
    MainFrame.Visible = not MainFrame.Visible
end

-- Setup toggle keybind
UIS.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Config.ToggleKey then
        ToggleGUI()
    end
end)

-- Create Category Function
function LethalityGUI:CreateCategory(name)
    local CategoryButton = Instance.new("TextButton")
    CategoryButton.Name = name.."Button"
    CategoryButton.BackgroundColor3 = Config.SecondaryColor
    CategoryButton.BorderSizePixel = 0
    CategoryButton.Size = UDim2.new(1, 0, 0, 35)
    CategoryButton.Font = Config.Font
    CategoryButton.Text = name
    CategoryButton.TextColor3 = Config.TextColor
    CategoryButton.TextSize = 14
    CategoryButton.Parent = Sidebar
    
    -- Position based on existing buttons
    local yPos = 0
    for _, child in pairs(Sidebar:GetChildren()) do
        if child:IsA("TextButton") and child ~= CategoryButton then
            yPos = yPos + 35
        end
    end
    CategoryButton.Position = UDim2.new(0, 0, 0, yPos)
    
    -- Create Content Page
    local ContentPage = Instance.new("ScrollingFrame")
    ContentPage.Name = name.."Page"
    ContentPage.BackgroundTransparency = 1
    ContentPage.BorderSizePixel = 0
    ContentPage.Size = UDim2.new(1, 0, 1, 0)
    ContentPage.CanvasSize = UDim2.new(0, 0, 0, 0)
    ContentPage.ScrollBarThickness = 4
    ContentPage.Visible = false
    ContentPage.Parent = ContentFrame
    
    TabContent[name] = ContentPage
    
    -- Show this page when button is clicked
    CategoryButton.MouseButton1Click:Connect(function()
        for _, page in pairs(TabContent) do
            page.Visible = false
        end
        ContentPage.Visible = true
        
        -- Highlight selected button
        for _, button in pairs(Sidebar:GetChildren()) do
            if button:IsA("TextButton") then
                button.BackgroundColor3 = Config.SecondaryColor
            end
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
    
    -- Add Toggle Function
    function Category:AddToggle(toggleName, callback)
        local ToggleFrame = Instance.new("Frame")
        ToggleFrame.Name = toggleName.."Frame"
        ToggleFrame.BackgroundTransparency = 1
        ToggleFrame.Size = UDim2.new(1, -20, 0, 30)
        ToggleFrame.Parent = ContentPage
        
        -- Position based on existing elements
        local yPos = 10
        for _, child in pairs(ContentPage:GetChildren()) do
            if child ~= ToggleFrame and child:IsA("Frame") then
                yPos = yPos + child.Size.Y.Offset + 5
            end
        end
        ToggleFrame.Position = UDim2.new(0, 10, 0, yPos)
        
        -- Update canvas size
        ContentPage.CanvasSize = UDim2.new(0, 0, 0, yPos + 40)
        
        -- Toggle Text
        local ToggleText = Instance.new("TextLabel")
        ToggleText.Name = "ToggleText"
        ToggleText.BackgroundTransparency = 1
        ToggleText.Position = UDim2.new(0, 0, 0, 0)
        ToggleText.Size = UDim2.new(1, -40, 1, 0)
        ToggleText.Font = Config.Font
        ToggleText.Text = toggleName
        ToggleText.TextColor3 = Config.TextColor
        ToggleText.TextSize = 14
        ToggleText.TextXAlignment = Enum.TextXAlignment.Left
        ToggleText.Parent = ToggleFrame
        
        -- Toggle Button
        local ToggleButton = Instance.new("Frame")
        ToggleButton.Name = "ToggleButton"
        ToggleButton.BackgroundColor3 = Config.ToggleOffColor
        ToggleButton.BorderSizePixel = 0
        ToggleButton.Position = UDim2.new(1, -30, 0.5, -10)
        ToggleButton.Size = UDim2.new(0, 20, 0, 20)
        ToggleButton.Parent = ToggleFrame
        
        -- Toggle Status
        local enabled = false
        
        -- Toggle Function
        local function updateToggle()
            enabled = not enabled
            ToggleButton.BackgroundColor3 = enabled and Config.ToggleOnColor or Config.ToggleOffColor
            if callback then
                callback(enabled)
            end
        end
        
        -- Make button clickable
        ToggleButton.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                updateToggle()
            end
        end)
        
        ToggleText.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                updateToggle()
            end
        end)
        
        -- Return toggle object with methods
        local toggleObj = {
            Set = function(value)
                if enabled ~= value then
                    updateToggle()
                end
            end,
            Get = function()
                return enabled
            end
        }
        
        return toggleObj
    end
    
    -- Add Button Function
    function Category:AddButton(buttonName, callback)
        local ButtonFrame = Instance.new("Frame")
        ButtonFrame.Name = buttonName.."Frame"
        ButtonFrame.BackgroundTransparency = 1
        ButtonFrame.Size = UDim2.new(1, -20, 0, 30)
        ButtonFrame.Parent = ContentPage
        
        -- Position based on existing elements
        local yPos = 10
        for _, child in pairs(ContentPage:GetChildren()) do
            if child ~= ButtonFrame and child:IsA("Frame") then
                yPos = yPos + child.Size.Y.Offset + 5
            end
        end
        ButtonFrame.Position = UDim2.new(0, 10, 0, yPos)
        
        -- Update canvas size
        ContentPage.CanvasSize = UDim2.new(0, 0, 0, yPos + 40)
        
        -- Button
        local Button = Instance.new("TextButton")
        Button.Name = "Button"
        Button.BackgroundColor3 = Config.SecondaryColor
        Button.BorderSizePixel = 0
        Button.Size = UDim2.new(1, 0, 1, 0)
        Button.Font = Config.Font
        Button.Text = buttonName
        Button.TextColor3 = Config.TextColor
        Button.TextSize = 14
        Button.Parent = ButtonFrame
        
        -- Click Effect
        Button.MouseButton1Down:Connect(function()
            Button.BackgroundColor3 = Config.AccentColor
        end)
        
        Button.MouseButton1Up:Connect(function()
            Button.BackgroundColor3 = Config.SecondaryColor
        end)
        
        Button.MouseLeave:Connect(function()
            Button.BackgroundColor3 = Config.SecondaryColor
        end)
        
        -- Callback
        Button.MouseButton1Click:Connect(function()
            if callback then
                callback()
            end
        end)
    end
    
    -- Add Slider Function
    function Category:AddSlider(sliderName, min, max, default, callback)
        local SliderFrame = Instance.new("Frame")
        SliderFrame.Name = sliderName.."Frame"
        SliderFrame.BackgroundTransparency = 1
        SliderFrame.Size = UDim2.new(1, -20, 0, 50)
        SliderFrame.Parent = ContentPage
        
        -- Position based on existing elements
        local yPos = 10
        for _, child in pairs(ContentPage:GetChildren()) do
            if child ~= SliderFrame and child:IsA("Frame") then
                yPos = yPos + child.Size.Y.Offset + 5
            end
        end
        SliderFrame.Position = UDim2.new(0, 10, 0, yPos)
        
        -- Update canvas size
        ContentPage.CanvasSize = UDim2.new(0, 0, 0, yPos + 60)
        
        -- Slider Text
        local SliderText = Instance.new("TextLabel")
        SliderText.Name = "SliderText"
        SliderText.BackgroundTransparency = 1
        SliderText.Position = UDim2.new(0, 0, 0, 0)
        SliderText.Size = UDim2.new(1, 0, 0, 20)
        SliderText.Font = Config.Font
        SliderText.Text = sliderName
        SliderText.TextColor3 = Config.TextColor
        SliderText.TextSize = 14
        SliderText.TextXAlignment = Enum.TextXAlignment.Left
        SliderText.Parent = SliderFrame
        
        -- Value Display
        local ValueText = Instance.new("TextLabel")
        ValueText.Name = "ValueText"
        ValueText.BackgroundTransparency = 1
        ValueText.Position = UDim2.new(1, -40, 0, 0)
        ValueText.Size = UDim2.new(0, 40, 0, 20)
        ValueText.Font = Config.Font
        ValueText.Text = tostring(default)
        ValueText.TextColor3 = Config.TextColor
        ValueText.TextSize = 14
        ValueText.TextXAlignment = Enum.TextXAlignment.Right
        ValueText.Parent = SliderFrame
        
        -- Slider Background
        local SliderBG = Instance.new("Frame")
        SliderBG.Name = "SliderBG"
        SliderBG.BackgroundColor3 = Config.SecondaryColor
        SliderBG.BorderSizePixel = 0
        SliderBG.Position = UDim2.new(0, 0, 0, 25)
        SliderBG.Size = UDim2.new(1, 0, 0, 6)
        SliderBG.Parent = SliderFrame
        
        -- Slider Fill
        local SliderFill = Instance.new("Frame")
        SliderFill.Name = "SliderFill"
        SliderFill.BackgroundColor3 = Config.AccentColor
        SliderFill.BorderSizePixel = 0
        SliderFill.Size = UDim2.new(0, 0, 1, 0)
        SliderFill.Parent = SliderBG
        
        -- Slider Logic
        local value = default
        local dragging = false
        
        local function updateSlider(input)
            local pos = UDim2.new(math.clamp((input.Position.X - SliderBG.AbsolutePosition.X) / SliderBG.AbsoluteSize.X, 0, 1), 0, 1, 0)
            SliderFill.Size = pos
            
            value = math.floor(min + ((max - min) * pos.X.Scale))
            ValueText.Text = tostring(value)
            
            if callback then
                callback(value)
            end
        end
        
        SliderBG.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
                updateSlider(input)
            end
        end)
        
        SliderBG.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = false
            end
        end)
        
        UIS.InputChanged:Connect(function(input)
            if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                updateSlider(input)
            end
        end)
        
        -- Set initial value
        SliderFill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
        
        -- Return slider object with methods
        local sliderObj = {
            Set = function(newValue)
                value = math.clamp(newValue, min, max)
                SliderFill.Size = UDim2.new((value - min) / (max - min), 0, 1, 0)
                ValueText.Text = tostring(value)
                if callback then
                    callback(value)
                end
            end,
            Get = function()
                return value
            end
        }
        
        return sliderObj
    end
    
    -- Add Dropdown Function
    function Category:AddDropdown(dropdownName, options, callback)
        local DropdownFrame = Instance.new("Frame")
        DropdownFrame.Name = dropdownName.."Frame"
        DropdownFrame.BackgroundTransparency = 1
        DropdownFrame.Size = UDim2.new(1, -20, 0, 50)
        DropdownFrame.ClipsDescendants = true
        DropdownFrame.Parent = ContentPage
        
        -- Position based on existing elements
        local yPos = 10
        for _, child in pairs(ContentPage:GetChildren()) do
            if child ~= DropdownFrame and child:IsA("Frame") then
                yPos = yPos + child.Size.Y.Offset + 5
            end
        end
        DropdownFrame.Position = UDim2.new(0, 10, 0, yPos)
        
        -- Update canvas size
        ContentPage.CanvasSize = UDim2.new(0, 0, 0, yPos + 60)
        
        -- Dropdown Text
        local DropdownText = Instance.new("TextLabel")
        DropdownText.Name = "DropdownText"
        DropdownText.BackgroundTransparency = 1
        DropdownText.Position = UDim2.new(0, 0, 0, 0)
        DropdownText.Size = UDim2.new(1, 0, 0, 20)
        DropdownText.Font = Config.Font
        DropdownText.Text = dropdownName
        DropdownText.TextColor3 = Config.TextColor
        DropdownText.TextSize = 14
        DropdownText.TextXAlignment = Enum.TextXAlignment.Left
        DropdownText.Parent = DropdownFrame
        
        -- Selected Value
        local SelectedText = Instance.new("TextLabel")
        SelectedText.Name = "SelectedText"
        SelectedText.BackgroundColor3 = Config.SecondaryColor
        SelectedText.BorderSizePixel = 0
        SelectedText.Position = UDim2.new(0, 0, 0, 25)
        SelectedText.Size = UDim2.new(1, 0, 0, 25)
        SelectedText.Font = Config.Font
        SelectedText.Text = options[1] or "Select..."
        SelectedText.TextColor3 = Config.TextColor
        SelectedText.TextSize = 14
        SelectedText.Parent = DropdownFrame
        
        -- Dropdown Arrow
        local Arrow = Instance.new("TextLabel")
        Arrow.Name = "Arrow"
        Arrow.BackgroundTransparency = 1
        Arrow.Position = UDim2.new(1, -20, 0, 25)
        Arrow.Size = UDim2.new(0, 20, 0, 25)
        Arrow.Font = Config.Font
        Arrow.Text = "▼"
        Arrow.TextColor3 = Config.TextColor
        Arrow.TextSize = 14
        Arrow.Parent = DropdownFrame
        
        -- Options Container
        local OptionsFrame = Instance.new("Frame")
        OptionsFrame.Name = "OptionsFrame"
        OptionsFrame.BackgroundColor3 = Config.SecondaryColor
        OptionsFrame.BorderSizePixel = 0
        OptionsFrame.Position = UDim2.new(0, 0, 0, 50)
        OptionsFrame.Size = UDim2.new(1, 0, 0, #options * 25)
        OptionsFrame.Visible = false
        OptionsFrame.Parent = DropdownFrame
        
        -- Create Option Buttons
        for i, option in ipairs(options) do
            local OptionButton = Instance.new("TextButton")
            OptionButton.Name = option.."Button"
            OptionButton.BackgroundColor3 = Config.SecondaryColor
            OptionButton.BorderSizePixel = 0
            OptionButton.Position = UDim2.new(0, 0, 0, (i-1) * 25)
            OptionButton.Size = UDim2.new(1, 0, 0, 25)
            OptionButton.Font = Config.Font
            OptionButton.Text = option
            OptionButton.TextColor3 = Config.TextColor
            OptionButton.TextSize = 14
            OptionButton.Parent = OptionsFrame
            
            -- Option Selection
            OptionButton.MouseButton1Click:Connect(function()
                SelectedText.Text = option
                OptionsFrame.Visible = false
                DropdownFrame.Size = UDim2.new(1, -20, 0, 50)
                
                if callback then
                    callback(option)
                end
            end)
        end
        
        -- Toggle Dropdown
        local dropped = false
        SelectedText.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dropped = not dropped
                if dropped then
                    OptionsFrame.Visible = true
                    DropdownFrame.Size = UDim2.new(1, -20, 0, 50 + #options * 25)
                    Arrow.Text = "▲"
                else
                    OptionsFrame.Visible = false
                    DropdownFrame.Size = UDim2.new(1, -20, 0, 50)
                    Arrow.Text = "▼"
                end
            end
        end)
        
        -- Return dropdown object with methods
        local dropdownObj = {
            Set = function(option)
                if table.find(options, option) then
                    SelectedText.Text = option
                    if callback then
                        callback(option)
                    end
                end
            end,
            Get = function()
                return SelectedText.Text
            end
        }
        
        return dropdownObj
    end
    
    -- Add Keybind Function
    function Category:AddKeybind(keybindName, defaultKey, callback)
        local KeybindFrame = Instance.new("Frame")
        KeybindFrame.Name = keybindName.."Frame"
        KeybindFrame.BackgroundTransparency = 1
        KeybindFrame.Size = UDim2.new(1, -20, 0, 30)
        KeybindFrame.Parent = ContentPage
        
        -- Position based on existing elements
        local yPos = 10
        for _, child in pairs(ContentPage:GetChildren()) do
            if child ~= KeybindFrame and child:IsA("Frame") then
                yPos = yPos + child.Size.Y.Offset + 5
            end
        end
        KeybindFrame.Position = UDim2.new(0, 10, 0, yPos)
        
        -- Update canvas size
        ContentPage.CanvasSize = UDim2.new(0, 0, 0, yPos + 40)
        
        -- Keybind Text
        local KeybindText = Instance.new("TextLabel")
        KeybindText.Name = "KeybindText"
        KeybindText.BackgroundTransparency = 1
        KeybindText.Position = UDim2.new(0, 0, 0, 0)
        KeybindText.Size = UDim2.new(1, -70, 1, 0)
        KeybindText.Font = Config.Font
        KeybindText.Text = keybindName
        KeybindText.TextColor3 = Config.TextColor
        KeybindText.TextSize = 14
        KeybindText.TextXAlignment = Enum.TextXAlignment.Left
        KeybindText.Parent = KeybindFrame
        
        -- Keybind Button
        local KeybindButton = Instance.new("TextButton")
        KeybindButton.Name = "KeybindButton"
        KeybindButton.BackgroundColor3 = Config.SecondaryColor
        KeybindButton.BorderSizePixel = 0
        KeybindButton.Position = UDim2.new(1, -60, 0, 0)
        KeybindButton.Size = UDim2.new(0, 60, 1, 0)
        KeybindButton.Font = Config.Font
        KeybindButton.Text = defaultKey.Name
        KeybindButton.TextColor3 = Config.TextColor
        KeybindButton.TextSize = 14
        KeybindButton.Parent = KeybindFrame
        
        -- Current key
        local currentKey = defaultKey
        local listening = false
        
        -- Set keybinding
        KeybindButton.MouseButton1Click:Connect(function()
            if listening then return end
            
            listening = true
            KeybindButton.Text = "..."
            
            local inputConnection
            inputConnection = UIS.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.Keyboard then
                    currentKey = input.KeyCode
                    KeybindButton.Text = currentKey.Name
                    
                    -- If this is the toggle key, update the indicator
                    if keybindName == "Toggle GUI" then
                        Config.ToggleKey = currentKey
                        KeybindIndicator.Text = "Toggle: " .. currentKey.Name
                    end
                    
                    if callback then
                        callback(currentKey)
                    end
                    
                    listening = false
                    inputConnection:Disconnect()
                end
            end)
        end)
        
        -- Return keybind object with methods
        local keybindObj = {
            Set = function(newKey)
                if typeof(newKey) == "EnumItem" and newKey.EnumType == Enum.KeyCode then
                    currentKey = newKey
                    KeybindButton.Text = currentKey.Name
                    
                    if keybindName == "Toggle GUI" then
                        Config.ToggleKey = currentKey
                        KeybindIndicator.Text = "Toggle: " .. currentKey.Name
                    end
                    
                    if callback then
                        callback(currentKey)
                    end
                end
            end,
            Get = function()
                return currentKey
            end
        }
        
        return keybindObj
    end
    
    return Category
end

-- Create Settings Category with Toggle Keybind
function LethalityGUI:Initialize()
    local SettingsCategory = LethalityGUI:CreateCategory("Settings")
    
    -- Add a keybind option for toggling the GUI
    SettingsCategory:AddKeybind("Toggle GUI", Config.ToggleKey, function(newKey)
        Config.ToggleKey = newKey
    end)
    
    return LethalityGUI
end

return LethalityGUI