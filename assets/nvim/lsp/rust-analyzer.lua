return {
  cargo = {
    allFeatures = true,
    loadOutDirsFromCheck = true,
    buildScripts = {
      enable = true,
    },
  },
  -- Add clippy lints for Rust.
  checkOnSave = true,
  procMacro = {
    enable = true,
    ignored = {
      ["async-trait"] = { "async_trait" },
      ["napi-derive"] = { "napi" },
      ["async-recursion"] = { "async_recursion" },
    },
  },
}
