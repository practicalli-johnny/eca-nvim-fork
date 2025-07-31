local M = {}

local config = {
  env = {
    OPENAI_API_KEY = '', -- Key from https://platform.openai.com/account/api-keys
    ECA_CONFIG = '{}',     -- ECA server configuration in JSON,  example: { "openaiApiKey": "openai_api_key" }
  },
  model = 'gpt-4.1',     -- Default model to use
  server_command = {},   -- Command to start the ECA server, example: { "java", "-jar", "path/to/eca-server.jar" }
}

M.get = function(key)
  return config[key]
end

M.apply = function(opts)
  for key, value in pairs(opts) do
    if config[key] ~= nil then
      config[key] = value
    else
      vim.notify('Invalid configuration key: ' .. key, vim.log.levels.DEBUG)
    end
  end
end


return M
