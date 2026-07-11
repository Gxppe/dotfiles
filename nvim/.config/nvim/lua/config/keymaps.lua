-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
--
--
--
vim.keymap.set("n", "<leader>lt", function()
  local template = vim.fn.readfile("/home/bonpepe/.config/nvim/templates/template_informe.tex")
  vim.api.nvim_buf_set_lines(0, 0, -1, false, template)
end, { desc = "Cargar plantilla LaTeX" })
