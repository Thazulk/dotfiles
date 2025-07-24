return {
  {
    "mbbill/undotree",
    lazy = false,
  },
  vim.keymap.set("n", "<leader>uu", vim.cmd.UndotreeToggle, { desc = "Toggle undotree" }),
}
