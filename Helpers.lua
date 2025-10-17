-- Helpers module
local Helpers = {}

function Helpers.getHumanoidRoot(player)
    if player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        return player.Character.HumanoidRootPart
    end
    return nil
end

function Helpers.fireServer(obj, arg)
    if type(arg) == "table" and arg[1] then
        obj:FireServer(unpack(arg))
    else
        obj:FireServer(arg)
    end
end

function Helpers.getNil(objType, objName)
    for _, v in ipairs(getnilinstances()) do
        if v.ClassName == objType and v.Name == objName then
            return v
        end
    end
end

function Helpers.strToVector3(coordStr)
    local x, y, z = coordStr:match("([^,]+), ([^,]+), ([^,]+)")
    return Vector3.new(tonumber(x), tonumber(y), tonumber(z))
end

return Helpers
