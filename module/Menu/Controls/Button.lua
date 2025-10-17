-- Button control adapter
local Button = {}

-- Create a button on a section. Returns the underlying maclib control or a small wrapper.
function Button.create(section, spec)
    if not section or not section.Button then
        return {
            UpdateName = function() end,
            Destroy = function() end,
        }
    end
    local ok, ctrl = pcall(function() return section:Button(spec) end)
    if not ok or not ctrl then
        return {
            UpdateName = function() end,
            Destroy = function() end,
        }
    end
    return ctrl
end

return Button
