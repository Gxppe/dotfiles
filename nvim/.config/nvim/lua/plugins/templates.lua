return {
  {
    "nvim-telescope/telescope.nvim",
    keys = {
      {
        "<leader>ft",
        function()
          local template_dir = vim.fn.expand("~/.config/nvim/templates/")
          require("telescope.builtin").find_files({
            prompt_title = "Plantillas LaTeX",
            cwd = template_dir,
            attach_mappings = function(_, map)
              map("i", "<CR>", function(bufnr)
                local selection = require("telescope.actions.state").get_selected_entry()
                require("telescope.actions").close(bufnr)
                local template_path = template_dir .. selection.value
                local lines = vim.fn.readfile(template_path)
                vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
              end)
              return true
            end,
          })
        end,
        desc = "Insertar plantilla LaTeX",
      },
    },
  },
}
