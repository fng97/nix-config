-- For WSL: Copy this to ~/.config/wezterm (Windows user)

local wezterm = require("wezterm")

local config = {}

function get_appearance()
	if wezterm.gui then
		return wezterm.gui.get_appearance()
	end
	return "Dark"
end

function scheme_for_appearance(appearance)
	if appearance:find("Dark") then
		return "Catppuccin Frappe"
	else
		return "Catppuccin Latte"
	end
end

local font = wezterm.font("JetBrains Mono")

config.color_scheme = scheme_for_appearance(get_appearance())
config.font = font
config.font_size = 14
config.hide_tab_bar_if_only_one_tab = true
config.tab_max_width = 32
config.use_fancy_tab_bar = false

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

config.leader = { key = "Space", mods = "CTRL", timeout_milliseconds = 1000 }

config.keys = {
	-- splits
	{ key = "-", mods = "LEADER", action = wezterm.action.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
	{ key = "|", mods = "LEADER|SHIFT", action = wezterm.action.SplitVertical({ domain = "CurrentPaneDomain" }) },

	-- new windows and tabs
	{ key = "n", mods = "LEADER", action = wezterm.action.SpawnWindow },
	{ key = "t", mods = "LEADER", action = wezterm.action.SpawnTab("DefaultDomain") },
	{ key = "q", mods = "LEADER", action = wezterm.action.CloseCurrentPane({ confirm = false }) },

	-- navigation between splits
	{ key = "h", mods = "LEADER", action = wezterm.action.ActivatePaneDirection("Left") },
	{ key = "j", mods = "LEADER", action = wezterm.action.ActivatePaneDirection("Down") },
	{ key = "k", mods = "LEADER", action = wezterm.action.ActivatePaneDirection("Up") },
	{ key = "l", mods = "LEADER", action = wezterm.action.ActivatePaneDirection("Right") },

	-- navigation between tabs
	{ key = "h", mods = "LEADER|CTRL", action = wezterm.action.ActivateTabRelative(-1) },
	{ key = "l", mods = "LEADER|CTRL", action = wezterm.action.ActivateTabRelative(1) },
}

return config
