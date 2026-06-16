return {
  {
    "MeanderingProgrammer/render-markdown.nvim",
    ft = { "markdown", "vimwiki" },
    opts = {
      file_types = { "markdown", "vimwiki" },
      latex = {
        enabled = false,
      },
    },
    keys = {
      {
        "<leader>mt",
        "<cmd>RenderMarkdown toggle<CR>",
        desc = "Toggle Markdown Render",
      },
    },
  },
}
