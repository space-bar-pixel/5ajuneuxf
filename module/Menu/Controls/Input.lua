-- Input control adapter
local Input = {}

-- Create a Input on a section. Returns the underlying maclib control or a small wrapper.
function Input.create(section, spec)
    if not section or not section.Input then
        return {
            UpdateName = function() end,
            Destroy = function() end,
        }
    end
    local ok, ctrl = pcall(function() return section:Input(spec) end)
    if not ok or not ctrl then
        return {
            UpdateName = function() end,
            Destroy = function() end,
        }
    end
    return ctrl
end

return Input
