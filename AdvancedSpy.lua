--[[
    AdvancedSpy
    A mobile-friendly enhanced remote spy for Roblox
    Author: Assistant
]]

local AdvancedSpy = {
    Version = "1.0.0",
    Enabled = false,
    Connections = {},
    RemoteLog = {},
    BlockedRemotes = {},
    ExcludedRemotes = {},
    Settings = {
        Theme = "dark",
        MaxLogs = 1000,
        AutoBlock = false,
        LogReturnValues = true,
        Debug = true -- Enable debug mode
    }
}

-- Debug logging function
local function debugLog(module, message)
    if AdvancedSpy.Settings.Debug then
        print(string.format("[AdvancedSpy Debug] [%s] %s", module, message))
    end
end

-- Load modules from local files
local function loadModule(name)
    debugLog("ModuleLoader", "Attempting to load module: " .. name)
    local success, module = pcall(function()
        return require("modules." .. name)
    end)

    if not success then
        debugLog("ModuleLoader", "Failed to load module " .. name .. ": " .. tostring(module))
        error("Failed to load module " .. name .. ": " .. tostring(module))
    end

    debugLog("ModuleLoader", "Successfully loaded module: " .. name)
    return module
end

-- Load modules
debugLog("Init", "Loading required modules...")
local UIComponents = loadModule("UIComponents")
local RemoteInterceptor = loadModule("RemoteInterceptor")
local ScriptGenerator = loadModule("ScriptGenerator")
local Theme = loadModule("Theme")
local TouchControls = loadModule("TouchControls")

-- Core UI Elements
local GUI = {
    Main = nil,
    LogList = nil,
    SearchBar = nil,
    SettingsPanel = nil
}

function AdvancedSpy:Init()
    debugLog("Init", "Initializing AdvancedSpy v" .. self.Version)

    -- Create main UI
    debugLog("UI", "Creating main UI components...")
    GUI.Main = UIComponents.CreateMainWindow()
    GUI.LogList = UIComponents.CreateLogList()
    GUI.SearchBar = UIComponents.CreateSearchBar()
    GUI.SettingsPanel = UIComponents.CreateSettingsPanel()

    -- Initialize touch controls
    debugLog("TouchControls", "Initializing touch controls...")
    TouchControls:Init(GUI.Main)

    -- Setup remote interceptors
    debugLog("RemoteInterceptor", "Setting up remote interceptors...")
    RemoteInterceptor:Init(function(remote, args, returnValue)
        self:HandleRemoteCall(remote, args, returnValue)
    end)

    -- Apply initial theme
    debugLog("Theme", "Applying initial theme: " .. self.Settings.Theme)
    Theme:Apply(self.Settings.Theme)

    self.Enabled = true
    debugLog("Init", "AdvancedSpy initialized successfully")

    -- Create a test remote call for non-Roblox environment
    if not RemoteInterceptor:IsRobloxEnvironment() then
        debugLog("Test", "Creating test remote call...")
        self:TestRemoteCall()
    end
end

function AdvancedSpy:TestRemoteCall()
    -- Create a mock remote object
    local mockRemote = {
        Name = "TestRemote",
        IsA = function(self, className)
            return className == "RemoteFunction"
        end
    }

    -- Simulate a remote call
    self:HandleRemoteCall(
        mockRemote,
        {
            "test_arg1",
            123,
            {key = "value"}
        },
        "test_return_value"
    )
end

function AdvancedSpy:HandleRemoteCall(remote, args, returnValue)
    debugLog("RemoteCall", string.format("Handling remote call: %s", remote.Name))

    if self:IsExcluded(remote) then 
        debugLog("RemoteCall", "Remote is excluded, ignoring...")
        return 
    end

    if self:IsBlocked(remote) then 
        debugLog("RemoteCall", "Remote is blocked, ignoring...")
        return 
    end

    local logEntry = {
        Remote = remote,
        Args = args,
        ReturnValue = returnValue,
        Timestamp = os.time(),
        Stack = debug.traceback(),
        Id = #self.RemoteLog + 1
    }

    table.insert(self.RemoteLog, 1, logEntry)
    debugLog("RemoteCall", string.format("Added log entry #%d", logEntry.Id))

    self:TrimLogs()
    self:UpdateLogDisplay(logEntry)
end

function AdvancedSpy:UpdateLogDisplay(logEntry)
    debugLog("UI", string.format("Updating display for log entry #%d", logEntry.Id))
    UIComponents.AddLogEntry(GUI.LogList, logEntry)
end

function AdvancedSpy:TrimLogs()
    while #self.RemoteLog > self.Settings.MaxLogs do
        table.remove(self.RemoteLog)
    end
    debugLog("Logs", string.format("Trimmed logs to %d entries", #self.RemoteLog))
end

function AdvancedSpy:IsBlocked(remote)
    return self.BlockedRemotes[remote] ~= nil
end

function AdvancedSpy:IsExcluded(remote)
    return self.ExcludedRemotes[remote] ~= nil
end

-- API Functions
function AdvancedSpy:BlockRemote(remote)
    debugLog("API", string.format("Blocking remote: %s", remote.Name))
    self.BlockedRemotes[remote] = true
end

function AdvancedSpy:UnblockRemote(remote)
    debugLog("API", string.format("Unblocking remote: %s", remote.Name))
    self.BlockedRemotes[remote] = nil
end

function AdvancedSpy:ExcludeRemote(remote)
    debugLog("API", string.format("Excluding remote: %s", remote.Name))
    self.ExcludedRemotes[remote] = true
end

function AdvancedSpy:IncludeRemote(remote)
    debugLog("API", string.format("Including remote: %s", remote.Name))
    self.ExcludedRemotes[remote] = nil
end

function AdvancedSpy:GetRemoteFiredSignal(remote)
    debugLog("API", string.format("Creating signal for remote: %s", remote.Name))
    return RemoteInterceptor:CreateSignal(remote)
end

function AdvancedSpy:Destroy()
    debugLog("Cleanup", "Destroying AdvancedSpy...")
    self.Enabled = false
    for _, connection in pairs(self.Connections) do
        connection:Disconnect()
    end
    GUI.Main:Destroy()
    debugLog("Cleanup", "AdvancedSpy destroyed successfully")
end

debugLog("Main", "Starting AdvancedSpy...")
-- Initialize when loaded
return function()
    AdvancedSpy:Init()
    return AdvancedSpy
end