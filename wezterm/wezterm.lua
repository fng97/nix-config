-- For WSL: Copy this to ~/.config/wezterm (Windows user)

local wezterm = require("wezterm")

local config = {}

config.font = wezterm.font("JetBrains Mono")
config.font_size = 16
config.color_scheme = "Gruvbox Dark (Gogh)"
config.hide_tab_bar_if_only_one_tab = true

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

return config
