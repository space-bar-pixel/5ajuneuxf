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

-- Load Modules
local MacLib = loadRemote("https://raw.githubusercontent.com/space-bar-pixel/5ajuneuxf/refs/heads/main/module/maclib.lua") or {}
_logLoaded("MacLib", MacLib)

-- Services
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local VirtualUser = game:GetService("VirtualUser")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualInputManager = game:GetService("VirtualInputManager")

local blocksFolder = workspace:FindFirstChild("PlayerBuiltBlocks")
local PlayerBuiltBlocks = workspace:WaitForChild("PlayerBuiltBlocks")

-- Remotes
local GiftRE = ReplicatedStorage:WaitForChild("Remote"):WaitForChild("GiftRE")
local DeployRE = ReplicatedStorage:WaitForChild("Remote"):WaitForChild("DeployRE")
local CharacterRE = ReplicatedStorage:WaitForChild("Remote"):WaitForChild("CharacterRE")
local FoodStoreRE = ReplicatedStorage:WaitForChild("Remote"):WaitForChild("FoodStoreRE")

-- Helpers
local function getHumanoidRoot()
	if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
		return player.Character.HumanoidRootPart
	end
	return nil
end

-- Window (MacLib)
local Window = MacLib:Window({
	Title = "Pizza Hub",
	Subtitle = "Free | V0.1",
	Size = UDim2.fromOffset(868, 650),
	DragStyle = 1,
	DisabledWindowControls = {},
	ShowUserInfo = true,
	Keybind = Enum.KeyCode.RightControl,
	AcrylicBlur = true,
})

local BuildFolderTree = MacLib:SetFolder("PizzaHub")
-----------------------------------------------------------
-- Define Sections (your structure)
-----------------------------------------------------------
local MainGroup = Window:TabGroup()
local mainTab = MainGroup:Tab({ Name = "Main", Image = "" })
local mainSecLeft1 = mainTab:Section({ Side = "Left" })
local mainSecLeft2 = mainTab:Section({ Side = "Left" })
local mainSecRight = mainTab:Section({ Side = "Right" })
local AutoTab = MainGroup:Tab({ Name = "AutoFarm", Image = "" })
local autoSec1 = AutoTab:Section({ Side = "Left" })

local SubGroup = Window:TabGroup()
local EggTab = SubGroup:Tab({ Name = "Egg", Image = "" })
local FruitTab = SubGroup:Tab({ Name = "Fruit", Image = "" })
local DupeTab = SubGroup:Tab({ Name = "Dupe", Image = "" })
local eggSec1 = EggTab:Section({ Side = "Left" })
local eggSec2 = EggTab:Section({ Side = "Right" })
local FruitSec1 = FruitTab:Section({ Side = "Left" })
local dupeSec1 = DupeTab:Section({ Side = "Left" })

local SettingGroup = Window:TabGroup()
local Misc = SettingGroup:Tab({ Name = "Misc", Image = "" })
local miscSec1 = Misc:Section({ Side = "Left" })
local Setting = SettingGroup:Tab({ Name = "Setting", Image = "" })
Setting:InsertConfigSection({ Side = "Left" })
local settingSec2 = Setting:Section({ Side = "Right" })

