# Configuration

This document describes all configuration options available for the `eca-nvim` plugin.

```lua
require('eca-nvim').setup({
  -- Server configuration
  server = {
    command = { '/usr/bin/java', '-jar', '/path/to/eca.jar', 'server' },
    spawn_args = { 
      cwd = vim.fn.getcwd(),
      env = { OPENAI_API_KEY = 'api key from https://platform.openai.com/settings/organization/api-keys' }
    }
  },
  -- Logging configuration
  log = {
    level = 'info',
    filepath = '/tmp/eca.log',
    methods = {
      debug = function(msg) print('[DEBUG] ' .. msg) end,
      info = function(msg) print('[INFO] ' .. msg) end,
      warn = function(msg) print('[WARN] ' .. msg) end,
      error = function(msg) print('[ERROR] ' .. msg) end,
    },
  },
})
```

## Configuration Options

### Server Configuration

Controls how the ECA server is started and managed.

#### `server.command` (table, optional)

Custom command to start the ECA server. If not provided, the plugin uses the default Java command.

**Default:** `{ '/usr/bin/java', '-jar', '<plugin-path>/eca.jar', 'server' }`

**Example:**
```lua
server = {
  command = { '/usr/local/bin/java', '-jar', '/custom/path/eca.jar', 'server' },
}
```

**Note:** The default command assumes Java is installed at `/usr/bin/java`. If your Java installation is in a different location, you must configure this option.

#### `server.spawn_args` (table, optional)

Specifies extra options to use when spawning the ECA server process. This table is passed as the `extra_spawn_args` parameter to `vim.lsp.rpc.start()`. For details on available options (such as `cwd`, `env`, etc.), refer to the [Neovim LSP documentation](https://neovim.io/doc/user/lsp.html#vim.lsp.rpc.start()).

**Default:** `{}`

**Example:**
```lua
server = {
  spawn_args = {
    cwd = vim.fn.getcwd(),
    env = { OPENAI_API_KEY = 'api key from https://platform.openai.com/settings/organization/api-keys' }
  }
}
```

### Logging Configuration

Controls logging behavior and output.

#### `log.methods` (table, optional)

You can provide your own logging functions here. If specified, these will override the default plenary logger. You may define any subset of the required methods; only those you provide will be used.

**Required methods:**
- `debug(msg)` - Debug level messages
- `info(msg)` - Information level messages  
- `warn(msg)` - Warning level messages
- `error(msg)` - Error level messages

**Example:**
```lua
log = {
  methods = {
    debug = function(msg) print('[DEBUG] ' .. msg) end,
    info = function(msg) print('[INFO] ' .. msg) end,
    warn = function(msg) print('[WARN] ' .. msg) end,
    error = function(msg) print('[ERROR] ' .. msg) end,
  },
}
```

#### `log.level` (string, optional)

Minimum log level for messages to be displayed.

**Valid values:** `'trace'`, `'debug'`, `'info'`, `'warn'`, `'error'`, `'fatal'`

**Default:** `'debug'`

**Example:**
```lua
log = {
  level = 'info',
}
```

#### `log.filepath` (string, optional)

Custom file path for log output. If not provided, logs are written to the default Neovim log directory.

**Default:** `vim.fn.stdpath('log') .. '/eca.log'`

**Example:**
```lua
log = {
  filepath = '/tmp/eca-custom.log',
}
```
