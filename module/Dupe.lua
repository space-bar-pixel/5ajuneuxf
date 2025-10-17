-- Dupe module: handles selecting eggs from inventory and giving them
local Dupe = {}

-- Build queue of egg ids matching selectedEggNames and selectedMutNames
function Dupe.buildQueue(eggInventory, selectedEggNames, selectedMutNames, totalToGive)
    local queue = {}
    for _, egg in ipairs(eggInventory) do
        for _, allowedName in ipairs(selectedEggNames) do
            for _, allowedMut in ipairs(selectedMutNames) do
                if egg.name == allowedName and egg.mutation == allowedMut then
                    table.insert(queue, egg.id)
                    break
                end
            end
        end
    end
    if totalToGive and totalToGive > 0 and #queue > totalToGive then
        while #queue > totalToGive do
            table.remove(queue)
        end
    end
    return queue
end

function Dupe.executeQueue(queue, targetPlayer, remoteService, opts)
    -- opts (optional table):
    --   controller: { isPaused = false, cancelled = false }
    --   onProgress: function(given, left) end
    -- Backwards compatible: if opts is nil and remoteService is actually opts, handle gracefully
    opts = opts or {}
    local controller = opts.controller or { isPaused = false, cancelled = false }
    local onProgress = opts.onProgress

    local given = 0
    for _, eggId in ipairs(queue) do
        -- cancellation check
        if controller.cancelled then break end

        -- pause support
        while controller.isPaused and not controller.cancelled do task.wait(0.2) end

        local ok, err = remoteService:DeployEgg(eggId)
        if not ok then
            -- skip this egg
            goto continue
        end
        task.wait(0.1)
        pcall(function() remoteService:Focus(eggId) end)
        task.wait(0.1)
        local ok3, err3 = remoteService:SendGift(targetPlayer)
        if ok3 then
            given = given + 1
        end

        if onProgress then
            pcall(onProgress, given, #queue - given)
        end

        task.wait(0.1)
        ::continue::
    end
    return given
end

return Dupe
