-- ConfigService: wrapper around ConfigManager for centralized config handling
local HttpService = game:GetService("HttpService")
local function safeLoad(url)
    local ok, result = pcall(function()
        local body = game:HttpGet(url)
        local fn, err = loadstring(body)
        if not fn then error("compile error: " .. tostring(err)) end
        return fn()
    end)
    if not ok then
        warn("[safeLoad] failed to load:", url, result)
        return nil
    end
    return result
end

local ConfigManager = safeLoad("https://raw.githubusercontent.com/space-bar-pixel/5ajuneuxf/main/module/ConfigManager.lua")
if not ConfigManager then
    error("Critical: ConfigManager failed to load; config system unavailable")
end

local ConfigService = {}
ConfigService.__index = ConfigService

-- Create a new service for a user
-- optional second parameter: maclib instance to integrate with MacLib config UI
function ConfigService.new(userName, maclib)
    local self = setmetatable({}, ConfigService)
    self.userName = tostring(userName or "Unknown")
    -- configDir holds programmatic config files (ConfigManager)
    self.configDir = "PizzaHub/" .. self.userName .. "/configs"
    -- maclibFolder is the folder MacLib expects (it will use /settings under this folder)
    self.maclibFolder = "PizzaHub/" .. self.userName
    self.managers = {} -- registry: name -> ConfigManager instance
    self.activeName = "default"
    self.maclib = maclib

    -- if maclib provided, set its folder to our user folder so UI configs live with program configs
    if self.maclib and type(self.maclib.SetFolder) == "function" then
        pcall(function() self.maclib:SetFolder(self.maclibFolder) end)
    end

    return self
end

-- Ensure folder exists (ConfigManager uses ensureFolder internally but we may list files)
local function ensureFolderExists(path)                                                                                                                     
    if type(path) ~= "string" then return end
    if not isfolder or not makefolder then return end
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

-- List available config names
function ConfigService:List()
    -- Prefer MacLib's config list when available
    if self.maclib and type(self.maclib.RefreshConfigList) == "function" then
        local ok, list = pcall(function() return self.maclib:RefreshConfigList() end)
        if ok and type(list) == "table" then
            table.sort(list)
            return list
        end
    end

    ensureFolderExists(self.configDir)
    local files = (isfolder and listfiles and isfolder(self.configDir) and listfiles(self.configDir)) or {}
    local names = {}
    for _, file in ipairs(files) do
        if file:match("%.json$") then
            table.insert(names, file:match("([^/]+)%.json$"))
        end
    end
    table.sort(names)
    return names
end

-- Create an empty config file
function ConfigService:Create(name)
    name = tostring(name or self.activeName)

    -- create using MacLib if available
    if self.maclib and self.maclibFolder and isfile and writefile then
        ensureFolderExists(self.maclibFolder .. "/settings")
        local macPath = self.maclibFolder .. "/settings/" .. name .. ".json"
        if not isfile(macPath) then
            writefile(macPath, HttpService:JSONEncode({}))
        end
    end

    ensureFolderExists(self.configDir)
    local path = self.configDir .. "/" .. name .. ".json"
    if not isfile(path) then
        writefile(path, HttpService:JSONEncode({}))
    end

    -- remove any cached manager so next Get will reload
    self.managers[name] = nil
end

-- Delete a config file
function ConfigService:Delete(name)
    name = tostring(name or self.activeName)

    -- remove maclib setting if present
    if self.maclib and self.maclibFolder and delfile then
        local macPath = self.maclibFolder .. "/settings/" .. name .. ".json"
        if isfile(macPath) then
            pcall(function() delfile(macPath) end)
        end
    end

    local path = self.configDir .. "/" .. name .. ".json"
    if isfile(path) then
        pcall(function() delfile(path) end)
    end
    self.managers[name] = nil
end

-- Get (or create) a manager for a given name; defaults is optional
function ConfigService:Get(name, defaults)
    name = tostring(name or self.activeName)
    if self.managers[name] then return self.managers[name] end
    ensureFolderExists(self.configDir)
    local fileName = name .. ".json"
    local mgr = ConfigManager.new(defaults or {}, self.configDir, fileName)
    mgr:Load()
    self.managers[name] = mgr
    return mgr
end

-- Save MacLib UI options to the maclib settings (if available)
function ConfigService:SaveActiveToMacLib()
    if not (self.maclib and type(self.maclib.SaveConfig) == "function") then
        return false, "MacLib not available"
    end
    return pcall(function() return self.maclib:SaveConfig(self.activeName) end)
end

-- Load MacLib UI options from maclib settings (if available)
function ConfigService:LoadActiveFromMacLib()
    if not (self.maclib and type(self.maclib.LoadConfig) == "function") then
        return false, "MacLib not available"
    end
    return pcall(function() return self.maclib:LoadConfig(self.activeName) end)
end

-- Refresh MacLib config list (if available)
function ConfigService:RefreshMacList()
    if not (self.maclib and type(self.maclib.RefreshConfigList) == "function") then
        return {}
    end
    local ok, list = pcall(function() return self.maclib:RefreshConfigList() end)
    if ok and type(list) == "table" then return list end
    return {}
end

-- Set and return active config name
function ConfigService:SetActive(name)
    self.activeName = tostring(name or self.activeName)
    return self.activeName
end

function ConfigService:GetActive()
    return self:Get(self.activeName)
end

function ConfigService:InitActive(defaults)
    return self:Get(self.activeName, defaults)
end

function ConfigService:SaveActive()
    local mgr = self.managers[self.activeName]
    if mgr then mgr:Save() end
end

return ConfigService
