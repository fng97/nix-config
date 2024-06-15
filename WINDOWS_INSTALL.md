# Windows Installation Notes

## TODOS

- learn FancyZones

## Before Installation

- Back up bookmarks
- Back up FanControl

1. Install Windows according to AtlasOS instructions (if allowed)

2. Upgrade PowerShell with `winget`

3. Install `scoop`

   ```powershell
   # also do
   scoop install git
   scoop bucket add extras
   ```

4. Install apps:

   ```powershell
   winget install --id Valve.Steam
   scoop install `
     powertoys `
     twinkle-tray `
     fancontrol `
     wezterm
   ```

5. Set up LibreWolf

   1. _Bookmarks Toolbar_ -> _Only show on new tab_

   2. Install extensions:

      - Bitwarden
      - Vimium
      - Dark Reader

6. Set refresh rate to max

7. Install GPU drivers

   - disable game bar
   - disable game mode
