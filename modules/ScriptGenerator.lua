local ScriptGenerator = {}

function ScriptGenerator:GenerateScript(remote, args)
    if remote:IsA("RemoteFunction") then
        return self:GenerateRemoteFunctionScript(remote, args)
    else
        return self:GenerateRemoteEventScript(remote, args)
    end
end

function ScriptGenerator:GenerateRemoteFunctionScript(remote, args)
    local script = string.format([[
local remote = game:GetService("ReplicatedStorage"):WaitForChild("%s")
local args = %s

local result = remote:InvokeServer(unpack(args))
print("Return value:", result)]], 
    self:GetRemotePath(remote),
    self:SerializeArgs(args))
    
    return script
end

function ScriptGenerator:GenerateRemoteEventScript(remote, args)
    local script = string.format([[
local remote = game:GetService("ReplicatedStorage"):WaitForChild("%s")
local args = %s

remote:FireServer(unpack(args))]], 
    self:GetRemotePath(remote),
    self:SerializeArgs(args))
    
    return script
end

function ScriptGenerator:GetRemotePath(remote)
    local path = {}
    local current = remote
    
    while current and current ~= game do
        table.insert(path, 1, current.Name)
        current = current.Parent
    end
    
    return table.concat(path, ".")
end

function ScriptGenerator:SerializeArgs(args)
    if #args == 0 then
        return "{}"
    end

    local serialized = "{\n"
    for i, arg in ipairs(args) do
        serialized = serialized .. "    " .. self:SerializeValue(arg)
        if i < #args then
            serialized = serialized .. ","
        end
        serialized = serialized .. "\n"
    end
    serialized = serialized .. "}"
    
    return serialized
end

function ScriptGenerator:SerializeValue(value)
    local valueType = typeof(value)
    
    if valueType == "string" then
        return string.format("%q", value)
    elseif valueType == "number" or valueType == "boolean" then
        return tostring(value)
    elseif valueType == "table" then
        local result = "{\n"
        for k, v in pairs(value) do
            local keyStr = type(k) == "string" and string.format("[%q]", k) or string.format("[%s]", tostring(k))
            result = result .. string.format("    %s = %s,\n", keyStr, self:SerializeValue(v))
        end
        result = result .. "}"
        return result
    elseif valueType == "Instance" then
        return string.format('game:GetService("%s")', value.ClassName)
    elseif valueType == "Vector3" then
        return string.format("Vector3.new(%f, %f, %f)", value.X, value.Y, value.Z)
    elseif valueType == "CFrame" then
        local x, y, z = value.Position:components()
        return string.format("CFrame.new(%f, %f, %f)", x, y, z)
    else
        return "nil --[[ Unable to serialize " .. valueType .. " ]]"
    end
end

return ScriptGenerator
