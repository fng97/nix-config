-- Ignore the user lua configuration
vim.opt.runtimepath:remove(vim.fn.stdpath("config")) -- ~/.config/nvim
vim.opt.runtimepath:remove(vim.fn.stdpath("config") .. "/after") -- ~/.config/nvim/after

-- Nixvim's internal module table
-- Can be used to share code throughout init.lua
local _M = {}

-- Set up globals {{{
do
	local nixvim_globals = { mapleader = " ", maplocalleader = " " }

	for k, v in pairs(nixvim_globals) do
		vim.g[k] = v
	end
end
-- }}}

-- Set up options {{{
do
	local nixvim_options = {
		confirm = true,
		expandtab = true,
		ignorecase = true,
		number = true,
		relativenumber = true,
		shiftwidth = 2,
		showmode = false,
		smartcase = true,
		smartindent = true,
		softtabstop = 2,
		tabstop = 2,
		termguicolors = true,
	}

	for k, v in pairs(nixvim_options) do
		vim.opt[k] = v
	end
end
-- }}}

require("gruvbox").setup({})

vim.cmd([[let $BAT_THEME = 'gruvbox'

colorscheme gruvbox
]])
require("nvim-web-devicons").setup({})

-- LSP {{{
do
	local __lspServers = {
		{ name = "zls" },
		{ name = "rust_analyzer" },
		{ name = "ruff" },
		{ name = "pylsp" },
		{ name = "nixd" },
		{ name = "cmake" },
		{ name = "clangd" },
	}
	-- Adding lspOnAttach function to nixvim module lua table so other plugins can hook into it.
	_M.lspOnAttach = function(client, bufnr)
		require("lsp-format").on_attach(client)
	end
	local __lspCapabilities = function()
		capabilities = vim.lsp.protocol.make_client_capabilities()

		return capabilities
	end

	local __setup = {
		on_attach = _M.lspOnAttach,
		capabilities = __lspCapabilities(),
	}

	for i, server in ipairs(__lspServers) do
		if type(server) == "string" then
			require("lspconfig")[server].setup(__setup)
		else
			local options = server.extraOptions

			if options == nil then
				options = __setup
			else
				options = vim.tbl_extend("keep", options, __setup)
			end

			require("lspconfig")[server.name].setup(options)
		end
	end
end
-- }}}

require("which-key").setup({})

vim.opt.runtimepath:prepend(vim.fs.joinpath(vim.fn.stdpath("data"), "site"))
require("nvim-treesitter.configs").setup({ parser_install_dir = vim.fs.joinpath(vim.fn.stdpath("data"), "site") })

require("telescope").setup({})

local __telescopeExtensions = {}
for i, extension in ipairs(__telescopeExtensions) do
	require("telescope").load_extension(extension)
end

require("snacks").setup({})

require("nvim-autopairs").setup({})

require("lualine").setup({})

require("lsp-format").setup({})

require("copilot").setup({
	copilot_node_command = "/nix/store/8wq28rxvbkpsqs7j818znjzxnqy4i72c-nodejs-18.20.7/bin/node",
})

require("conform").setup({
	format_on_save = function(bufnr)
		if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
			return
		end

		return { timeout_ms = 500, lsp_fallback = true }
	end,
	formatters_by_ft = {
		_ = { "trim_whitespace", "trim_newlines" },
		bash = { "shellcheck", "shfmt" },
		cmake = { "cmake_format" },
		cpp = { "clang-format" },
		json = { "prettier" },
		lua = { "stylua" },
		markdown = { "prettier" },
		nix = { "nixfmt" },
		python = { "black" },
		rust = { "rustfmt" },
		toml = { "prettier" },
		yaml = { "prettier" },
	},
})

require("bufferline").setup({ options = { always_show_bufferline = false } })

require("neo-tree").setup({ document_symbols = { custom_kinds = {} } })

