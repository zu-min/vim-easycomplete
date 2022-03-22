local Util = require "easycomplete_util"
local Servers = require("nvim-lsp-installer.servers")
local console = Util.console
local log = Util.log
local AutoLoad = {}

AutoLoad.lua = {
  setup = function(self)
    local curr_plugin_ctx = Util.current_plugin_ctx()
    local plugin_name = Util.current_plugin_name()
    local curr_lsp_name = Util.current_lsp_name()
    local ok, server = Servers.get_server(curr_lsp_name)
    if not ok then
      return
    end

    local lua_config_path = Util.get_default_config_path()
    local lua_cmd_full_path = Util.get_default_command_full_path()
    local nvim_lsp_root = Util.get(server, "root_dir")
    local nvim_cmd_path = vim.fn.join({nvim_lsp_root, "extension", "server", "bin"}, "/")
    local nvim_cmd_bin = "lua-language-server"
    local nvim_lua_script = "main.lua"
    local full_cmd_str = vim.fn.join({
      nvim_cmd_path .. "/" .. nvim_cmd_bin,
      "-E",
      "-e",
      "LANG=en",
      nvim_cmd_path .. "/" .. nvim_lua_script,
      "--configpath=" .. lua_config_path
    }, " ")

    Util.create_command(lua_cmd_full_path, {
      "#!/usr/bin/env bash",
      full_cmd_str .. " \\$*",
    })
    Util.create_config(lua_config_path, {
      '{',
      '  "Lua": {',
      '    "workspace.library": {',
      '      "/usr/share/nvim/runtime/lua": true,',
      '      "/usr/share/nvim/runtime/lua/vim": true,',
      '      "/usr/share/nvim/runtime/lua/vim/lsp": true',
      '    },',
      '    "diagnostics": {',
      '      "globals": [ "vim", "use", "use_rocks"]',
      '    }',
      '  },',
      '  "sumneko-lua.enableNvimLuaDev": true',
      '}',
    })

    vim.fn['easycomplete#ConstructorCallingByName'](plugin_name)
    vim.fn.timer_start(100, function()
      log("LSP is initalized successfully!")
    end)
  end
}

function AutoLoad.get(plugin_name)
  return Util.get(AutoLoad, plugin_name)
end

return AutoLoad
