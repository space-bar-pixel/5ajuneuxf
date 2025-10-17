-- Gift module: handles building fruit queue and sending gifts
local Gift = {}

-- Build fruit queue from Menu.data.fruits and fruitAmounts
-- params: fruitsTable (array with fullname), fruitAmounts (map fullname->count)
function Gift.buildQueue(fruitsTable, fruitAmounts)
    local queue = {}
    for _, fruit in ipairs(fruitsTable) do
        local count = tonumber(fruitAmounts[fruit.fullname]) or 0
        for i = 1, count do
            table.insert(queue, fruit.fullname)
        end
    end
    return queue
end

function Gift.sendQueue(queue, playerName, Players, Window, remoteService)
    local targetPlayer = Players:FindFirstChild(playerName)
    if not targetPlayer then
        if Window and Window.Notify then
            Window:Notify({ Title = "Error", Description = "Player not found: " .. tostring(playerName), Lifetime = 3 })
        end
        return false, "not_found"
    end

    local given = 0
    for _, fruitFullName in ipairs(queue) do
        local ok, err = remoteService:Focus(fruitFullName)
        task.wait(0.05)
        if not ok then
            -- log but continue
            if Window and Window.Notify then Window:Notify({ Title = "Warning", Description = "Focus failed: "..tostring(err), Lifetime = 2 }) end
        end
        local ok2, err2 = remoteService:SendGift(targetPlayer)
        if not ok2 then
            if Window and Window.Notify then Window:Notify({ Title = "Warning", Description = "SendGift failed: "..tostring(err2), Lifetime = 2 }) end
        else
            given = given + 1
        end
        task.wait(0.3)
    end
    return true, given
end

return Gift
