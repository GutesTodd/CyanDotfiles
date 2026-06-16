return {
  {
    -- 1. Подменяем источник: вместо folke указываем автора форка
    "mateuszsip/sidekick.nvim",
    -- 2. Убираем version = "*", так как мы тянем конкретную ветку
    branch = "feat/agy-cli",

    opts = function(_, opts)
      -- Базовая настройка NES для Copilot
      LazyVim.cmp.actions.ai_nes = function()
        local Nes = require("sidekick.nes")
        if Nes.have() and (Nes.jump() or Nes.apply()) then
          return true
        end
      end

      Snacks.toggle({
        name = "Sidekick NES",
        get = function()
          return require("sidekick.nes").enabled
        end,
        set = function(state)
          require("sidekick.nes").enable(state)
        end,
      }):map("<leader>uN")

      -- Поскольку в форке уже есть нативная поддержка,
      -- нам больше не нужны никакие махинации с opts.cli.tools.
      -- Плагин сам найдет agy в твоем $PATH.

      return opts
    end,
    -- stylua: ignore
    keys = {
      { "<tab>", function() LazyVim.cmp.map({ "ai_nes" }, "<tab>") end, mode = { "n" }, expr = true },
      { "<leader>a", "", desc = "+ai", mode = { "n", "v" } },
      { "<c-.>", function() require("sidekick.cli").focus() end, desc = "Sidekick Focus", mode = { "n", "t", "i", "x" } },
      { "<leader>aa", function() require("sidekick.cli").toggle() end, desc = "Sidekick Toggle CLI" },
      { "<leader>as", function() require("sidekick.cli").select() end, desc = "Select CLI" },
      { "<leader>ad", function() require("sidekick.cli").close() end, desc = "Detach a CLI Session" },
      { "<leader>at", function() require("sidekick.cli").send({ msg = "{this}" }) end, mode = { "x", "n" }, desc = "Send This" },
      { "<leader>af", function() require("sidekick.cli").send({ msg = "{file}" }) end, desc = "Send File" },
      { "<leader>av", function() require("sidekick.cli").send({ msg = "{selection}" }) end, mode = { "x" }, desc = "Send Visual Selection" },
      { "<leader>ap", function() require("sidekick.cli").prompt() end, mode = { "n", "x" }, desc = "Sidekick Select Prompt" },
    },
  },

  {
    "folke/snacks.nvim",
    optional = true,
    opts = {
      picker = {
        actions = {
          sidekick_send = function(...)
            return require("sidekick.cli.picker.snacks").send(...)
          end,
        },
        win = {
          input = {
            keys = {
              ["<a-a>"] = {
                "sidekick_send",
                mode = { "n", "i" },
              },
            },
          },
        },
      },
    },
  },

  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      local sk = LazyVim.opts("sidekick.nvim") ---@type sidekick.Config|{}
      if vim.tbl_get(sk, "nes", "enabled") ~= false then
        opts.servers = opts.servers or {}
        opts.servers.copilot = opts.servers.copilot or {}
      end
    end,
  },
}
