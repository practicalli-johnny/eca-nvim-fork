local M = {}

local function has_methods(tbl, methods)
  if type(tbl) ~= 'table' then
    return false
  end

  for _, m in ipairs(methods) do
    if type(tbl[m]) == 'function' then
      return true
    end
  end

  return false
end

local function make_noop_logger()
  return {
    debug = function() end,
    info = function() end,
    warn = function() end,
    error = function() end,
  }
end

local function get_plenary_logger(level, filepath)
  local ok, plenary_log = pcall(require, 'plenary.log')

  if not ok then
    return nil
  end

  local logger = plenary_log.new({
    plugin = 'eca',
    level = level or 'debug',
    use_console = false,
    use_file = true,
  })

  logger.filepath = filepath or vim.fn.stdpath('log') .. '/eca.log'

  return logger
end

M.get_logger = function(log_config)
  local methods = { 'debug', 'info', 'warn', 'error' }
  local logger_methods = (type(log_config) == 'table' and log_config.methods) or nil
  local level = (type(log_config) == 'table' and log_config.level) or 'debug'
  local filepath = (type(log_config) == 'table' and log_config.filepath) or nil

  if has_methods(logger_methods, methods) then
    local custom_logger = setmetatable({}, {
      __index = function(_, k)
        return (logger_methods and logger_methods[k]) or make_noop_logger()[k]
      end
    })

    custom_logger.filepath = filepath

    return custom_logger
  end

  local plenary_logger = get_plenary_logger(level, filepath)

  if plenary_logger then
    return plenary_logger
  end

  return make_noop_logger()
end

return M