-----------------------------------------------------------
-- Menu Table
-----------------------------------------------------------
local Menu = {
	ConfigDefaults = {
		general = {
			collectCoins = { delay = 30 },
			eventSeasonPass = { claimEnabled = false }
		},
		pet = {
			placeEnabled = false,
			unlockEnabled = false,
			lock = {
				data = { min = 1, max = 100 },
				mode = "produce_speed"
			}
		}
	},
	playerData = {
        player = player,
        humanoidRootPart = getHumanoidRoot(),
        userName = player.Name,
        userId = player.UserId
    },
	tabs = {
		main = { 
			left1 = mainSecLeft1, 
			left2 = mainSecLeft2, 
			right = mainSecRight 
		},
		egg = { 
			left1 = eggSec1, 
			right1 = eggSec2 
		},
		fruit = { 
			left1 = FruitSec1 
		},
		dupe = { 
			dupeSec1 = dupeSec1
		},
		auto = { 
			autoSec1 = autoSec1 
		},
        misc = {
            miscSec1 = miscSec1
        },
		setting = {
			settingSec2 = settingSec2
		}
	},
	system = {
		keyBind = Enum.KeyCode.K
	},
	data = {
		plants = {
			Island_1 = {
				mountain = {
					{id="1", coord="-180, 16, 4", empty=true},
					{id="2", coord="-172, 16, 4", empty=true},
					{id="3", coord="-164, 16, 4", empty=true},
					{id="4", coord="-156, 16, 4", empty=true},
					{id="5", coord="-148, 16, 4", empty=true},
					{id="6", coord="-140, 16, 4", empty=true},
					{id="7", coord="-132, 16, 4", empty=true},
					{id="8", coord="-124, 16, 4", empty=true},
					{id="9", coord="-116, 16, 4", empty=true},
					{id="10", coord="-108, 16, 4", empty=true},
					{id="11", coord="-100, 16, 4", empty=true},
					{id="12", coord="-92, 16, 4", empty=true},
					{id="13", coord="-84, 16, 4", empty=true},
					{id="14", coord="-76, 16, 4", empty=true},
					{id="15", coord="-68, 16, 4", empty=true},
					{id="16", coord="-60, 16, 4", empty=true},
					{id="17", coord="-52, 16, 4", empty=true},
					{id="18", coord="-44, 16, 4", empty=true},
					{id="19", coord="-180, 16, -4", empty=true},
					{id="20", coord="-172, 16, -4", empty=true},
					{id="21", coord="-164, 16, -4", empty=true},
					{id="22", coord="-156, 16, -4", empty=true},
					{id="23", coord="-148, 16, -4", empty=true},
					{id="24", coord="-140, 16, -4", empty=true},
					{id="25", coord="-132, 16, -4", empty=true},
					{id="26", coord="-124, 16, -4", empty=true},
					{id="27", coord="-116, 16, -4", empty=true},
					{id="28", coord="-108, 16, -4", empty=true},
					{id="29", coord="-100, 16, -4", empty=true},
					{id="30", coord="-92, 16, -4", empty=true},
					{id="31", coord="-84, 16, -4", empty=true},
					{id="32", coord="-76, 16, -4", empty=true},
					{id="33", coord="-68, 16, -4", empty=true},
					{id="34", coord="-60, 16, -4", empty=true},
					{id="35", coord="-52, 16, -4", empty=true},
					{id="36", coord="-44, 16, -4", empty=true},
					{id="37", coord="-180, 16, -12", empty=true},
					{id="38", coord="-172, 16, -12", empty=true},
					{id="39", coord="-164, 16, -12", empty=true},
					{id="40", coord="-156, 16, -12", empty=true},
					{id="41", coord="-148, 16, -12", empty=true},
					{id="42", coord="-140, 16, -12", empty=true},
					{id="43", coord="-132, 16, -12", empty=true},
					{id="44", coord="-124, 16, -12", empty=true},
					{id="45", coord="-116, 16, -12", empty=true},
					{id="46", coord="-108, 16, -12", empty=true},
					{id="47", coord="-100, 16, -12", empty=true},
					{id="48", coord="-92, 16, -12", empty=true},
					{id="49", coord="-84, 16, -12", empty=true},
					{id="50", coord="-76, 16, -12", empty=true},
					{id="51", coord="-68, 16, -12", empty=true},
					{id="52", coord="-60, 16, -12", empty=true},
					{id="53", coord="-52, 16, -12", empty=true},
					{id="54", coord="-44, 16, -12", empty=true},
					{id="55", coord="-180, 16, -20", empty=true},
					{id="56", coord="-172, 16, -20", empty=true},
					{id="57", coord="-164, 16, -20", empty=true},
					{id="58", coord="-156, 16, -20", empty=true},
					{id="59", coord="-148, 16, -20", empty=true},
					{id="60", coord="-140, 16, -20", empty=true},
					{id="61", coord="-132, 16, -20", empty=true},
					{id="62", coord="-124, 16, -20", empty=true},
					{id="63", coord="-116, 16, -20", empty=true},
					{id="64", coord="-108, 16, -20", empty=true},
					{id="65", coord="-100, 16, -20", empty=true},
					{id="66", coord="-92, 16, -20", empty=true},
					{id="67", coord="-84, 16, -20", empty=true},
					{id="68", coord="-76, 16, -20", empty=true},
					{id="69", coord="-68, 16, -20", empty=true},
					{id="70", coord="-60, 16, -20", empty=true},
					{id="71", coord="-52, 16, -20", empty=true},
					{id="72", coord="-44, 16, -20", empty=true},
					{id="73", coord="-180, 16, -28", empty=true},
					{id="74", coord="-172, 16, -28", empty=true},
					{id="75", coord="-164, 16, -28", empty=true},
					{id="76", coord="-156, 16, -28", empty=true},
					{id="77", coord="-148, 16, -28", empty=true},
					{id="78", coord="-140, 16, -28", empty=true},
					{id="79", coord="-132, 16, -28", empty=true},
					{id="80", coord="-124, 16, -28", empty=true},
					{id="81", coord="-116, 16, -28", empty=true},
					{id="82", coord="-108, 16, -28", empty=true},
					{id="83", coord="-100, 16, -28", empty=true},
					{id="84", coord="-92, 16, -28", empty=true},
					{id="85", coord="-84, 16, -28", empty=true},
					{id="86", coord="-76, 16, -28", empty=true},
					{id="87", coord="-68, 16, -28", empty=true},
					{id="88", coord="-60, 16, -28", empty=true},
					{id="89", coord="-52, 16, -28", empty=true},
					{id="90", coord="-44, 16, -28", empty=true},
					{id="91", coord="-180, 16, -36", empty=true},
					{id="92", coord="-172, 16, -36", empty=true},
					{id="93", coord="-164, 16, -36", empty=true},
					{id="94", coord="-156, 16, -36", empty=true},
					{id="95", coord="-148, 16, -36", empty=true},
					{id="96", coord="-140, 16, -36", empty=true},
					{id="97", coord="-132, 16, -36", empty=true},
					{id="98", coord="-124, 16, -36", empty=true},
					{id="99", coord="-116, 16, -36", empty=true},
					{id="100", coord="-108, 16, -36", empty=true},
					{id="101", coord="-100, 16, -36", empty=true},
					{id="102", coord="-92, 16, -36", empty=true},
					{id="103", coord="-84, 16, -36", empty=true},
					{id="104", coord="-76, 16, -36", empty=true},
					{id="105", coord="-68, 16, -36", empty=true},
					{id="106", coord="-60, 16, -36", empty=true},
					{id="107", coord="-52, 16, -36", empty=true},
					{id="108", coord="-44, 16, -36", empty=true},
					{id="109", coord="-164, 16, -44", empty=true},
					{id="110", coord="-156, 16, -44", empty=true},
					{id="111", coord="-148, 16, -44", empty=true},
					{id="112", coord="-140, 16, -44", empty=true},
					{id="113", coord="-132, 16, -44", empty=true},
					{id="114", coord="-124, 16, -44", empty=true},
					{id="115", coord="-116, 16, -44", empty=true},
					{id="116", coord="-108, 16, -44", empty=true},
					{id="117", coord="-100, 16, -44", empty=true},
					{id="118", coord="-92, 16, -44", empty=true},
					{id="119", coord="-84, 16, -44", empty=true},
					{id="120", coord="-76, 16, -44", empty=true},
					{id="121", coord="-68, 16, -44", empty=true},
					{id="122", coord="-60, 16, -44", empty=true},
					{id="123", coord="-164, 16, -52", empty=true},
					{id="124", coord="-156, 16, -52", empty=true},
					{id="125", coord="-148, 16, -52", empty=true},
					{id="126", coord="-140, 16, -52", empty=true},
					{id="127", coord="-132, 16, -52", empty=true},
					{id="128", coord="-124, 16, -52", empty=true},
					{id="129", coord="-116, 16, -52", empty=true},
					{id="130", coord="-108, 16, -52", empty=true},
					{id="131", coord="-100, 16, -52", empty=true},
					{id="132", coord="-92, 16, -52", empty=true},
					{id="133", coord="-84, 16, -52", empty=true},
					{id="134", coord="-76, 16, -52", empty=true},
					{id="135", coord="-68, 16, -52", empty=true},
					{id="136", coord="-60, 16, -52", empty=true},
					{id="137", coord="-164, 16, -60", empty=true},
					{id="138", coord="-156, 16, -60", empty=true},
					{id="139", coord="-148, 16, -60", empty=true},
					{id="140", coord="-140, 16, -60", empty=true},
					{id="141", coord="-132, 16, -60", empty=true},
					{id="142", coord="-124, 16, -60", empty=true},
					{id="143", coord="-116, 16, -60", empty=true},
					{id="144", coord="-108, 16, -60", empty=true},
					{id="145", coord="-100, 16, -60", empty=true},
					{id="146", coord="-92, 16, -60", empty=true},
					{id="147", coord="-84, 16, -60", empty=true},
					{id="148", coord="-76, 16, -60", empty=true},
					{id="149", coord="-68, 16, -60", empty=true},
					{id="150", coord="-60, 16, -60", empty=true},
					{id="151", coord="-164, 16, -68", empty=true},
					{id="152", coord="-156, 16, -68", empty=true},
					{id="153", coord="-148, 16, -68", empty=true},
					{id="154", coord="-140, 16, -68", empty=true},
					{id="155", coord="-132, 16, -68", empty=true},
					{id="156", coord="-124, 16, -68", empty=true},
					{id="157", coord="-116, 16, -68", empty=true},
					{id="158", coord="-108, 16, -68", empty=true},
					{id="159", coord="-100, 16, -68", empty=true},
					{id="160", coord="-92, 16, -68", empty=true},
					{id="161", coord="-84, 16, -68", empty=true},
					{id="162", coord="-76, 16, -68", empty=true},
					{id="163", coord="-68, 16, -68", empty=true},
					{id="164", coord="-60, 16, -68", empty=true},
					{id="165", coord="-164, 16, -76", empty=true},
					{id="166", coord="-156, 16, -76", empty=true},
					{id="167", coord="-148, 16, -76", empty=true},
					{id="168", coord="-140, 16, -76", empty=true},
					{id="169", coord="-132, 16, -76", empty=true},
					{id="170", coord="-124, 16, -76", empty=true},
					{id="171", coord="-116, 16, -76", empty=true},
					{id="172", coord="-108, 16, -76", empty=true},
					{id="173", coord="-100, 16, -76", empty=true},
					{id="174", coord="-92, 16, -76", empty=true},
					{id="175", coord="-84, 16, -76", empty=true},
					{id="176", coord="-76, 16, -76", empty=true},
					{id="177", coord="-68, 16, -76", empty=true},
					{id="178", coord="-60, 16, -76", empty=true},
					{id="179", coord="-164, 16, -84", empty=true},
					{id="180", coord="-156, 16, -84", empty=true},
					{id="181", coord="-148, 16, -84", empty=true},
					{id="182", coord="-140, 16, -84", empty=true},
					{id="183", coord="-132, 16, -84", empty=true},
					{id="184", coord="-124, 16, -84", empty=true},
					{id="185", coord="-116, 16, -84", empty=true},
					{id="186", coord="-108, 16, -84", empty=true},
					{id="187", coord="-100, 16, -84", empty=true},
					{id="188", coord="-92, 16, -84", empty=true},
					{id="189", coord="-84, 16, -84", empty=true},
					{id="190", coord="-76, 16, -84", empty=true},
					{id="191", coord="-68, 16, -84", empty=true},
					{id="192", coord="-60, 16, -84", empty=true}
				},
				ocean = {}
			},
			Island_2 = {
				mountain = {
					{id="1", coord="92, 16, 4", empty=true},
					{id="2", coord="100, 16, 4", empty=true},
					{id="3", coord="108, 16, 4", empty=true},
					{id="4", coord="116, 16, 4", empty=true},
					{id="5", coord="124, 16, 4", empty=true},
					{id="6", coord="132, 16, 4", empty=true},
					{id="7", coord="140, 16, 4", empty=true},
					{id="8", coord="148, 16, 4", empty=true},
					{id="9", coord="156, 16, 4", empty=true},
					{id="10", coord="164, 16, 4", empty=true},
					{id="11", coord="172, 16, 4", empty=true},
					{id="12", coord="180, 16, 4", empty=true},
					{id="13", coord="188, 16, 4", empty=true},
					{id="14", coord="196, 16, 4", empty=true},
					{id="15", coord="204, 16, 4", empty=true},
					{id="16", coord="212, 16, 4", empty=true},
					{id="17", coord="220, 16, 4", empty=true},
					{id="18", coord="228, 16, 4", empty=true},
					{id="19", coord="92, 16, -4", empty=true},
					{id="20", coord="100, 16, -4", empty=true},
					{id="21", coord="108, 16, -4", empty=true},
					{id="22", coord="116, 16, -4", empty=true},
					{id="23", coord="124, 16, -4", empty=true},
					{id="24", coord="132, 16, -4", empty=true},
					{id="25", coord="140, 16, -4", empty=true},
					{id="26", coord="148, 16, -4", empty=true},
					{id="27", coord="156, 16, -4", empty=true},
					{id="28", coord="164, 16, -4", empty=true},
					{id="29", coord="172, 16, -4", empty=true},
					{id="30", coord="180, 16, -4", empty=true},
					{id="31", coord="188, 16, -4", empty=true},
					{id="32", coord="196, 16, -4", empty=true},
					{id="33", coord="204, 16, -4", empty=true},
					{id="34", coord="212, 16, -4", empty=true},
					{id="35", coord="220, 16, -4", empty=true},
					{id="36", coord="228, 16, -4", empty=true},
					{id="37", coord="92, 16, -12", empty=true},
					{id="38", coord="100, 16, -12", empty=true},
					{id="39", coord="108, 16, -12", empty=true},
					{id="40", coord="116, 16, -12", empty=true},
					{id="41", coord="124, 16, -12", empty=true},
					{id="42", coord="132, 16, -12", empty=true},
					{id="43", coord="140, 16, -12", empty=true},
					{id="44", coord="148, 16, -12", empty=true},
					{id="45", coord="156, 16, -12", empty=true},
					{id="46", coord="164, 16, -12", empty=true},
					{id="47", coord="172, 16, -12", empty=true},
					{id="48", coord="180, 16, -12", empty=true},
					{id="49", coord="188, 16, -12", empty=true},
					{id="50", coord="196, 16, -12", empty=true},
					{id="51", coord="204, 16, -12", empty=true},
					{id="52", coord="212, 16, -12", empty=true},
					{id="53", coord="220, 16, -12", empty=true},
					{id="54", coord="228, 16, -12", empty=true},
					{id="55", coord="92, 16, -20", empty=true},
					{id="56", coord="100, 16, -20", empty=true},
					{id="57", coord="108, 16, -20", empty=true},
					{id="58", coord="116, 16, -20", empty=true},
					{id="59", coord="124, 16, -20", empty=true},
					{id="60", coord="132, 16, -20", empty=true},
					{id="61", coord="140, 16, -20", empty=true},
					{id="62", coord="148, 16, -20", empty=true},
					{id="63", coord="156, 16, -20", empty=true},
					{id="64", coord="164, 16, -20", empty=true},
					{id="65", coord="172, 16, -20", empty=true},
					{id="66", coord="180, 16, -20", empty=true},
					{id="67", coord="188, 16, -20", empty=true},
					{id="68", coord="196, 16, -20", empty=true},
					{id="69", coord="204, 16, -20", empty=true},
					{id="70", coord="212, 16, -20", empty=true},
					{id="71", coord="220, 16, -20", empty=true},
					{id="72", coord="228, 16, -20", empty=true},
					{id="73", coord="92, 16, -28", empty=true},
					{id="74", coord="100, 16, -28", empty=true},
					{id="75", coord="108, 16, -28", empty=true},
					{id="76", coord="116, 16, -28", empty=true},
					{id="77", coord="124, 16, -28", empty=true},
					{id="78", coord="132, 16, -28", empty=true},
					{id="79", coord="140, 16, -28", empty=true},
					{id="80", coord="148, 16, -28", empty=true},
					{id="81", coord="156, 16, -28", empty=true},
					{id="82", coord="164, 16, -28", empty=true},
					{id="83", coord="172, 16, -28", empty=true},
					{id="84", coord="180, 16, -28", empty=true},
					{id="85", coord="188, 16, -28", empty=true},
					{id="86", coord="196, 16, -28", empty=true},
					{id="87", coord="204, 16, -28", empty=true},
					{id="88", coord="212, 16, -28", empty=true},
					{id="89", coord="220, 16, -28", empty=true},
					{id="90", coord="228, 16, -28", empty=true},
					{id="91", coord="92, 16, -36", empty=true},
					{id="92", coord="100, 16, -36", empty=true},
					{id="93", coord="108, 16, -36", empty=true},
					{id="94", coord="116, 16, -36", empty=true},
					{id="95", coord="124, 16, -36", empty=true},
					{id="96", coord="132, 16, -36", empty=true},
					{id="97", coord="140, 16, -36", empty=true},
					{id="98", coord="148, 16, -36", empty=true},
					{id="99", coord="156, 16, -36", empty=true},
					{id="100", coord="164, 16, -36", empty=true},
					{id="101", coord="172, 16, -36", empty=true},
					{id="102", coord="180, 16, -36", empty=true},
					{id="103", coord="188, 16, -36", empty=true},
					{id="104", coord="196, 16, -36", empty=true},
					{id="105", coord="204, 16, -36", empty=true},
					{id="106", coord="212, 16, -36", empty=true},
					{id="107", coord="220, 16, -36", empty=true},
					{id="108", coord="228, 16, -36", empty=true},
					{id="109", coord="108, 16, -44", empty=true},
					{id="110", coord="116, 16, -44", empty=true},
					{id="111", coord="124, 16, -44", empty=true},
					{id="112", coord="132, 16, -44", empty=true},
					{id="113", coord="140, 16, -44", empty=true},
					{id="114", coord="148, 16, -44", empty=true},
					{id="115", coord="156, 16, -44", empty=true},
					{id="116", coord="164, 16, -44", empty=true},
					{id="117", coord="172, 16, -44", empty=true},
					{id="118", coord="180, 16, -44", empty=true},
					{id="119", coord="188, 16, -44", empty=true},
					{id="120", coord="196, 16, -44", empty=true},
					{id="121", coord="204, 16, -44", empty=true},
					{id="122", coord="212, 16, -44", empty=true},
					{id="123", coord="108, 16, -52", empty=true},
					{id="124", coord="116, 16, -52", empty=true},
					{id="125", coord="124, 16, -52", empty=true},
					{id="126", coord="132, 16, -52", empty=true},
					{id="127", coord="140, 16, -52", empty=true},
					{id="128", coord="148, 16, -52", empty=true},
					{id="129", coord="156, 16, -52", empty=true},
					{id="130", coord="164, 16, -52", empty=true},
					{id="131", coord="172, 16, -52", empty=true},
					{id="132", coord="180, 16, -52", empty=true},
					{id="133", coord="188, 16, -52", empty=true},
					{id="134", coord="196, 16, -52", empty=true},
					{id="135", coord="204, 16, -52", empty=true},
					{id="136", coord="212, 16, -52", empty=true},
					{id="137", coord="108, 16, -60", empty=true},
					{id="138", coord="116, 16, -60", empty=true},
					{id="139", coord="124, 16, -60", empty=true},
					{id="140", coord="132, 16, -60", empty=true},
					{id="141", coord="140, 16, -60", empty=true},
					{id="142", coord="148, 16, -60", empty=true},
					{id="143", coord="156, 16, -60", empty=true},
					{id="144", coord="164, 16, -60", empty=true},
					{id="145", coord="172, 16, -60", empty=true},
					{id="146", coord="180, 16, -60", empty=true},
					{id="147", coord="188, 16, -60", empty=true},
					{id="148", coord="196, 16, -60", empty=true},
					{id="149", coord="204, 16, -60", empty=true},
					{id="150", coord="212, 16, -60", empty=true},
					{id="151", coord="108, 16, -68", empty=true},
					{id="152", coord="116, 16, -68", empty=true},
					{id="153", coord="124, 16, -68", empty=true},
					{id="154", coord="132, 16, -68", empty=true},
					{id="155", coord="140, 16, -68", empty=true},
					{id="156", coord="148, 16, -68", empty=true},
					{id="157", coord="156, 16, -68", empty=true},
					{id="158", coord="164, 16, -68", empty=true},
					{id="159", coord="172, 16, -68", empty=true},
					{id="160", coord="180, 16, -68", empty=true},
					{id="161", coord="188, 16, -68", empty=true},
					{id="162", coord="196, 16, -68", empty=true},
					{id="163", coord="204, 16, -68", empty=true},
					{id="164", coord="212, 16, -68", empty=true},
					{id="165", coord="108, 16, -76", empty=true},
					{id="166", coord="116, 16, -76", empty=true},
					{id="167", coord="124, 16, -76", empty=true},
					{id="168", coord="132, 16, -76", empty=true},
					{id="169", coord="140, 16, -76", empty=true},
					{id="170", coord="148, 16, -76", empty=true},
					{id="171", coord="156, 16, -76", empty=true},
					{id="172", coord="164, 16, -76", empty=true},
					{id="173", coord="172, 16, -76", empty=true},
					{id="174", coord="180, 16, -76", empty=true},
					{id="175", coord="188, 16, -76", empty=true},
					{id="176", coord="196, 16, -76", empty=true},
					{id="177", coord="204, 16, -76", empty=true},
					{id="178", coord="212, 16, -76", empty=true},
					{id="179", coord="108, 16, -84", empty=true},
					{id="180", coord="116, 16, -84", empty=true},
					{id="181", coord="124, 16, -84", empty=true},
					{id="182", coord="132, 16, -84", empty=true},
					{id="183", coord="140, 16, -84", empty=true},
					{id="184", coord="148, 16, -84", empty=true},
					{id="185", coord="156, 16, -84", empty=true},
					{id="186", coord="164, 16, -84", empty=true},
					{id="187", coord="172, 16, -84", empty=true},
					{id="188", coord="180, 16, -84", empty=true},
					{id="189", coord="188, 16, -84", empty=true},
					{id="190", coord="196, 16, -84", empty=true},
					{id="191", coord="204, 16, -84", empty=true},
					{id="192", coord="212, 16, -84", empty=true}
				},
				ocean = {}
			},
			Island_3 = {
				mountain = {
					{id="1", coord="-444, 16, 4", empty=true},
					{id="2", coord="-452, 16, 4", empty=true},
					{id="3", coord="-460, 16, 4", empty=true},
					{id="4", coord="-468, 16, 4", empty=true},
					{id="5", coord="-476, 16, 4", empty=true},
					{id="6", coord="-484, 16, 4", empty=true},
					{id="7", coord="-492, 16, 4", empty=true},
					{id="8", coord="-500, 16, 4", empty=true},
					{id="9", coord="-508, 16, 4", empty=true},
					{id="10", coord="-516, 16, 4", empty=true},
					{id="11", coord="-524, 16, 4", empty=true},
					{id="12", coord="-532, 16, 4", empty=true},
					{id="13", coord="-540, 16, 4", empty=true},
					{id="14", coord="-548, 16, 4", empty=true},
					{id="15", coord="-556, 16, 4", empty=true},
					{id="16", coord="-564, 16, 4", empty=true},
					{id="17", coord="-572, 16, 4", empty=true},
					{id="18", coord="-580, 16, 4", empty=true},
					{id="19", coord="-444, 16, -4", empty=true},
					{id="20", coord="-452, 16, -4", empty=true},
					{id="21", coord="-460, 16, -4", empty=true},
					{id="22", coord="-468, 16, -4", empty=true},
					{id="23", coord="-476, 16, -4", empty=true},
					{id="24", coord="-484, 16, -4", empty=true},
					{id="25", coord="-492, 16, -4", empty=true},
					{id="26", coord="-500, 16, -4", empty=true},
					{id="27", coord="-508, 16, -4", empty=true},
					{id="28", coord="-516, 16, -4", empty=true},
					{id="29", coord="-524, 16, -4", empty=true},
					{id="30", coord="-532, 16, -4", empty=true},
					{id="31", coord="-540, 16, -4", empty=true},
					{id="32", coord="-548, 16, -4", empty=true},
					{id="33", coord="-556, 16, -4", empty=true},
					{id="34", coord="-564, 16, -4", empty=true},
					{id="35", coord="-572, 16, -4", empty=true},
					{id="36", coord="-580, 16, -4", empty=true},
					{id="37", coord="-444, 16, -12", empty=true},
					{id="38", coord="-452, 16, -12", empty=true},
					{id="39", coord="-460, 16, -12", empty=true},
					{id="40", coord="-468, 16, -12", empty=true},
					{id="41", coord="-476, 16, -12", empty=true},
					{id="42", coord="-484, 16, -12", empty=true},
					{id="43", coord="-492, 16, -12", empty=true},
					{id="44", coord="-500, 16, -12", empty=true},
					{id="45", coord="-508, 16, -12", empty=true},
					{id="46", coord="-516, 16, -12", empty=true},
					{id="47", coord="-524, 16, -12", empty=true},
					{id="48", coord="-532, 16, -12", empty=true},
					{id="49", coord="-540, 16, -12", empty=true},
					{id="50", coord="-548, 16, -12", empty=true},
					{id="51", coord="-556, 16, -12", empty=true},
					{id="52", coord="-564, 16, -12", empty=true},
					{id="53", coord="-572, 16, -12", empty=true},
					{id="54", coord="-580, 16, -12", empty=true},
					{id="55", coord="-444, 16, -20", empty=true},
					{id="56", coord="-452, 16, -20", empty=true},
					{id="57", coord="-460, 16, -20", empty=true},
					{id="58", coord="-468, 16, -20", empty=true},
					{id="59", coord="-476, 16, -20", empty=true},
					{id="60", coord="-484, 16, -20", empty=true},
					{id="61", coord="-492, 16, -20", empty=true},
					{id="62", coord="-500, 16, -20", empty=true},
					{id="63", coord="-508, 16, -20", empty=true},
					{id="64", coord="-516, 16, -20", empty=true},
					{id="65", coord="-524, 16, -20", empty=true},
					{id="66", coord="-532, 16, -20", empty=true},
					{id="67", coord="-540, 16, -20", empty=true},
					{id="68", coord="-548, 16, -20", empty=true},
					{id="69", coord="-556, 16, -20", empty=true},
					{id="70", coord="-564, 16, -20", empty=true},
					{id="71", coord="-572, 16, -20", empty=true},
					{id="72", coord="-580, 16, -20", empty=true},
					{id="73", coord="-444, 16, -28", empty=true},
					{id="74", coord="-452, 16, -28", empty=true},
					{id="75", coord="-460, 16, -28", empty=true},
					{id="76", coord="-468, 16, -28", empty=true},
					{id="77", coord="-476, 16, -28", empty=true},
					{id="78", coord="-484, 16, -28", empty=true},
					{id="79", coord="-492, 16, -28", empty=true},
					{id="80", coord="-500, 16, -28", empty=true},
					{id="81", coord="-508, 16, -28", empty=true},
					{id="82", coord="-516, 16, -28", empty=true},
					{id="83", coord="-524, 16, -28", empty=true},
					{id="84", coord="-532, 16, -28", empty=true},
					{id="85", coord="-540, 16, -28", empty=true},
					{id="86", coord="-548, 16, -28", empty=true},
					{id="87", coord="-556, 16, -28", empty=true},
					{id="88", coord="-564, 16, -28", empty=true},
					{id="89", coord="-572, 16, -28", empty=true},
					{id="90", coord="-580, 16, -28", empty=true},
					{id="91", coord="-444, 16, -36", empty=true},
					{id="92", coord="-452, 16, -36", empty=true},
					{id="93", coord="-460, 16, -36", empty=true},
					{id="94", coord="-468, 16, -36", empty=true},
					{id="95", coord="-476, 16, -36", empty=true},
					{id="96", coord="-484, 16, -36", empty=true},
					{id="97", coord="-492, 16, -36", empty=true},
					{id="98", coord="-500, 16, -36", empty=true},
					{id="99", coord="-508, 16, -36", empty=true},
					{id="100", coord="-516, 16, -36", empty=true},
					{id="101", coord="-524, 16, -36", empty=true},
					{id="102", coord="-532, 16, -36", empty=true},
					{id="103", coord="-540, 16, -36", empty=true},
					{id="104", coord="-548, 16, -36", empty=true},
					{id="105", coord="-556, 16, -36", empty=true},
					{id="106", coord="-564, 16, -36", empty=true},
					{id="107", coord="-572, 16, -36", empty=true},
					{id="108", coord="-580, 16, -36", empty=true},
					{id="109", coord="-428, 16, -44", empty=true},
					{id="110", coord="-420, 16, -44", empty=true},
					{id="111", coord="-412, 16, -44", empty=true},
					{id="112", coord="-404, 16, -44", empty=true},
					{id="113", coord="-396, 16, -44", empty=true},
					{id="114", coord="-388, 16, -44", empty=true},
					{id="115", coord="-380, 16, -44", empty=true},
					{id="116", coord="-372, 16, -44", empty=true},
					{id="117", coord="-364, 16, -44", empty=true},
					{id="118", coord="-356, 16, -44", empty=true},
					{id="119", coord="-348, 16, -44", empty=true},
					{id="120", coord="-340, 16, -44", empty=true},
					{id="121", coord="-332, 16, -44", empty=true},
					{id="122", coord="-324, 16, -44", empty=true},
					{id="123", coord="-428, 16, -52", empty=true},
					{id="124", coord="-420, 16, -52", empty=true},
					{id="125", coord="-412, 16, -52", empty=true},
					{id="126", coord="-404, 16, -52", empty=true},
					{id="127", coord="-396, 16, -52", empty=true},
					{id="128", coord="-388, 16, -52", empty=true},
					{id="129", coord="-380, 16, -52", empty=true},
					{id="130", coord="-372, 16, -52", empty=true},
					{id="131", coord="-364, 16, -52", empty=true},
					{id="132", coord="-356, 16, -52", empty=true},
					{id="133", coord="-348, 16, -52", empty=true},
					{id="134", coord="-340, 16, -52", empty=true},
					{id="135", coord="-332, 16, -52", empty=true},
					{id="136", coord="-324, 16, -52", empty=true},
					{id="137", coord="-428, 16, -60", empty=true},
					{id="138", coord="-420, 16, -60", empty=true},
					{id="139", coord="-412, 16, -60", empty=true},
					{id="140", coord="-404, 16, -60", empty=true},
					{id="141", coord="-396, 16, -60", empty=true},
					{id="142", coord="-388, 16, -60", empty=true},
					{id="143", coord="-380, 16, -60", empty=true},
					{id="144", coord="-372, 16, -60", empty=true},
					{id="145", coord="-364, 16, -60", empty=true},
					{id="146", coord="-356, 16, -60", empty=true},
					{id="147", coord="-348, 16, -60", empty=true},
					{id="148", coord="-340, 16, -60", empty=true},
					{id="149", coord="-332, 16, -60", empty=true},
					{id="150", coord="-324, 16, -60", empty=true},
					{id="151", coord="-428, 16, -68", empty=true},
					{id="152", coord="-420, 16, -68", empty=true},
					{id="153", coord="-412, 16, -68", empty=true},
					{id="154", coord="-404, 16, -68", empty=true},
					{id="155", coord="-396, 16, -68", empty=true},
					{id="156", coord="-388, 16, -68", empty=true},
					{id="157", coord="-380, 16, -68", empty=true},
					{id="158", coord="-372, 16, -68", empty=true},
					{id="159", coord="-364, 16, -68", empty=true},
					{id="160", coord="-356, 16, -68", empty=true},
					{id="161", coord="-348, 16, -68", empty=true},
					{id="162", coord="-340, 16, -68", empty=true},
					{id="163", coord="-332, 16, -68", empty=true},
					{id="164", coord="-324, 16, -68", empty=true},
					{id="165", coord="-428, 16, -76", empty=true},
					{id="166", coord="-420, 16, -76", empty=true},
					{id="167", coord="-412, 16, -76", empty=true},
					{id="168", coord="-404, 16, -76", empty=true},
					{id="169", coord="-396, 16, -76", empty=true},
					{id="170", coord="-388, 16, -76", empty=true},
					{id="171", coord="-380, 16, -76", empty=true},
					{id="172", coord="-372, 16, -76", empty=true},
					{id="173", coord="-364, 16, -76", empty=true},
					{id="174", coord="-356, 16, -76", empty=true},
					{id="175", coord="-348, 16, -76", empty=true},
					{id="176", coord="-340, 16, -76", empty=true},
					{id="177", coord="-332, 16, -76", empty=true},
					{id="178", coord="-324, 16, -76", empty=true},
					{id="179", coord="-428, 16, -84", empty=true},
					{id="180", coord="-420, 16, -84", empty=true},
					{id="181", coord="-412, 16, -84", empty=true},
					{id="182", coord="-404, 16, -84", empty=true},
					{id="183", coord="-396, 16, -84", empty=true},
					{id="184", coord="-388, 16, -84", empty=true},
					{id="185", coord="-380, 16, -84", empty=true},
					{id="186", coord="-372, 16, -84", empty=true},
					{id="187", coord="-364, 16, -84", empty=true},
					{id="188", coord="-356, 16, -84", empty=true},
					{id="189", coord="-348, 16, -84", empty=true},
					{id="190", coord="-340, 16, -84", empty=true},
					{id="191", coord="-332, 16, -84", empty=true},
					{id="192", coord="-324, 16, -84", empty=true}
				},
				ocean = {}
			},
			Island_4 = {
				mountain = {
					{id="1", coord="-308, 16, 204", empty=true},
					{id="2", coord="-316, 16, 204", empty=true},
					{id="3", coord="-324, 16, 204", empty=true},
					{id="4", coord="-332, 16, 204", empty=true},
					{id="5", coord="-340, 16, 204", empty=true},
					{id="6", coord="-348, 16, 204", empty=true},
					{id="7", coord="-356, 16, 204", empty=true},
					{id="8", coord="-364, 16, 204", empty=true},
					{id="9", coord="-372, 16, 204", empty=true},
					{id="10", coord="-380, 16, 204", empty=true},
					{id="11", coord="-388, 16, 204", empty=true},
					{id="12", coord="-396, 16, 204", empty=true},
					{id="13", coord="-404, 16, 204", empty=true},
					{id="14", coord="-412, 16, 204", empty=true},
					{id="15", coord="-420, 16, 204", empty=true},
					{id="16", coord="-428, 16, 204", empty=true},
					{id="17", coord="-436, 16, 204", empty=true},
					{id="18", coord="-444, 16, 204", empty=true},
					{id="19", coord="-308, 16, 212", empty=true},
					{id="20", coord="-316, 16, 212", empty=true},
					{id="21", coord="-324, 16, 212", empty=true},
					{id="22", coord="-332, 16, 212", empty=true},
					{id="23", coord="-340, 16, 212", empty=true},
					{id="24", coord="-348, 16, 212", empty=true},
					{id="25", coord="-356, 16, 212", empty=true},
					{id="26", coord="-364, 16, 212", empty=true},
					{id="27", coord="-372, 16, 212", empty=true},
					{id="28", coord="-380, 16, 212", empty=true},
					{id="29", coord="-388, 16, 212", empty=true},
					{id="30", coord="-396, 16, 212", empty=true},
					{id="31", coord="-404, 16, 212", empty=true},
					{id="32", coord="-412, 16, 212", empty=true},
					{id="33", coord="-420, 16, 212", empty=true},
					{id="34", coord="-428, 16, 212", empty=true},
					{id="35", coord="-436, 16, 212", empty=true},
					{id="36", coord="-444, 16, 212", empty=true},
					{id="37", coord="-308, 16, 220", empty=true},
					{id="38", coord="-316, 16, 220", empty=true},
					{id="39", coord="-324, 16, 220", empty=true},
					{id="40", coord="-332, 16, 220", empty=true},
					{id="41", coord="-340, 16, 220", empty=true},
					{id="42", coord="-348, 16, 220", empty=true},
					{id="43", coord="-356, 16, 220", empty=true},
					{id="44", coord="-364, 16, 220", empty=true},
					{id="45", coord="-372, 16, 220", empty=true},
					{id="46", coord="-380, 16, 220", empty=true},
					{id="47", coord="-388, 16, 220", empty=true},
					{id="48", coord="-396, 16, 220", empty=true},
					{id="49", coord="-404, 16, 220", empty=true},
					{id="50", coord="-412, 16, 220", empty=true},
					{id="51", coord="-420, 16, 220", empty=true},
					{id="52", coord="-428, 16, 220", empty=true},
					{id="53", coord="-436, 16, 220", empty=true},
					{id="54", coord="-444, 16, 220", empty=true},
					{id="55", coord="-308, 16, 228", empty=true},
					{id="56", coord="-316, 16, 228", empty=true},
					{id="57", coord="-324, 16, 228", empty=true},
					{id="58", coord="-332, 16, 228", empty=true},
					{id="59", coord="-340, 16, 228", empty=true},
					{id="60", coord="-348, 16, 228", empty=true},
					{id="61", coord="-356, 16, 228", empty=true},
					{id="62", coord="-364, 16, 228", empty=true},
					{id="63", coord="-372, 16, 228", empty=true},
					{id="64", coord="-380, 16, 228", empty=true},
					{id="65", coord="-388, 16, 228", empty=true},
					{id="66", coord="-396, 16, 228", empty=true},
					{id="67", coord="-404, 16, 228", empty=true},
					{id="68", coord="-412, 16, 228", empty=true},
					{id="69", coord="-420, 16, 228", empty=true},
					{id="70", coord="-428, 16, 228", empty=true},
					{id="71", coord="-436, 16, 228", empty=true},
					{id="72", coord="-444, 16, 228", empty=true},
					{id="73", coord="-308, 16, 236", empty=true},
					{id="74", coord="-316, 16, 236", empty=true},
					{id="75", coord="-324, 16, 236", empty=true},
					{id="76", coord="-332, 16, 236", empty=true},
					{id="77", coord="-340, 16, 236", empty=true},
					{id="78", coord="-348, 16, 236", empty=true},
					{id="79", coord="-356, 16, 236", empty=true},
					{id="80", coord="-364, 16, 236", empty=true},
					{id="81", coord="-372, 16, 236", empty=true},
					{id="82", coord="-380, 16, 236", empty=true},
					{id="83", coord="-388, 16, 236", empty=true},
					{id="84", coord="-396, 16, 236", empty=true},
					{id="85", coord="-404, 16, 236", empty=true},
					{id="86", coord="-412, 16, 236", empty=true},
					{id="87", coord="-420, 16, 236", empty=true},
					{id="88", coord="-428, 16, 236", empty=true},
					{id="89", coord="-436, 16, 236", empty=true},
					{id="90", coord="-444, 16, 236", empty=true},
					{id="91", coord="-308, 16, 244", empty=true},
					{id="92", coord="-316, 16, 244", empty=true},
					{id="93", coord="-324, 16, 244", empty=true},
					{id="94", coord="-332, 16, 244", empty=true},
					{id="95", coord="-340, 16, 244", empty=true},
					{id="96", coord="-348, 16, 244", empty=true},
					{id="97", coord="-356, 16, 244", empty=true},
					{id="98", coord="-364, 16, 244", empty=true},
					{id="99", coord="-372, 16, 244", empty=true},
					{id="100", coord="-380, 16, 244", empty=true},
					{id="101", coord="-388, 16, 244", empty=true},
					{id="102", coord="-396, 16, 244", empty=true},
					{id="103", coord="-404, 16, 244", empty=true},
					{id="104", coord="-412, 16, 244", empty=true},
					{id="105", coord="-420, 16, 244", empty=true},
					{id="106", coord="-428, 16, 244", empty=true},
					{id="107", coord="-436, 16, 244", empty=true},
					{id="108", coord="-444, 16, 244", empty=true},
					{id="109", coord="-324, 16, 252", empty=true},
					{id="110", coord="-332, 16, 252", empty=true},
					{id="111", coord="-340, 16, 252", empty=true},
					{id="112", coord="-348, 16, 252", empty=true},
					{id="113", coord="-356, 16, 252", empty=true},
					{id="114", coord="-364, 16, 252", empty=true},
					{id="115", coord="-372, 16, 252", empty=true},
					{id="116", coord="-380, 16, 252", empty=true},
					{id="117", coord="-388, 16, 252", empty=true},
					{id="118", coord="-396, 16, 252", empty=true},
					{id="119", coord="-404, 16, 252", empty=true},
					{id="120", coord="-412, 16, 252", empty=true},
					{id="121", coord="-420, 16, 252", empty=true},
					{id="122", coord="-428, 16, 252", empty=true},
					{id="123", coord="-324, 16, 260", empty=true},
					{id="124", coord="-332, 16, 260", empty=true},
					{id="125", coord="-340, 16, 260", empty=true},
					{id="126", coord="-348, 16, 260", empty=true},
					{id="127", coord="-356, 16, 260", empty=true},
					{id="128", coord="-364, 16, 260", empty=true},
					{id="129", coord="-372, 16, 260", empty=true},
					{id="130", coord="-380, 16, 260", empty=true},
					{id="131", coord="-388, 16, 260", empty=true},
					{id="132", coord="-396, 16, 260", empty=true},
					{id="133", coord="-404, 16, 260", empty=true},
					{id="134", coord="-412, 16, 260", empty=true},
					{id="135", coord="-420, 16, 260", empty=true},
					{id="136", coord="-428, 16, 260", empty=true},
					{id="137", coord="-324, 16, 268", empty=true},
					{id="138", coord="-332, 16, 268", empty=true},
					{id="139", coord="-340, 16, 268", empty=true},
					{id="140", coord="-348, 16, 268", empty=true},
					{id="141", coord="-356, 16, 268", empty=true},
					{id="142", coord="-364, 16, 268", empty=true},
					{id="143", coord="-372, 16, 268", empty=true},
					{id="144", coord="-380, 16, 268", empty=true},
					{id="145", coord="-388, 16, 268", empty=true},
					{id="146", coord="-396, 16, 268", empty=true},
					{id="147", coord="-404, 16, 268", empty=true},
					{id="148", coord="-412, 16, 268", empty=true},
					{id="149", coord="-420, 16, 268", empty=true},
					{id="150", coord="-428, 16, 268", empty=true},
					{id="151", coord="-324, 16, 276", empty=true},
					{id="152", coord="-332, 16, 276", empty=true},
					{id="153", coord="-340, 16, 276", empty=true},
					{id="154", coord="-348, 16, 276", empty=true},
					{id="155", coord="-356, 16, 276", empty=true},
					{id="156", coord="-364, 16, 276", empty=true},
					{id="157", coord="-372, 16, 276", empty=true},
					{id="158", coord="-380, 16, 276", empty=true},
					{id="159", coord="-388, 16, 276", empty=true},
					{id="160", coord="-396, 16, 276", empty=true},
					{id="161", coord="-404, 16, 276", empty=true},
					{id="162", coord="-412, 16, 276", empty=true},
					{id="163", coord="-420, 16, 276", empty=true},
					{id="164", coord="-428, 16, 276", empty=true},
					{id="165", coord="-324, 16, 284", empty=true},
					{id="166", coord="-332, 16, 284", empty=true},
					{id="167", coord="-340, 16, 284", empty=true},
					{id="168", coord="-348, 16, 284", empty=true},
					{id="169", coord="-356, 16, 284", empty=true},
					{id="170", coord="-364, 16, 284", empty=true},
					{id="171", coord="-372, 16, 284", empty=true},
					{id="172", coord="-380, 16, 284", empty=true},
					{id="173", coord="-388, 16, 284", empty=true},
					{id="174", coord="-396, 16, 284", empty=true},
					{id="175", coord="-404, 16, 284", empty=true},
					{id="176", coord="-412, 16, 284", empty=true},
					{id="177", coord="-420, 16, 284", empty=true},
					{id="178", coord="-428, 16, 284", empty=true},
					{id="179", coord="-324, 16, 292", empty=true},
					{id="180", coord="-332, 16, 292", empty=true},
					{id="181", coord="-340, 16, 292", empty=true},
					{id="182", coord="-348, 16, 292", empty=true},
					{id="183", coord="-356, 16, 292", empty=true},
					{id="184", coord="-364, 16, 292", empty=true},
					{id="185", coord="-372, 16, 292", empty=true},
					{id="186", coord="-380, 16, 292", empty=true},
					{id="187", coord="-388, 16, 292", empty=true},
					{id="188", coord="-396, 16, 292", empty=true},
					{id="189", coord="-404, 16, 292", empty=true},
					{id="190", coord="-412, 16, 292", empty=true},
					{id="191", coord="-420, 16, 292", empty=true},
					{id="192", coord="-428, 16, 292", empty=true}
				},
				ocean = {}
			},
			Island_5 = {
				mountain = {
					{id="1", coord="-44, 16, 204", empty=true},
					{id="2", coord="-52, 16, 204", empty=true},
					{id="3", coord="-60, 16, 204", empty=true},
					{id="4", coord="-68, 16, 204", empty=true},
					{id="5", coord="-76, 16, 204", empty=true},
					{id="6", coord="-84, 16, 204", empty=true},
					{id="7", coord="-92, 16, 204", empty=true},
					{id="8", coord="-100, 16, 204", empty=true},
					{id="9", coord="-108, 16, 204", empty=true},
					{id="10", coord="-116, 16, 204", empty=true},
					{id="11", coord="-124, 16, 204", empty=true},
					{id="12", coord="-132, 16, 204", empty=true},
					{id="13", coord="-140, 16, 204", empty=true},
					{id="14", coord="-148, 16, 204", empty=true},
					{id="15", coord="-156, 16, 204", empty=true},
					{id="16", coord="-164, 16, 204", empty=true},
					{id="17", coord="-172, 16, 204", empty=true},
					{id="18", coord="-180, 16, 204", empty=true},
					{id="19", coord="-44, 16, 212", empty=true},
					{id="20", coord="-52, 16, 212", empty=true},
					{id="21", coord="-60, 16, 212", empty=true},
					{id="22", coord="-68, 16, 212", empty=true},
					{id="23", coord="-76, 16, 212", empty=true},
					{id="24", coord="-84, 16, 212", empty=true},
					{id="25", coord="-92, 16, 212", empty=true},
					{id="26", coord="-100, 16, 212", empty=true},
					{id="27", coord="-108, 16, 212", empty=true},
					{id="28", coord="-116, 16, 212", empty=true},
					{id="29", coord="-124, 16, 212", empty=true},
					{id="30", coord="-132, 16, 212", empty=true},
					{id="31", coord="-140, 16, 212", empty=true},
					{id="32", coord="-148, 16, 212", empty=true},
					{id="33", coord="-156, 16, 212", empty=true},
					{id="34", coord="-164, 16, 212", empty=true},
					{id="35", coord="-172, 16, 212", empty=true},
					{id="36", coord="-180, 16, 212", empty=true},
					{id="37", coord="-44, 16, 220", empty=true},
					{id="38", coord="-52, 16, 220", empty=true},
					{id="39", coord="-60, 16, 220", empty=true},
					{id="40", coord="-68, 16, 220", empty=true},
					{id="41", coord="-76, 16, 220", empty=true},
					{id="42", coord="-84, 16, 220", empty=true},
					{id="43", coord="-92, 16, 220", empty=true},
					{id="44", coord="-100, 16, 220", empty=true},
					{id="45", coord="-108, 16, 220", empty=true},
					{id="46", coord="-116, 16, 220", empty=true},
					{id="47", coord="-124, 16, 220", empty=true},
					{id="48", coord="-132, 16, 220", empty=true},
					{id="49", coord="-140, 16, 220", empty=true},
					{id="50", coord="-148, 16, 220", empty=true},
					{id="51", coord="-156, 16, 220", empty=true},
					{id="52", coord="-164, 16, 220", empty=true},
					{id="53", coord="-172, 16, 220", empty=true},
					{id="54", coord="-180, 16, 220", empty=true},
					{id="55", coord="-44, 16, 228", empty=true},
					{id="56", coord="-52, 16, 228", empty=true},
					{id="57", coord="-60, 16, 228", empty=true},
					{id="58", coord="-68, 16, 228", empty=true},
					{id="59", coord="-76, 16, 228", empty=true},
					{id="60", coord="-84, 16, 228", empty=true},
					{id="61", coord="-92, 16, 228", empty=true},
					{id="62", coord="-100, 16, 228", empty=true},
					{id="63", coord="-108, 16, 228", empty=true},
					{id="64", coord="-116, 16, 228", empty=true},
					{id="65", coord="-124, 16, 228", empty=true},
					{id="66", coord="-132, 16, 228", empty=true},
					{id="67", coord="-140, 16, 228", empty=true},
					{id="68", coord="-148, 16, 228", empty=true},
					{id="69", coord="-156, 16, 228", empty=true},
					{id="70", coord="-164, 16, 228", empty=true},
					{id="71", coord="-172, 16, 228", empty=true},
					{id="72", coord="-180, 16, 228", empty=true},
					{id="73", coord="-44, 16, 236", empty=true},
					{id="74", coord="-52, 16, 236", empty=true},
					{id="75", coord="-60, 16, 236", empty=true},
					{id="76", coord="-68, 16, 236", empty=true},
					{id="77", coord="-76, 16, 236", empty=true},
					{id="78", coord="-84, 16, 236", empty=true},
					{id="79", coord="-92, 16, 236", empty=true},
					{id="80", coord="-100, 16, 236", empty=true},
					{id="81", coord="-108, 16, 236", empty=true},
					{id="82", coord="-116, 16, 236", empty=true},
					{id="83", coord="-124, 16, 236", empty=true},
					{id="84", coord="-132, 16, 236", empty=true},
					{id="85", coord="-140, 16, 236", empty=true},
					{id="86", coord="-148, 16, 236", empty=true},
					{id="87", coord="-156, 16, 236", empty=true},
					{id="88", coord="-164, 16, 236", empty=true},
					{id="89", coord="-172, 16, 236", empty=true},
					{id="90", coord="-180, 16, 236", empty=true},
					{id="91", coord="-44, 16, 244", empty=true},
					{id="92", coord="-52, 16, 244", empty=true},
					{id="93", coord="-60, 16, 244", empty=true},
					{id="94", coord="-68, 16, 244", empty=true},
					{id="95", coord="-76, 16, 244", empty=true},
					{id="96", coord="-84, 16, 244", empty=true},
					{id="97", coord="-92, 16, 244", empty=true},
					{id="98", coord="-100, 16, 244", empty=true},
					{id="99", coord="-108, 16, 244", empty=true},
					{id="100", coord="-116, 16, 244", empty=true},
					{id="101", coord="-124, 16, 244", empty=true},
					{id="102", coord="-132, 16, 244", empty=true},
					{id="103", coord="-140, 16, 244", empty=true},
					{id="104", coord="-148, 16, 244", empty=true},
					{id="105", coord="-156, 16, 244", empty=true},
					{id="106", coord="-164, 16, 244", empty=true},
					{id="107", coord="-172, 16, 244", empty=true},
					{id="108", coord="-180, 16, 244", empty=true},
					{id="109", coord="-60, 16, 252", empty=true},
					{id="110", coord="-68, 16, 252", empty=true},
					{id="111", coord="-76, 16, 252", empty=true},
					{id="112", coord="-84, 16, 252", empty=true},
					{id="113", coord="-92, 16, 252", empty=true},
					{id="114", coord="-100, 16, 252", empty=true},
					{id="115", coord="-108, 16, 252", empty=true},
					{id="116", coord="-116, 16, 252", empty=true},
					{id="117", coord="-124, 16, 252", empty=true},
					{id="118", coord="-132, 16, 252", empty=true},
					{id="119", coord="-140, 16, 252", empty=true},
					{id="120", coord="-148, 16, 252", empty=true},
					{id="121", coord="-156, 16, 252", empty=true},
					{id="122", coord="-164, 16, 252", empty=true},
					{id="123", coord="-60, 16, 260", empty=true},
					{id="124", coord="-68, 16, 260", empty=true},
					{id="125", coord="-76, 16, 260", empty=true},
					{id="126", coord="-84, 16, 260", empty=true},
					{id="127", coord="-92, 16, 260", empty=true},
					{id="128", coord="-100, 16, 260", empty=true},
					{id="129", coord="-108, 16, 260", empty=true},
					{id="130", coord="-116, 16, 260", empty=true},
					{id="131", coord="-124, 16, 260", empty=true},
					{id="132", coord="-132, 16, 260", empty=true},
					{id="133", coord="-140, 16, 260", empty=true},
					{id="134", coord="-148, 16, 260", empty=true},
					{id="135", coord="-156, 16, 260", empty=true},
					{id="136", coord="-164, 16, 260", empty=true},
					{id="137", coord="-60, 16, 268", empty=true},
					{id="138", coord="-68, 16, 268", empty=true},
					{id="139", coord="-76, 16, 268", empty=true},
					{id="140", coord="-84, 16, 268", empty=true},
					{id="141", coord="-92, 16, 268", empty=true},
					{id="142", coord="-100, 16, 268", empty=true},
					{id="143", coord="-108, 16, 268", empty=true},
					{id="144", coord="-116, 16, 268", empty=true},
					{id="145", coord="-124, 16, 268", empty=true},
					{id="146", coord="-132, 16, 268", empty=true},
					{id="147", coord="-140, 16, 268", empty=true},
					{id="148", coord="-148, 16, 268", empty=true},
					{id="149", coord="-156, 16, 268", empty=true},
					{id="150", coord="-164, 16, 268", empty=true},
					{id="151", coord="-60, 16, 276", empty=true},
					{id="152", coord="-68, 16, 276", empty=true},
					{id="153", coord="-76, 16, 276", empty=true},
					{id="154", coord="-84, 16, 276", empty=true},
					{id="155", coord="-92, 16, 276", empty=true},
					{id="156", coord="-100, 16, 276", empty=true},
					{id="157", coord="-108, 16, 276", empty=true},
					{id="158", coord="-116, 16, 276", empty=true},
					{id="159", coord="-124, 16, 276", empty=true},
					{id="160", coord="-132, 16, 276", empty=true},
					{id="161", coord="-140, 16, 276", empty=true},
					{id="162", coord="-148, 16, 276", empty=true},
					{id="163", coord="-156, 16, 276", empty=true},
					{id="164", coord="-164, 16, 276", empty=true},
					{id="165", coord="-60, 16, 284", empty=true},
					{id="166", coord="-68, 16, 284", empty=true},
					{id="167", coord="-76, 16, 284", empty=true},
					{id="168", coord="-84, 16, 284", empty=true},
					{id="169", coord="-92, 16, 284", empty=true},
					{id="170", coord="-100, 16, 284", empty=true},
					{id="171", coord="-108, 16, 284", empty=true},
					{id="172", coord="-116, 16, 284", empty=true},
					{id="173", coord="-124, 16, 284", empty=true},
					{id="174", coord="-132, 16, 284", empty=true},
					{id="175", coord="-140, 16, 284", empty=true},
					{id="176", coord="-148, 16, 284", empty=true},
					{id="177", coord="-156, 16, 284", empty=true},
					{id="178", coord="-164, 16, 284", empty=true},
					{id="179", coord="-60, 16, 292", empty=true},
					{id="180", coord="-68, 16, 292", empty=true},
					{id="181", coord="-76, 16, 292", empty=true},
					{id="182", coord="-84, 16, 292", empty=true},
					{id="183", coord="-92, 16, 292", empty=true},
					{id="184", coord="-100, 16, 292", empty=true},
					{id="185", coord="-108, 16, 292", empty=true},
					{id="186", coord="-116, 16, 292", empty=true},
					{id="187", coord="-124, 16, 292", empty=true},
					{id="188", coord="-132, 16, 292", empty=true},
					{id="189", coord="-140, 16, 292", empty=true},
					{id="190", coord="-148, 16, 292", empty=true},
					{id="191", coord="-156, 16, 292", empty=true},
					{id="192", coord="-164, 16, 292", empty=true}
				},
				ocean = {}
			},
			Island_6 = {
				mountain = {
					{id="1", coord="228, 16, 204", empty=true},
					{id="2", coord="220, 16, 204", empty=true},
					{id="3", coord="212, 16, 204", empty=true},
					{id="4", coord="204, 16, 204", empty=true},
					{id="5", coord="196, 16, 204", empty=true},
					{id="6", coord="188, 16, 204", empty=true},
					{id="7", coord="180, 16, 204", empty=true},
					{id="8", coord="172, 16, 204", empty=true},
					{id="9", coord="164, 16, 204", empty=true},
					{id="10", coord="156, 16, 204", empty=true},
					{id="11", coord="148, 16, 204", empty=true},
					{id="12", coord="140, 16, 204", empty=true},
					{id="13", coord="132, 16, 204", empty=true},
					{id="14", coord="124, 16, 204", empty=true},
					{id="15", coord="116, 16, 204", empty=true},
					{id="16", coord="108, 16, 204", empty=true},
					{id="17", coord="100, 16, 204", empty=true},
					{id="18", coord="92, 16, 204", empty=true},
					{id="19", coord="228, 16, 212", empty=true},
					{id="20", coord="220, 16, 212", empty=true},
					{id="21", coord="212, 16, 212", empty=true},
					{id="22", coord="204, 16, 212", empty=true},
					{id="23", coord="196, 16, 212", empty=true},
					{id="24", coord="188, 16, 212", empty=true},
					{id="25", coord="180, 16, 212", empty=true},
					{id="26", coord="172, 16, 212", empty=true},
					{id="27", coord="164, 16, 212", empty=true},
					{id="28", coord="156, 16, 212", empty=true},
					{id="29", coord="148, 16, 212", empty=true},
					{id="30", coord="140, 16, 212", empty=true},
					{id="31", coord="132, 16, 212", empty=true},
					{id="32", coord="124, 16, 212", empty=true},
					{id="33", coord="116, 16, 212", empty=true},
					{id="34", coord="108, 16, 212", empty=true},
					{id="35", coord="100, 16, 212", empty=true},
					{id="36", coord="92, 16, 212", empty=true},
					{id="37", coord="228, 16, 220", empty=true},
					{id="38", coord="220, 16, 220", empty=true},
					{id="39", coord="212, 16, 220", empty=true},
					{id="40", coord="204, 16, 220", empty=true},
					{id="41", coord="196, 16, 220", empty=true},
					{id="42", coord="188, 16, 220", empty=true},
					{id="43", coord="180, 16, 220", empty=true},
					{id="44", coord="172, 16, 220", empty=true},
					{id="45", coord="164, 16, 220", empty=true},
					{id="46", coord="156, 16, 220", empty=true},
					{id="47", coord="148, 16, 220", empty=true},
					{id="48", coord="140, 16, 220", empty=true},
					{id="49", coord="132, 16, 220", empty=true},
					{id="50", coord="124, 16, 220", empty=true},
					{id="51", coord="116, 16, 220", empty=true},
					{id="52", coord="108, 16, 220", empty=true},
					{id="53", coord="100, 16, 220", empty=true},
					{id="54", coord="92, 16, 220", empty=true},
					{id="55", coord="228, 16, 228", empty=true},
					{id="56", coord="220, 16, 228", empty=true},
					{id="57", coord="212, 16, 228", empty=true},
					{id="58", coord="204, 16, 228", empty=true},
					{id="59", coord="196, 16, 228", empty=true},
					{id="60", coord="188, 16, 228", empty=true},
					{id="61", coord="180, 16, 228", empty=true},
					{id="62", coord="172, 16, 228", empty=true},
					{id="63", coord="164, 16, 228", empty=true},
					{id="64", coord="156, 16, 228", empty=true},
					{id="65", coord="148, 16, 228", empty=true},
					{id="66", coord="140, 16, 228", empty=true},
					{id="67", coord="132, 16, 228", empty=true},
					{id="68", coord="124, 16, 228", empty=true},
					{id="69", coord="116, 16, 228", empty=true},
					{id="70", coord="108, 16, 228", empty=true},
					{id="71", coord="100, 16, 228", empty=true},
					{id="72", coord="92, 16, 228", empty=true},
					{id="73", coord="228, 16, 236", empty=true},
					{id="74", coord="220, 16, 236", empty=true},
					{id="75", coord="212, 16, 236", empty=true},
					{id="76", coord="204, 16, 236", empty=true},
					{id="77", coord="196, 16, 236", empty=true},
					{id="78", coord="188, 16, 236", empty=true},
					{id="79", coord="180, 16, 236", empty=true},
					{id="80", coord="172, 16, 236", empty=true},
					{id="81", coord="164, 16, 236", empty=true},
					{id="82", coord="156, 16, 236", empty=true},
					{id="83", coord="148, 16, 236", empty=true},
					{id="84", coord="140, 16, 236", empty=true},
					{id="85", coord="132, 16, 236", empty=true},
					{id="86", coord="124, 16, 236", empty=true},
					{id="87", coord="116, 16, 236", empty=true},
					{id="88", coord="108, 16, 236", empty=true},
					{id="89", coord="100, 16, 236", empty=true},
					{id="90", coord="92, 16, 236", empty=true},
					{id="91", coord="228, 16, 244", empty=true},
					{id="92", coord="220, 16, 244", empty=true},
					{id="93", coord="212, 16, 244", empty=true},
					{id="94", coord="204, 16, 244", empty=true},
					{id="95", coord="196, 16, 244", empty=true},
					{id="96", coord="188, 16, 244", empty=true},
					{id="97", coord="180, 16, 244", empty=true},
					{id="98", coord="172, 16, 244", empty=true},
					{id="99", coord="164, 16, 244", empty=true},
					{id="100", coord="156, 16, 244", empty=true},
					{id="101", coord="148, 16, 244", empty=true},
					{id="102", coord="140, 16, 244", empty=true},
					{id="103", coord="132, 16, 244", empty=true},
					{id="104", coord="124, 16, 244", empty=true},
					{id="105", coord="116, 16, 244", empty=true},
					{id="106", coord="108, 16, 244", empty=true},
					{id="107", coord="100, 16, 244", empty=true},
					{id="108", coord="92, 16, 244", empty=true},
					{id="109", coord="212, 16, 252", empty=true},
					{id="110", coord="204, 16, 252", empty=true},
					{id="111", coord="196, 16, 252", empty=true},
					{id="112", coord="188, 16, 252", empty=true},
					{id="113", coord="180, 16, 252", empty=true},
					{id="114", coord="172, 16, 252", empty=true},
					{id="115", coord="164, 16, 252", empty=true},
					{id="116", coord="156, 16, 252", empty=true},
					{id="117", coord="148, 16, 252", empty=true},
					{id="118", coord="140, 16, 252", empty=true},
					{id="119", coord="132, 16, 252", empty=true},
					{id="120", coord="124, 16, 252", empty=true},
					{id="121", coord="116, 16, 252", empty=true},
					{id="122", coord="108, 16, 252", empty=true},
					{id="123", coord="212, 16, 260", empty=true},
					{id="124", coord="204, 16, 260", empty=true},
					{id="125", coord="196, 16, 260", empty=true},
					{id="126", coord="188, 16, 260", empty=true},
					{id="127", coord="180, 16, 260", empty=true},
					{id="128", coord="172, 16, 260", empty=true},
					{id="129", coord="164, 16, 260", empty=true},
					{id="130", coord="156, 16, 260", empty=true},
					{id="131", coord="148, 16, 260", empty=true},
					{id="132", coord="140, 16, 260", empty=true},
					{id="133", coord="132, 16, 260", empty=true},
					{id="134", coord="124, 16, 260", empty=true},
					{id="135", coord="116, 16, 260", empty=true},
					{id="136", coord="108, 16, 260", empty=true},
					{id="137", coord="212, 16, 268", empty=true},
					{id="138", coord="204, 16, 268", empty=true},
					{id="139", coord="196, 16, 268", empty=true},
					{id="140", coord="188, 16, 268", empty=true},
					{id="141", coord="180, 16, 268", empty=true},
					{id="142", coord="172, 16, 268", empty=true},
					{id="143", coord="164, 16, 268", empty=true},
					{id="144", coord="156, 16, 268", empty=true},
					{id="145", coord="148, 16, 268", empty=true},
					{id="146", coord="140, 16, 268", empty=true},
					{id="147", coord="132, 16, 268", empty=true},
					{id="148", coord="124, 16, 268", empty=true},
					{id="149", coord="116, 16, 268", empty=true},
					{id="150", coord="108, 16, 268", empty=true},
					{id="151", coord="212, 16, 276", empty=true},
					{id="152", coord="204, 16, 276", empty=true},
					{id="153", coord="196, 16, 276", empty=true},
					{id="154", coord="188, 16, 276", empty=true},
					{id="155", coord="180, 16, 276", empty=true},
					{id="156", coord="172, 16, 276", empty=true},
					{id="157", coord="164, 16, 276", empty=true},
					{id="158", coord="156, 16, 276", empty=true},
					{id="159", coord="148, 16, 276", empty=true},
					{id="160", coord="140, 16, 276", empty=true},
					{id="161", coord="132, 16, 276", empty=true},
					{id="162", coord="124, 16, 276", empty=true},
					{id="163", coord="116, 16, 276", empty=true},
					{id="164", coord="108, 16, 276", empty=true},
					{id="165", coord="212, 16, 284", empty=true},
					{id="166", coord="204, 16, 284", empty=true},
					{id="167", coord="196, 16, 284", empty=true},
					{id="168", coord="188, 16, 284", empty=true},
					{id="169", coord="180, 16, 284", empty=true},
					{id="170", coord="172, 16, 284", empty=true},
					{id="171", coord="164, 16, 284", empty=true},
					{id="172", coord="156, 16, 284", empty=true},
					{id="173", coord="148, 16, 284", empty=true},
					{id="174", coord="140, 16, 284", empty=true},
					{id="175", coord="132, 16, 284", empty=true},
					{id="176", coord="124, 16, 284", empty=true},
					{id="177", coord="116, 16, 284", empty=true},
					{id="178", coord="108, 16, 284", empty=true},
					{id="179", coord="212, 16, 292", empty=true},
					{id="180", coord="204, 16, 292", empty=true},
					{id="181", coord="196, 16, 292", empty=true},
					{id="182", coord="188, 16, 292", empty=true},
					{id="183", coord="180, 16, 292", empty=true},
					{id="184", coord="172, 16, 292", empty=true},
					{id="185", coord="164, 16, 292", empty=true},
					{id="186", coord="156, 16, 292", empty=true},
					{id="187", coord="148, 16, 292", empty=true},
					{id="188", coord="140, 16, 292", empty=true},
					{id="189", coord="132, 16, 292", empty=true},
					{id="190", coord="124, 16, 292", empty=true},
					{id="191", coord="116, 16, 292", empty=true},
					{id="192", coord="108, 16, 292", empty=true}
				},
				ocean = {}
			}
		},
		fruits = {
			{name="Strawberry", fullname="Strawberry"},
			{name="Blueberry", fullname="Blueberry"},
			{name="Watermelon", fullname="Watermelon"},
			{name="Apple", fullname="Apple"},
			{name="Orange", fullname="Orange"},
			{name="Corn", fullname="Corn"},
			{name="Banana", fullname="Banana"},
			{name="Grape", fullname="Grape"},
			{name="Pear", fullname="Pear"},
			{name="PineApple", fullname="PineApple"},
			{name="Dragon Fruit", fullname="DragonFruit"},
			{name="Gold Mango", fullname="GoldMango"},
			{name="Bloodstone Cycad", fullname="BloodstoneCycad"},
			{name="Colossal Pinecone", fullname="ColossalPinecone"},
			{name="Volt Ginkgo", fullname="VoltGinkgo"},
			{name="Deepsea Pearl", fullname="DeepseaPearlFruit"},
			{name="Durian", fullname="Durian"},
            {name="Pumpkin", fullname="Pumpkin"}
		},
		eggs = {
			{name="Basic Egg"},
			{name="Rare Egg"},
			{name="Super Rare Egg"},
			{name="Sea Weed Egg"},
			{name="Legend Egg"},
			{name="Clownfish Egg"},
			{name="Prismatic Egg"},
			{name="Lionfish Egg"},
			{name="Hyper Egg"},
			{name="Dark Goaty Egg"},
			{name="Void Egg"},
			{name="Bowser Egg"},
			{name="Shark Egg"},
			{name="Demon Egg"},
			{name="Rhino Rock Egg"},
			{name="Corn Egg"},
			{name="Anglerfish Egg"},
			{name="Bonedragon Egg"},
			{name="Ultra Egg"},
			{name="Unicorn Egg"},
			{name="Unicorn Pro Egg"},
			{name="Octopus Egg"},
			{name="Saber Cub Egg"},
			{name="Kaiju Egg"},
			{name="General Kong Egg"}
		},
		muts = { 
			"Dino", 
			"Golden", 
			"Diamon", 
			"Electric", 
			"Fire", 
			"Jurassic", 
			"Snow",
            "Halloween"
		},
		EggInventory = {},
		FruitShop = {}
	}
}

