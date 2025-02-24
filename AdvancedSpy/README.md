# AdvancedSpy Installation

1. Create the following folder structure:
```
/AdvancedSpy/
├── AdvancedSpy.lua
└── modules/
    ├── RemoteInterceptor.lua
    ├── UIComponents.lua
    ├── TouchControls.lua
    ├── Theme.lua
    ├── ScriptGenerator.lua
    └── NetworkVisualizer.lua
```

2. Copy each file's contents into the corresponding files.

3. To use in Roblox, run:
```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/YourUsername/AdvancedSpy/main/AdvancedSpy.lua"))()
```

The tool will automatically load all required modules and initialize the UI.
