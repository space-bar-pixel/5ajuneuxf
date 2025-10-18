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

local Button = safeLoad("https://raw.githubusercontent.com/space-bar-pixel/5ajuneuxf/main/module/Menu/Controls/Button.lua")
local Input = safeLoad("https://raw.githubusercontent.com/space-bar-pixel/5ajuneuxf/main/module/Menu/Controls/Input.lua")
local Slider = safeLoad("https://raw.githubusercontent.com/space-bar-pixel/5ajuneuxf/main/module/Menu/Controls/Slider.lua")
local Toggle = safeLoad("https://raw.githubusercontent.com/space-bar-pixel/5ajuneuxf/main/module/Menu/Controls/Toggle.lua")

-- Fallback minimal stubs when controls fail to load
local function makeStub()
    return {
        create = function() return { UpdateState = function() end, UpdateValue = function() end, UpdateText = function() end, UpdateName = function() end } end
    }
end
Toggle = Toggle or makeStub()
Input = Input or makeStub()
Button = Button or makeStub()
Slider = Slider or makeStub()

local Section = {}

function Section.new(rawSection)
    local self = {}
    self._raw = rawSection

    function self:Toggle(spec)
        return Toggle.create(self._raw, spec)
    end

    function self:Input(spec)
        return Input.create(self._raw, spec)
    end

    function self:Button(spec)
        return Button.create(self._raw, spec)
    end

    function self:Slider(spec)
        return Slider.create(self._raw, spec)
    end

    function self:Label(spec)
        if self._raw and self._raw:Label then
            return self._raw:Label(spec)
        end
        return { UpdateName = function() end }
    end

    function self:Destroy()
        -- nothing special, raw section will be destroyed by MacLib window
    end

    return self
end

return Section
