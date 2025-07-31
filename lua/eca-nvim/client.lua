local config = require('eca-nvim.tools.config')
local Server = require('eca-nvim.tools.server')

local Client = {}

function Client.new()
  local instance = {
    server = nil,
  }

  setmetatable(instance, { __index = Client })

  return instance
end

function Client.connect(server_path, callback, opts)
  local client = Client.new()

  client:start_server(server_path, callback, opts)

  return client
end

function Client:start_server(server_path, callback, opts)
  self.server = Server.start(server_path, opts)

  return self.server:request('initialize', {
    processId = vim.fn.getpid(),
    clientInfo = {
      name = 'Neovim',
      version = vim.version().major .. '.' .. vim.version().minor .. '.' .. vim.version().patch,
    },
    capabilities = {
      codeAssistant = {
        chat = true
      }
    },
    initializationOptions = {
    },
    workspaceFolders = { { uri = 'file://' .. vim.fn.getcwd() } },
  }, function(err, result)
    if err then
      self.server = nil
      return
    end

    callback(result, err)
  end)
end

function Client:send_message(session_id, request_id, message, callback)
  if not self.server then
    return false, 'Client is not connected. Please connect the client first.'
  end

  local model = config.get('model')

  local ok, response = self.server:request('chat/prompt', {
    chatId = session_id,
    requestId = request_id,
    message = message,
    model = model,
    behavior = 'chat',
    -- contexts =  '',
  }, callback)

  if not ok then
    return false, 'Failed to send message: ' .. response
  end

  return true, nil
end

return Client
