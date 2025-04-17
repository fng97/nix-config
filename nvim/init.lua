-- OPTIONS

vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.termguicolors = true
vim.opt.scrolloff = 10 -- pad lines around cursor
vim.opt.breakindent = true -- start with tab in case of line wrap
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
require("lspconfig").pylsp.setup({})
require("lspconfig").pyright.setup({})
require("lspconfig").nixd.setup({})

-- FORMATTING

require("conform").setup({
	format_on_save = {}, -- use defaults
	formatters_by_ft = {
		_ = { "trim_whitespace", "trim_newlines" },
		c = { "clang-format" },
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

local ts = require("telescope.builtin")

-- search
vim.keymap.set("n", "<leader><leader>", ts.find_files, { desc = "Search files" })
vim.keymap.set("n", "<leader>/", ts.live_grep, { desc = "Search content of all files by grep" })
vim.keymap.set("n", "<leader>sc", ts.oldfiles, { desc = "[S]earch recently [C]losed files" })
vim.keymap.set("n", "<leader>sg", ts.current_buffer_fuzzy_find, { desc = "[S]earch buffer by [G]rep" })
vim.keymap.set("n", "<leader>sb", ts.buffers, { desc = "[S]earch [B]uffers" })
vim.keymap.set("n", "<leader>sh", ts.help_tags, { desc = "[S]earch [H]elp" })
vim.keymap.set("n", "<leader>sr", ts.resume, { desc = "[S]earch [R]esume (reopen previous search)" })
vim.keymap.set("n", "<leader>sk", ts.keymaps, { desc = "[S]earch [K]eymaps" })
vim.keymap.set("n", "<leader>sf", function()
	require("telescope.builtin").find_files({ hidden = true, no_ignore = true })
end, { desc = "[S]earch all [F]iles (including hidden/ignored)" })
vim.keymap.set("n", "<leader>ss", ts.lsp_workspace_symbols, { desc = "[S]earch [S]ymbols" })

-- tweak some defaults
vim.keymap.set("v", "<", "<gv", { desc = "Indent Left" })
vim.keymap.set("v", ">", ">gv", { desc = "Indent Right" })
vim.keymap.set({ "n", "x" }, "j", "v:count == 0 ? 'gj' : 'j'", { desc = "Down", expr = true, silent = true })
vim.keymap.set({ "n", "x" }, "k", "v:count == 0 ? 'gk' : 'k'", { desc = "Up", expr = true, silent = true })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = "Page up and center" })
vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = "Page down and center" })
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Clear search highlight" })

-- navigation
vim.keymap.set("n", "<S-h>", "<cmd>bprevious<CR>", { desc = "Previous Buffer" })
vim.keymap.set("n", "<S-l>", "<cmd>bnext<CR>", { desc = "Next Buffer" })
vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "Go to Left Window", remap = true })
vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "Go to Lower Window", remap = true })
vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "Go to Upper Window", remap = true })
vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Go to Right Window", remap = true })
vim.keymap.set("n", "<leader>e", function()
	require("neo-tree.command").execute({
		toggle = true,
		reveal = true,
	})
end, { desc = "UI: Toggle file [E]xplorer tree" })

-- window management
vim.keymap.set("n", "<leader>-", "<C-W>s", { desc = "Split Window Below", remap = true })
vim.keymap.set("n", "<leader>|", "<C-W>v", { desc = "Split Window Right", remap = true })
vim.keymap.set("n", "<leader>dw", "<C-W>c", { desc = "[D]elete [W]indow", remap = true })
vim.keymap.set("n", "<C-Up>", "<cmd>resize +2<CR>", { desc = "Increase Window Height" })
vim.keymap.set("n", "<C-Down>", "<cmd>resize -2<CR>", { desc = "Decrease Window Height" })
vim.keymap.set("n", "<C-Left>", "<cmd>vertical resize -2<CR>", { desc = "Decrease Window Width" })
vim.keymap.set("n", "<C-Right>", "<cmd>vertical resize +2<CR>", { desc = "Increase Window Width" })

-- buffer management
vim.keymap.set("n", "<leader>nb", "<cmd>enew<CR>", { desc = "[N]ew [B]uffer" })
vim.keymap.set("n", "<leader>db", "<cmd>bd<CR>", { desc = "[D]elete [B]uffer" })
vim.keymap.set("n", "<leader>do", function()
	local current = vim.api.nvim_get_current_buf()
	for _, buf in ipairs(vim.api.nvim_list_bufs()) do
		if buf ~= current then
			vim.api.nvim_buf_delete(buf, { force = true })
		end
	end
end, { desc = "[D]elete [O]ther buffers" })

-- clipboard
vim.keymap.set("n", "<leader>y", '"+y', { desc = "Yank to system clipboard" })
vim.keymap.set("n", "<leader>p", '"+p', { desc = "Paste from system clipboard after cursor" })
vim.keymap.set("n", "<leader>yy", '"+yy', { desc = "Yank line to system clipboard" })
vim.keymap.set("n", "<leader>P", '"+P', { desc = "Paste from system clipboard before cursor" })
vim.keymap.set("v", "<leader>y", '"+y', { desc = "Yank selection to system clipboard" })
vim.keymap.set("v", "<leader>p", '"+p', { desc = "Paste selection from system clipboard after cursor" })
vim.keymap.set("v", "<leader>P", '"+P', { desc = "Paste selection from system clipboard before cursor" })

-- lsp goodies
vim.keymap.set("n", "<leader>r", vim.lsp.buf.rename, { desc = "[R]ename symbol" })
vim.keymap.set("n", "gd", ts.lsp_definitions, { desc = "[G]oto [D]efinition" })
vim.keymap.set("n", "gr", ts.lsp_references, { desc = "[G]oto [R]eferences" })
vim.keymap.set("n", "gcd", vim.diagnostic.setloclist, { desc = "[G]oto [C]ode [D]iagnostic" })
vim.keymap.set("n", "gca", vim.lsp.buf.code_action, { desc = "[G]oto [C]ode [A]ction" })

-- ui options
vim.keymap.set("n", "<leader>ud", function()
	vim.diagnostic.config({ virtual_text = not vim.diagnostic.config().virtual_text })
end, { desc = "[U]I: Toggle [D]iagnostics" })
