return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        -- Выключаем старый pyright
        pyright = { enabled = false },

        -- Включаем basedpyright
        basedpyright = {
          enabled = true,
          settings = {
            basedpyright = {
              analysis = {
                typeCheckingMode = "basic", -- "basic" меньше ругается, чем "standard"
                autoImportCompletions = true,
                diagnosticSeverityOverrides = {
                  reportOptionalMemberAccess = "none", -- чтобы не бесило на None
                },
              },
            },
          },
        },
      },
    },
  },
}
