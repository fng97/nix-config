-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")

-- Hard wrap markdown because markdown-cli doesn't
vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.textwidth = 80
    vim.cmd("setlocal formatoptions+=t")
  end,
})
