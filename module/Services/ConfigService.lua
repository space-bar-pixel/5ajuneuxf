-- ConfigService: wrapper around ConfigManager for centralized config handling
local HttpService = game:GetService("HttpService")
local ConfigManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/space-bar-pixel/5ajuneuxf/refs/heads/main/module/ConfigManager.lua"))()

local ConfigService = {}
ConfigService.__index = ConfigService

-- Create a new service for a user
function ConfigService.new(userName)
    local self = setmetatable({}, ConfigService)
    self.userName = tostring(userName or "Unknown")
    self.configDir = "PizzaHub/" .. self.userName .. "/configs"
    self.managers = {} -- registry: name -> ConfigManager instance
    self.activeName = "default"
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
    ensureFolderExists(self.configDir)
    local files = listfiles(self.configDir)
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
    local path = self.configDir .. "/" .. name .. ".json"
    if isfile(path) then
        delfile(path)
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
