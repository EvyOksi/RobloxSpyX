# AdvancedSpy Modules

This directory contains the core modules for AdvancedSpy:

- `RemoteInterceptor.lua`: Handles interception of RemoteEvent and RemoteFunction calls
- `UIComponents.lua`: UI elements and window management
- `TouchControls.lua`: Mobile-friendly touch controls
- `Theme.lua`: Theme management (dark/light)
- `ScriptGenerator.lua`: Generates replayable scripts from intercepted calls
- `NetworkVisualizer.lua`: Network traffic analysis and visualization

## Usage

These modules are automatically loaded by the main `AdvancedSpy.lua` script. Do not require them directly.

## Development

When contributing new features:
1. Each module should have a single responsibility
2. Include proper error handling for non-Roblox environments
3. Add debug logging where appropriate
4. Follow the established code style
