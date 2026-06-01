--// Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

--// Rayfield GUI
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "Universal | v4",
    LoadingTitle = "Universal Cheat",
    LoadingSubtitle = "Aimbot + TriggerBot + Anti-Recoil + Anti-Aim",
    ConfigurationSaving = { Enabled = false },
    KeySystem = false
})

local AimbotTab = Window:CreateTab("Aimbot", 4483362748)
local CombatTab = Window:CreateTab("Combat", 4483362748)
local MiscTab = Window:CreateTab("Misc", 4483362748)

--// Settings
getgenv().Settings = {
    Aimbot = {
        Enabled = false,
        TeamCheck = true,
        WallCheck = true,
        ShowFOV = false,
        FOV = 130,
        Smoothness = 0.16,
        TargetPart = "Head"
    },
    TriggerBot = {
        Enabled = false,
        Delay = 0.05,           -- ยิ่งต่ำยิ่งเร็ว
        TeamCheck = true,
        WallCheck = true
    },
    AntiRecoil = { Enabled = false },
    AntiAim = { Enabled = false },
    Misc = {
        WalkSpeed = 16,
        JumpPower = 50
    }
}

local Settings = getgenv().Settings
local Holding = false
local LastShot = 0

--// Aimbot Functions
local function CanSee(Target)
    if not Settings.Aimbot.WallCheck then return true end
    local Origin = Camera.CFrame.Position
    local Result = workspace:Raycast(Origin, (Target.Position - Origin).Unit * 500)
    return Result and Result.Instance:IsDescendantOf(Target.Parent)
end

local function GetClosestTarget()
    local Closest, Shortest = nil, Settings.Aimbot.FOV
    for _, v in pairs(Players:GetPlayers()) do
        if v \~= LocalPlayer and v.Character and v.Character:FindFirstChild(Settings.Aimbot.TargetPart) then
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

--// TriggerBot Function
local function TriggerBot()
    if not Settings.TriggerBot.Enabled then return end
    if tick() - LastShot < Settings.TriggerBot.Delay then return end

    local Target = GetClosestTarget()
    if Target and Target.Character then
        local Part = Target.Character:FindFirstChild(Settings.Aimbot.TargetPart)
        if Part and CanSee(Part) then
            -- ยิง (Mouse Click)
            VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
            task.wait(0.03)
            VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
            LastShot = tick()
        end
    end
end

--// Main Loop
RunService.Heartbeat:Connect(function()
    -- Aimbot
    if Settings.Aimbot.Enabled and Holding then
        local Target = GetClosestTarget()
        if Target and Target.Character then
            local Part = Target.Character[Settings.Aimbot.TargetPart]
            if Part then
                local NewCF = CFrame.new(Camera.CFrame.Position, Part.Position)
                Camera.CFrame = Camera.CFrame:Lerp(NewCF, Settings.Aimbot.Smoothness)
            end
        end
    end

    -- TriggerBot
    TriggerBot()

    -- Anti-Recoil
    if Settings.AntiRecoil.Enabled and LocalPlayer.Character then
        local Hum = LocalPlayer.Character:FindFirstChild("Humanoid")
        if Hum then Hum.CameraOffset = Vector3.new(0, 0, 0) end
    end

    -- Anti-Aim
    if Settings.AntiAim.Enabled and LocalPlayer.Character then
        local HRP = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if HRP then
            HRP.CFrame = HRP.CFrame * CFrame.Angles(0, math.rad(math.random(-12, 12)), 0)
        end
    end

    -- Movement
    if LocalPlayer.Character then
        local Hum = LocalPlayer.Character:FindFirstChild("Humanoid")
        if Hum then
            Hum.WalkSpeed = Settings.Misc.WalkSpeed
            Hum.JumpPower = Settings.Misc.JumpPower
        end
    end
end)

--// FOV Circle
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

--// ==================== GUI ====================

-- Aimbot
AimbotTab:CreateToggle({
    Name = "Enable Aimbot",
    CurrentValue = false,
    Callback = function(v) Settings.Aimbot.Enabled = v end
})

AimbotTab:CreateToggle({
    Name = "Show FOV Circle",
    CurrentValue = false,
    Callback = function(v) Settings.Aimbot.ShowFOV = v end
})

AimbotTab:CreateSlider({
    Name = "FOV",
    Range = {30, 300},
    Increment = 5,
    CurrentValue = 130,
    Callback = function(v) Settings.Aimbot.FOV = v end
})

AimbotTab:CreateSlider({
    Name = "Smoothness",
    Range = {0.05, 0.4},
    Increment = 0.01,
    CurrentValue = 0.16,
    Callback = function(v) Settings.Aimbot.Smoothness = v end
})

AimbotTab:CreateToggle({
    Name = "WallCheck",
    CurrentValue = true,
    Callback = function(v) Settings.Aimbot.WallCheck = v end
})

AimbotTab:CreateToggle({
    Name = "TeamCheck",
    CurrentValue = true,
    Callback = function(v) Settings.Aimbot.TeamCheck = v end
})

-- Combat
CombatTab:CreateToggle({
    Name = "TriggerBot",
    CurrentValue = false,
    Callback = function(v) Settings.TriggerBot.Enabled = v end
})

CombatTab:CreateSlider({
    Name = "TriggerBot Delay",
    Range = {0.01, 0.3},
    Increment = 0.01,
    CurrentValue = 0.05,
    Callback = function(v) Settings.TriggerBot.Delay = v end
})

CombatTab:CreateToggle({
    Name = "Anti-Recoil",
    CurrentValue = false,
    Callback = function(v) Settings.AntiRecoil.Enabled = v end
})

CombatTab:CreateToggle({
    Name = "Anti-Aim (Jitter)",
    CurrentValue = false,
    Callback = function(v) Settings.AntiAim.Enabled = v end
})

-- Misc
MiscTab:CreateSlider({
    Name = "WalkSpeed",
    Range = {16, 100},
    Increment = 1,
    CurrentValue = 16,
    Callback = function(v) Settings.Misc.WalkSpeed = v end
})

MiscTab:CreateSlider({
    Name = "JumpPower",
    Range = {50, 200},
    Increment = 5,
    CurrentValue = 50,
    Callback = function(v) Settings.Misc.JumpPower = v end
})

--// Keybind
UserInputService.InputBegan:Connect(function(Input)
    if Input.KeyCode == Enum.KeyCode.Q then
        Holding = not Holding
        Rayfield:Notify({
            Title = "Aimbot",
            Content = Holding and "ON" or "OFF",
            Duration = 1
        })
    end
end)

print("[Universal v4] Loaded | กด Q เพื่อเปิด Aimbot")
Rayfield:Notify({
    Title = "Loaded",
    Content = "Aimbot + TriggerBot + Anti-Recoil + Anti-Aim",
    Duration = 4
})