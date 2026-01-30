-- ╔═══════════════════════════════════════════════════════════╗
-- ║   ULTIMATE HUB V3.0 - MAIN SCRIPT (PREMIUM EDITION)      ║
-- ║   Advanced Anti-Cheat Bypass + Premium Features          ║
-- ╚═══════════════════════════════════════════════════════════╝

-- Check if user has valid permissions
if not getgenv().UserPermissions or getgenv().UserPermissions.tier == "NONE" then
    game.Players.LocalPlayer:Kick("Unauthorized Access - Please verify your key first")
    return
end

local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/jensonhirst/Orion/main/source')))()
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

-- ═════════════════════════════════════════════════════════════
-- ║          ADVANCED ANTI-CHEAT BYPASS SYSTEM               ║
-- ═════════════════════════════════════════════════════════════

local function SetupMaximumBypass()
    -- Metamethod Protection
    local mt = getrawmetatable(game)
    local oldNamecall = mt.__namecall
    local oldIndex = mt.__index
    local oldNewIndex = mt.__newindex
    
    setreadonly(mt, false)
    
    -- Block all anti-cheat remote calls
    mt.__namecall = newcclosure(function(Self, ...)
        local Args = {...}
        local Method = getnamecallmethod()
        
        if Method == "FireServer" or Method == "InvokeServer" then
            local RemoteName = tostring(Self):lower()
            if RemoteName:find("ban") or RemoteName:find("kick") or 
               RemoteName:find("anticheat") or RemoteName:find("ac") or
               RemoteName:find("detection") or RemoteName:find("flag") or
               RemoteName:find("report") or RemoteName:find("log") or
               RemoteName:find("admin") then
                return nil
            end
        end
        
        if Method == "Kick" then
            return nil
        end
        
        return oldNamecall(Self, ...)
    end)
    
    -- Spoof property readings
    mt.__index = newcclosure(function(Self, Key)
        if typeof(Self) == "Instance" and Self:IsA("Humanoid") then
            if Key == "WalkSpeed" then
                return 16
            elseif Key == "JumpPower" then
                return 50
            elseif Key == "JumpHeight" then
                return 7.2
            end
        end
        return oldIndex(Self, Key)
    end)
    
    setreadonly(mt, true)
    
    -- Anti-Kick Protection
    hookfunction(LocalPlayer.Kick, function() return nil end)
    
    -- Anti-AFK (Multiple Methods)
    local VirtualUser = game:GetService("VirtualUser")
    LocalPlayer.Idled:Connect(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end)
    
    spawn(function()
        while wait(math.random(60, 180)) do
            local keys = {Enum.KeyCode.W, Enum.KeyCode.A, Enum.KeyCode.S, Enum.KeyCode.D}
            local randomKey = keys[math.random(1, #keys)]
            local VIM = game:GetService("VirtualInputManager")
            VIM:SendKeyEvent(true, randomKey, false, game)
            wait(0.1)
            VIM:SendKeyEvent(false, randomKey, false, game)
        end
    end)
end

pcall(SetupMaximumBypass)

-- ═════════════════════════════════════════════════════════════
-- ║              GLOBAL SETTINGS & STORAGE                   ║
-- ═════════════════════════════════════════════════════════════

getgenv().UltimateHub = getgenv().UltimateHub or {
    Settings = {},
    Connections = {},
    Premium = {
        ScriptBuilder = {},
        CustomScripts = {},
        SavedConfigs = {}
    }
}

-- ═════════════════════════════════════════════════════════════
-- ║              ADVANCED FEATURE FUNCTIONS                  ║
-- ═════════════════════════════════════════════════════════════

local Features = {}

-- Advanced Movement
function Features.SetWalkSpeed(speed)
    local character = LocalPlayer.Character
    if character then
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = speed
            
            if getgenv().UltimateHub.Connections.WalkSpeed then
                getgenv().UltimateHub.Connections.WalkSpeed:Disconnect()
            end
            
            getgenv().UltimateHub.Connections.WalkSpeed = RunService.Heartbeat:Connect(function()
                if humanoid.WalkSpeed ~= speed then
                    humanoid.WalkSpeed = speed
                end
            end)
        end
    end
end

function Features.SetJumpPower(power)
    local character = LocalPlayer.Character
    if character then
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            pcall(function()
                humanoid.UseJumpPower = true
                humanoid.JumpPower = power
            end)
            pcall(function()
                humanoid.UseJumpPower = false
                humanoid.JumpHeight = power / 7
            end)
        end
    end
end

function Features.InfiniteJump(enabled)
    if enabled then
        getgenv().UltimateHub.Connections.InfJump = UserInputService.JumpRequest:Connect(function()
            local character = LocalPlayer.Character
            if character then
                local humanoid = character:FindFirstChildOfClass("Humanoid")
                if humanoid then
                    humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end
        end)
    else
        if getgenv().UltimateHub.Connections.InfJump then
            getgenv().UltimateHub.Connections.InfJump:Disconnect()
        end
    end
end

function Features.NoClip(enabled)
    if enabled then
        getgenv().UltimateHub.Connections.NoClip = RunService.Stepped:Connect(function()
            local character = LocalPlayer.Character
            if character then
                for _, part in pairs(character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end)
    else
        if getgenv().UltimateHub.Connections.NoClip then
            getgenv().UltimateHub.Connections.NoClip:Disconnect()
        end
    end
end

function Features.Fly(enabled)
    if enabled then
        local character = LocalPlayer.Character
        if not character then return end
        
        local rootPart = character:FindFirstChild("HumanoidRootPart")
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if not rootPart or not humanoid then return end
        
        local BV = Instance.new("BodyVelocity")
        BV.Velocity = Vector3.new(0, 0, 0)
        BV.MaxForce = Vector3.new(9e9, 9e9, 9e9)
        BV.Parent = rootPart
        
        local BG = Instance.new("BodyGyro")
        BG.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
        BG.CFrame = rootPart.CFrame
        BG.Parent = rootPart
        
        getgenv().UltimateHub.FlyBV = BV
        getgenv().UltimateHub.FlyBG = BG
        
        getgenv().UltimateHub.Connections.Fly = RunService.Heartbeat:Connect(function()
            local speed = 100
            local camera = workspace.CurrentCamera
            local direction = Vector3.new(0, 0, 0)
            
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                direction = direction + camera.CFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                direction = direction - camera.CFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                direction = direction - camera.CFrame.RightVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                direction = direction + camera.CFrame.RightVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                direction = direction + Vector3.new(0, 1, 0)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
                direction = direction - Vector3.new(0, 1, 0)
            end
            
            BV.Velocity = direction.Unit * speed
            BG.CFrame = camera.CFrame
            humanoid.PlatformStand = true
        end)
    else
        if getgenv().UltimateHub.Connections.Fly then
            getgenv().UltimateHub.Connections.Fly:Disconnect()
        end
        if getgenv().UltimateHub.FlyBV then
            getgenv().UltimateHub.FlyBV:Destroy()
        end
        if getgenv().UltimateHub.FlyBG then
            getgenv().UltimateHub.FlyBG:Destroy()
        end
        
        local character = LocalPlayer.Character
        if character then
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid.PlatformStand = false
            end
        end
    end
end

function Features.Aimbot(enabled)
    if enabled then
        getgenv().UltimateHub.Connections.Aimbot = RunService.RenderStepped:Connect(function()
            local camera = workspace.CurrentCamera
            local closestPlayer = nil
            local shortestDistance = 200
            
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character then
                    local head = player.Character:FindFirstChild("Head")
                    if head then
                        local screenPos, onScreen = camera:WorldToViewportPoint(head.Position)
                        if onScreen then
                            local mousePos = UserInputService:GetMouseLocation()
                            local distance = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                            
                            if distance < shortestDistance then
                                closestPlayer = player
                                shortestDistance = distance
                            end
                        end
                    end
                end
            end
            
            if closestPlayer and closestPlayer.Character then
                local head = closestPlayer.Character:FindFirstChild("Head")
                if head then
                    local targetCFrame = CFrame.new(camera.CFrame.Position, head.Position)
                    camera.CFrame = camera.CFrame:Lerp(targetCFrame, 0.5)
                end
            end
        end)
    else
        if getgenv().UltimateHub.Connections.Aimbot then
            getgenv().UltimateHub.Connections.Aimbot:Disconnect()
        end
    end
end

function Features.ESP(enabled)
    local function addESP(player)
        if player == LocalPlayer then return end
        local character = player.Character or player.CharacterAdded:Wait()
        
        if enabled then
            if character:FindFirstChild("ESP_Highlight") then
                character.ESP_Highlight:Destroy()
            end
            
            local highlight = Instance.new("Highlight")
            highlight.Name = "ESP_Highlight"
            highlight.Parent = character
            highlight.FillColor = Color3.fromRGB(255, 0, 0)
            highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
            highlight.FillTransparency = 0.5
            highlight.OutlineTransparency = 0
            highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        else
            if character:FindFirstChild("ESP_Highlight") then
                character.ESP_Highlight:Destroy()
            end
        end
    end
    
    for _, player in pairs(Players:GetPlayers()) do
        if player.Character then
            addESP(player)
        end
        player.CharacterAdded:Connect(function()
            wait(1)
            addESP(player)
        end)
    end
end

function Features.KillAura(enabled, range)
    if enabled then
        spawn(function()
            while getgenv().UltimateHub.Settings.KillAura do
                wait(0.05)
                local character = LocalPlayer.Character
                if character then
                    local rootPart = character:FindFirstChild("HumanoidRootPart")
                    if rootPart then
                        for _, player in pairs(Players:GetPlayers()) do
                            if player ~= LocalPlayer and player.Character then
                                local targetRoot = player.Character:FindFirstChild("HumanoidRootPart")
                                local targetHumanoid = player.Character:FindFirstChildOfClass("Humanoid")
                                
                                if targetRoot and targetHumanoid then
                                    local distance = (rootPart.Position - targetRoot.Position).Magnitude
                                    if distance <= range then
                                        targetHumanoid.Health = 0
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end)
    end
    getgenv().UltimateHub.Settings.KillAura = enabled
end

-- ═════════════════════════════════════════════════════════════
-- ║              PREMIUM-ONLY FEATURES                       ║
-- ═════════════════════════════════════════════════════════════

local PremiumFeatures = {}

-- Script Builder (Premium Only)
function PremiumFeatures.ScriptBuilder()
    local scriptCode = ""
    
    local builderWindow = OrionLib:MakeWindow({
        Name = "💎 Script Builder (Premium)",
        HidePremium = false,
        SaveConfig = false
    })
    
    local builderTab = builderWindow:MakeTab({
        Name = "Builder",
        Icon = "rbxassetid://4483345998"
    })
    
    builderTab:AddTextbox({
        Name = "Script Code",
        Default = "-- Enter your code here",
        TextDisappear = false,
        Callback = function(Value)
            scriptCode = Value
        end
    })
    
    builderTab:AddButton({
        Name = "Execute Script",
        Callback = function()
            local success, err = pcall(function()
                loadstring(scriptCode)()
            end)
            
            if success then
                OrionLib:MakeNotification({
                    Name = "✅ Success",
                    Content = "Script executed successfully",
                    Time = 3
                })
            else
                OrionLib:MakeNotification({
                    Name = "❌ Error",
                    Content = tostring(err),
                    Time = 5
                })
            end
        end
    })
    
    builderTab:AddButton({
        Name = "Save Script",
        Callback = function()
            table.insert(getgenv().UltimateHub.Premium.CustomScripts, scriptCode)
            OrionLib:MakeNotification({
                Name = "✅ Saved",
                Content = "Script saved to library",
                Time = 3
            })
        end
    })
end

-- Advanced Aimbot Settings (Premium)
function PremiumFeatures.AdvancedAimbot()
    return {
        prediction = true,
        silentAim = true,
        targetPart = "Head",
        ignoreTeam = true,
        visibilityCheck = true,
        smoothness = 0.8
    }
end

-- Mass Actions (Premium)
function PremiumFeatures.MassKill()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid.Health = 0
            end
        end
    end
end

function PremiumFeatures.MassTeleport(location)
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local rootPart = player.Character:FindFirstChild("HumanoidRootPart")
            if rootPart then
                rootPart.CFrame = location
            end
        end
    end
end

-- Game Modifier (Premium)
function PremiumFeatures.ModifyGame()
    return {
        changeGravity = function(value) workspace.Gravity = value end,
        changeTime = function(value) game.Lighting.ClockTime = value end,
        removeParts = function(name)
            for _, v in pairs(workspace:GetDescendants()) do
                if v.Name == name then
                    v:Destroy()
                end
            end
        end,
        cloneParts = function(part)
            return part:Clone()
        end
    }
end

-- ═════════════════════════════════════════════════════════════
-- ║              OWNER-ONLY FEATURES                         ║
-- ═════════════════════════════════════════════════════════════

local OwnerFeatures = {}

-- Complete Game Control
function OwnerFeatures.GameControl()
    return {
        kickPlayer = function(player)
            if player and player ~= LocalPlayer then
                player:Kick("Kicked by script owner")
            end
        end,
        
        kickAll = function()
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= LocalPlayer then
                    player:Kick("Server cleared by owner")
                end
            end
        end,
        
        freezePlayer = function(player)
            if player and player.Character then
                local rootPart = player.Character:FindFirstChild("HumanoidRootPart")
                if rootPart then
                    rootPart.Anchored = true
                end
            end
        end,
        
        crashServer = function()
            while true do end
        end,
        
        modifyRemotes = function()
            for _, v in pairs(game:GetDescendants()) do
                if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") then
                    v:Destroy()
                end
            end
        end
    }
end

-- Script Editor (Owner)
function OwnerFeatures.EditScript()
    return {
        modifySource = true,
        addFeatures = true,
        removeRestrictions = true,
        exportScript = function()
            return getgenv().UltimateHub
        end
    }
end

-- ═════════════════════════════════════════════════════════════
-- ║                    CREATE MAIN GUI                       ║
-- ═════════════════════════════════════════════════════════════

local tierEmoji = {
    FREE = "🔴",
    PREMIUM = "💎",
    OWNER = "👑"
}

local Window = OrionLib:MakeWindow({
    Name = tierEmoji[getgenv().UserPermissions.tier] .. " ULTIMATE HUB V3.0 - " .. getgenv().UserPermissions.tier,
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "UltimateHubV3",
    IntroEnabled = true,
    IntroText = "Welcome " .. getgenv().UserPermissions.tier .. " User",
    IntroIcon = "rbxassetid://4483345998"
})

OrionLib:MakeNotification({
    Name = "✅ ULTIMATE HUB LOADED",
    Content = "Tier: " .. getgenv().UserPermissions.tier,
    Image = "rbxassetid://4483345998",
    Time = 5
})

-- ═════════════════════════════════════════════════════════════
-- ║                    TAB 1: PLAYER                         ║
-- ═════════════════════════════════════════════════════════════

local PlayerTab = Window:MakeTab({
    Name = "Player",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

local MovementSection = PlayerTab:AddSection({
    Name = "⚡ MOVEMENT"
})

PlayerTab:AddSlider({
    Name = "WalkSpeed",
    Min = 16,
    Max = 500,
    Default = 16,
    Color = Color3.fromRGB(255, 85, 0),
    Increment = 1,
    ValueName = "Speed",
    Save = true,
    Flag = "WalkSpeed",
    Callback = function(Value)
        Features.SetWalkSpeed(Value)
    end
})

PlayerTab:AddSlider({
    Name = "JumpPower",
    Min = 50,
    Max = 500,
    Default = 50,
    Color = Color3.fromRGB(0, 255, 127),
    Increment = 1,
    ValueName = "Power",
    Save = true,
    Flag = "JumpPower",
    Callback = function(Value)
        Features.SetJumpPower(Value)
    end
})

PlayerTab:AddSlider({
    Name = "Gravity",
    Min = 0,
    Max = 196.2,
    Default = 196.2,
    Color = Color3.fromRGB(128, 0, 255),
    Increment = 1,
    ValueName = "G",
    Save = true,
    Flag = "Gravity",
    Callback = function(Value)
        workspace.Gravity = Value
    end
})

PlayerTab:AddToggle({
    Name = "Infinite Jump",
    Default = false,
    Save = true,
    Flag = "InfJump",
    Callback = function(Value)
        Features.InfiniteJump(Value)
    end
})

PlayerTab:AddToggle({
    Name = "NoClip",
    Default = false,
    Save = true,
    Flag = "NoClip",
    Callback = function(Value)
        Features.NoClip(Value)
    end
})

PlayerTab:AddToggle({
    Name = "Fly",
    Default = false,
    Save = true,
    Flag = "Fly",
    Callback = function(Value)
        Features.Fly(Value)
    end
})

-- ═════════════════════════════════════════════════════════════
-- ║                    TAB 2: COMBAT                         ║
-- ═════════════════════════════════════════════════════════════

local CombatTab = Window:MakeTab({
    Name = "Combat",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

local AimbotSection = CombatTab:AddSection({
    Name = "🎯 AIMBOT"
})

CombatTab:AddToggle({
    Name = "Aimbot",
    Default = false,
    Save = true,
    Flag = "Aimbot",
    Callback = function(Value)
        Features.Aimbot(Value)
    end
})

CombatTab:AddToggle({
    Name = "ESP",
    Default = false,
    Save = true,
    Flag = "ESP",
    Callback = function(Value)
        Features.ESP(Value)
    end
})

CombatTab:AddToggle({
    Name = "Kill Aura",
    Default = false,
    Save = true,
    Flag = "KillAura",
    Callback = function(Value)
        Features.KillAura(Value, 20)
    end
})

-- ═════════════════════════════════════════════════════════════
-- ║              TAB 3: PREMIUM FEATURES                     ║
-- ═════════════════════════════════════════════════════════════

if getgenv().UserPermissions.premium then
    local PremiumTab = Window:MakeTab({
        Name = "💎 Premium",
        Icon = "rbxassetid://4483345998",
        PremiumOnly = false
    })
    
    local PremiumSection = PremiumTab:AddSection({
        Name = "💎 PREMIUM EXCLUSIVE"
    })
    
    PremiumTab:AddButton({
        Name = "Script Builder",
        Callback = function()
            PremiumFeatures.ScriptBuilder()
        end
    })
    
    PremiumTab:AddButton({
        Name = "Mass Kill All Players",
        Callback = function()
            PremiumFeatures.MassKill()
            OrionLib:MakeNotification({
                Name = "💎 Premium Feature",
                Content = "Mass kill executed",
                Time = 3
            })
        end
    })
    
    PremiumTab:AddButton({
        Name = "Advanced Aimbot",
        Callback = function()
            local settings = PremiumFeatures.AdvancedAimbot()
            OrionLib:MakeNotification({
                Name = "💎 Premium Feature",
                Content = "Advanced aimbot activated",
                Time = 3
            })
        end
    })
end

-- ═════════════════════════════════════════════════════════════
-- ║              TAB 4: OWNER FEATURES                       ║
-- ═════════════════════════════════════════════════════════════

if getgenv().UserPermissions.admin then
    local OwnerTab = Window:MakeTab({
        Name = "👑 Owner",
        Icon = "rbxassetid://4483345998",
        PremiumOnly = false
    })
    
    local OwnerSection = OwnerTab:AddSection({
        Name = "👑 OWNER CONTROLS"
    })
    
    OwnerTab:AddButton({
        Name = "Kick All Players",
        Callback = function()
            OwnerFeatures.GameControl().kickAll()
        end
    })
    
    OwnerTab:AddButton({
        Name = "Crash Server",
        Callback = function()
            OwnerFeatures.GameControl().crashServer()
        end
    })
    
    OwnerTab:AddButton({
        Name = "Delete All Remotes",
        Callback = function()
            OwnerFeatures.GameControl().modifyRemotes()
        end
    })
    
    OwnerTab:AddButton({
        Name = "Export Script Source",
        Callback = function()
            local source = OwnerFeatures.EditScript().exportScript()
            setclipboard(game:GetService("HttpService"):JSONEncode(source))
            OrionLib:MakeNotification({
                Name = "👑 Owner Feature",
                Content = "Script source exported to clipboard",
                Time = 3
            })
        end
    })
    
    OwnerTab:AddTextbox({
        Name = "Execute Custom Code",
        Default = "",
        TextDisappear = false,
        Callback = function(Value)
            loadstring(Value)()
        end
    })
end

-- ═════════════════════════════════════════════════════════════
-- ║                    TAB: INFO                             ║
-- ═════════════════════════════════════════════════════════════

local InfoTab = Window:MakeTab({
    Name = "Info",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

InfoTab:AddParagraph("Your License", 
    "Tier: " .. getgenv().UserPermissions.tier .. "\n" ..
    "Premium: " .. tostring(getgenv().UserPermissions.premium) .. "\n" ..
    "Admin: " .. tostring(getgenv().UserPermissions.admin)
)

if getgenv().UserPermissions.validUntil ~= math.huge then
    local daysLeft = math.floor((getgenv().UserPermissions.validUntil - os.time()) / 86400)
    InfoTab:AddLabel("Days Remaining: " .. daysLeft)
else
    InfoTab:AddLabel("Expiry: UNLIMITED")
end

OrionLib:Init()
