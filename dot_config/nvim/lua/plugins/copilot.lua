return {
  "zbirenbaum/copilot.lua",
  keys = {
    {
      "<leader>at",
      function()
        if require("copilot.client").is_disabled() then
          require("copilot.command").enable()
          print("Copilot enabled")
        else
          require("copilot.command").disable()
          print("Copilot disabled")
        end
      end,
      desc = "Toggle (Copilot)",
    },
  },
}
