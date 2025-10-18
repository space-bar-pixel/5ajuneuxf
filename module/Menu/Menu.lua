-- Minimal Menu builder that mirrors the previous inline UI creation
local Menu = {}

function Menu.new(opts)
    local MacLib = opts.MacLib
    local window = MacLib:Window({
        Title = opts.Title or "Pizza Hub",
        Subtitle = opts.Subtitle or "",
        Size = opts.Size or UDim2.fromOffset(868, 650),
        DragStyle = opts.DragStyle or 1,
        DisabledWindowControls = opts.DisabledWindowControls or {},
        ShowUserInfo = opts.ShowUserInfo or true,
        Keybind = opts.Keybind or Enum.KeyCode.RightControl,
        AcrylicBlur = opts.AcrylicBlur
    })

    -- Create main groups and tabs/sections (match names used by test.lua)
    local MainGroup = window:TabGroup()
    local mainTab = MainGroup:Tab({ Name = "Main", Image = "" })
    local raw_mainSecLeft1 = mainTab:Section({ Side = "Left" })
    local raw_mainSecLeft2 = mainTab:Section({ Side = "Left" })
    local raw_mainSecRight = mainTab:Section({ Side = "Right" })
    local AutoTab = MainGroup:Tab({ Name = "AutoFarm", Image = "" })
    local autoSec1 = AutoTab:Section({ Side = "Left" })

    local SubGroup = window:TabGroup()
    local EggTab = SubGroup:Tab({ Name = "Egg", Image = "" })
    local FruitTab = SubGroup:Tab({ Name = "Fruit", Image = "" })
    local DupeTab = SubGroup:Tab({ Name = "Dupe", Image = "" })
    local raw_eggSec1 = EggTab:Section({ Side = "Left" })
    local raw_eggSec2 = EggTab:Section({ Side = "Right" })
    local raw_FruitSec1 = FruitTab:Section({ Side = "Left" })
    local raw_dupeSec1 = DupeTab:Section({ Side = "Left" })

    local SettingGroup = window:TabGroup()
    local Misc = SettingGroup:Tab({ Name = "Misc", Image = "" })
    local Setting = SettingGroup:Tab({ Name = "Setting", Image = "" })
    local raw_settingSec1 = Setting:Section({ Side = "Left" })
    local raw_settingSec2 = Setting:Section({ Side = "Left" })
    local raw_settingSec3 = Setting:Section({ Side = "Right" })

    -- wrap raw sections with our adapter
    local Section = loadstring(game:HttpGet("https://raw.githubusercontent.com/space-bar-pixel/5ajuneuxf/main/module/Menu/Section.lua"))()
    local mainSecLeft1 = Section.new(raw_mainSecLeft1)
    local mainSecLeft2 = Section.new(raw_mainSecLeft2)
    local mainSecRight = Section.new(raw_mainSecRight)
    local eggSec1 = Section.new(raw_eggSec1)
    local eggSec2 = Section.new(raw_eggSec2)
    local FruitSec1 = Section.new(raw_FruitSec1)
    local dupeSec1 = Section.new(raw_dupeSec1)
    local settingSec1 = Section.new(raw_settingSec1)
    local settingSec2 = Section.new(raw_settingSec2)
    local settingSec3 = Section.new(raw_settingSec3)

    local wrapper = {
        Window = window,
        MainGroup = MainGroup,
        mainTab = mainTab,
        mainSecLeft1 = mainSecLeft1,
        mainSecLeft2 = mainSecLeft2,
        mainSecRight = mainSecRight,
        AutoTab = AutoTab,
        autoSec1 = autoSec1,
        SubGroup = SubGroup,
        EggTab = EggTab,
        FruitTab = FruitTab,
        DupeTab = DupeTab,
        eggSec1 = eggSec1,
        eggSec2 = eggSec2,
        FruitSec1 = FruitSec1,
        dupeSec1 = dupeSec1,
        SettingGroup = SettingGroup,
        Misc = Misc,
        Setting = Setting,
        settingSec1 = settingSec1,
        settingSec2 = settingSec2,
        settingSec3 = settingSec3,
    }

    function wrapper:Destroy()
        pcall(function() window:Destroy() end)
    end

    return wrapper
end

return Menu
