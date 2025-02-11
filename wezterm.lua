-- For WSL: Copy this to ~/.config/wezterm (Win user)

local wezterm = require("wezterm")
local config = {}

config.font = wezterm.font("JetBrains Mono")
config.color_scheme = "Gruvbox Dark (Gogh)"
config.hide_tab_bar_if_only_one_tab = true

config.wsl_domains = {
	{
		name = "WSL:NixOS",
		distribution = "NixOS",
		default_cwd = "/home/fng",
	},
}

config.default_domain = "WSL:NixOS"

return config