local function fireServer(obj, arg)
	if type(arg) == "table" and arg[1] then
		obj:FireServer(unpack(arg))
	else
		obj:FireServer(arg)
	end
end

local function getNil(objType, objName)
	for _, v in ipairs(getnilinstances()) do
		if v.ClassName == objType and v.Name == objName then
			return v
		end
	end
end

local function strToVector3(coordStr)
	local x, y, z = coordStr:match("([^,]+), ([^,]+), ([^,]+)")
	return Vector3.new(tonumber(x), tonumber(y), tonumber(z))
end

-- State vars
local islandName = player:GetAttribute("AssignedIslandName")

local isRunning = false
local isPaused = false
local runId = 0
local dupeRunning = false
local dupePaused = false
local autofarm = false
local autoBuyEggs = false
local autoBuyFruit = false
local plantStage = false

local fruitOptions = {}
local fruitAmounts = {}
local eggOptions = {}

local selectedPlayerName = nil
local selectedEggName = {}
local selectedMutName = {}
local selectedFruits = {}

local menuVisible = true

local autofarmThread
local plantThread

-- MENU FUNC
local function GetEggsInv()
    local scrollingFrame = player.PlayerGui.ScreenStorage.Frame.Content:FindFirstChild("ScrollingFrame")
    local eggs = {}
    if not scrollingFrame then return eggs end

    for _, item in pairs(scrollingFrame:GetChildren()) do
        local btn = item:FindFirstChild("BTN")
        if btn then
            local stat = btn:FindFirstChild("Stat")
            local mutsFolder = btn:FindFirstChild("Muts")
            local eggName = "Unknown"
            if stat and stat:FindFirstChild("NAME") and stat.NAME:FindFirstChild("Value") then
                local nameValue = stat.NAME.Value
                if nameValue:IsA("TextLabel") then
                    eggName = nameValue.Text
                end
            end

            local visibleMut = nil
            if mutsFolder then
                for _, mut in pairs(mutsFolder:GetChildren()) do
                    if mut:IsA("GuiObject") and mut.Visible then
                        visibleMut = mut.Name
                        break
                    end
                end
            end

            if visibleMut then
                table.insert(eggs, {id = item.Name, name = eggName, mutation = visibleMut})
            end
        end
    end

    return eggs
