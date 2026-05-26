require("nvchad.configs.lspconfig").defaults()

local servers = { "html", "cssls" }
vim.lsp.enable(servers)

-- read :h vim.lsp.config for changing options of lsp servers 
vim.lsp.config("yamlls", {
  -- on_attach = nvlsp.on_attach,
  -- on_init = nvlsp.on_init,
  -- capabilities = nvlsp.capabilities,
  settings = {
    yaml = {
      schemas = {
        ["https://raw.githubusercontent.com/srl-labs/containerlab/refs/heads/main/schemas/clab.schema.json"] = {
          "/*.clab.yml",
          "/*.clab.yaml",
          "clab.yaml",
        },
      },
      validate = true,
      completion = true,
      hover = true,
    },
  },
})

-- Now enable it
vim.lsp.enable("yamlls")
