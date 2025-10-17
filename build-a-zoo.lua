-- build-a-zoo.lua
-- Lightweight composition root that creates the UI and mounts features.

local MacLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/space-bar-pixel/5ajuneuxf/refs/heads/main/module/maclib.lua"))()

-- Shared state passed by reference to features
local State = {
    selectedPlayerName = nil,
    selectedEggName = {},
    selectedMutName = {},
    selectedFruits = {},
    fruitAmounts = {},
    EggInventory = {},
    totalToGive = 0,
}

-- Create UI window
local Window = MacLib:Window({
    Title = "Pizza Hub - Build a Zoo",
    Subtitle = "",
    Size = UDim2.fromOffset(900, 650),
    DragStyle = 1,
    DisabledWindowControls = {},
    ShowUserInfo = false,
    Keybind = Enum.KeyCode.RightControl,
    AcrylicBlur = true,
})

-- Simple tab layout used by features (adapts to the expected Menu.tabs.* shape)
local tabs = {}
tabs.main = { left1 = Window:Tab({ Name = "Main Left1" }), left2 = Window:Tab({ Name = "Main Left2" }), right = Window:Tab({ Name = "Main Right" }) }
tabs.dupe = { dupeSec1 = Window:Tab({ Name = "Dupe" }) }
tabs.auto = { autoSec1 = Window:Tab({ Name = "Auto" }) }
tabs.egg = { left1 = Window:Tab({ Name = "Egg Left" }), right1 = Window:Tab({ Name = "Egg Right" }) }
tabs.fruit = { left1 = Window:Tab({ Name = "Fruit" }) }
tabs.setting = { settingSec1 = Window:Tab({ Name = "Settings" }), settingSec3 = Window:Tab({ Name = "Advanced" }) }

-- Minimal services bag for features
local services = {
    Players = game:GetService("Players"),
    Window = Window,
    remoteService = loadstring(game:HttpGet("https://raw.githubusercontent.com/space-bar-pixel/5ajuneuxf/refs/heads/main/module/Services/RemoteService.lua"))(),
    Data = loadstring(game:HttpGet("https://raw.githubusercontent.com/space-bar-pixel/5ajuneuxf/refs/heads/main/module/Data.lua"))(),
}

-- Load feature modules remotely and mount them
local GiftFeature = loadstring(game:HttpGet("https://raw.githubusercontent.com/space-bar-pixel/5ajuneuxf/refs/heads/main/module/Features/GiftFeature.lua"))()
local DupeFeature = loadstring(game:HttpGet("https://raw.githubusercontent.com/space-bar-pixel/5ajuneuxf/refs/heads/main/module/Features/DupeFeature.lua"))()

local giftMount = GiftFeature.mount({ sections = { left2 = tabs.main.left2, main = { left2 = tabs.main.left2 } }, services = services, state = State })
local dupeMount = DupeFeature.mount({ sections = { dupeSec1 = tabs.dupe.dupeSec1, main = { right = tabs.main.right }, dupe = tabs.main.right }, services = services, state = State })

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

-- Export a simple API for debugging when pasted into a LocalScript
return {
    Window = Window,
    State = State,
    Mounts = mounted,
}
