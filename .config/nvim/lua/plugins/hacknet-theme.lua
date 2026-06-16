local palette = {
  bg = "#071015",
  bg_dark = "#050a0e",
  bg_panel = "#0a151b",
  bg_float = "#0b171e",
  border = "#17313b",
  border_dim = "#10252d",
  cyan = "#7dd7e5",
  cyan_dim = "#58a9b8",
  blue = "#6f91b6",
  blue_dim = "#48657e",
  green = "#92cda0",
  green_dim = "#6b9b76",
  text = "#d7e4ea",
  subtext = "#aabdc6",
  muted = "#758a95",
  red = "#c97474",
  yellow = "#c7b36a",
}

local function lualine_theme()
  return {
    normal = {
      a = { fg = palette.bg_dark, bg = palette.cyan, gui = "bold" },
      b = { fg = palette.cyan, bg = palette.bg_panel },
      c = { fg = palette.text, bg = palette.bg_dark },
    },
    insert = {
      a = { fg = palette.bg_dark, bg = palette.green, gui = "bold" },
      b = { fg = palette.green, bg = palette.bg_panel },
    },
    visual = {
      a = { fg = palette.bg_dark, bg = palette.blue, gui = "bold" },
      b = { fg = palette.blue, bg = palette.bg_panel },
    },
    replace = {
      a = { fg = palette.bg_dark, bg = palette.red, gui = "bold" },
      b = { fg = palette.red, bg = palette.bg_panel },
    },
    command = {
      a = { fg = palette.bg_dark, bg = palette.yellow, gui = "bold" },
      b = { fg = palette.yellow, bg = palette.bg_panel },
    },
    inactive = {
      a = { fg = palette.muted, bg = palette.bg_dark },
      b = { fg = palette.muted, bg = palette.bg_dark },
      c = { fg = palette.muted, bg = palette.bg_dark },
    },
  }
end

return {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    opts = {
      flavour = "mocha",
      transparent_background = true,
      term_colors = true,
      styles = {
        comments = { "italic" },
        conditionals = {},
        loops = {},
        functions = {},
        keywords = {},
        strings = {},
        variables = {},
      },
      color_overrides = {
        all = {
          rosewater = palette.text,
          flamingo = palette.text,
          pink = palette.cyan_dim,
          mauve = palette.blue,
          red = palette.red,
          maroon = palette.red,
          peach = palette.yellow,
          yellow = palette.yellow,
          green = palette.green,
          teal = palette.green_dim,
          sky = palette.cyan,
          sapphire = palette.cyan_dim,
          blue = palette.blue,
          lavender = palette.blue,
          text = palette.text,
          subtext1 = palette.subtext,
          subtext0 = palette.muted,
          overlay2 = palette.subtext,
          overlay1 = palette.muted,
          overlay0 = palette.blue_dim,
          surface2 = palette.border,
          surface1 = palette.border_dim,
          surface0 = palette.bg_panel,
          base = palette.bg,
          mantle = palette.bg_panel,
          crust = palette.bg_dark,
        },
      },
      custom_highlights = function(colors)
        return {
          NormalFloat = { fg = colors.text, bg = palette.bg_float },
          FloatBorder = { fg = palette.border, bg = palette.bg_float },
          FloatTitle = { fg = palette.cyan, bg = palette.bg_float, style = { "bold" } },
          Pmenu = { fg = colors.text, bg = palette.bg_float },
          PmenuSel = { fg = palette.bg_dark, bg = palette.cyan },
          CursorLine = { bg = "#102029" },
          CursorLineNr = { fg = palette.cyan, style = { "bold" } },
          LineNr = { fg = palette.blue_dim },
          WinSeparator = { fg = palette.border_dim },
          VertSplit = { fg = palette.border_dim },
          StatusLine = { fg = colors.text, bg = palette.bg_dark },
          StatusLineNC = { fg = palette.muted, bg = palette.bg_dark },
          TabLineFill = { bg = palette.bg_dark },
          Search = { fg = palette.bg_dark, bg = palette.cyan_dim },
          IncSearch = { fg = palette.bg_dark, bg = palette.green },
          Visual = { bg = "#173945" },
          DiagnosticError = { fg = palette.red },
          DiagnosticWarn = { fg = palette.yellow },
          DiagnosticInfo = { fg = palette.cyan_dim },
          DiagnosticHint = { fg = palette.green_dim },
          GitSignsAdd = { fg = palette.green_dim },
          GitSignsChange = { fg = palette.cyan_dim },
          GitSignsDelete = { fg = palette.red },
          NeoTreeNormal = { fg = colors.text, bg = "NONE" },
          NeoTreeNormalNC = { fg = colors.text, bg = "NONE" },
          NeoTreeWinSeparator = { fg = palette.border_dim, bg = "NONE" },
          SnacksPicker = { fg = colors.text, bg = palette.bg_float },
          SnacksPickerBorder = { fg = palette.border, bg = palette.bg_float },
          SnacksPickerInput = { fg = colors.text, bg = palette.bg_panel },
          SnacksPickerMatch = { fg = palette.cyan, style = { "bold" } },
        }
      end,
      integrations = {
        bufferline = true,
        gitsigns = true,
        lsp_trouble = true,
        mason = true,
        mini = true,
        native_lsp = {
          enabled = true,
          virtual_text = {
            errors = {},
            hints = {},
            warnings = {},
            information = {},
          },
        },
        neotree = true,
        noice = true,
        snacks = true,
        treesitter = true,
        which_key = true,
      },
    },
  },

  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "catppuccin-mocha",
    },
  },

  {
    "nvim-lualine/lualine.nvim",
    opts = function(_, opts)
      opts.options = opts.options or {}
      opts.options.theme = lualine_theme()
      opts.options.globalstatus = true
      opts.options.section_separators = { left = "", right = "" }
      opts.options.component_separators = { left = "|", right = "|" }
      opts.options.disabled_filetypes = opts.options.disabled_filetypes or {}
      opts.options.disabled_filetypes.statusline = { "dashboard", "snacks_dashboard" }
    end,
  },

  {
    "akinsho/bufferline.nvim",
    opts = function(_, opts)
      opts.options = opts.options or {}
      opts.options.separator_style = "thin"
      opts.options.indicator = { style = "none" }
      opts.options.show_buffer_close_icons = false
      opts.options.show_close_icon = false
      local base_highlights = opts.highlights
      opts.highlights = function()
        local highlights = type(base_highlights) == "function" and base_highlights() or base_highlights or {}
        return vim.tbl_deep_extend("force", highlights, {
          fill = { bg = palette.bg_dark },
          background = { fg = palette.muted, bg = palette.bg_dark },
          buffer_selected = { fg = palette.text, bg = palette.bg_dark, bold = true },
          indicator_selected = { fg = palette.cyan, bg = palette.bg_dark },
          separator = { fg = palette.border_dim, bg = palette.bg_dark },
          separator_selected = { fg = palette.border, bg = palette.bg_dark },
          modified = { fg = palette.green_dim, bg = palette.bg_dark },
          modified_selected = { fg = palette.green, bg = palette.bg_dark },
        })
      end
    end,
  },
}
