local Chat = require("eca-nvim.ui.chat")
local Client = require("eca-nvim.client")
local config = require("eca-nvim.tools.config")
local install = require("eca-nvim.install")

local M = {}

local index = 0

local function increment_and_return()
  index = index + 1
  return index
end

local function send_message(chat, client)
  local message = chat:get_closest_message('user')

  if not message then
    return
  end

  local ok, response = client:send_message(1, index, message.content,
    function(_, _)
      chat:lock()

      chat:append('\n')

      chat:add_message({
        id = increment_and_return(),
        role = "assistant",
        content = '',
      })
    end)

  if not ok then
    vim.notify('ECA Server\n' .. response, vim.log.levels.DEBUG)
  end
end

local function set_keymaps(chat, client)
  vim.keymap.set(
    'n',
    '<CR>',
    function() send_message(chat, client) end,
    { buffer = chat.bufnr, nowait = true, desc = 'ECA Submit Prompt' }
  )
end

local function client_setup(chat)
  return function(message, err)
    if err then
      vim.notify('ECA Server\n' .. err, vim.log.levels.DEBUG)
      return
    end

    chat:lock()

    chat:add_message({
      id = increment_and_return(),
      role = "assistant",
      content = message.chatWelcomeMessage,
    })

    chat:add_message({
      id = increment_and_return(),
      role = "user",
      content = '',
    })

    chat:unlock()
  end
end

local function client_opts(chat)
  return
  {
    on_running = function(_)
      if not chat:is_locked() then
        chat:lock()
      end
    end,
    on_finished = function(_)
      chat:append('\n')

      chat:add_message({
        id = increment_and_return(),
        role = "user",
        content = '',
      })

      chat:unlock()
    end,
    on_answer = function(text)
      chat:append(text)
    end
  }
end

M.run = function()
  local ok, server_path = install.resolve_server_path()

  if not ok then
    vim.notify(server_path, vim.log.levels.DEBUG)
    return
  end

  local chat = Chat.open({})
  local client = Client.connect(server_path, client_setup(chat), client_opts(chat))

  set_keymaps(chat, client)
end

M.setup = function(opts)
  config.apply(opts or {})
end

return M
