local HitboxExpandModule = {}

-- Services
local Players = game:GetService("Players")
local GUI = {} -- Assuming GUI library is available

-- Function to expand hitboxes
local function ExpandHitboxes()
    local players = Players:GetPlayers()
    local localPlayer = Players.LocalPlayer
    
    for _, v in pairs(players) do
        if v ~= localPlayer and v.Character then
            if v.Character:FindFirstChild("RightUpperLeg") then
                v.Character.RightUpperLeg.CanCollide = false
                v.Character.RightUpperLeg.Transparency = 10
                v.Character.RightUpperLeg.Size = Vector3.new(13, 13, 13)
            end
            
            if v.Character:FindFirstChild("LeftUpperLeg") then
                v.Character.LeftUpperLeg.CanCollide = false
                v.Character.LeftUpperLeg.Transparency = 10
                v.Character.LeftUpperLeg.Size = Vector3.new(13, 13, 13)
            end
            
            if v.Character:FindFirstChild("HeadHB") then
                v.Character.HeadHB.CanCollide = false
                v.Character.HeadHB.Transparency = 10
                v.Character.HeadHB.Size = Vector3.new(13, 13, 13)
            end
            
            if v.Character:FindFirstChild("HumanoidRootPart") then
                v.Character.HumanoidRootPart.CanCollide = false
                v.Character.HumanoidRootPart.Transparency = 10
                v.Character.HumanoidRootPart.Size = Vector3.new(13, 13, 13)
            end
        end
    end
end

-- Initialize GUI button
function HitboxExpandModule:Initialize(GUI)
    local HitboxExpandCategory = GUI:CreateCategory("Hitboxes")
    HitboxExpandCategory:AddButton("Expand Hitboxes", ExpandHitboxes)
    print("Hitbox Expand Module initialized with button.")
end

return HitboxExpandModule
