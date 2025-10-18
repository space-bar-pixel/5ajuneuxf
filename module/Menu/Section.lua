local Toggle = loadstring(game:HttpGet("https://raw.githubusercontent.com/space-bar-pixel/5ajuneuxf/main/module/Menu/Controls/Toggle.lua"))()
local Button = loadstring(game:HttpGet("https://raw.githubusercontent.com/space-bar-pixel/5ajuneuxf/main/module/Menu/Controls/Button.lua"))()
local Slider = loadstring(game:HttpGet("https://raw.githubusercontent.com/space-bar-pixel/5ajuneuxf/main/module/Menu/Controls/Slider.lua"))()

local Section = {}

function Section.new(rawSection)
    local self = {}
    self._raw = rawSection

    function self:Toggle(spec)
        return Toggle.create(self._raw, spec)
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
