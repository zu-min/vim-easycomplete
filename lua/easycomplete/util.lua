local Util = {}

function Util.get_servers()
  if not Util.nvim_installer_installed() then
    return nil
  end
  local Servers = require("nvim-lsp-installer.servers")
  return Servers
end

function Util.get_server()
  if not Util.nvim_installer_installed() then
    return nil
  end
  local Server = require("nvim-lsp-installer.server")
  return Server
end

-- TODO 需要再测试一下这个函数
function Util.get(a, ...)
  local args = {...}
  if type(a) ~= "table" then
    return a
  end
  local tmp_obj = a
  for i = 1, #args do
    tmp_obj = tmp_obj[args[i]]
    if tmp_obj == nil or type(tmp_obj) == nil then
      break
    end
  end
  return tmp_obj
end

-- get word or abbr
function Util.get_word(a)
  local k = a.abbr
  if type(k) == nil or k == nil or k ~= "" then
    local k = a.word
  end
  return k
end

function Util.curr_lsp_constructor_calling()
  Util.constructor_calling_by_name(Util.current_plugin_name())
end

function Util.show_success_message()
  vim.defer_fn(function()
    Util.log("LSP is initalized successfully!")
  end, 100)
end

function Util.get_configuration()
  local curr_lsp_name = Util.current_lsp_name()
  local Servers = Util.get_servers()
  local Server = Util.get_server()
  local ok, server = Servers.get_server(curr_lsp_name)
  return {
    easy_plugin_ctx = Util.current_plugin_ctx(),
    easy_plugin_name = Util.current_plugin_name(),
    easy_lsp_name = curr_lsp_name,
    easy_lsp_config_path = Util.get_default_config_path(),
    easy_cmd_full_path = Util.get_default_command_full_path(),
    nvim_lsp_root = Util.get(server, "root_dir"),
    nvim_lsp_root_path = Server.get_server_root_path(),
    nvim_lsp_ok = ok,
  }
end

function Util.constructor_calling_by_name(plugin_name)
  vim.fn['easycomplete#ConstructorCallingByName'](plugin_name)
end

function Util.console(...)
  return vim.fn['easycomplete#log#log'](...)
end

function Util.log(...)
  return vim.fn['easycomplete#util#info'](...)
end

function Util.current_plugin_ctx()
  return vim.fn['easycomplete#GetCurrentLspContext']()
end

function Util.current_plugin_name()
  local curr_ctx = Util.current_plugin_ctx()
  local plugin_name = Util.get(curr_ctx, 'name')
  return plugin_name
end

function Util.current_lsp_name()
  local curr_plugin_ctx = Util.current_plugin_ctx()
  if curr_plugin_ctx.name == "ts" then
    return "tsserver"
  end
  local lsp_name = Util.get(curr_plugin_ctx, "lsp", "name")
  return lsp_name
end

function Util.get_default_lsp_root_path()
  local all_root = vim.fn['easycomplete#installer#LspServerDir']()
  local plugin_name = Util.current_plugin_name()
  local root_path = vim.fn.join({
    all_root,
    plugin_name,
  }, "/")
  return root_path
end

function Util.get_default_config_path()
  local lsp_root = Util.get_default_lsp_root_path()
  local config_path = vim.fn.join({
    lsp_root,
    "config.json",
  }, "/")
  return config_path
end

function Util.get_default_command_full_path()
  local curr_plugin_ctx = Util.current_plugin_ctx()
  local command_name = Util.get(curr_plugin_ctx, "command")
  local command_full_path = vim.fn.join({
    Util.get_default_lsp_root_path(),
    command_name
  }, "/")
  return command_full_path
end

function Util.nvim_installer_installed()
  return vim.g.loaded_nvim_lsp_installer
end

-- concat is a array
function Util.create_command(file_path, content)
  if vim.fn.executable(file_path) then
    vim.fn.delete(file_path, "rf")
  end
  vim.fn.writefile(content, file_path, "a")
  vim.fn.setfperm(file_path, "rwxr-xr-x")
end

function Util.create_config(file_path, content)
  if vim.fn.executable(file_path) then
    vim.fn.delete(file_path, "rf")
  end
  vim.fn.writefile(content, file_path, "a")
end

function Util.nvim_lsp_installed()
  local current_lsp_ctx = Util.current_plugin_ctx()
  local lsp_name = Util.current_lsp_name()
  if not Util.nvim_installer_installed() or type(lsp_name) == nil then
    return false
  end
  local Servers = Util.get_servers()
  local install_list = Servers.get_installed_server_names()
  local flag = false
  for i = 1, #install_list do
    if lsp_name == install_list[i] then
      flag = true
      break
    end
  end
  return flag
end

function Util.easy_lsp_installed()
  local plugin_name = vim.fn["easycomplete#util#GetLspPluginName"]()
  local current_lsp_ctx = Util.current_plugin_ctx()
  local easy_available_command = vim.fn["easycomplete#installer#GetCommand"](plugin_name) 
  if plugin_name == "ts" and string.find(easy_available_command, "tsserver$") then
    return true
  end
  local easy_lsp_ready = Util.get(current_lsp_ctx, "lsp", "ready")
  if easy_available_command ~= "" and easy_lsp_ready == true then
    return true
  else
    return false
  end
end

return Util
