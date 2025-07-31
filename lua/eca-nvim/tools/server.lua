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

  self.rpc = vim.lsp.rpc.start(
    {
      '/usr/bin/java',
      '-jar',
      server_path,
      'server',
    },
    {
      notification = function(method, params)
        vim.notify('ECA Server\nUnknown notification method: ' .. method .. '\nParams: ' .. vim.inspect(params),
          vim.log.levels.DEBUG, { timeout = 5000 })
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
        else
          vim.notify('ECA Server\nUnknown notification method: ' .. method .. '\nParams: ' .. vim.inspect(params),
            vim.log.levels.DEBUG, { timeout = 5000 })
        end
      end,
      server_request = function(method, params)
        vim.notify('ECA Server\nUnknown request method: ' .. method .. '\nParams: ' .. vim.inspect(params),
          vim.log.levels.DEBUG, { timeout = 5000 })
      end,
      on_exit = function(code, _)
        if code ~= 0 then
          vim.notify('ECA Server exited with code: ' .. code,
            vim.log.levels.DEBUG, { timeout = 5000 })
        end
      end,
      on_error = function(_, data)
        vim.notify('ECA Server Error\n' .. table.concat(data, " "),
          vim.log.levels.DEBUG, { timeout = 5000 })
      end,
    },
    {
      cwd = vim.fn.getcwd(),
      env = {
        OPENAI_API_KEY = "...openai_api_key...",
      },
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