-- Set up keybinds {{{
do
	local __nixvim_binds = {
		{
			action = function()
				require("neo-tree.command").execute({
					toggle = true,
					reveal = true,
				})
			end,
			key = "<leader>e",
			mode = "n",
			options = { desc = "Reveal file tree" },
		},
		{ action = "<cmd>nohlsearch<CR>", key = "<Esc>", mode = "n" },
		{
			action = function()
				Snacks.bufdelete()
			end,
			key = "<leader>bd",
			mode = "n",
			options = { desc = "Delete buffer" },
		},
		{
			action = function()
				Snacks.bufdelete.other()
			end,
			key = "<leader>bo",
			mode = "n",
			options = { desc = "Delete other buffers" },
		},
		{
			action = function()
				require("telescope.builtin").find_files({ hidden = true, no_ignore = true })
			end,
			key = "<leader>fF",
			mode = "n",
			options = { desc = "Find all files" },
		},
		{
			action = function()
				require("telescope.builtin").find_files()
			end,
			key = "<leader><leader>",
			mode = "n",
			options = { desc = "Find files" },
		},
		{
			action = function()
				require("telescope.builtin").live_grep()
			end,
			key = "<leader>/",
			mode = "n",
			options = { desc = "Live grep" },
		},
	}
	for i, map in ipairs(__nixvim_binds) do
		vim.keymap.set(map.mode, map.key, map.action, map.options)
	end
end
-- }}}

local map = vim.keymap.set

-- better up/down
map({ "n", "x" }, "j", "v:count == 0 ? 'gj' : 'j'", { desc = "Down", expr = true, silent = true })
map({ "n", "x" }, "<Down>", "v:count == 0 ? 'gj' : 'j'", { desc = "Down", expr = true, silent = true })
map({ "n", "x" }, "k", "v:count == 0 ? 'gk' : 'k'", { desc = "Up", expr = true, silent = true })
map({ "n", "x" }, "<Up>", "v:count == 0 ? 'gk' : 'k'", { desc = "Up", expr = true, silent = true })

-- center on page up/down
map("n", "<C-u>", "<C-u>zz")
map("n", "<C-d>", "<C-d>zz")

-- Move to window using the <ctrl> hjkl keys
map("n", "<C-h>", "<C-w>h", { desc = "Go to Left Window", remap = true })
map("n", "<C-j>", "<C-w>j", { desc = "Go to Lower Window", remap = true })
map("n", "<C-k>", "<C-w>k", { desc = "Go to Upper Window", remap = true })
map("n", "<C-l>", "<C-w>l", { desc = "Go to Right Window", remap = true })

-- Resize window using <ctrl> arrow keys
map("n", "<C-Up>", "<cmd>resize +2<cr>", { desc = "Increase Window Height" })
map("n", "<C-Down>", "<cmd>resize -2<cr>", { desc = "Decrease Window Height" })
map("n", "<C-Left>", "<cmd>vertical resize -2<cr>", { desc = "Decrease Window Width" })
map("n", "<C-Right>", "<cmd>vertical resize +2<cr>", { desc = "Increase Window Width" })

-- Move Lines
map("n", "<A-j>", "<cmd>execute 'move .+' . v:count1<cr>==", { desc = "Move Down" })
map("n", "<A-k>", "<cmd>execute 'move .-' . (v:count1 + 1)<cr>==", { desc = "Move Up" })
map("i", "<A-j>", "<esc><cmd>m .+1<cr>==gi", { desc = "Move Down" })
map("i", "<A-k>", "<esc><cmd>m .-2<cr>==gi", { desc = "Move Up" })
map("v", "<A-j>", ":<C-u>execute \"'<,'>move '>+\" . v:count1<cr>gv=gv", { desc = "Move Down" })
map("v", "<A-k>", ":<C-u>execute \"'<,'>move '<-\" . (v:count1 + 1)<cr>gv=gv", { desc = "Move Up" })

-- buffers
map("n", "<S-h>", "<cmd>bprevious<cr>", { desc = "Prev Buffer" })
map("n", "<S-l>", "<cmd>bnext<cr>", { desc = "Next Buffer" })
map("n", "<leader>bD", "<cmd>:bd<cr>", { desc = "Delete Buffer and Window" })

-- save file
map({ "i", "x", "n", "s" }, "<C-s>", "<cmd>w<cr><esc>", { desc = "Save File" })

