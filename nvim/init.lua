-- OPTIONS

vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.termguicolors = true
vim.opt.undofile = true -- persist undo history
vim.opt.cmdheight = 0 -- hide command line unless active
vim.opt.confirm = true -- don't fail silently
vim.opt.ignorecase = true -- ignore case when searching...
vim.opt.smartcase = true -- unless uppercase used in search
vim.opt.textwidth = 120 -- break lines at 120
vim.opt.tabstop = 2 -- a tab character is displayed as 2 spaces
vim.opt.softtabstop = 2 -- pressing tab inserts 2 spaces
vim.opt.shiftwidth = 2 -- indentation uses 2 spaces
vim.opt.expandtab = true -- convert tabs to spaces
vim.opt.smartindent = true -- automatically indent new lines

-- AUTOCOMMANDS

vim.api.nvim_create_autocmd("TextYankPost", {
	pattern = "*",
	callback = function()
		vim.highlight.on_yank({ timeout = 150 })
	end,
	desc = "Highlight yanked text",
})

vim.api.nvim_create_autocmd("FileType", {
	pattern = { "cpp", "c" },
	callback = function()
		vim.bo.commentstring = "// %s"
	end,
	desc = "Set comment style to '//' for C and C++ (default is '/**/')",
})

-- APPEARANCE

require("catppuccin").setup({
	background = { light = "latte", dark = "frappe" },
})

vim.cmd.colorscheme("catppuccin")

require("lualine").setup({
	options = { globalstatus = true },
	sections = {
		lualine_c = { { "buffers", max_length = vim.o.columns * 2 / 3 } },
		lualine_x = { "searchcount", "progress" },
		lualine_y = { "location" },
		lualine_z = { { "datetime", style = "%d/%m/%y %H:%M" } },
	},
})

require("auto-dark-mode").setup({ update_interval = 1000 })

-- LSP

-- vim.lsp.enable("clangd") -- FIXME: below is legacy, switch to this style once upgraded to nvim 0.11+
require("lspconfig").clangd.setup({})
require("lspconfig").ruff.setup({})

-- FORMATTING

require("conform").setup({
	format_on_save = {},
	formatters_by_ft = {
		_ = { "trim_whitespace", "trim_newlines" },
		cpp = { "clang-format" },
		zig = { "zigfmt" },
		rust = { "rustfmt" },
		cmake = { "cmake_format" },
		python = { "ruff_format" },
		bash = { "shfmt" },
		lua = { "stylua" },
		nix = { "nixfmt" },
		markdown = { "prettier" },
		json = { "jq" },
	},
})

-- KEY MAPPINGS

local map = vim.keymap.set

-- file operations
map("n", "<leader>w", ":w<CR>", { desc = "Save file" })
map("n", "<leader>q", ":q<CR>", { desc = "Quit" })
map("n", "<leader>wq", ":wq<CR>", { desc = "Save and quit" })
map("n", "<leader>fn", "<cmd>enew<CR>", { desc = "New File" })

-- toggle neo-tree
map("n", "<leader>e", function()
	require("neo-tree.command").execute({
		toggle = true,
		reveal = true,
	})
end, { desc = "Toggle file tree" })

-- telescope
map("n", "<leader><leader>", "<cmd>Telescope find_files<CR>", { desc = "Find files" })
map("n", "<leader>/", "<cmd>Telescope live_grep<CR>", { desc = "Live grep" })
map("n", "<leader>fb", "<cmd>Telescope buffers<CR>", { desc = "Find buffers" })
map("n", "<leader>fh", "<cmd>Telescope help_tags<CR>", { desc = "Find help" })
map("n", "<leader>fr", "<cmd>Telescope oldfiles<CR>", { desc = "Find recently opened files" })
map("n", "<leader>fk", "<cmd>Telescope keymaps<CR>", { desc = "Search keymaps" })
map("n", "<leader>ff", function()
	require("telescope.builtin").find_files({ hidden = true, no_ignore = true })
end, { desc = "Find all files" })

-- navigation
map({ "n", "x" }, "j", "v:count == 0 ? 'gj' : 'j'", { desc = "Down", expr = true, silent = true })
map({ "n", "x" }, "k", "v:count == 0 ? 'gk' : 'k'", { desc = "Up", expr = true, silent = true })
map("n", "<C-u>", "<C-u>zz", { desc = "Page up and center" })
map("n", "<C-d>", "<C-d>zz", { desc = "Page down and center" })

-- better visual mode indentation (indent without deselecting)
map("v", "<", "<gv", { desc = "Indent Left" })
map("v", ">", ">gv", { desc = "Indent Right" })

-- clear search highlighting
map("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Clear search highlight" })

-- window management
map("n", "<C-h>", "<C-w>h", { desc = "Go to Left Window", remap = true })
map("n", "<C-j>", "<C-w>j", { desc = "Go to Lower Window", remap = true })
map("n", "<C-k>", "<C-w>k", { desc = "Go to Upper Window", remap = true })
map("n", "<C-l>", "<C-w>l", { desc = "Go to Right Window", remap = true })
map("n", "<leader>-", "<C-W>s", { desc = "Split Window Below", remap = true })
map("n", "<leader>|", "<C-W>v", { desc = "Split Window Right", remap = true })
map("n", "<leader>wd", "<C-W>c", { desc = "Delete Window", remap = true })

-- resize windows
map("n", "<C-Up>", "<cmd>resize +2<CR>", { desc = "Increase Window Height" })
map("n", "<C-Down>", "<cmd>resize -2<CR>", { desc = "Decrease Window Height" })
map("n", "<C-Left>", "<cmd>vertical resize -2<CR>", { desc = "Decrease Window Width" })
map("n", "<C-Right>", "<cmd>vertical resize +2<CR>", { desc = "Increase Window Width" })

-- buffer management
map("n", "<S-h>", "<cmd>bprevious<CR>", { desc = "Previous Buffer" })
map("n", "<S-l>", "<cmd>bnext<CR>", { desc = "Next Buffer" })
map("n", "<leader>bd", "<cmd>bd<CR>", { desc = "Delete buffer" })
map("n", "<leader>bo", "<cmd>%bd|e#|bd#<CR>", { desc = "Delete other buffers" })

-- clipboard
map("n", "<leader>y", '"+y', { desc = "Yank to system clipboard" })
map("n", "<leader>p", '"+p', { desc = "Paste from system clipboard after cursor" })
map("n", "<leader>P", '"+P', { desc = "Paste from system clipboard before cursor" })
map("v", "<leader>y", '"+y', { desc = "Yank selection to system clipboard" })
map("v", "<leader>p", '"+p', { desc = "Paste selection from system clipboard after cursor" })
map("v", "<leader>P", '"+P', { desc = "Paste selection from system clipboard before cursor" })

-- lsp
map("n", "gD", "<cmd>lua vim.lsp.buf.declaration()<CR>", { desc = "Go to declaration" })
map("n", "gd", "<cmd>lua vim.lsp.buf.definition()<CR>", { desc = "Go to definition" })

-- ui
map("n", "<leader>ud", function()
	vim.diagnostic.config({ virtual_text = not vim.diagnostic.config().virtual_text })
end, { desc = "Toggle Diagnostics" })
