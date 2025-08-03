local Handler = {}

function Handler.new(eca, chat, client, executor, logger)
  local instance = {
    eca = eca,
    chat = chat,
    client = client,
    logger = logger,
    executor = executor,
  }

  setmetatable(instance, { __index = Handler })

  return instance
end

function Handler:init(set_submit_prompt_keymaps)
  self.executor:run(function(done)
    local dispatchers_ok, dispatchers = self.eca:dispatchers(
      {
        on_running = function() self:on_running() end,
        on_finished = function() self:on_finished() end,
        on_answer = function(...) self:on_answer(...) end,
        on_unknown = function(...) self:on_unknown(...) end,
      })

    if not dispatchers_ok then
      self.logger.error('Failed to initialize eca dispatchers: ' .. dispatchers)
      return
    end

    local connect_ok, dispatchers_err = self.client:connect(dispatchers)

    if not connect_ok then
      self.logger.error('Failed to connect client: ' .. dispatchers_err)
      return
    end

    local init_ok, init_request = self.eca:init(
      {
        callback = function(ok, welcome_message) self:setup(ok, welcome_message) end,
      })

    if not init_ok then
      self.logger.error('Failed to create init request: ' .. init_request)
      return
    end

    local request_ok, request_err = self.client:request(init_request)

    if not request_ok then
      self.logger.error('Failed to send init request: ' .. request_err)
      return
    end

    set_submit_prompt_keymaps(function() self:send_request() end)

    done()
  end)
end

function Handler:on_running()
  self.executor:run(function(done)
    if not self.chat:is_locked() then
      self.chat:lock()
    end
    done()
  end)
end

function Handler:on_finished()
  self.executor:run(function(done)
    self.chat:append('\n')

    self.chat:add_message({
      id = self.executor:index(),
      role = "user",
      content = '',
    })

    self.chat:unlock()
    done()
  end)
end

function Handler:on_answer(text)
  self.executor:run(function(done)
    self.chat:append(text)
    done()
  end)
end

function Handler:on_unknown(...)
  local args = { ... }
  self.executor:run(function(done)
    local log = ''
    for i, v in ipairs(args) do
      if type(v) ~= 'string' then
        v = vim.inspect(v)
      end

      log = log .. 'Arg ' .. i .. ': ' .. tostring(v) .. '\n'
    end

    self.logger.debug('Unknown event received:\n' .. log)
    done()
  end)
end

function Handler:setup(ok, welcome_message)
  self.executor:run(function(done)
    if not ok then
      self.logger.error('Failed to initialize: ' .. tostring(welcome_message))
      return
    end

    local model_ok, model_err = self.eca:set_model('gpt-4.1')

    if not model_ok then
      self.logger.error('Setup error: ' .. model_err)
      return
    end

    local initialized_ok, initialized_request = self.eca:initialized()

    if not initialized_ok then
      self.logger.error('Setup error: ' .. initialized_request)
      return
    end

    local notify_ok = self.client:notify(initialized_request)

    if not notify_ok then
      self.logger.error('Setup error: Failed to send initialization notification')
      return
    end

    self.chat:lock()

    self.chat:add_message({
      id = self.executor:index(),
      role = 'assistant',
      content = welcome_message,
    })

    self.chat:add_message({
      id = self.executor:index(),
      role = 'user',
      content = '',
    })

    self.chat:unlock()
    done()
  end)
end

function Handler:send_request()
  self.executor:run(function(done)
    local message = self.chat:get_closest_message('user')

    if not message or not message.content or type(message.content) ~= 'string' then
      self.logger.error('No user message found to send.')
      return
    end

    local prompt_ok, prompt_request = self.eca:prompt(
      message.content,
      {
        chat_id = 1,
        request_id = self.executor:index()
      },
      function(err)
        self.chat:lock()

        self.chat:append('\n')

        self.chat:add_message({
          id = self.executor:index(),
          role = "assistant",
          content = err and err.message or '',
        })

        if err then
          self.chat:append('\n')

          self.chat:add_message({
            id = self.executor:index(),
            role = 'user',
            content = '',
          })

          self.chat:unlock()
        end
      end
    )

    if not prompt_ok then
      self.logger.error('Failed to create prompt request: ' .. prompt_request)
      return
    end

    local request_ok, request_err = self.client:request(prompt_request)

    if not request_ok then
      self.logger.error('Failed to send prompt request: ' .. request_err)
    end

    done()
  end)
end

return Handler
