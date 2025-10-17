-- RemoteService: centralizes RemoteEvent calls
local RemoteService = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local remoteFolder = ReplicatedStorage:WaitForChild("Remote")

-- default retry options
local DEFAULT_RETRIES = 3
local DEFAULT_BACKOFF = 0.1

function RemoteService.new(opts)
    opts = opts or {}
    local self = {}
    self.GiftRE = remoteFolder:WaitForChild("GiftRE")
    self.DeployRE = remoteFolder:WaitForChild("DeployRE")
    self.CharacterRE = remoteFolder:WaitForChild("CharacterRE")
    self.FoodStoreRE = remoteFolder:WaitForChild("FoodStoreRE")
    self.retries = opts.retries or DEFAULT_RETRIES
    self.backoff = opts.backoff or DEFAULT_BACKOFF

    local function attempt(fn)
        local lastErr
        for i = 1, self.retries do
            local ok, err = pcall(fn)
            if ok then
                return true, nil
            end
            lastErr = err
            task.wait(self.backoff * i)
        end
        return false, tostring(lastErr)
    end

    function self:Focus(target)
        -- Try both common call signatures, succeed if either works
        local ok, err = attempt(function()
            self.CharacterRE:FireServer({"Focus", target})
        end)
        if ok then return true, nil end
        local ok2, err2 = attempt(function()
            self.CharacterRE:FireServer("Focus", target)
        end)
        if ok2 then return true, nil end
        return false, err2 or err
    end

    function self:SendGift(targetPlayer)
        return attempt(function()
            self.GiftRE:FireServer(targetPlayer)
        end)
    end

    function self:DeployEgg(eggId)
        return attempt(function()
            self.DeployRE:FireServer({ event = "deploy", uid = eggId })
        end)
    end

    return self
end

return RemoteService
