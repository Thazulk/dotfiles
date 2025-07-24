-- Define the on_highlights function
local function set_highlights()
  local hl = vim.api.nvim_set_hl
  local c = require("tokyonight.colors").setup()

  hl(0, "DiagnosticVirtualTextError", { fg = c.error, bg = "none", blend = 100 })
  hl(0, "DiagnosticVirtualTextWarn", { fg = c.warning, bg = "none", blend = 100 })
  hl(0, "DiagnosticVirtualTextInfo", { fg = c.info, bg = "none", blend = 100 })
  hl(0, "DiagnosticVirtualTextHint", { fg = c.hint, bg = "none", blend = 100 })
  hl(0, "LspInlayHint", { fg = c.fg_dark, bg = "none", blend = 100 })
end

-- Apply the highlights after all plugins have been loaded
-- vim.api.nvim_create_autocmd("User", {
--   pattern = "LazyVimStarted",
--   callback = set_highlights,
-- })
--

-- Apply the highlights after the colorscheme has been loaded
vim.api.nvim_create_autocmd("ColorScheme", {
  pattern = "*",
  callback = set_highlights,
})

return {
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    opts = {
      transparent = true,
      styles = {
        sidebars = "transparent",
        floats = "transparent",
      },
      terminal_colors = true,
      sidebars = {},
      undercurl = true, -- Enable curly underlines
      underline = true, -- Enable terminal underline
      -- on_highlights = function(hl, c)
      --   hl.diagnosticVirtualTextError = {
      --     fg = c.error,
      --     bg = "none",
      --     blend = 100,
      --   }
      --   hl.diagnosticVirtualTextWarn = {
      --     fg = c.warning,
      --     bg = "none",
      --     blend = 100,
      --   }
      --   hl.diagnosticVirtualTextInfo = {
      --     fg = c.info,
      --     bg = "none",
      --     blend = 0,
      --   }
      --   hl.diagnosticVirtualTextHint = {
      --     fg = c.hint,
      --     bg = "none",
      --     blend = 0,
      --   }
      --   hl.LspInlayHint = {
      --     fg = c.fg_dark,
      --     bg = "none",
      --     blend = 100,
      --   }
      -- end,
    },
  }, -- add gruvbox
  { "ellisonleao/gruvbox.nvim", opts = {
    transparent_mode = true,
  } },

  --add rose-pine
  {
    "rose-pine/neovim",
    name = "rose-pine",
    opts = {
      styles = {
        bold = true,
        italic = false,
        transparency = true,
      },
    },
  },

  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "tokyonight",
    },
  },
}
