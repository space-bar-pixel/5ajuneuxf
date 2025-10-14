-- ConfigManager (ModuleScript)
local HttpService = game:GetService("HttpService")
local ConfigManager = {}
ConfigManager.__index = ConfigManager

-- default values injected
function ConfigManager.new(defaults, fileName)
    local self = setmetatable({}, ConfigManager)
    self.defaults = defaults or {}
    self.fileName = fileName or "config.json"
    self.config = {} -- loaded values
    return self
end

-- Load config from file or fallback to defaults
function ConfigManager:Load()
    if isfile(self.fileName) then
        local success, data = pcall(function()
            return HttpService:JSONDecode(readfile(self.fileName))
        end)
        if success and type(data) == "table" then
            self.config = self:Merge(self.defaults, data)
        else
            self.config = self.defaults
        end
    else
        self.config = self.defaults
    end
end

-- Save current config to file
function ConfigManager:Save()
    writefile(self.fileName, HttpService:JSONEncode(self.config))
end

-- Recursive merge defaults with loaded data
function ConfigManager:Merge(defaults, loaded)
    local result = {}
    for k,v in pairs(defaults) do
        if type(v) == "table" then
            result[k] = self:Merge(v, loaded[k] or {})
        else
            result[k] = loaded[k] or v
        end
    end
    -- Add any extra keys in loaded config
    for k,v in pairs(loaded) do
        if result[k] == nil then result[k] = v end
    end
    return result
end

-- Get value
function ConfigManager:Get(path)
    local parts = string.split(path, ".")
    local value = self.config
    for _, part in ipairs(parts) do
        if type(value) ~= "table" then return nil end
        value = value[part]
    end
    return value
end

-- Set value
function ConfigManager:Set(path, value)
    local parts = string.split(path, ".")
    local tbl = self.config
    for i = 1, #parts-1 do
        local key = parts[i]
        tbl[key] = tbl[key] or {}
        tbl = tbl[key]
    end
    tbl[parts[#parts]] = value
end

return ConfigManager
