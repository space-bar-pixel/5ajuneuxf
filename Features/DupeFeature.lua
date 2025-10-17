local Dupe = loadstring(game:HttpGet("https://raw.githubusercontent.com/space-bar-pixel/5ajuneuxf/refs/heads/main/module/Dupe.lua"))()

local DupeFeature = {}

function DupeFeature.mount(ctx)
    local section = ctx.sections.mainRight or ctx.sections.main and ctx.sections.main.right
    -- We'll expect a section with direct access for dupe actions; use ctx.sections.dupe or ctx.sections.main.right
    section = ctx.sections.dupe or ctx.sections.main and ctx.sections.main.right or ctx.sections.mainRight
    local Window = ctx.services.Window
    local state = ctx.state
    local remoteService = ctx.services.remoteService
    local players = ctx.services.Players

    -- Add Execute Dupe button to the dupe section (dupeSec1)
    local dupeSection = ctx.sections.dupeSec1 or ctx.sections.dupe

    -- status label
    local statusLabel = dupeSection:Label({ Text = "Given: 0                                             Left: 0" })

    local isRunning = false
    local isPaused = false
    local runId = 0

    local function updateStatus(given, left)
        pcall(function()
            if statusLabel.UpdateName then
                statusLabel:UpdateName(string.format("Given: %d                                             Left: %d", given or 0, left or 0))
            end
        end)
    end

    dupeSection:Button({ Name = "Execute Dupe", Callback = function()
        local playerName = state.selectedPlayerName
        if not playerName or playerName == "" then
            Window:Notify({ Title = "Error", Description = "Please select a player.", Lifetime = 3 })
            return
        end
        local targetPlayer = players:FindFirstChild(playerName)
        if not targetPlayer then
            Window:Notify({ Title = "Error", Description = "Player not found: " .. tostring(playerName), Lifetime = 3 })
            return
        end
        if (not state.selectedEggName or #state.selectedEggName == 0) or (not state.selectedMutName or #state.selectedMutName == 0) then
            Window:Notify({ Title = "Error", Description = "Select at least one egg and a mutation!", Lifetime = 3 })
            return
        end

        local queue = Dupe.buildQueue(state.EggInventory or {}, state.selectedEggName or {}, state.selectedMutName or {}, state.totalToGive or 0)
        if #queue == 0 then
            Window:Notify({Title = "Error", Description = "No matching eggs found!", Lifetime = 3})
            return
        end

        if isRunning then
            Window:Notify({ Title = "Busy", Description = "Dupe loop already running.", Lifetime = 3 })
            return
        end

        isRunning = true
        isPaused = false
        runId = runId + 1
        local myId = runId

        local controller = { isPaused = false, cancelled = false }

        task.spawn(function()
            local given = Dupe.executeQueue(queue, targetPlayer, remoteService, {
                controller = controller,
                onProgress = function(g, left)
                    updateStatus(g, left)
                end
            })

            -- if cancelled externally, leave given as-is
            Window:Notify({Title = "Done", Description = "Egg give finished. Total: " .. tostring(given), Lifetime = 3})
            isRunning = false
            isPaused = false
        end)
    end})

    -- Pause / Resume (dupe)
    dupeSection:Button({ Name = "Pause / Resume", Callback = function()
        if not isRunning then
            Window:Notify({ Title = "Info", Description = "Not currently running.", Lifetime = 2 })
            return
        end
        isPaused = not isPaused
        -- update controller if present
        pcall(function() controller.isPaused = isPaused end)
        Window:Notify({ Title = isPaused and "Paused" or "Resumed", Description = "", Lifetime = 2 })
    end})

    -- Cancel Loop (dupe)
    dupeSection:Button({ Name = "Cancel Loop", Callback = function()
        -- Cancel via controller
        runId = runId + 1
        isRunning = false
        isPaused = false
        pcall(function() controller.cancelled = true end)
        pcall(function() statusLabel:UpdateName("Given: 0                                             Left: 0") end)
        Window:Notify({ Title = "Cancelled", Text = "Dupe loop stopped.", Lifetime = 2 })
    end})

    local mounted = {}
    function mounted:Destroy() end
    return mounted
end

return DupeFeature
