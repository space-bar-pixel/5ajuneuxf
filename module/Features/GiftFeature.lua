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

local Gift = safeLoad("https://raw.githubusercontent.com/space-bar-pixel/5ajuneuxf/main/module/Gift.lua") or {}
local Data = safeLoad("https://raw.githubusercontent.com/space-bar-pixel/5ajuneuxf/main/module/Data.lua") or {}

local GiftFeature = {}

function GiftFeature.mount(ctx)
    -- ctx: { sections = { left2 = section }, services = { Players, Window, remoteService, Data }, state = State }
    local section = ctx.sections and (ctx.sections.left2 or ctx.sections.main and ctx.sections.main.left2) or ctx.sections
    local players = ctx.services and ctx.services.Players
    local Window = ctx.services and ctx.services.Window
    local remoteService = ctx.services and ctx.services.remoteService
    local data = (ctx.services and ctx.services.Data) or (ctx.data) or { fruits = {} }
    local state = ctx.state or {}

    local isRunning = false
    local isPaused = false
    local runId = 0

    for _, fruit in ipairs(Data.fruits) do
        section:Input({
            Name = fruit.name,
            Placeholder = "                   ",
            AcceptedCharacters = "Numeric",
            Callback = function(val)
                fruitAmounts[fruit.fullname] = val
            end
        })
    end

    -- status label owned by feature
    local statusLabel = section:Label({ Text = "Given: 0                                             Left: 0" })

    local function updateStatus(given, left)
        pcall(function()
            if statusLabel.UpdateName then
                statusLabel:UpdateName(string.format("Given: %d                                             Left: %d", given or 0, left or 0))
            end
        end)
    end
    
    section:Button({ Name = "Start Gift Loop", Callback = function()
        local playerName = state.selectedPlayerName
        if not playerName or playerName == "" then
            Window:Notify({ Title = "Error", Description = "Please select a player.", Lifetime = 3 })
            return
        end

        local queue = Gift.buildQueue(data.fruits, state.fruitAmounts)
        if #queue == 0 then
            Window:Notify({ Title = "Error", Description = "No fruits selected!", Lifetime = 3 })
            return
        end

        if isRunning then
            Window:Notify({ Title = "Busy", Description = "Gift loop already running.", Lifetime = 3 })
            return
        end

        isRunning = true
        isPaused = false
        runId = runId + 1
        local myId = runId

        task.spawn(function()
            local ok, result = pcall(function()
                local success, givenOrErr = Gift.sendQueue(queue, playerName, players, Window, remoteService)
                if success then
                    Window:Notify({ Title = "Done!", Description = "Gift loop finished.", Lifetime = 4 })
                end
                return success, givenOrErr
            end)
            if not ok then
                Window:Notify({ Title = "Error", Description = "Gift loop failed.", Lifetime = 4 })
            end
            isRunning = false
            isPaused = false
        end)
    end})

    -- Pause/Resume
    section:Button({ Name = "Pause / Resume", Callback = function()
        if not isRunning then
            Window:Notify({ Title = "Info", Description = "Not currently running.", Lifetime = 2 })
            return
        end
        isPaused = not isPaused
        Window:Notify({ Title = isPaused and "Paused" or "Resumed", Description = "", Lifetime = 2 })
    end})

    -- Cancel Loop
    section:Button({ Name = "Cancel Loop", Callback = function()
        runId = runId + 1
        isRunning = false
        isPaused = false
        updateStatus(0, 0)
        Window:Notify({ Title = "Cancelled", Text = "Gift loop stopped.", Lifetime = 2 })
    end})

    local mounted = {}
    function mounted:Destroy()
        -- nothing special to cleanup; maclib will remove controls with window
        isRunning = false
        isPaused = false
    end
    return mounted
end

return GiftFeature
