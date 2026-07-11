return {
  {
    "lervag/vimtex",
    lazy = false,
    config = function()
      vim.g.vimtex_view_method = "zathura"
      vim.g.vimtex_compiler_method = "latexmk"
      vim.g.vimtex_compiler_latexmk = {
        out_dir = "build",
        options = {
          "-pdf",
          "-interaction=nonstopmode",
          "-file-line-error",
        },
      }
    end,
  },
}
