local MacLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/space-bar-pixel/5ajuneuxf/refs/heads/main/module/maclib.lua"))()
local ConfigManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/space-bar-pixel/5ajuneuxf/refs/heads/main/module/ConfigManager.lua"))()
local Helpers = loadstring(game:HttpGet("https://raw.githubusercontent.com/space-bar-pixel/5ajuneuxf/refs/heads/main/module/Helpers.lua"))()
local Data = loadstring(game:HttpGet("https://raw.githubusercontent.com/space-bar-pixel/5ajuneuxf/refs/heads/main/module/Data.lua"))()
local Gift = loadstring(game:HttpGet("https://raw.githubusercontent.com/space-bar-pixel/5ajuneuxf/refs/heads/main/module/Gift.lua"))()
local Dupe = loadstring(game:HttpGet("https://raw.githubusercontent.com/space-bar-pixel/5ajuneuxf/refs/heads/main/module/Dupe.lua"))()

-- Load GiftFeature and mount it (feature owns Start/Pause/Cancel now)
local GiftFeature = loadstring(game:HttpGet("https://raw.githubusercontent.com/space-bar-pixel/5ajuneuxf/refs/heads/main/module/Features/GiftFeature.lua"))()
local giftMount = GiftFeature.mount({
	sections = { left2 = Menu.tabs.main.left2, main = { left2 = Menu.tabs.main.left2 } },
	services = { Players = Players, Window = Window, remoteService = remoteService, Data = Menu.data },
	state = State,
})


local menuVisible = true

local autofarmThread
local plantThread

-- MENU FUNC
local function GetEggsInv()
    local scrollingFrame = player.PlayerGui:WaitForChild("ScreenStorage"):WaitForChild("Frame")
        :WaitForChild("Content"):FindFirstChild("ScrollingFrame")
    local eggs = {}
    if not scrollingFrame then
        warn("No ScrollingFrame found in egg inventory UI.")
        return eggs
    end

    for _, item in ipairs(scrollingFrame:GetChildren()) do
        local btn = item:FindFirstChild("BTN")
        if btn then
            local stat = btn:FindFirstChild("Stat")
            local mutsFolder = btn:FindFirstChild("Muts")

            local eggName = "Unknown"
            if stat and stat:FindFirstChild("NAME") then
                local nameContainer = stat.NAME
                local valueLabel = nameContainer:FindFirstChild("Value")
                if valueLabel and valueLabel:IsA("TextLabel") then
                    eggName = valueLabel.Text ~= "" and valueLabel.Text or "Unknown"
                end
            end

            local visibleMut = nil
            if mutsFolder then
                for _, mut in ipairs(mutsFolder:GetChildren()) do
                    if mut:IsA("GuiObject") and mut.Visible then
                        visibleMut = mut.Name
						-- Gift UI is now owned by GiftFeature (Start/Pause/Cancel and status label)
	Menu.tabs.main.left2:Input({
		Name = fruit.name,
		Placeholder = "                   ",
		AcceptedCharacters = "Numeric",
		Callback = function(val)
			State.fruitAmounts[fruit.fullname] = val
		end
	})
end

-- Counters (right side)
local givenLabel = Menu.tabs.main.left2:Label({ Text = "Given: 0                                             Left: 0" })

