--// ==================== EARTH HUB - STEALTH PRIORITY 2026 ====================
repeat task.wait() until game:IsLoaded() and workspace.CurrentCamera

--// Stealth Metamethod Hook (ปลอดภัยสูง)
local oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local method = getnamecallmethod()
    local args = {...}
    if method == "GetService" and (args[1] == "Drawing" or args[1] == "VirtualInputManager") then
        return game:GetService("ReplicatedStorage") -- spoof เป็น service ธรรมดา
    end
    return oldNamecall(self, ...)
end)

--// Full Drawing Proxy
local OriginalDrawing = Drawing
getgenv().Drawing = setmetatable({}, {
    __index = function(_, key)
        return OriginalDrawing[key]
    end
})

--// Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

--// Settings
getgenv().Settings = {
    Aimbot = { Enabled = false, TeamCheck = true, WallCheck = true, ShowFOV = false, FOV = 130, Smoothness = 0.18, TargetPart = "Head" },
    TriggerBot = { Enabled = false, Delay = 0.07, TeamCheck = true, WallCheck = true },
    AntiRecoil = { Enabled = false },
    AntiAim = { Enabled = false },
    Misc = { WalkSpeed = 16, JumpPower = 50 }
}

local Settings = getgenv().Settings
local Holding = false
local LastShot = 0

--// Functions
local function CanSee(Target)
    if not Settings.Aimbot.WallCheck then return true end
    local Origin = Camera.CFrame.Position
    local Result = workspace:Raycast(Origin, (Target.Position - Origin).Unit * 500)
    return Result and Result.Instance:IsDescendantOf(Target.Parent)
end

local function GetClosestTarget()
    local Closest, Shortest = nil, Settings.Aimbot.FOV
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild(Settings.Aimbot.TargetPart) then
            local Part = v.Character[Settings.Aimbot.TargetPart]
            local Pos, OnScreen = Camera:WorldToViewportPoint(Part.Position)
            if OnScreen then
                local Dist = (Vector2.new(Pos.X, Pos.Y) - Camera.ViewportSize/2).Magnitude
                if Dist < Shortest and CanSee(Part) then
                    if Settings.Aimbot.TeamCheck and v.Team == LocalPlayer.Team then continue end
                    Closest = v
                    Shortest = Dist
                end
            end
        end
    end
    return Closest
end

--// Stealth TriggerBot
local function TriggerBot()
    if not Settings.TriggerBot.Enabled then return end
    local randomDelay = Settings.TriggerBot.Delay + (math.random(12, 38)/1000)
    if tick() - LastShot < randomDelay then return end

    local Target = GetClosestTarget()
    if Target and Target.Character then
        local Part = Target.Character:FindFirstChild(Settings.Aimbot.TargetPart)
        if Part and CanSee(Part) then
            if math.random(1, 100) > 20 then
                VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
                task.wait(0.014 + math.random(2, 9)/100)
                VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
                LastShot = tick()
            end
        end
    end
end

--// Main Loop - Silent Aim + Heavy Humanization
RunService.Heartbeat:Connect(function()
    if Settings.Aimbot.Enabled and Holding then
        local Target = GetClosestTarget()
        if Target and Target.Character then
            local Part = Target.Character[Settings.Aimbot.TargetPart]
            if Part then
                local NewCF = CFrame.new(Camera.CFrame.Position, Part.Position)
                local randomSmooth = Settings.Aimbot.Smoothness + (math.random(-18, 18)/100)
                Camera.CFrame = Camera.CFrame:Lerp(NewCF, math.clamp(randomSmooth, 0.12, 0.29))
            end
        end
    end

    TriggerBot()

    if Settings.AntiRecoil.Enabled and LocalPlayer.Character then
        local Hum = LocalPlayer.Character:FindFirstChild("Humanoid")
        if Hum then Hum.CameraOffset = Vector3.new(0, 0, 0) end
    end

    if Settings.AntiAim.Enabled and LocalPlayer.Character then
        local HRP = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if HRP then
            HRP.CFrame = HRP.CFrame * CFrame.Angles(0, math.rad(math.random(-22, 22)), 0)
        end
    end

    if LocalPlayer.Character then
        local Hum = LocalPlayer.Character:FindFirstChild("Humanoid")
        if Hum then
            Hum.WalkSpeed = Settings.Misc.WalkSpeed
            Hum.JumpPower = Settings.Misc.JumpPower
        end
    end
end)

