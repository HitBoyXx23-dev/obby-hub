local REPO_OWNER = "hitboyxx23-dev"
local REPO_NAME = "obby-hub"
local BRANCH = "main"
local CACHE_BUST = "?v=" .. tostring(os.time())
local BASE_URL = "https://cdn.jsdelivr.net/gh/" .. REPO_OWNER .. "/" .. REPO_NAME .. "@" .. BRANCH .. "/"
local PURGE_URL = "https://purge.jsdelivr.net/gh/" .. REPO_OWNER .. "/" .. REPO_NAME .. "@" .. BRANCH .. "/main.lua"

pcall(function()
    game:HttpGet(PURGE_URL, true)
end)

local GAME_IDS = {
    [5253186791]  = "tower-of-hell",
    [1962086868]  = "tower-of-hell",
    [6139577944]  = "tower-of-hell",
    [7405923460]  = "tower-of-hell",
    [10043890669] = "tower-of-hell",
    [8562822414]  = "eternal-towers-of-hell",
    [18779022606] = "eternal-towers-of-hell",
    [13218032675] = "eternal-towers-of-hell",
    [3260590327]  = "speed-run-4",
    [738339342]   = "flood-escape-2",
    [32990482]    = "flood-escape-classic",
    [5903500229]  = "obby-but-youre-on-fire",
    [2057442689]  = "mega-fun-obby",
    [2787465289]  = "the-difficulty-machine",
    [7190410167]  = "escape-the-obby",
    [1635445174]  = "parkour",
    [4940135548]  = "difficulty-chart-obby",
}

local GAME_NAMES = {
    [5253186791]  = "tower of hell appeals",
    [1962086868]  = "tower of hell",
    [6139577944]  = "tower of hell christmas",
    [7405923460]  = "tower of hell rings",
    [10043890669] = "tower of hell challenge",
    [8562822414]  = "eternal towers of hell",
    [18779022606] = "mini eternal towers of hell",
    [13218032675] = "etoh xl",
    [3260590327]  = "speed run 4",
    [738339342]   = "flood escape 2",
    [32990482]    = "flood escape classic",
    [5903500229]  = "obby but you're on fire",
    [2057442689]  = "mega fun obby",
    [2787465289]  = "the difficulty machine",
    [7190410167]  = "escape the obby",
    [1635445174]  = "parkour",
    [4940135548]  = "difficulty chart obby",
}

local FALLBACK = "generic"

local function notify(title, text)
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = title,
            Text = text,
            Duration = 4
        })
    end)
end

local gameId = game.PlaceId
local gameFile = GAME_IDS[gameId] or FALLBACK
local displayName = GAME_NAMES[gameId] or "generic mode"

local function fetch(path)
    local url = BASE_URL .. path .. CACHE_BUST
    local success, result = pcall(function()
        return game:HttpGet(url, true)
    end)
    if not success or not result then
        warn("[Obby Menu] HTTP failed for " .. path .. ": " .. tostring(result))
        return nil
    end
    if result:lower():find("404: not found") or result:lower():find("couldn't find") then
        warn("[Obby Menu] 404 for " .. path)
        return nil
    end
    return result
end

local function run(path)
    local source = fetch(path)
    if not source then return nil end
    local fn, compileErr = loadstring(source)
    if not fn then
        warn("[Obby Menu] Compile error in " .. path .. ": " .. tostring(compileErr))
        return nil
    end
    local ok, result = pcall(fn)
    if not ok then
        warn("[Obby Menu] Runtime error in " .. path .. ": " .. tostring(result))
        return nil
    end
    return result
end

local uiModule = run("lib/ui.lua")
local utilsModule = run("lib/utils.lua")

if not uiModule then
    notify("Obby Menu", "Failed to load UI library")
    return
end

if not utilsModule then
    notify("Obby Menu", "Failed to load utils library")
    return
end

_G.ObbyHubUI = uiModule
_G.ObbyHubUtils = utilsModule
_G.ObbyHubLoaded = true
_G.ObbyHubGameId = gameId
_G.ObbyHubGameFile = gameFile
_G.ObbyHubDisplayName = displayName

local loaded = run("games/" .. gameFile .. ".lua")

if not loaded then
    notify("Obby Menu", "Failed to load " .. gameFile)
    return
end

if gameFile == FALLBACK then
    notify("Obby Menu", "Generic menu loaded")
else
    notify("Obby Menu", "Loaded: " .. displayName)
end

print("[Obby Menu] Loaded " .. gameFile .. " (" .. tostring(gameId) .. ")")
