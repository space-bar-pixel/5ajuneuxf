Pizza Hub - Modularized Script

Structure
- module/
  - Menu/ (UI builders)
  - Menu/Controls/ (Button/Toggle/Slider adapters)
  - Services/ (RemoteService, ConfigService)
  - Features/ (GiftFeature, DupeFeature, AutoFarm, Plant)
  - Data.lua, Helpers.lua, ConfigManager.lua

Load strategy
- This repository uses remote loadstring() calls to fetch modules at runtime (keeps compatibility with previous behavior).

How to extend
- Add a new feature under `module/Features/` that exports `mount(ctx)` and `Destroy()`.
- Use `Services/RemoteService.lua` to centralize RemoteEvent calls.

Running
- Drop `test.lua` into your Roblox local script environment as before. No build steps required.
