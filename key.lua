--// ==================== KEY SYSTEM ====================
local Key = "Fyfff2026"                              -- เปลี่ยนคีย์ตรงนี้ได้
local KeyFile = "UniversalKey.txt"

-- ลิงก์ Raw จาก GitHub ของมึง (อัพเดทแล้ว)
local MainScriptURL = "https://raw.githubusercontent.com/Earth3095/Earth-Hub/main/main.lua"

local function LoadMainScript()
    print("[Key System] Key ถูกต้อง กำลังโหลดสคริปต์จาก GitHub...")
    
    local success, err = pcall(function()
        loadstring(game:HttpGet(MainScriptURL))()
    end)
    
    if not success then
        warn("[Key System] โหลดสคริปต์ล้มเหลว: " .. tostring(err))
    end
end

-- ตรวจสอบคีย์ที่บันทึกไว้
if isfile(KeyFile) then
    if readfile(KeyFile) == Key then
        LoadMainScript()
        return
    else
        delfile(KeyFile)
    end
end

-- GUI ใส่คีย์
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "Key System",
    LoadingTitle = "Earth Hub",
    LoadingSubtitle = "กรุณาใส่คีย์",
})

local Tab = Window:CreateTab("Enter Key")

Tab:CreateInput({
    Name = "ใส่คีย์",
    PlaceholderText = "กรุณาใส่คีย์ที่นี่",
    RemoveTextAfterFocusLost = false,
    Callback = function(Input)
        if Input == Key then
            writefile(KeyFile, Key)
            Rayfield:Notify({
                Title = "สำเร็จ",
                Content = "คีย์ถูกต้อง กำลังโหลดสคริปต์...",
                Duration = 2
            })
            task.wait(1)
            Window:Destroy()
            LoadMainScript()
        else
            Rayfield:Notify({
                Title = "ผิดพลาด",
                Content = "คีย์ไม่ถูกต้อง",
                Duration = 3
            })
        end
    end
})

Tab:CreateLabel("คีย์จะถูกบันทึกไว้ ไม่ต้องใส่ซ้ำครั้งต่อไป")