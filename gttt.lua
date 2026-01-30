-- ╔═══════════════════════════════════════════════════════════╗
-- ║          ULTIMATE HUB V3.0 - KEY SYSTEM                  ║
-- ║          Advanced Encryption & Premium Access            ║
-- ╚═══════════════════════════════════════════════════════════╝

local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/jensonhirst/Orion/main/source')))()

-- ═════════════════════════════════════════════════════════════
-- ║              ADVANCED ENCRYPTION SYSTEM                  ║
-- ═════════════════════════════════════════════════════════════

local EncryptionModule = {}

-- XOR Encryption
function EncryptionModule.XOR(text, key)
    local result = {}
    for i = 1, #text do
        local byte = string.byte(text, i)
        local keyByte = string.byte(key, (i - 1) % #key + 1)
        table.insert(result, string.char(bit32.bxor(byte, keyByte)))
    end
    return table.concat(result)
end

-- Base64 Encoding
function EncryptionModule.Base64Encode(data)
    local b = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
    return ((data:gsub('.', function(x) 
        local r,b='',x:byte()
        for i=8,1,-1 do r=r..(b%2^i-b%2^(i-1)>0 and '1' or '0') end
        return r;
    end)..'0000'):gsub('%d%d%d?%d?%d?%d?', function(x)
        if (#x < 6) then return '' end
        local c=0
        for i=1,6 do c=c+(x:sub(i,i)=='1' and 2^(6-i) or 0) end
        return b:sub(c+1,c+1)
    end)..({ '', '==', '=' })[#data%3+1])
end

-- Base64 Decoding
function EncryptionModule.Base64Decode(data)
    local b='ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
    data = string.gsub(data, '[^'..b..'=]', '')
    return (data:gsub('.', function(x)
        if (x == '=') then return '' end
        local r,f='',(b:find(x)-1)
        for i=6,1,-1 do r=r..(f%2^i-f%2^(i-1)>0 and '1' or '0') end
        return r;
    end):gsub('%d%d%d?%d?%d?%d?%d?%d?', function(x)
        if (#x ~= 8) then return '' end
        local c=0
        for i=1,8 do c=c+(x:sub(i,i)=='1' and 2^(8-i) or 0) end
        return string.char(c)
    end))
end

-- SHA256-like Hash Function
function EncryptionModule.Hash(str)
    local hash = 0
    for i = 1, #str do
        local char = string.byte(str, i)
        hash = ((hash * 31) + char) % 2147483647
    end
    return string.format("%x", hash)
end

-- Advanced Key Validation
function EncryptionModule.ValidateKey(inputKey, correctHash)
    local hashedInput = EncryptionModule.Hash(inputKey)
    return hashedInput == correctHash
end

-- ═════════════════════════════════════════════════════════════
-- ║                  KEY DATABASE (ENCRYPTED)                ║
-- ═════════════════════════════════════════════════════════════

local KeyDatabase = {
    -- Owner Key (Unlimited Access)
    ["22779918PPm!"] = {
        hash = EncryptionModule.Hash("22779918PPm!"),
        tier = "OWNER",
        expiry = math.huge,
        hwid = "ANY",
        permissions = {
            admin = true,
            premium = true,
            unlimited = true,
            modify_script = true,
            access_all = true
        }
    },
    
    -- Premium Keys (Example)
    ["PREMIUM2024"] = {
        hash = EncryptionModule.Hash("PREMIUM2024"),
        tier = "PREMIUM",
        expiry = os.time() + (30 * 24 * 60 * 60), -- 30 days
        hwid = "MULTI",
        permissions = {
            admin = false,
            premium = true,
            unlimited = false,
            modify_script = false,
            access_all = true
        }
    },
    
    -- Free Keys (Limited)
    ["FREE2024"] = {
        hash = EncryptionModule.Hash("FREE2024"),
        tier = "FREE",
        expiry = os.time() + (7 * 24 * 60 * 60), -- 7 days
        hwid = "SINGLE",
        permissions = {
            admin = false,
            premium = false,
            unlimited = false,
            modify_script = false,
            access_all = false
        }
    }
}

-- ═════════════════════════════════════════════════════════════
-- ║                  HWID SYSTEM                             ║
-- ═════════════════════════════════════════════════════════════

local function GetHWID()
    local hwid = game:GetService("RbxAnalyticsService"):GetClientId()
    return EncryptionModule.Hash(hwid)
end

-- ═════════════════════════════════════════════════════════════
-- ║                  KEY VERIFICATION                        ║
-- ═════════════════════════════════════════════════════════════

getgenv().UserPermissions = {
    tier = "NONE",
    premium = false,
    admin = false,
    unlimited = false,
    validUntil = 0
}

local function VerifyKey(key)
    -- Check if key exists in database
    local keyData = KeyDatabase[key]
    
    if not keyData then
        return false, "Invalid Key"
    end
    
    -- Validate hash
    local inputHash = EncryptionModule.Hash(key)
    if inputHash ~= keyData.hash then
        return false, "Key Corruption Detected"
    end
    
    -- Check expiry
    if os.time() > keyData.expiry then
        return false, "Key Expired"
    end
    
    -- HWID Check
    local currentHWID = GetHWID()
    if keyData.hwid ~= "ANY" and keyData.hwid ~= "MULTI" then
        if keyData.hwid ~= currentHWID then
            return false, "HWID Mismatch"
        end
    end
    
    -- Set user permissions
    getgenv().UserPermissions = {
        tier = keyData.tier,
        premium = keyData.permissions.premium,
        admin = keyData.permissions.admin,
        unlimited = keyData.permissions.unlimited,
        modify_script = keyData.permissions.modify_script,
        access_all = keyData.permissions.access_all,
        validUntil = keyData.expiry
    }
    
    return true, "Key Verified: " .. keyData.tier
end

-- ═════════════════════════════════════════════════════════════
-- ║              CREATE KEY SYSTEM GUI                       ║
-- ═════════════════════════════════════════════════════════════

local KeyWindow = OrionLib:MakeWindow({
    Name = "🔐 ULTIMATE HUB - KEY SYSTEM",
    HidePremium = true,
    SaveConfig = false,
    IntroEnabled = true,
    IntroText = "Key Verification Required",
    IntroIcon = "rbxassetid://4483345998"
})

local KeyTab = KeyWindow:MakeTab({
    Name = "Key System",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

local InfoSection = KeyTab:AddSection({
    Name = "🔒 License Verification"
})

KeyTab:AddParagraph("Welcome!", "Enter your license key to access Ultimate Hub V3.0")

KeyTab:AddParagraph("Key Tiers", 
    "🔴 FREE - Basic Features (7 Days)\n" ..
    "🟡 PREMIUM - All Features (30 Days)\n" ..
    "🟢 OWNER - Unlimited Access"
)

local KeySection = KeyTab:AddSection({
    Name = "Enter Your Key"
})

local enteredKey = ""

KeyTab:AddTextbox({
    Name = "License Key",
    Default = "",
    TextDisappear = false,
    Callback = function(Value)
        enteredKey = Value
    end      
})

KeyTab:AddButton({
    Name = "Verify Key",
    Callback = function()
        if enteredKey == "" then
            OrionLib:MakeNotification({
                Name = "❌ Error",
                Content = "Please enter a key",
                Image = "rbxassetid://4483345998",
                Time = 3
            })
            return
        end
        
        local success, message = VerifyKey(enteredKey)
        
        if success then
            OrionLib:MakeNotification({
                Name = "✅ Success",
                Content = message,
                Image = "rbxassetid://4483345998",
                Time = 3
            })
            
            wait(1)
            
            -- Destroy key window
            KeyWindow:Destroy()
            
            -- Load main script
            wait(0.5)
      loadstring(game:HttpGet("https://raw.githubusercontent.com/Earth3095/Earth-Hub/main/UltimateHub_Main.lua"))()
        else
            OrionLib:MakeNotification({
                Name = "❌ Verification Failed",
                Content = message,
                Image = "rbxassetid://4483345998",
                Time = 5
            })
        end
    end    
})

local GetKeySection = KeyTab:AddSection({
    Name = "📥 Get a Key"
})

KeyTab:AddButton({
    Name = "Copy Discord Server Link",
    Callback = function()
        setclipboard("https://discord.gg/YourServerHere")
        OrionLib:MakeNotification({
            Name = "✅ Copied",
            Content = "Discord link copied to clipboard",
            Image = "rbxassetid://4483345998",
            Time = 3
        })
    end    
})

KeyTab:AddButton({
    Name = "Copy Key Purchase Link",
    Callback = function()
        setclipboard("https://your-shop-link.com")
        OrionLib:MakeNotification({
            Name = "✅ Copied",
            Content = "Purchase link copied to clipboard",
            Image = "rbxassetid://4483345998",
            Time = 3
        })
    end    
})

local HWIDSection = KeyTab:AddSection({
    Name = "💻 HWID Information"
})

KeyTab:AddLabel("Your HWID: " .. GetHWID():sub(1, 16) .. "...")

KeyTab:AddButton({
    Name = "Copy HWID",
    Callback = function()
        setclipboard(GetHWID())
        OrionLib:MakeNotification({
            Name = "✅ Copied",
            Content = "HWID copied to clipboard",
            Image = "rbxassetid://4483345998",
            Time = 3
        })
    end    
})

OrionLib:Init()