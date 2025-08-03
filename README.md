# eca-nvim

:warning: Warning: Work In Progress
`eca-nvim` is currently a work in progress. This project is in its early stages of development, with limited functionality and a basic user interface. Users should expect bugs and potential issues. Contributions and feedback are welcome as we continue to improve and expand the plugin's capabilities.

## Overview

`eca-nvim` is a Neovim plugin designed to integrate with ECA (Editor Code Assistant), a free and open-source tool that connects LLMs (Language Learning Models) with editors. ECA aims to provide the best possible user experience for AI pair programming by utilizing a well-defined protocol, heavily influenced by the successful implementation of the LSP protocol.

## Installation

### Using Lazy.nvim

Plugin spec to install eca-nvim via [lazy.nvim](https://github.com/folke/lazy.nvim). The spec will lazy load the plugin, loading only when a Clojure related file is opened.

Create an environment variable within your operating system called `OPENAI_API_KEY` and set it to the value of your OpenAI key.

```lua
return {
  "editor-code-assistant/eca-nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
  ft = { "clojure" },  -- lazy load, only run when Clojure file type is opened
  opts = {
    env = {OPENAI_API_KEY = vim.env.OPENAI_API_KEY},  -- set key from OS Env Var of same name
  },
}
```

### Using Packer

To install `eca-nvim` with Packer, add the following to your Neovim configuration:

```lua
use({
  'editor-code-assistant/eca-nvim',
  requires = {
    { 'nvim-lua/plenary.nvim' },
  },
  config = function()
    require('eca-nvim').setup({
      env = {
        OPENAI_API_KEY = "openai_api_key_here", -- Set your OpenAI API key here from => https://platform.openai.com/settings/organization/api-keys
      },
    })
  end
})
```

Local Installation is also supported. Clone the repository and add the path to your Packer plugins:

```lua
use({
  '<local-path>/eca-nvim',
  requires = {
    { 'nvim-lua/plenary.nvim' },
  },
  config = function()
    require('eca-nvim').setup({
      env = {
        OPENAI_API_KEY = "openai_api_key_here", -- Set your OpenAI API key here from => https://platform.openai.com/settings/organization/api-keys
      },
    })
  end
})
```

### Other Installation Methods

Installation instructions using other package managers are TBD. Please note that this plugin is under active development, and instructions might change.

## Getting Started

To start the `eca-nvim` plugin, run the following command in Neovim:

```lua
:lua require('eca-nvim').run()
```

This command will install `eca` within the plugin directory if it's not already present. Note that this process can introduce UI lag since the asynchronous handling of this request is not yet implemented. In case of any issues, you can manually download eca. Ensure that you have Java installed at `/usr/bin/java`, or update the startup command (see `config.lua` file).

## Contribution

Since this project is in the early stages, contributions and feedback are welcome. Stay tuned for more updates and improvements as we continue development.