-- Start Gift Loop button
Menu.tabs.main.left2:Button({
	Name = "Start Gift Loop",
	Callback = function()
	local playerName = State.selectedPlayerName
		if not playerName or playerName == "" then
			Window:Notify({ Title = "Error", Description = "Please select a player.", Lifetime = 3 })
			return
		end

		if isRunning then
			Window:Notify({ Title = "Busy", Description = "Gift loop already running.", Lifetime = 3 })
			return
		end

	local queue = Gift.buildQueue(Menu.data.fruits, State.fruitAmounts)
		if #queue == 0 then
			Window:Notify({ Title = "Error", Description = "No fruits selected!", Lifetime = 3 })
			return
		end

		isRunning = true
		isPaused = false
		runId += 1
		local myId = runId

		task.spawn(function()
			local ok, result = pcall(function()
				local success, givenOrErr = Gift.sendQueue(queue, playerName, Players, Window, remoteService)
				if success then
					Window:Notify({ Title = "Done!", Description = "Gift loop finished.", Lifetime = 4 })
				end
				return success, givenOrErr
			end)
			if not ok then
				Window:Notify({ Title = "Error", Description = "Gift loop failed.", Lifetime = 4 })
			end
			isRunning = false
			isPaused = false
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
		State.selectedEggName = {}
		table.insert(State.selectedEggName, v)
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
		State.selectedMutName = {}
		table.insert(State.selectedMutName, v)
		Window:Notify({ Title = "Selected", Description = "Selected" .. v .. " Eggs!", Lifetime = 3 })
	end
})

-- Input box for total to give
local totalInput = Menu.tabs.main.right:Input({
	Name = "Total",
	Placeholder = "Enter total",
	AcceptedCharacters = "Numeric",
	Callback = function(Value)
		-- store as number when possible
		State.totalToGive = tonumber(Value) or 0
	end
})
-- Start Give Loop button
local dupeLabel = Menu.tabs.main.right:Label({ Text = "Given: 0                                             Left: 0" })


-- Mount Dupe feature (encapsulates execute dupe and related buttons)
local DupeFeature = loadstring(game:HttpGet("https://raw.githubusercontent.com/space-bar-pixel/5ajuneuxf/refs/heads/main/module/Features/DupeFeature.lua"))()
local dupeMount = DupeFeature.mount({
	sections = { dupeSec1 = Menu.tabs.dupe.dupeSec1, main = { right = Menu.tabs.main.right }, dupe = Menu.tabs.main.right },
	services = { Players = Players, Window = Window, remoteService = remoteService },
	state = State
})


-- Pause / Resume
-- Dupe feature provides Pause/Resume and Cancel controls now (owned by Features/DupeFeature.lua)

-----------------------------------------------------------
-- AUTOFARM TAB
-----------------------------------------------------------
local AutoFarmToggle = Menu.tabs.auto.autoSec1:Toggle({
    Name = "AutoFarm",
    Default = Config:Get("AutoFarm.Enabled") or false,
    Callback = function(state)
        Config:SetAndSave("AutoFarm.Enabled", state)
        autofarm = state
        if state then
            Window:Notify({ Title = "AutoFarm", Description = "Started", Lifetime = 2 })
            task.spawn(function()
                while autofarm do
                    local Pets = workspace:FindFirstChild("Pets")
                    if Pets then
                        for _, pet in pairs(Pets:GetChildren()) do
                            if not autofarm then break end
                            if pet:GetAttribute("UserId") == player.UserId then
                                local root = pet:FindFirstChild("RootPart")
                                local RF = root and root:FindFirstChild("RF")
                                local RE = root and root:FindFirstChild("RE")
                                if RF and RF:IsA("RemoteFunction") then pcall(function() RF:InvokeServer("Claim") end)
                                elseif RE and RE:IsA("RemoteEvent") then pcall(function() RE:FireServer("Claim") end)
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
})

-----------------------------------------------------------
-- EGG TAB
----------------------------------------------------------
local function updatePlantStatus()
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


-- === Egg Dropdown ===
local EggDropdown2 = Menu.tabs.egg.left1:Dropdown({
    Name = "Eggs List",
    Search = true,
    Multi = true,
    Required = true,
    Options = eggOptions,
    Default = Config:GetList("PlantEggs.SelectedEggs"),
    Callback = function(Value)
		State.selectedEggName = {}
		for v, S in next, Value do if S then table.insert(State.selectedEggName, v) end end
		Config:SetListAndSave("PlantEggs.SelectedEggs", State.selectedEggName)
    end
})

local MutsDropdown2 = Menu.tabs.egg.left1:Dropdown({
    Name = "Mutation List",
    Search = true,
    Multi = true,
    Required = true,
    Options = Menu.data.muts,
    Default = Config:GetList("PlantEggs.SelectedMuts"),
    Callback = function(Value)
		State.selectedMutName = {}
		for v, S in next, Value do if S then table.insert(State.selectedMutName, v) end end
		Config:SetListAndSave("PlantEggs.SelectedMuts", State.selectedMutName)
    end
})

-- === Plant All Eggs Toggle ===
local AutoPlantsToggle = Menu.tabs.egg.left1:Toggle({
    Name = "Plant All Eggs",
    Default = Config:Get("PlantEggs.Enabled") or false,
    Callback = function(s)
        plantStage = s
        Config:SetAndSave("PlantEggs.Enabled", s)

        if plantStage then
            plantThread = task.spawn(function()
                while plantStage do
                    updatePlantStatus()
                    Menu.data.EggInventory = GetEggsInv()
                    -- validation
					if (not State.selectedEggName or #State.selectedEggName == 0 or not State.selectedMutName or #State.selectedMutName == 0) then
                        Window:Notify({ Title = "Error", Description = "Select at least one egg and mutation!", Lifetime = 3 })
                        return
                    end
                    -- queue logic
                    local queue = {}
                    for _, egg in ipairs(Menu.data.EggInventory) do
						for _, n in ipairs(State.selectedEggName) do
							for _, m in ipairs(State.selectedMutName) do
                                if egg.name == n and egg.mutation == m then
                                    table.insert(queue, egg.id)
                                end
                            end
                        end
                    end
                    -- plant eggs
                    local islandData = Menu.data.plants[tostring(islandName)]
                    local plants = islandData and islandData.mountain
                    if plants and #queue > 0 then
                        local eggIndex = 1
                        for _, plant in ipairs(plants) do
                            if not plantStage then break end
                            if plant.empty and eggIndex <= #queue then
                                local pos = strToVector3(plant.coord)
                                local eggId = queue[eggIndex]
                                -- player.Character.HumanoidRootPart.CFrame = CFrame.new(pos + Vector3.new(0, 5, 0))
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
                    end
                    task.wait(2)
                end
            end)
        else
            plantStage = false
            Window:Notify({ Title = "Stopped", Description = "Stopped planting eggs.", Lifetime = 3 })
        end
    end
})


Menu.tabs.egg.left1:Button({
	Name = "Hatch All Eggs",
	Callback = function()
		for _, block in ipairs(PlayerBuiltBlocks:GetChildren()) do
			local root = block:FindFirstChild("RootPart")
			if root then
				local prompt = root:FindFirstChildOfClass("ProximityPrompt")
				if prompt then
					task.spawn(function()
						fireproximityprompt(prompt, 1) 
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
    Options = eggOptions,
    Default = Config:GetList("Eggs.Selected"),
    Callback = function(Value)
		State.selectedEggName = {}
		for v, S in next, Value do if S then table.insert(State.selectedEggName, v) end end
		Config:SetListAndSave("Eggs.Selected", State.selectedEggName)
    end
})

local MutsDropdown3 = Menu.tabs.egg.right1:Dropdown({
    Name = "Mutation List",
    Search = true,
    Multi = true,
    Options = Menu.data.muts,
    Default = Config:GetList("Mutations.Selected"),
    Callback = function(Value)
		State.selectedMutName = {}
		for v, S in next, Value do if S then table.insert(State.selectedMutName, v) end end
		Config:SetListAndSave("Mutations.Selected", State.selectedMutName)
    end
})

local AutoBuyEToggle = Menu.tabs.egg.right1:Toggle({
    Name = "Automatic buy",
    Default = Config:Get("Eggs.AutoBuy") or false,
    Callback = function(state)
        Config:SetAndSave("Eggs.AutoBuy", state)
        autoBuyEggs = state
        if state then
            task.spawn(function()
                while autoBuyEggs do
                    local eggsOnBelt = getAllEggOnBelt()
					for _, egg in ipairs(eggsOnBelt) do
						if table.find(State.selectedEggName, egg.name) and table.find(State.selectedMutName, egg.mutate) then
							pcall(function() CharacterRE:FireServer("BuyEgg", egg.fullname) end)
						end
					end
                    task.wait(0.3)
                end
            end)
        end
    end
})

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
    Options = fruitOptions,
    Default = Config:GetList("Fruit.Selected"),
	Callback = function(Value)
		State.selectedFruits = {}
		local nameFruits = {}
		for v, S in next, Value do
			if S then
				for _, f in ipairs(Menu.data.fruits) do
					if f.name == v then
						table.insert(State.selectedFruits, f.fullname)
						table.insert(nameFruits, f.name)
						break
					end
				end
			end
		end
		Config:SetListAndSave("Fruit.Selected", nameFruits)
	end
})

local AutoBuyFToggle = Menu.tabs.fruit.left1:Toggle({
    Name = "AutoBuy",
    Default = Config:Get("Fruit.AutoBuy") or false,
    Callback = function(stage)
        Config:SetAndSave("Fruit.AutoBuy", stage)
        autoBuyFruit = stage
        if stage then
            Window:Notify({ Title = "AutoBuy", Description = "Started", Lifetime = 2 })
            task.spawn(function()
                while autoBuyFruit do
                    local ScrollingFrame = player.PlayerGui.ScreenFoodStore.Root.Frame.ScrollingFrame
                    if ScrollingFrame then
                        for _, fruit in ipairs(selectedFruits) do
                            if not autoBuyFruit then break end
                            local fruitFrame = ScrollingFrame:FindFirstChild(fruit)
                            if fruitFrame then
                                local itemButton = fruitFrame:FindFirstChild("ItemButton")
                                local stockLabel = itemButton and itemButton:FindFirstChild("StockLabel")
                                if stockLabel and stockLabel.Text ~= "No Stock" then
                                    pcall(function() FoodStoreRE:FireServer(fruit) end)
                                    task.wait(0.1)
                                    pcall(function() CharacterRE:FireServer("Focus") end)
                                end
                            end
                        end
                    end
                    task.wait(1)
                end
            end)
        end
    end
})

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
-- SETTING TAB
-----------------------------------------------------------
-- === Function to load config into UI ===
local UIConfigMap = {
    -- Egg tab left
    [EggDropdown2] = "PlantEggs.SelectedEggs",
    [MutsDropdown2] = "PlantEggs.SelectedMuts",
    [AutoPlantsToggle] = "PlantEggs.Enabled",

    -- Egg tab right
    [EggDropdown3] = "Eggs.Selected",
    [MutsDropdown3] = "Mutations.Selected",
    [AutoBuyEToggle] = "Eggs.AutoBuy",

    -- Fruit tab
    [FruitDropdown] = "Fruit.Selected",
    [AutoBuyFToggle] = "Fruit.AutoBuy",

    -- AutoFarm tab
    [AutoFarmToggle] = "AutoFarm.Enabled",
}

local function LoadConfigToUI()
    for ui, path in pairs(UIConfigMap) do
        if ui.UpdateState then
            local value = Config:Get(path)
            if value ~= nil then
                ui:UpdateState(value)
            end
        elseif ui.UpdateSelection then
            local value = Config:GetList(path)
            ui:UpdateSelection(value)
        end
    end
end

local ConfigSelect = Menu.tabs.setting.settingSec1:Dropdown({
    Name = "Select Config",
    Search = true,
    Multi = false,
    Options = listConfigs(),
    Default = { "" },
    Callback = function(selected)
        ACTIVE_CONFIG = selected
        Config = ConfigManager.LoadConfig(Config.defaults, Config.folderPath, selected)
        LoadConfigToUI()
        print("[Config] Active set to:", selected)
    end
})

local function updateDropdownOptions()
	ConfigSelect:ClearOptions()
	local configs = ConfigManager.ListConfigs(Config.folderPath)
	ConfigSelect:InsertOptions(configs)
end

local function loadConfigByName(name)
	if not name or name == "" then return end
	ACTIVE_CONFIG = name
	Config = ConfigManager.LoadConfig(Config.defaults, Config.folderPath, ACTIVE_CONFIG)
	LoadConfigToUI()
	if ConfigSelect and ConfigSelect.UpdateSelection then
		ConfigSelect:UpdateSelection(ACTIVE_CONFIG)
	end
end

local ConfigInput = Menu.tabs.setting.settingSec1:Input({
	Name = "Create Config->",
	Placeholder = "Config Name",
	AcceptedCharacters = "AlphaNumeric",
	Callback = function(input)
		local newName = tostring(input)
		if newName == "" then
			Window:Notify({ Title = "Create Config", Description = "[Config] Please set a config name", Lifetime = 2 })
			return
		end
		if table.find(ConfigManager.ListConfigs(Config.folderPath), newName) then
			Window:Notify({ Title = "Create Config", Description = "[Config] Config already exists: " .. newName, Lifetime = 2 })
			return
		end

		-- Create and load
		ConfigManager.CreateConfig(Config.folderPath, newName)
		loadConfigByName(newName)

		updateDropdownOptions()
		Window:Notify({ Title = "Create Config", Description = "[Config] Created and loaded: " .. newName, Lifetime = 2 })
	end
})


-- Save current config
Menu.tabs.setting.settingSec1:Button({
	Name = "Save Config",
	Callback = function()
		if ACTIVE_CONFIG then
			Config:Save()
			Window:Notify({ Title = "Save Config", Description = "[Config] Saved: " .. ACTIVE_CONFIG, Lifetime = 2 })
		else
			Window:Notify({ Title = "Save Config", Description = "[Config] No active config selected!", Lifetime = 2 })
		end
	end
})

-- Delete selected config
Menu.tabs.setting.settingSec1:Button({
	Name = "Delete Config",
	Callback = function()
		if ACTIVE_CONFIG then
			ConfigManager.DeleteConfig(Config.folderPath, ACTIVE_CONFIG)
			updateDropdownOptions()
			Window:Notify({ Title = "Delete Config", Description = "[Config] Deleted: " .. ACTIVE_CONFIG, Lifetime = 2 })

			local configs = ConfigManager.ListConfigs(Config.folderPath)
			if #configs > 0 then
				loadConfigByName(configs[1])
			else
				ACTIVE_CONFIG = nil
			end
		else
			Window:Notify({ Title = "Delete Config", Description = "[Config] No active config selected!", Lifetime = 2 })
		end
	end
})

Menu.tabs.setting.settingSec1:Button({
	Name = "Refetch Config List",
	Callback = function()
		updateDropdownOptions()
	end
})

Menu.tabs.setting.settingSec3:Keybind({
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

Menu.tabs.setting.settingSec3:Button({
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