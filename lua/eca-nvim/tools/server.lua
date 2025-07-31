local config = require('eca-nvim.tools.config')

local Server = {}

function Server.new()
  local instance = {
    rpc = nil,
  }

  setmetatable(instance, { __index = Server })

  return instance
end

function Server.start(server_path, opts)
  local server = Server.new()

  server:connect(server_path, opts)

  return server
end

function Server:connect(server_path, opts)
  if self.rpc then
    return
  end

  local env = config.get('env')
  local server_command = config.get('server_command')

  if server_command and #server_command < 1 then
    server_command = {
      '/usr/bin/java',
      '-jar',
      server_path,
      'server',
    }
  end

  self.rpc = vim.lsp.rpc.start(
    server_command,
    {
      notification = function(method, params)
        if method == 'chat/contentReceived' then
          if params.role == 'system' then
            if params.content.type == 'progress' then
              if params.content.state == 'running' then
                opts.on_running(params.content.text)
              elseif params.content.state == 'finished' then
                opts.on_finished(params.content.text)
              end
            end
          end

          if params.role == 'assistant' then
            if params.content.type == 'text' then
              opts.on_answer(params.content.text)
            end
          end
        end
      end,
      server_request = function(method, params) end,
      on_exit = function(code, _) end,
      on_error = function(_, data) end,
    },
    {
      cwd = vim.fn.getcwd(),
      env = env
    }
  )
end

function Server:request(method, params, callback)
  if not self.rpc then
    return false, 'RPC is not started.'
  end

  local ok, request_id = self.rpc.request(method, params, callback)

  if not ok then
    return false, 'RPC request failed: ' .. method .. '\nParams: ' .. vim.inspect(params)
  end

  return true, request_id
end

return Server
