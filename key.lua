--// ==================== KEY SYSTEM (Fixed) ====================
local Key = "Fyfff2026"
local KeyFile = "UniversalKey.txt"
local MainScriptURL = "https://raw.githubusercontent.com/Earth3095/Earth-Hub/main/main.lua"

local function LoadMainScript()
    local success, err = pcall(function()
        loadstring(game:HttpGet(MainScriptURL))()
    end)
    
    if not success then
        warn("[Key System] โหลดสคริปต์ล้มเหลว: " .. tostring(err))
    end
end

-- ตรวจสอบคีย์เก่า
if isfile(KeyFile) and readfile(KeyFile) == Key then
    LoadMainScript()
    return
end

-- GUI
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "Key System",
    LoadingTitle = "Earth Hub",
    LoadingSubtitle = "Enter Key",
})

local Tab = Window:CreateTab("Key")

Tab:CreateInput({
    Name = "Enter Key",
    PlaceholderText = "Input your key here",
    RemoveTextAfterFocusLost = false,
    Callback = function(Input)
        if Input == Key then
            local success, err = pcall(function()
                writefile(KeyFile, Key)
            end)
            
            if success then
                Rayfield:Notify({
                    Title = "Success",
                    Content = "Key accepted. Loading script...",
                    Duration = 2
                })
                task.wait(1)
                Window:Destroy()
                LoadMainScript()
            else
                Rayfield:Notify({
                    Title = "Error",
                    Content = "Failed to save key: " .. tostring(err),
                    Duration = 4
                })
            end
        else
            Rayfield:Notify({
                Title = "Wrong Key",
                Content = "Invalid key. Please try again.",
                Duration = 3
            })
        end
    end
})
