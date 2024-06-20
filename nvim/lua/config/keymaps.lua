-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local map = vim.keymap.set

-- Center cursor when scrolling half pages
map("n", "<C-u>", "<C-u>zz")
map("n", "<C-d>", "<C-d>zz")
