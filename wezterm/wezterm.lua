-- For WSL: Copy this to ~/.config/wezterm (Windows user)

local wezterm = require("wezterm")

local config = wezterm.config_builder()

config.font = wezterm.font("JetBrains Mono")
config.font_size = 14
config.window_decorations = "INTEGRATED_BUTTONS"

-- Switch between light and dark themes based on system theme.
if wezterm.gui.get_appearance():find("Dark") then
	config.color_scheme = "Catppuccin Frappe"
else
	config.color_scheme = "Catppuccin Latte"
end

-- On Windows, use NixOS-WSL and launch the fish shell.
if wezterm.target_triple == "x86_64-pc-windows-msvc" and wezterm.running_under_wsl then
	config.wsl_domains = {
		{
			name = "WSL:NixOS",
			distribution = "NixOS",
			default_cwd = "/home/fng",
		},
	}
	config.default_domain = "WSL:NixOS"
else
	config.default_prog = { "/etc/profiles/per-user/fng/bin/fish" }
end

-- Bind CTRL+Space to enter the "nav" key table (Zellij-like modal state). This lets us use neovim
-- keybinds without clashing.

local navigation_mode_active = false

wezterm.on("update-right-status", function(window, pane)
	if navigation_mode_active then
		window:set_right_status(wezterm.format({
			{ Attribute = { Intensity = "Bold" } },
			{ Foreground = { AnsiColor = "Yellow" } },
			{ Text = "   N   " },
		}))
	else
		window:set_right_status("") -- clear
	end
end)

wezterm.on("enter-navigation-mode", function()
	navigation_mode_active = true
end)

wezterm.on("exit-navigation-mode", function()
	navigation_mode_active = false
end)

config.keys = {
	{
		key = "Space",
		mods = "CTRL",
		action = wezterm.action.Multiple({
			wezterm.action.EmitEvent("enter-navigation-mode"),
			wezterm.action.ActivateKeyTable({
				name = "navigation",
				one_shot = false, -- keep key table active until "PopKeyTable" is called
			}),
		}),
	},
}

config.key_tables = {
	navigation = {
		{ key = "h", action = wezterm.action.ActivatePaneDirection("Left") },
		{ key = "j", action = wezterm.action.ActivatePaneDirection("Down") },
		{ key = "k", action = wezterm.action.ActivatePaneDirection("Up") },
		{ key = "l", action = wezterm.action.ActivatePaneDirection("Right") },
		{ key = "H", action = wezterm.action.ActivateTabRelative(-1) },
		{ key = "L", action = wezterm.action.ActivateTabRelative(1) },
		{ key = "|", action = wezterm.action.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
		{ key = "-", action = wezterm.action.SplitVertical({ domain = "CurrentPaneDomain" }) },
		{
			key = "Escape",
			action = wezterm.action.Multiple({
				wezterm.action.EmitEvent("exit-navigation-mode"),
				"PopKeyTable",
			}),
		},
	},
}

return config
