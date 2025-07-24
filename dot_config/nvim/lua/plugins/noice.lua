return {
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    opts = {
      lsp = {

        hover = {
          -- Set not show a message if hover is not available
          -- ex: shift+k on Typescript code
          silent = true,
        },
      },
      views = {
        mini = {
          win_options = {
            winblend = 0,
          },
        },
      },
    },
  },
}
