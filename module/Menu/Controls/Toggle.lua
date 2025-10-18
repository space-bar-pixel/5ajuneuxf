-- Toggle control adapter
local Toggle = {}

function Toggle.create(section, spec)
    if not section or not section.Toggle then
        return {
            Set = function() end,
            Get = function() return spec and spec.Value or false end,
            Destroy = function() end,
        }
    end
    local ok, ctrl = pcall(function() return section:Toggle(spec) end)
    if not ok or not ctrl then
        return {
            Set = function() end,
            Get = function() return spec and spec.Value or false end,
            Destroy = function() end,
        }
    end
    return ctrl
end

return Toggle