-- better indenting
map("v", "<", "<gv")
map("v", ">", ">gv")

-- go to header/impl
map("n", "gD", "<cmd>lua vim.lsp.buf.declaration()<cr>", { desc = "Go to declaration" })
map("n", "gd", "<cmd>lua vim.lsp.buf.definition()<cr>", { desc = "Go to definition" })

-- new file
map("n", "<leader>fn", "<cmd>enew<cr>", { desc = "New File" })

-- toggle options
Snacks.toggle.diagnostics():map("<leader>ud")
if vim.lsp.inlay_hint then
	Snacks.toggle.inlay_hints():map("<leader>uh")
end

-- lazygit
if vim.fn.executable("lazygit") == 1 then
	map("n", "<leader>gg", function()
		Snacks.lazygit()
	end, { desc = "Lazygit (cwd)" })
end

map("n", "<leader>gb", function()
	Snacks.git.blame_line()
end, { desc = "Git Blame Line" })
map({ "n", "x" }, "<leader>gB", function()
	Snacks.gitbrowse()
end, { desc = "Git Browse (open)" })

-- quit
map("n", "<leader>qq", "<cmd>qa<cr>", { desc = "Quit All" })

-- windows
map("n", "<leader>w", "<c-w>", { desc = "Windows", remap = true })
map("n", "<leader>-", "<C-W>s", { desc = "Split Window Below", remap = true })
map("n", "<leader>|", "<C-W>v", { desc = "Split Window Right", remap = true })
map("n", "<leader>wd", "<C-W>c", { desc = "Delete Window", remap = true })

-- system clipboard
vim.api.nvim_set_keymap(
	"n",
	"<leader>y",
	'"+y',
	{ noremap = true, silent = true, desc = "Yank to system clipboard (motion, e.g. <leader>yib)" }
)
vim.api.nvim_set_keymap(
	"n",
	"<leader>p",
	'"+p',
	{ noremap = true, silent = true, desc = "Paste from system clipboard after cursor" }
)
vim.api.nvim_set_keymap(
	"n",
	"<leader>P",
	'"+P',
	{ noremap = true, silent = true, desc = "Paste from system clipboard before cursor" }
)
vim.api.nvim_set_keymap(
	"v",
	"<leader>y",
	'"+y',
	{ noremap = true, silent = true, desc = "Yank selection to system clipboard" }
)
vim.api.nvim_set_keymap(
	"v",
	"<leader>p",
	'"+p',
	{ noremap = true, silent = true, desc = "Paste from system clipboard after cursor" }
)
vim.api.nvim_set_keymap(
	"v",
	"<leader>P",
	'"+P',
	{ noremap = true, silent = true, desc = "Paste from system clipboard before cursor" }
)

-- Set up autogroups {{
do
	local __nixvim_autogroups = { nixvim_binds_LspAttach = { clear = true } }

	for group_name, options in pairs(__nixvim_autogroups) do
		vim.api.nvim_create_augroup(group_name, options)
	end
end
-- }}
-- Set up autocommands {{
do
	local __nixvim_autocommands = {
		{
			callback = function(args)
				do
					local __nixvim_binds = {}

					for i, map in ipairs(__nixvim_binds) do
						local options = vim.tbl_extend("keep", map.options or {}, { buffer = args.buf })
						vim.keymap.set(map.mode, map.key, map.action, options)
					end
				end
			end,
			desc = "Load keymaps for LspAttach",
			event = "LspAttach",
			group = "nixvim_binds_LspAttach",
		},
		{ command = "lua vim.highlight.on_yank{timeout=150}", event = "TextYankPost", pattern = "*" },
	}

	for _, autocmd in ipairs(__nixvim_autocommands) do
		vim.api.nvim_create_autocmd(autocmd.event, {
			group = autocmd.group,
			pattern = autocmd.pattern,
			buffer = autocmd.buffer,
			desc = autocmd.desc,
			callback = autocmd.callback,
			command = autocmd.command,
			once = autocmd.once,
			nested = autocmd.nested,
		})
	end
end
-- }}
