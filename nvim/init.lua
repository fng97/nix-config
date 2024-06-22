-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")

-- hard wrap markdown because markdown-cli doesn't
vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.textwidth = 80
    vim.cmd("setlocal formatoptions+=t")
  end,
})

-- fix WSL clipboard
vim.g.clipboard = {
  name = "win32yank-wsl",
  copy = {
    ["+"] = "win32yank.exe -i --crlf",
    ["*"] = "win32yank.exe -i --crlf",
  },
  paste = {
    ["+"] = "win32yank.exe -o --lf",
    ["*"] = "win32yank.exe -o --lf",
  },
  cache_enabled = false,
}
