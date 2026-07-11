return {
  "HakonHarnes/img-clip.nvim",
  event = "VeryLazy",
  opts = {
    default = {
      -- guarda las imágenes en una carpeta junto al .tex
      dir_path = "figures",
      file_name = "%Y-%m-%d-%H-%M-%S",
      use_absolute_path = false,
    },
    filetypes = {
      tex = {
        template = [[
\begin{figure}[htbp]
  \centering
  \includegraphics[width=0.8\textwidth]{$FILE_PATH}
  \caption{$CURSOR}
  \label{fig:$LABEL}
\end{figure}
        ]],
      },
    },
  },
  keys = {
    { "<leader>p", "<cmd>PasteImage<cr>", desc = "Pegar imagen del portapapeles" },
  },
}
