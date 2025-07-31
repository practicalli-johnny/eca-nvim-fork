local async = require('plenary.async')
local curl = require('plenary.curl')
local config = require('eca-nvim.tools.config')

local M = {}

local function request(url, opts)
  local result = nil
  local ok = false

  pcall(async.run,
    function()
      local curl_args = {
        timeout = 30000,
        raw = {
          '--retry',
          '2',
          '--retry-delay',
          '1',
          '--keepalive-time',
          '60',
          '--no-compressed',
          '--connect-timeout',
          '10',
          '--tcp-nodelay',
          '--no-buffer',
        },
      }

      local args = {
        on_error = function(output)
          return false, output and output.stderr or output
        end,
      }

      args = vim.tbl_deep_extend('force', curl_args, args)
      args = vim.tbl_deep_extend('force', args, opts or {})

      return curl.get(url, args), args
    end,
    function(response, args)
      ok = true
      result = response

      if response and not vim.startswith(tostring(response.status), '20') then
        vim.notify('Error fetching URL: ' .. url .. ' - ' .. (response.body or response.status),
          vim.log.levels.DEBUG)
        ok = false
        result = response.body or response.status
        return
      end

      if not args.json_response then
        return
      end

      local body, not_ok = vim.json.decode(tostring(response.body))

      if not_ok then
        ok = false
        return
      end

      ok = true
      result = body
    end)

  return ok, result
end

local function get_latest_version()
  local ok, response = request('https://api.github.com/repos/editor-code-assistant/eca/releases',
    { json_response = true })

  if ok and response and #response > 0 then
    if response[1].tag_name and response[1].tag_name ~= '' then
      return true, response[1].tag_name
    end
  end

  return false, nil
end

local function download(version, artifactName, download_path)
  local url = 'https://github.com/editor-code-assistant/eca/releases/download/' .. version .. '/' .. artifactName

  local ok, response = request(url, { output = download_path })

  if not ok then
    return false, 'Failed to download ECA from ' .. url .. '' .. ':\n' .. response
  end

  if vim.fn.fnamemodify(download_path, ":e") ~= '' then
    local chmod_out = vim.fn.system { 'chmod', '755', download_path }

    if vim.v.shell_error ~= 0 then
      return false, 'Failed to set executable permissions for ' .. download_path .. ':\n' .. chmod_out
    end
  end

  return true, download_path
end

local function file_exists(filename)
  local f = io.open(filename, "r") -- Attempt to open the file in read mode

  if f then
    io.close(f) -- Close the file if successfully opened
    return true
  end

  return false
end

M.resolve_server_path = function()
  local server_command = config.get('server_command')

  if server_command and #server_command > 0 then
    return true, server_command
  end

  local artifact_name = 'eca.jar'
  local extension_path = vim.api.nvim_get_runtime_file('lua/eca-nvim', false)[1]
  local server_path = extension_path .. '/' .. artifact_name

  if not file_exists(server_path) then
    local ok, version = get_latest_version()

    if not ok then
      return false, 'Failed to get latest ECA version: ' .. version
    end

    vim.notify('Downloading ECA server version: ' .. version, vim.log.levels.DEBUG)

    local ok, response = download(version, artifact_name, server_path)

    if not ok then
      return false, 'Failed to download ECA server: ' .. response
    end

    server_path = response
  end

  return true, server_path
end

return M
