local Plant = {}

function Plant.mount(ctx)
    local mounted = {}
    function mounted:Destroy() end
    return mounted
end

return Plant
