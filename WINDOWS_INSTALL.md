# Windows Installation

1. Install Windows according to AtlasOS instructions
2. Upgrade PowerShell with `winget`
3. Install `scoop` and then:
   ```powershell
   # also do
   scoop install git
   scoop bucket add extras
   ```
4. Install apps:
   ```powershell
   scoop install `
     powertoys `
     firefox `
     twinkle-tray `
     wezterm `
     win32yank
   ```
5. Copy `wezterm.lua` to `~/.config/wezterm` (Windows user)
6. Change Caps Lock to CTRL in Powertoys
