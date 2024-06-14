# Installation Notes

Just finished setting up Alacritty on Pop OS.

What I did:

- installed neovim with apt
- installed omz
- installed p10k with brew
- installed zsh autocompletions and syntax highlighting with brew
- installed JetBrainsMono Nerd Font manually
- installed markdownlint-cli with homebrew (for nvim)

  ```zsh
  wget -P ~/.local/share/fonts https://github.com/ryanoasis/nerd-fonts/releases/download/v3.0.2/JetBrainsMono.zip \
  && cd ~/.local/share/fonts \
  && unzip JetBrainsMono.zip \
  && rm JetBrainsMono.zip \
  && fc-cache -fv
  ```
