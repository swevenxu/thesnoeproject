local HttpService = game:GetService("HttpService")

local KEY_LINK = "https://work.ink/2cCC/snoe-checkpoint-1"
local KEY_FILE = "snoe_key_data.json"
local KEY_DURATION = 24 * 60 * 60
local REPO_BASE = "https://raw.githubusercontent.com/swevenxu/thesnoeproject/main/"

local scripts = {
    [93044798454681] = "games/deadly-delivery.obfuscated.lua",
    [76558904092080] = "games/the-forge.obfuscated.lua",
}

local gameNames = {
    [93044798454681] = "Deadly Delivery",
    [76558904092080] = "The Forge",
}

local function checkSavedKey()
    local success, content = pcall(function() return readfile(KEY_FILE) end)
    if not success then return false end
    local ok, data = pcall(function() return HttpService:JSONDecode(content) end)
    if not ok then return false end
    if data and data.timestamp then
        local elapsed = os.time() - data.timestamp
        if elapsed < KEY_DURATION then return true end
        pcall(function() delfile(KEY_FILE) end)
    end
    return false
end

local function saveKey()
    pcall(function()
        writefile(KEY_FILE, HttpService:JSONEncode({timestamp = os.time()}))
    end)
end

local function validateKey(key)
    if not key or key == "" then return false end
    local success, response = pcall(function()
        return game:HttpGet("https://work.ink/_api/v2/token/isValid/" .. key .. "?deleteToken=1")
    end)
    if success then
        return HttpService:JSONDecode(response).valid == true
    end
    return false
end

local function loadGameScript()
    local gameId = game.PlaceId
    local scriptPath = scripts[gameId]
    
    if scriptPath then
        print("[Snoe] Loading: " .. (gameNames[gameId] or "Unknown"))
        local success, err = pcall(function()
            loadstring(game:HttpGet(REPO_BASE .. scriptPath))()
        end)
        if not success then warn("[Snoe] Failed: " .. tostring(err)) end
    else
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Snoe Hub", Text = "No script for this game", Duration = 5
        })
    end
end

if checkSavedKey() then loadGameScript(); return end

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/x2zu/OPEN-SOURCE-UI-ROBLOX/refs/heads/main/X2ZU%20UI%20ROBLOX%20OPEN%20SOURCE/DummyUi-leak-by-x2zu/fetching-main/Tools/Framework.luau"))()

local Window = Library:Window({
    Title = "Snoe Hub", Desc = "Key System", Theme = "Dark",
    Config = { Keybind = Enum.KeyCode.RightControl, Size = UDim2.new(0, 400, 0, 250) },
    CloseUIButton = { Enabled = true, Text = "Close" }
})

local KeyTab = Window:Tab({Title = "Key System", Icon = "key"})
KeyTab:Section({Title = "Authentication"})

local keyInput = ""

KeyTab:Textbox({
    Title = "Enter Key", Desc = "Paste your key here", Placeholder = "Key...", Value = "",
    Callback = function(text) keyInput = text end
})

KeyTab:Button({
    Title = "Submit Key", Desc = "Validate and continue",
    Callback = function()
        if keyInput == "" then Window:Notify({Title = "Error", Desc = "Please enter a key!", Time = 3}); return end
        Window:Notify({Title = "Checking...", Desc = "Validating key...", Time = 2})
        if validateKey(keyInput) then
            saveKey()
            Window:Notify({Title = "Success!", Desc = "Key valid for 24 hours!", Time = 3})
            task.wait(1)
            pcall(function()
                for _, gui in pairs(game:GetService("CoreGui"):GetChildren()) do
                    if gui.Name == "Dummy Kawaii" then gui:Destroy() end
                end
            end)
            loadGameScript()
        else
            Window:Notify({Title = "Invalid", Desc = "Key is not valid or already used!", Time = 3})
        end
    end
})

KeyTab:Button({
    Title = "Get Key", Desc = "Copy key link to clipboard",
    Callback = function()
        setclipboard(KEY_LINK)
        Window:Notify({Title = "Copied!", Desc = "Paste link in your browser", Time = 3})
    end
})

Window:Notify({Title = "Snoe Hub", Desc = "Enter your key to continue", Time = 4})
