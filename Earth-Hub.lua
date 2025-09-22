-- ======= Earth Hub =======
local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/jensonhirst/Orion/main/source')))()

local Window = OrionLib:MakeWindow({
    Name = "Earth Hub",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "EarthHubConfig"
})

-- ======= Player Tab =======
local PlayerTab = Window:MakeTab({
    Name = "Player",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

-- ตัวแปรความเร็วบิน
local flyspeed = 50
local flying = false

-- ฟังก์ชันเริ่มบิน FlyGuiV3 แบบปรับความเร็วได้
local function startFlying()
    if flying then return end
    flying = true
    local code = game:HttpGet("https://raw.githubusercontent.com/XNEOFF/FlyGuiV3/main/FlyGuiV3.txt")
    local FlyFunc = loadstring(code)
    -- ใส่ตัวแปร flyspeed ก่อนรัน
    _G.FlySpeed = flyspeed
    FlyFunc()
end

local function stopFlying()
    if not flying then return end
    flying = false
    if _G.FlyStop then
        _G.FlyStop() -- FlyGuiV3 ต้องมีตัวแปรหยุดบิน
    end
end

-- ปุ่มบิน
PlayerTab:AddButton({
    Name = "บิน",
    Callback = function()
        startFlying()
    end
})

-- ความเร็วในการบิน
PlayerTab:AddTextbox({
    Name = "ความเร็วในการบิน",
    Default = "50",
    TextDisappear = true,
    Callback = function(Value)
        local num = tonumber(Value)
        if num then
            flyspeed = math.clamp(num, 1, 1000)
            _G.FlySpeed = flyspeed -- อัปเดตให้ FlyGuiV3 รับค่าใหม่
        end
    end
})

-- ======= Movement Tab =======
local MoveTab = Window:MakeTab({
    Name = "การเคลื่อนที่",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

local walkSpeed = 16
local jumpPower = 50
local noclipEnabled = false

MoveTab:AddTextbox({
    Name = "ความเร็วในการเดิน",
    Default = "16",
    TextDisappear = true,
    Callback = function(Value)
        local num = tonumber(Value)
        if num then
            walkSpeed = num
            if game.Players.LocalPlayer.Character then
                game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = walkSpeed
            end
        end
    end
})

MoveTab:AddTextbox({
    Name = "ความสูงการกระโดด",
    Default = "50",
    TextDisappear = true,
    Callback = function(Value)
        local num = tonumber(Value)
        if num then
            jumpPower = num
            if game.Players.LocalPlayer.Character then
                game.Players.LocalPlayer.Character.Humanoid.JumpPower = jumpPower
            end
        end
    end
})

MoveTab:AddToggle({
    Name = "เดินทะลุกำแพง",
    Default = false,
    Callback = function(Value)
        noclipEnabled = Value
        local function NoclipLoop()
            while noclipEnabled and game:GetService("RunService").Stepped:Wait() do
                if game.Players.LocalPlayer.Character then
                    for _,v in pairs(game.Players.LocalPlayer.Character:GetDescendants()) do
                        if v:IsA("BasePart") then
                            v.CanCollide = false
                        end
                    end
                end
            end
        end
        spawn(NoclipLoop)
    end
})

MoveTab:AddToggle({
    Name = "กระโดดไม่จำกัด",
    Default = false,
    Callback = function(Value)
        local plr = game.Players.LocalPlayer
        if Value then
            plr.Character.Humanoid:GetPropertyChangedSignal("JumpPower"):Connect(function()
                plr.Character.Humanoid.JumpPower = jumpPower
            end)
        end
    end
})

-- ======= Map Tab =======
local MapTab = Window:MakeTab({
    Name = "แมพ",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

MapTab:AddButton({
    Name = "Steal A Brainrot v1",
    Callback = function()
        loadstring(game:HttpGet("https://pastefy.app/0CVCLFPZ/raw"))()
    end
})

-- ตั้งค่าความเร็วและกระโดดเริ่มต้น
game.Players.LocalPlayer.CharacterAdded:Connect(function(char)
    wait(0.5)
    char.Humanoid.WalkSpeed = walkSpeed
    char.Humanoid.JumpPower = jumpPower
end)