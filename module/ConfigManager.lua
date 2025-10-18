-- // ConfigManager.lua
local HttpService = game:GetService("HttpService")
local ConfigManager = {}
ConfigManager.__index = ConfigManager

-----------------------------------------------------
-- 🗂️ INTERNAL HELPERS
-----------------------------------------------------
local function ensureFolder(path)
    if type(path) ~= "string" then
        warn("[ConfigManager] ensureFolder expected string, got " .. typeof(path))
        return
    end

    if not isfolder or not makefolder then
        return
    end

    path = path:gsub("\\", "/")
    local parts = string.split(path, "/")
    local current = ""

    for _, part in ipairs(parts) do
        if part ~= "" then
            current = (current == "") and part or (current .. "/" .. part)
            if not isfolder(current) then
                makefolder(current)
            end
        end
    end
end

local function getFileNameOnly(path)
	return path:match("([^/\\]+)%.json$")
end

-----------------------------------------------------
-- 🧠 CREATE NEW MANAGER
-----------------------------------------------------
function ConfigManager.new(defaults, folderPath, fileName)
	folderPath = folderPath or "configs"
	fileName = fileName or "default.json"

	ensureFolder(folderPath)

	local self = setmetatable({}, ConfigManager)
	self.defaults = defaults or {}
	self.folderPath = folderPath
	self.fileName = fileName
	self.filePath = self.folderPath .. "/" .. self.fileName
	self.config = {}

	self:Load()
	return self
end

-----------------------------------------------------
-- 📖 LOAD / SAVE
-----------------------------------------------------
function ConfigManager:Load()
	if isfile(self.filePath) then
		local success, data = pcall(function()
			return HttpService:JSONDecode(readfile(self.filePath))
		end)
		if success and type(data) == "table" then
			self.config = self:Merge(self.defaults, data)
		else
			self.config = self.defaults
		end
	else
		self.config = self.defaults
		self:Save()
	end
end

function ConfigManager:Save()
	ensureFolder(self.folderPath)
	writefile(self.filePath, HttpService:JSONEncode(self.config))
end

-----------------------------------------------------
-- 🔁 MERGE DEFAULTS
-----------------------------------------------------
function ConfigManager:Merge(defaults, loaded)
	local result = {}
	for k, v in pairs(defaults) do
		if type(v) == "table" then
			result[k] = self:Merge(v, loaded[k] or {})
		else
			result[k] = loaded[k] or v
		end
	end
	for k, v in pairs(loaded) do
		if result[k] == nil then
			result[k] = v
		end
	end
	return result
end

-----------------------------------------------------
-- ⚙️ GET / SET VALUE
-----------------------------------------------------
function ConfigManager:Get(path)
	local parts = string.split(path, ".")
	local value = self.config
	for _, part in ipairs(parts) do
		if type(value) ~= "table" then return nil end
		value = value[part]
	end
	return value
end

function ConfigManager:Set(path, value)
	local parts = string.split(path, ".")
	local tbl = self.config
	for i = 1, #parts - 1 do
		local key = parts[i]
		tbl[key] = tbl[key] or {}
		tbl = tbl[key]
	end
	tbl[parts[#parts]] = value
end

-----------------------------------------------------
-- 🧩 LIST VALUE SUPPORT
-----------------------------------------------------
function ConfigManager:SetList(path, list)
	if type(list) ~= "table" then
		error("Expected table for SetList(path, list)")
	end
	self:Set(path, list)
end

function ConfigManager:GetList(path)
	local value = self:Get(path)
	if type(value) ~= "table" then
		return {}
	end
	return value
end

-----------------------------------------------------
-- 📂 MULTI-CONFIG MANAGEMENT
-----------------------------------------------------
function ConfigManager.ListConfigs(folderPath)
	folderPath = folderPath or "configs"
	ensureFolder(folderPath)

	local files = listfiles(folderPath)
	local names = {}
	for _, file in ipairs(files) do
		if file:match("%.json$") then
			table.insert(names, getFileNameOnly(file))
		end
	end
	return names
end

function ConfigManager.CreateConfig(folderPath, name)
	folderPath = folderPath or "configs"
	ensureFolder(folderPath)
	local path = folderPath .. "/" .. name .. ".json"
	if not isfile(path) then
		writefile(path, HttpService:JSONEncode({}))
	end
end

function ConfigManager.DeleteConfig(folderPath, name)
	folderPath = folderPath or "configs"
	local path = folderPath .. "/" .. name .. ".json"
	if isfile(path) then
		delfile(path)
	end
end

function ConfigManager.LoadConfig(defaults, folderPath, name)
	local manager = ConfigManager.new(defaults, folderPath, name .. ".json")
	manager:Load()
	return manager
end

-----------------------------------------------------
-- ✅ SAVE CHANGES IMMEDIATELY
-----------------------------------------------------
function ConfigManager:SetAndSave(path, value)
	self:Set(path, value)
	self:Save()
end

function ConfigManager:SetListAndSave(path, list)
	self:SetList(path, list)
	self:Save()
end

return ConfigManager