end


GetEggsInv()

-- Live player dropdown
local playerDropdown = Menu.tabs.main.left1:Dropdown({
	Name = "Select Player",
	Options = {},
    IgnoreConfig = true,
	Multi = false,
	Callback = function(selected)
		selectedPlayerName = selected
		Window:Notify({
			Title = "Player Selected",
			Description = tostring(selected),
			Lifetime = 2
		})
	end
})

-- Now define RefreshPlayers
local function RefreshPlayers()
	local items = {}
	for _, p in ipairs(Players:GetPlayers()) do
		table.insert(items, p.Name)
	end

	local found = false
	if selectedPlayerName then
		for _, n in ipairs(items) do
			if n == selectedPlayerName then
				found = true
				break
			end
		end
	end
	if not found then
		selectedPlayerName = nil
	end

	-- Update dropdown
	pcall(function()
		playerDropdown:ClearOptions()
		playerDropdown:InsertOptions(items)
	end)
end

-- Connect events
Players.PlayerAdded:Connect(RefreshPlayers)
Players.PlayerRemoving:Connect(RefreshPlayers)

-- Initial populate
RefreshPlayers()



for _, fruit in ipairs(Menu.data.fruits) do
	Menu.tabs.main.left2:Input({
		Name = fruit.name,
        IgnoreConfig = true,
		Placeholder = "                   ",
		AcceptedCharacters = "Numeric",
		Callback = function(val)
			fruitAmounts[fruit.fullname] = val
		end
	})
