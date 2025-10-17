-- Slider control adapter
local Slider = {}

function Slider.create(section, spec)
    if not section or not section.Slider then
        return {
            Set = function() end,
            Get = function() return spec and spec.Value or 0 end,
            Destroy = function() end,
        }
    end
    local ok, ctrl = pcall(function() return section:Slider(spec) end)
    if not ok or not ctrl then
        return {
            Set = function() end,
            Get = function() return spec and spec.Value or 0 end,
            Destroy = function() end,
        }
    end
    return ctrl
end

return Slider