--// FOV Circle (เริ่มต้นปิดเพื่อความปลอดภัยสูงสุด)
local FOVCircle = Drawing.new("Circle")
FOVCircle.Visible = false
FOVCircle.Color = Color3.fromRGB(255, 0, 0)
FOVCircle.Thickness = 1
FOVCircle.NumSides = 64

RunService.RenderStepped:Connect(function()
    FOVCircle.Visible = Settings.Aimbot.ShowFOV and Settings.Aimbot.Enabled
    FOVCircle.Radius = Settings.Aimbot.FOV
    FOVCircle.Position = Camera.ViewportSize / 2
end)

--// Rayfield GUI
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "Earth Hub | Stealth Priority 2026",
    LoadingTitle = "Universal Cheat",
    LoadingSubtitle = "Safety First - โดนแบนยากสุด",
    ConfigurationSaving = { Enabled = false },
    KeySystem = false
})

local AimbotTab = Window:CreateTab("Aimbot", 4483362748)
local CombatTab = Window:CreateTab("Combat", 4483362748)
local MiscTab = Window:CreateTab("Misc", 4483362748)

AimbotTab:CreateToggle({Name = "Enable Aimbot", CurrentValue = false, Callback = function(v) Settings.Aimbot.Enabled = v end})
AimbotTab:CreateToggle({Name = "Show FOV Circle", CurrentValue = false, Callback = function(v) Settings.Aimbot.ShowFOV = v end})
AimbotTab:CreateSlider({Name = "FOV", Range = {30, 300}, Increment = 5, CurrentValue = 130, Callback = function(v) Settings.Aimbot.FOV = v end})
AimbotTab:CreateSlider({Name = "Smoothness", Range = {0.05, 0.4}, Increment = 0.01, CurrentValue = 0.18, Callback = function(v) Settings.Aimbot.Smoothness = v end})
AimbotTab:CreateToggle({Name = "WallCheck", CurrentValue = true, Callback = function(v) Settings.Aimbot.WallCheck = v end})
AimbotTab:CreateToggle({Name = "TeamCheck", CurrentValue = true, Callback = function(v) Settings.Aimbot.TeamCheck = v end})

CombatTab:CreateToggle({Name = "TriggerBot", CurrentValue = false, Callback = function(v) Settings.TriggerBot.Enabled = v end})
CombatTab:CreateSlider({Name = "TriggerBot Delay", Range = {0.01, 0.3}, Increment = 0.01, CurrentValue = 0.07, Callback = function(v) Settings.TriggerBot.Delay = v end})
CombatTab:CreateToggle({Name = "Anti-Recoil", CurrentValue = false, Callback = function(v) Settings.AntiRecoil.Enabled = v end})
CombatTab:CreateToggle({Name = "Anti-Aim (Jitter)", CurrentValue = false, Callback = function(v) Settings.AntiAim.Enabled = v end})

MiscTab:CreateSlider({Name = "WalkSpeed", Range = {16, 100}, Increment = 1, CurrentValue = 16, Callback = function(v) Settings.Misc.WalkSpeed = v end})
MiscTab:CreateSlider({Name = "JumpPower", Range = {50, 200}, Increment = 5, CurrentValue = 50, Callback = function(v) Settings.Misc.JumpPower = v end})

UserInputService.InputBegan:Connect(function(Input)
    if Input.KeyCode == Enum.KeyCode.Q then
        Holding = not Holding
        Rayfield:Notify({Title = "Aimbot", Content = Holding and "ON" or "OFF", Duration = 1})
    end
end)

print("[Earth Hub] Stealth Priority 2026 Loaded | เน้นปลอดภัยสูงสุด")
Rayfield:Notify({Title = "Loaded", Content = "Stealth Priority 2026 - โดนแบนยากสุด", Duration = 4})
