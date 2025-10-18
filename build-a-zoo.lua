-- build-a-zoo.lua

-- Helper to safely load remote modules
local function loadRemote(url)
    local ok, result = pcall(function()
        local body = game:HttpGet(url)
        local fn, err = loadstring(body)
        if not fn then error("compile error: " .. tostring(err)) end
        return fn()
    end)
    if not ok then
        warn("[build-a-zoo] failed to load: ", url, " - ", tostring(result), "\n", debug.traceback())
        return nil
    end
    return result
end

local MacLib = loadRemote("https://raw.githubusercontent.com/space-bar-pixel/5ajuneuxf/main/module/maclib.lua")
if not MacLib then error("Failed to load MacLib") end
local function _logLoaded(name, obj)
    local t = type(obj)
    if t == "table" then
        -- check for a few known markers
        local markers = {}
        if obj.Window then table.insert(markers, "Window") end
        if obj.Options then table.insert(markers, "Options") end
        if obj.Folder then table.insert(markers, "Folder") end
        print(string.format("[build-a-zoo] loaded %s => type=%s markers=%s", name, t, table.concat(markers, ",")))
    else
        print(string.format("[build-a-zoo] loaded %s => type=%s", name, t))
    end
end
_logLoaded("MacLib", MacLib)

-- Shared state passed by reference to features
local State = {
    selectedPlayerName = nil,
    selectedEggName = {},
    selectedMutName = {},
    selectedFruits = {},
    fruitAmounts = {},
    EggInventory = {},
    totalToGive = 0
}

-- Use the Menu builder so sections are wrapped exactly as expected by features
local MenuBuilder = loadRemote("https://raw.githubusercontent.com/space-bar-pixel/5ajuneuxf/main/module/Menu/Menu.lua")
if not MenuBuilder or type(MenuBuilder.new) ~= "function" then
    error("Failed to load Menu builder")
end
_logLoaded("MenuBuilder", MenuBuilder)

local Menu
do
    local ok, res = pcall(function()
        return MenuBuilder.new({ MacLib = MacLib, Title = "Pizza Hub - Build a Zoo", Subtitle = "", Size = UDim2.fromOffset(900,650), DragStyle = 1, DisabledWindowControls = {}, ShowUserInfo = false, Keybind = Enum.KeyCode.RightControl, AcrylicBlur = true })
    end)
    if not ok then
        error("MenuBuilder.new failed: " .. tostring(res) .. "\n" .. debug.traceback())
    end
    Menu = res
end
local Window = Menu.Window

local tabs = {}
tabs.main = { left1 = Menu.mainSecLeft1, left2 = Menu.mainSecLeft2, right = Menu.mainSecRight }
tabs.dupe = { dupeSec1 = Menu.dupeSec1 }
tabs.auto = { autoSec1 = Menu.autoSec1 }
tabs.egg = { left1 = Menu.eggSec1, right1 = Menu.eggSec2 }
tabs.fruit = { left1 = Menu.FruitSec1 }
tabs.setting = { settingSec1 = Menu.settingSec1, settingSec3 = Menu.settingSec3 }

-- Minimal services bag for features
local services = {
    Players = game:GetService("Players"),
    Window = Window,
    remoteService = loadRemote("https://raw.githubusercontent.com/space-bar-pixel/5ajuneuxf/main/module/Services/RemoteService.lua"),
    Data = loadRemote("https://raw.githubusercontent.com/space-bar-pixel/5ajuneuxf/main/module/Data.lua"),
}
_logLoaded("remoteService", services.remoteService)
_logLoaded("Data", services.Data)

-- ConfigService integration: load locally and pass the MacLib instance so UI config uses same folder
local ConfigService = loadRemote("https://raw.githubusercontent.com/space-bar-pixel/5ajuneuxf/main/module/Services/ConfigService.lua")
local configServiceInstance
if ConfigService and type(ConfigService.new) == "function" then
    local PlayersSvc = game:GetService("Players")
    local userName = (PlayersSvc.LocalPlayer and PlayersSvc.LocalPlayer.Name) or (PlayersSvc:GetPlayers()[1] and PlayersSvc:GetPlayers()[1].Name) or "Unknown"
    configServiceInstance = nil
    local ok, res = pcall(function() return ConfigService.new(tostring(userName), MacLib) end)
    if ok then
        configServiceInstance = res
        services.ConfigService = configServiceInstance
    else
        warn("ConfigService.new failed: ", tostring(res))
        services.ConfigService = nil
    end
_logLoaded("ConfigService", ConfigService)
else
    warn("ConfigService not available; config UI will operate on MacLib only")
    services.ConfigService = nil
end

-- Load feature modules remotely and mount them
local GiftFeature = loadRemote("https://raw.githubusercontent.com/space-bar-pixel/5ajuneuxf/main/module/Features/GiftFeature.lua")
local DupeFeature = loadRemote("https://raw.githubusercontent.com/space-bar-pixel/5ajuneuxf/main/module/Features/DupeFeature.lua")
_logLoaded("GiftFeature", GiftFeature)
_logLoaded("DupeFeature", DupeFeature)

local giftMount, dupeMount
if GiftFeature and type(GiftFeature.mount) == "function" then
    local ok, res = pcall(function()
        return GiftFeature.mount({ sections = { left2 = tabs.main.left2, main = { left2 = tabs.main.left2 } }, services = services, state = State })
    end)
    if ok then
        giftMount = res
    else
        warn("GiftFeature.mount failed: ", tostring(res))
    end
else
    warn("GiftFeature not available or missing mount(); skipping gift mount")
end

if DupeFeature and type(DupeFeature.mount) == "function" then
    local ok, res = pcall(function()
        return DupeFeature.mount({ sections = { dupeSec1 = tabs.dupe.dupeSec1, main = { right = tabs.main.right }, dupe = tabs.main.right }, services = services, state = State })
    end)
    if ok then
        dupeMount = res
    else
        warn("DupeFeature.mount failed: ", tostring(res))
    end
else
    warn("DupeFeature not available or missing mount(); skipping dupe mount")
end

-- Basic wiring: player selection helper (features expect a live Players service and Window)
local Players = services.Players
local function RefreshPlayers(dropdown)
    local items = {}
    for _, p in ipairs(Players:GetPlayers()) do table.insert(items, p.Name) end
    if dropdown and dropdown.ClearOptions then
        pcall(function() dropdown:ClearOptions(); dropdown:InsertOptions(items) end)
    end
end
Players.PlayerAdded:Connect(function() RefreshPlayers() end)
Players.PlayerRemoving:Connect(function() RefreshPlayers() end)

-- Keep a reference to the mounts to allow cleanup later
local mounted = { gift = giftMount, dupe = dupeMount }

-- Let MacLib perform autoload if configured
pcall(function()
    if type(MacLib.LoadAutoLoadConfig) == "function" then
        MacLib:LoadAutoLoadConfig()
    end
end)

-- Export a simple API for debugging when pasted into a LocalScript
return {
    Window = Window,
    State = State,
    Mounts = mounted,
    Services = services,
}
