local AutoFarm = {}

function AutoFarm.mount(ctx)
    -- ctx: { sections, services, state }
    local mounted = {}
    function mounted:Destroy() end
    return mounted
end

return AutoFarm
