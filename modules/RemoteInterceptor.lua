local RemoteInterceptor = {}

local hookFunction = hookfunction or replaceclosure or function(func, hook)
    local metatable = getrawmetatable(game)
    local oldNamecall = metatable.__namecall
    setreadonly(metatable, false)

    metatable.__namecall = newcclosure(function(self, ...)
        local method = getnamecallmethod()
        if method == func then
            return hook(self, ...)
        end
        return oldNamecall(self, ...)
    end)

    setreadonly(metatable, true)
end

function RemoteInterceptor:IsRobloxEnvironment()
    return type(game) == "userdata" and type(game.GetService) == "function"
end

function RemoteInterceptor:Init(callback)
    if not self:IsRobloxEnvironment() then
        print("[RemoteInterceptor] Warning: Running outside Roblox environment. Remote interception will be limited.")
        return
    end

    print("[RemoteInterceptor] Initializing remote interceptor...")
    self.Callback = callback
    self:HookRemotes()
end

function RemoteInterceptor:HookRemotes()
    if not self:IsRobloxEnvironment() then
        print("[RemoteInterceptor] Skipping remote hooks in non-Roblox environment")
        return
    end

    print("[RemoteInterceptor] Setting up remote hooks...")
    -- Hook RemoteFunction
    local oldInvoke = Instance.new("RemoteFunction").InvokeServer
    hookFunction(oldInvoke, function(self, ...)
        local args = {...}
        local success, returnValue = pcall(function()
            return oldInvoke(self, unpack(args))
        end)

        if success then
            print(string.format("[RemoteInterceptor] Intercepted RemoteFunction call: %s", self.Name))
            self.Callback(self, args, returnValue)
            return returnValue
        else
            warn("[RemoteInterceptor] Failed to intercept RemoteFunction:", returnValue)
            return oldInvoke(self, unpack(args))
        end
    end)

    -- Hook RemoteEvent
    local oldFireServer = Instance.new("RemoteEvent").FireServer
    hookFunction(oldFireServer, function(self, ...)
        local args = {...}
        local success, returnValue = pcall(function()
            return oldFireServer(self, unpack(args))
        end)

        if success then
            print(string.format("[RemoteInterceptor] Intercepted RemoteEvent call: %s", self.Name))
            self.Callback(self, args, nil)
            return returnValue
        else
            warn("[RemoteInterceptor] Failed to intercept RemoteEvent:", returnValue)
            return oldFireServer(self, unpack(args))
        end
    end)

    print("[RemoteInterceptor] Remote hooks setup completed")
end

function RemoteInterceptor:CreateSignal(remote)
    print(string.format("[RemoteInterceptor] Creating signal for remote: %s", remote.Name))
    local signal = {}
    local connections = {}

    function signal:Connect(callback)
        local connection = {
            Connected = true,
            Disconnect = function(self)
                self.Connected = false
                for i, conn in ipairs(connections) do
                    if conn == self then
                        table.remove(connections, i)
                        break
                    end
                end
            end
        }

        table.insert(connections, connection)

        -- Hook the remote
        self:HookSpecificRemote(remote, function(...)
            if connection.Connected then
                callback(...)
            end
        end)

        return connection
    end

    return signal
end

function RemoteInterceptor:HookSpecificRemote(remote, callback)
    if not self:IsRobloxEnvironment() then
        print(string.format("[RemoteInterceptor] Skipping specific remote hook for %s in non-Roblox environment", remote.Name))
        return
    end

    print(string.format("[RemoteInterceptor] Setting up specific hook for remote: %s", remote.Name))
    if remote:IsA("RemoteFunction") then
        local oldInvoke = remote.InvokeServer
        remote.InvokeServer = function(self, ...)
            local args = {...}
            local result = oldInvoke(self, unpack(args))
            callback(unpack(args))
            return result
        end
    elseif remote:IsA("RemoteEvent") then
        local oldFire = remote.FireServer
        remote.FireServer = function(self, ...)
            local args = {...}
            oldFire(self, unpack(args))
            callback(unpack(args))
        end
    end
end

-- Create mock remote simulation for testing
function RemoteInterceptor:SimulateRemoteCall(remote, args, returnValue)
    print(string.format("[RemoteInterceptor] Simulating remote call for: %s", remote.Name))
    if self.Callback then
        self.Callback(remote, args, returnValue)
    else
        print("[RemoteInterceptor] Warning: No callback registered for remote simulation")
    end
end

return RemoteInterceptor