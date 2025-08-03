--- Exemplos e documentação dos campos aceitos em require('eca-nvim').setup().
-- Esta tabela NÃO é usada no código, serve apenas como referência!
--[[
local eca_config_doc = {
  -- Logger customizado (opcional):
  -- Deve ser uma tabela com os métodos de log e nível desejado.
  -- methods: tabela com métodos: debug(msg), info(msg), warn(msg), error(msg)
  -- level: string do nível mínimo ('trace', 'debug', 'info', 'warn', 'error', 'fatal')
  log = {
    methods = {
      debug = function(msg) end,
      info  = function(msg) end,
      warn  = function(msg) end,
      error = function(msg) end,
    },
    level = 'info',
  },

  -- Configuração do servidor ECA (opcional):
  -- O campo 'command' substitui o comando Java padrão; 'spawn_args' são argumentos adicionais.
  server = {
    command = { '/caminho/para/java', '-jar', '/caminho/para/eca.jar', 'server' },
    spawn_args = { '--alguma-flag' },
  },

  -- Outros campos de configuração podem ser documentados aqui no futuro.
}
]]

local config = {
  user = {},
}

function config.apply(user_opts)
  config.user = vim.tbl_deep_extend("force", config.user or {}, user_opts or {})
end

---@param key string
function config.get(key)
  if not key then
    return config.user
  end

  return config.user[key]
end

return config