end

-- Counters (right side)
local givenLabel = Menu.tabs.main.left2:Label({ Text = "Given: 0                                             Left: 0" })

-- Start Gift Loop button
Menu.tabs.main.left2:Button({
	Name = "Start Gift Loop",
	Callback = function()
		local playerName = selectedPlayerName
		if not playerName or playerName == "" then
			Window:Notify({ Title = "Error", Description = "Please select a player.", Lifetime = 3 })
			return
		end

		local targetPlayer = Players:FindFirstChild(playerName)
		if not targetPlayer then
			Window:Notify({ Title = "Error", Description = "Player not found: " .. tostring(playerName), Lifetime = 3 })
			return
		end

		if isRunning then
			Window:Notify({ Title = "Busy", Description = "Gift loop already running.", Lifetime = 3 })
			return
		end

		-- Build queue
		local queue = {}
		for _, fruit in ipairs(Menu.data.fruits) do
			local count = fruitAmounts[fruit.fullname] or 0
			for i = 1, count do
				table.insert(queue, fruit.fullname)
			end
		end

		if #queue == 0 then
			Window:Notify({ Title = "Error", Description = "No fruits selected!", Lifetime = 3 })
			return
		end

		isRunning = true
		isPaused = false
		runId += 1
		local myId = runId

		task.spawn(function()
			local given = 0
			for _, fruitFullName in ipairs(queue) do
				if not isRunning or myId ~= runId then break end
				while isPaused and isRunning and myId == runId do task.wait(0.1) end

				-- focus then send
				pcall(function()
					fireServer(CharacterRE,{"Focus", fruitFullName})
				end)
				task.wait(0.1)
				pcall(function()
					GiftRE:FireServer(targetPlayer)
				end)

				given += 1
				local ok, _ = pcall(function() givenLabel:UpdateName("Given: " .. given .. "                                             Left: " .. (#queue - given)) end)
				if not ok then pcall(function() givenLabel.Text = "Given: " .. given .. "                                             Left: " .. (#queue - given) end) end

				task.wait(0.3)
			end

			if myId == runId then
				isRunning = false
				isPaused = false
				pcall(function() givenLabel:UpdateName("Given: 0") end)
				pcall(function() leftLabel:UpdateName("Left: 0") end)
				Window:Notify({ Title = "Done!", Description = "Gift loop finished.", Lifetime = 4 })
			end
		end)
	end
})

-- Pause/Resume
Menu.tabs.main.left2:Button({
	Name = "Pause / Resume",
	Callback = function()
		if not isRunning then
			Window:Notify({ Title = "Info", Description = "Not currently running.", Lifetime = 2 })
			return
		end
		isPaused = not isPaused
		Window:Notify({ Title = isPaused and "Paused" or "Resumed", Description = "", Lifetime = 2 })
	end
})

-- Cancel Loop
Menu.tabs.main.left2:Button({
	Name = "Cancel Loop",
	Callback = function()
		runId += 1
		isRunning = false
		isPaused = false
		pcall(function() givenLabel:UpdateName("Given: 0                                             Left: 0") end)
		Window:Notify({ Title = "Cancelled", Text = "Gift loop stopped.", Lifetime = 2 })
	end
})

-- Create dropdown UI
for _, egg in ipairs(Menu.data.eggs) do
	table.insert(eggOptions, egg.name)
end

local EggDropdown1 = Menu.tabs.main.right:Dropdown({
	Name = "Eggs List",
	Search = true,
	Multi = false,
	Required = false,
	Options = eggOptions,
	Default = {  },
	Callback = function(v)
		table.insert(selectedEggName, v)
		Window:Notify({ Title = "Selected", Description = "Selected" .. v .. " Eggs!", Lifetime = 3 })
	end
})

-- Create dropdown UI
local MutsDropdown1 = Menu.tabs.main.right:Dropdown({
	Name = "Mutation List",
	Search = true,
	Multi = false,
	Required = false,
	Options = Menu.data.muts,
	Default = {  },
	Callback = function(v)
		table.insert(selectedEggName, v)
		Window:Notify({ Title = "Selected", Description = "Selected" .. v .. " Eggs!", Lifetime = 3 })
	end
})

-- Input box for total to give

local totalInput = Menu.tabs.main.right:Input({
	Name = "Total",
	Placeholder = "Enter total",
	AcceptedCharacters = "Numeric",
	Callback = function(value)
	end
})

-- Start Give Loop button
local dupeLabel = Menu.tabs.main.right:Label({ Text = "Given: 0                                             Left: 0" })

Menu.tabs.main.right:Button({
	Name = "execute give loop",
	Callback = function()
		Menu.data.EggInventory = GetEggsInv()

		local totalToGive = tonumber(totalInput:GetInput()) or 0
		if totalToGive <= 0 then totalToGive = #Menu.data.EggInventory end

		local playerName = selectedPlayerName
		if not playerName or playerName == "" then
			Window:Notify({ Title = "Error", Description = "Please select a player.", Lifetime = 3 })
			return
		end

		local targetPlayer = Players:FindFirstChild(playerName)
		if not targetPlayer then
			Window:Notify({ Title = "Error", Description = "Player not found: " .. tostring(playerName), Lifetime = 3 })
			return
		end

		local targetChar = targetPlayer.Character
		if targetChar and targetChar:FindFirstChild("HumanoidRootPart") and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
			player.Character.HumanoidRootPart.CFrame = targetChar.HumanoidRootPart.CFrame + Vector3.new(0,5,0)
		end

		if (not selectedEggName or #selectedEggName == 0) or (not selectedMutName or #selectedMutName == "") then
			Window:Notify({
				Title = "Error",
				Description = "Select at least one egg and a mutation!",
				Lifetime = 3
			})
			return
		end

		local queue = {}
		for _, egg in ipairs(Menu.data.EggInventory) do
			for _, allowedName in ipairs(selectedEggName) do
				for _, allowedMut in ipairs(selectedMutName) do
					if egg.name == allowedName and egg.mutation == allowedMut then
						table.insert(queue, egg.id)
						break
					end
				end
			end
		end

		if #queue == 0 then
			Window:Notify({Title = "Error", Description = "No matching eggs found!", Lifetime = 3})
			return
		end

		while #queue > totalToGive do
			table.remove(queue)
		end

		-- Start give loop
		local given = 0
		dupeRunning = true
		dupePaused = false
		runId += 1
		local myId = runId

		task.spawn(function()
			for _, eggId in ipairs(queue) do
				if not dupeRunning then break end
				while dupePaused and dupeRunning and myId == runId do task.wait(0.1) end
				

				pcall(function() DeployRE:FireServer({ event = "deploy", uid = eggId }) end)
				task.wait(0.1)
				pcall(function() CharacterRE:FireServer("Focus", eggId) end)
				task.wait(0.1)
				pcall(function() GiftRE:FireServer(targetPlayer) end)

				given += 1
				pcall(function()
					dupeLabel:UpdateName("Given: " .. given .. "                                             Left: " .. (#queue - given))
				end)
				task.wait(0.1)
			end

			dupeRunning = false
			Window:Notify({Title = "Done", Description = "Egg give finished.", Lifetime = 3})
			pcall(function() dupeLabel:UpdateName("Given: 0                                             Left: 0") end)
		end)
	end
})

-- Pause / Resume
Menu.tabs.main.right:Button({
	Name = "Pause / Resume",
	Callback = function()
		if not dupeRunning then
			Window:Notify({ Title = "Info", Description = "Not currently running.", Lifetime = 2 })
			return
		end
		dupePaused = not dupePaused
		Window:Notify({ Title = dupePaused and "Paused" or "Resumed", Description = "", Lifetime = 2 })
	end
})

-- Cancel Loop
Menu.tabs.main.right:Button({
	Name = "Cancel Loop",
	Callback = function()
		runId += 1
		dupeRunning = false
		dupePaused = false
		pcall(function() dupeLabel:UpdateName("Given: 0                                             Left: 0") end)
		Window:Notify({ Title = "Cancelled", Text = "Gift loop stopped.", Lifetime = 2 })
	end
})
-----------------------------------------------------------
-- EGG TAB
----------------------------------------------------------
local function updatePlantStatus()
    -- Get pets folder
    local petsFolder = workspace:FindFirstChild("Pets")
    if not petsFolder then
        warn("No Pets folder found in workspace!")
        return
    end
    local pets = petsFolder:GetChildren()

    local blocks = {}
    if blocksFolder then
        for _, model in ipairs(blocksFolder:GetChildren()) do
            if model:IsA("Model") and model.PrimaryPart then
                table.insert(blocks, model)
            end
        end
    else
        warn("No PlayerBuiltBlocks folder found!")
    end

    local plants = Menu.data.plants[tostring(islandName)] and Menu.data.plants[tostring(islandName)].mountain
    if not plants then
        warn("No plants for island: " .. tostring(islandName))
        return
    end

    for _, plant in ipairs(plants) do
        local success, plantPos = pcall(strToVector3, plant.coord)
        if not success then
            warn("Invalid plant coord: " .. tostring(plant.coord))
            plant.empty = true
            continue
        end

        plant.empty = true

        for _, pet in ipairs(pets) do
            if pet.PrimaryPart then
                local petPos = pet.PrimaryPart.Position
                if math.abs(petPos.X - plantPos.X) < 4 and math.abs(petPos.Z - plantPos.Z) < 4 then
                    plant.empty = false
                    break
                end
            end
        end

        if plant.empty then
            for _, block in ipairs(blocks) do
                local blockPos = block.PrimaryPart.Position
                if math.abs(blockPos.X - plantPos.X) < 4 and math.abs(blockPos.Z - plantPos.Z) < 4 then
                    plant.empty = false
                    break
                end
            end
        end
    end

    for _, plant in ipairs(plants) do
        if plant.empty then
			print(string.format("ID: %s | Coord: %s | Empty: %s", plant.id, plant.coord, tostring(plant.empty)))
		end
    end
end


-- === Egg Dropdown (Persistent) ===
local EggDropdown2 = Menu.tabs.egg.left1:Dropdown({
	Name = "Eggs List",
	Search = true,
	Multi = true,
	Required = true,
	Options = eggOptions,
	Default = false,
	Callback = function(Value)
		selectedEggName = {}
		for v, State in next, Value do
			if State then
				table.insert(selectedEggName, v)
			end
		end
	end
})

-- === Mutation Dropdown (Persistent) ===
local MutsDropdown2 = Menu.tabs.egg.left1:Dropdown({
	Name = "Mutation List",
	Search = true,
	Multi = true,
	Required = true,
	Options = Menu.data.muts,
	Default = {  },
	Callback = function(Value)
		selectedMutName = {}
		for v, State in next, Value do
			if State then
				table.insert(selectedMutName, v)
			end
		end
	end
})

-- === Plant All Eggs Toggle (Persistent) ===
local AutoPlantsToggle = Menu.tabs.egg.left1:Toggle({
	Name = "Plant All Eggs",
	Default = false,
	Callback = function(s)
		plantStage = s

		if plantStage then
			plantThread = task.spawn(function()
				while plantStage do
					updatePlantStatus()
					Menu.data.EggInventory = GetEggsInv()

					local islandData = Menu.data.plants[tostring(islandName)]
					local plants = islandData and islandData.mountain
					if not plants or #plants == 0 then
						task.wait(2)
						continue
					end

					if (not selectedEggName or #selectedEggName == 0) or (not selectedMutName or #selectedMutName == 0) then
						Window:Notify({
							Title = "Error",
							Description = "Select at least one egg and a mutation!",
							Lifetime = 3
						})
						return
					end

					local queue = {}
					for _, egg in ipairs(Menu.data.EggInventory) do
						for _, allowedName in ipairs(selectedEggName) do
							for _, allowedMut in ipairs(selectedMutName) do
								if egg.name == allowedName and egg.mutation == allowedMut then
									table.insert(queue, egg.id)
									break
								end
							end
						end
					end

					if #queue == 0 then
						task.wait(3)
						continue
					end

					local eggIndex = 1
					for _, plant in ipairs(plants) do
						if not plantStage then break end
						if plant.empty and eggIndex <= #queue then
							local pos = strToVector3(plant.coord)
							local eggId = queue[eggIndex]
							
							player.Character.HumanoidRootPart.CFrame = CFrame.new(pos + Vector3.new(0, 5, 0))

							pcall(function() DeployRE:FireServer({ event = "deploy", uid = eggId }) end)
							task.wait(0.1)
							pcall(function() CharacterRE:FireServer("Focus", eggId) end)
							task.wait(0.1)
							pcall(function() CharacterRE:FireServer("Place", { DST = pos, ID = eggId }) end)
							task.wait(0.75)

							plant.empty = false
							eggIndex += 1
						end
					end

					task.wait(2)
				end
			end)
		else
			plantStage = false
			Window:Notify({
				Title = "Stopped",
				Description = "Stopped planting eggs.",
				Lifetime = 3
			})
		end
	end
})


Menu.tabs.egg.left1:Button({
	Name = "Hatch All Eggs",
	Callback = function()
		local HatchScript = player.PlayerScripts.LocalScriptAttach.RunTime:FindFirstChild("CS_HatchEgg")

		for _, block in ipairs(PlayerBuiltBlocks:GetChildren()) do
			local root = block:FindFirstChild("RootPart")
			if root then
				local prompt = root:FindFirstChildOfClass("ProximityPrompt")
				if prompt then
					task.spawn(function()
						fireproximityprompt(prompt, 0)
					end)
				end
			end
		end
	end
})

local island = workspace.Art:FindFirstChild(islandName)
local conveyor9, belt

if island and island:FindFirstChild("ENV") then
	local conveyorFolder = island.ENV:FindFirstChild("Conveyor")
	if conveyorFolder then
		for _, conveyor in ipairs(conveyorFolder:GetChildren()) do
			if conveyor:IsA("Model") and conveyor.Name:match("^Conveyor%d+$") then
				local foundBelt = conveyor:FindFirstChild("Belt")
				if foundBelt then
					belt = foundBelt
					conveyor9 = conveyor
					break
				end
			end
		end
	end
end

local island = workspace.Art:FindFirstChild(islandName)
local conveyor9, belt

if island and island:FindFirstChild("ENV") then
	local conveyorFolder = island.ENV:FindFirstChild("Conveyor")
	if conveyorFolder then
		for _, conveyor in ipairs(conveyorFolder:GetChildren()) do
			if conveyor:IsA("Model") and conveyor.Name:match("^Conveyor%d+$") then
				local foundBelt = conveyor:FindFirstChild("Belt")
				if foundBelt then
					belt = foundBelt
					conveyor9 = conveyor
					break
				end
			end
		end
	end
end

local function getAllEggOnBelt()
	local results = {}
	if not belt then
		return results
	end

	for _, obj in ipairs(belt:GetChildren()) do
		local rootPart = obj:FindFirstChild("RootPart")
		if not rootPart then
			continue
		end

		local gui = rootPart:FindFirstChild("GUI/EggGUI")
		if not gui then
			continue
		end

		local eggNameObj = gui:FindFirstChild("EggName")
		local mutateObj = gui:FindFirstChild("Mutate")

		if eggNameObj and mutateObj then
			local eggName = eggNameObj.Text ~= "" and eggNameObj.Text or "Unknown"
			local mutateValue = mutateObj.Text ~= "" and mutateObj.Text or "Dino"

			table.insert(results, {
				fullname = obj.Name,
				name = eggName,
				mutate = mutateValue
			})
		end
	end

	-- for i, egg in ipairs(results) do
	-- 	print(string.format("[%d] %s | Name: %s | Mutate: %s", i, egg.fullname, egg.name, egg.mutate))
	-- end

	return results
end

-- Eggs Dropdown
local EggDropdown3 = Menu.tabs.egg.right1:Dropdown({
	Name = "Eggs List",
	Search = true,
	Multi = true,
	Required = false,
	Options = eggOptions,
	Default = {  }, -- load saved
	Callback = function(Value)
		selectedEggName = {}
		for v, S in next, Value do if S then table.insert(selectedEggName, v) end end
	end
}, "AutoBuyEggDropdown3")

-- Mutation Dropdown
local MutsDropdown3 = Menu.tabs.egg.right1:Dropdown({
	Name = "Mutation List",
	Search = true,
	Multi = true,
	Required = false,
	Options = Menu.data.muts,
	Default = {  }, -- load saved
	Callback = function(Value)
		selectedMutName = {}
		for v, S in next, Value do if S then table.insert(selectedMutName, v) end end
	end
}, "AutoBuyMutsDropdown3")


local AutoBuyEToggle = Menu.tabs.egg.right1:Toggle({
	Name = "Automatic buy",
	Default = false,
	Callback = function(state)
		autoBuyEggs = state
        if state then
            task.spawn(function()
                while autoBuyEggs do
                    local eggsOnBelt = getAllEggOnBelt()
					for _, egg in ipairs(eggsOnBelt) do
						if table.find(selectedEggName, egg.name) and table.find(selectedMutName, egg.mutate) then
							pcall(function() CharacterRE:FireServer("BuyEgg", egg.fullname) end)
						end
					end
                    task.wait(0.3)
                end
            end)
        end
	end
}, "AutoBuyEToggle")

-----------------------------------------------------------
-- FRUIT TAB
-----------------------------------------------------------
for _, v in ipairs(Menu.data.fruits) do
	table.insert(fruitOptions, v.name)
end

local FruitDropdown = Menu.tabs.fruit.left1:Dropdown({
	Name = "Fruit List",
	Search = true,
	Multi = true,
	Required = false,
	Options = fruitOptions,
	Default = {  },
	Callback = function(Value)
		selectedFruits = {}
		local nameFruits = {}
		for v, State in next, Value do
			if State then
				for _, fruitData in ipairs(Menu.data.fruits) do
                    if fruitData.name == v then
                        table.insert(selectedFruits, fruitData.fullname)
						table.insert(nameFruits, fruitData.name)
                        break
                    end
                end
			end
		end
	end
}, "FruitDropdown")

-- Auto Buy Fruit Toggle
local AutoBuyFToggle = Menu.tabs.fruit.left1:Toggle({
    Name = "AutoBuy",
    Default = false,
    Callback = function(stage)
        autoBuyFruit = stage

        if stage then
            Window:Notify({ Title = "AutoBuy", Description = "Started", Lifetime = 2 })
            task.spawn(function()
                while autoBuyFruit do
                    local ScrollingFrame = player.PlayerGui.ScreenFoodStore.Root.Frame.ScrollingFrame
                    if ScrollingFrame then
                        for _, fruit in pairs(selectedFruits) do
                            if not autoBuyFruit then break end
                            local fruitFrame = ScrollingFrame:FindFirstChild(fruit)
                            if fruitFrame then
                                local itemButton = fruitFrame:FindFirstChild("ItemButton")
                                if itemButton then
                                    local stockLabel = itemButton:FindFirstChild("StockLabel")
                                    if stockLabel and stockLabel.Text ~= "No Stock" then
                                        pcall(function() FoodStoreRE:FireServer(fruit) end)
                                        task.wait(0.1)
                                        pcall(function() CharacterRE:FireServer("Focus") end)
                                    end
                                end
                            end
                        end
                    end
                    task.wait(0.1)
                end
            end)
        end
    end
}, "AutoBuyFToggle")

-----------------------------------------------------------
-- DUPE TAB
-----------------------------------------------------------
Menu.tabs.dupe.dupeSec1:Button({
	Name = "Start Dupe",
	Callback = function()

		getAllEggOnBelt()

	end
})

-----------------------------------------------------------
-- AUTOFARM TAB
-----------------------------------------------------------
-- AutoFarm Toggle
local AutoFarmToggle = Menu.tabs.auto.autoSec1:Toggle({
	Name = "AutoFarm",
	Default = false,
	Callback = function(state)
		autofarm = state

		if state then
			Window:Notify({ Title = "AutoFarm", Description = "Started", Lifetime = 2 })
			task.spawn(function()
				while autofarm do
					local Pets = workspace:FindFirstChild("Pets")
					if Pets then
						for _, pet in pairs(Pets:GetChildren()) do
							if not autofarm then break end
							local petOwner = pet:GetAttribute("UserId")
							if petOwner == player.UserId then
								local root = pet:FindFirstChild("RootPart")
								if root then
									local RF = root:FindFirstChild("RF")
									if RF and RF:IsA("RemoteFunction") then
										pcall(function() RF:InvokeServer("Claim") end)
									elseif root:FindFirstChild("RE") and root.RE:IsA("RemoteEvent") then
										pcall(function() root.RE:FireServer("Claim") end)
									end
								end
							end
						end
					end
					task.wait(30)
				end
				Window:Notify({ Title = "AutoFarm", Description = "Stopped", Lifetime = 2 })
			end)
		else
			Window:Notify({ Title = "AutoFarm", Description = "Disabled", Lifetime = 2 })
		end
	end
}, "AutoFarmToggle")

-----------------------------------------------------------
-- MISC TAB
-----------------------------------------------------------

local tasksFrame = player:WaitForChild("PlayerGui"):WaitForChild("ScreenDino")
                         :WaitForChild("Root"):WaitForChild("TasksFrame")
                         :WaitForChild("Frame"):WaitForChild("ScrollingFrame")
local autoClaim = false

Menu.tabs.misc.miscSec1:Toggle({
    Name = "Auto Claim Events (EXPERIMENTAL)",
    Default = false,
    Callback = function(enabled)
        autoClaim = enabled
        print("[DEBUG] Auto Claim Events toggled:", enabled)

        if enabled then
            task.spawn(function()
                while autoClaim do
                    local claimed = false
                    for _, taskItem in ipairs(tasksFrame:GetChildren()) do
                        local claimBtn = taskItem:FindFirstChild("ClaimButton")
                        if claimBtn and claimBtn.Visible then
                            print("[DEBUG] Claiming task:", taskItem.Name)

                            if claimBtn:IsA("TextButton") or claimBtn:IsA("ImageButton") then
                                claimBtn.MouseButton1Click:Fire()
                            end

                            claimed = true
                            break
                        end
                    end

                    if not claimed then
                        print("[DEBUG] No claimable tasks found this loop.")
                    end

                    task.wait(0.5)
                end
                print("[DEBUG] Auto Claim loop stopped.")
            end)
        else
            print("[DEBUG] Auto Claim disabled.")
        end
    end,
}, "AutoClaimEventsToggle")

-----------------------------------------------------------
-- SETTING TAB
-----------------------------------------------------------

Menu.tabs.setting.settingSec2:Keybind({
	Name = "Set Key Bind",
	onBinded = function(bind)
		Menu.system.keyBind = bind or Enum.KeyCode.K
		Window:Notify({
			Title = "Pizza Hub",
			Description = "Rebinded Reset Key Bind to " .. tostring(Menu.system.keyBind),
			Lifetime = 3
		})
	end,
}, "ResetKeyBind")

Menu.tabs.setting.settingSec2:Button({
	Name = "Kill Menu",
	Callback = function()
		Window:Unload()
	end,
})

-----------------------------------------------------------
-- ANTI-AFK
-----------------------------------------------------------
task.spawn(function()
	while task.wait(240) do
		if player.Character and player.Character:FindFirstChild("Humanoid") then
			player.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
		end
	end
end)

player.Idled:Connect(function()
	pcall(function()
		VirtualUser:CaptureController()
		VirtualUser:ClickButton2(Vector2.new())
	end)
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if input.KeyCode == Menu.system.keyBind then
		menuVisible = not menuVisible
		pcall(function() Window:SetState(menuVisible) end)
	end
end)

player.CharacterAdded:Connect(function(char)
	Menu.playerData.humanoidRootPart = char:WaitForChild("HumanoidRootPart")
end)

RefreshPlayers()

MacLib:LoadAutoLoadConfig()
