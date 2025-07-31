# eca-nvim

:warning: Warning: Work In Progress
`eca-nvim` is currently a work in progress. This project is in its early stages of development, with limited functionality and a basic user interface. Users should expect bugs and potential issues. Contributions and feedback are welcome as we continue to improve and expand the plugin's capabilities.

## Overview

`eca-nvim` is a Neovim plugin designed to integrate with ECA (Editor Code Assistant), a free and open-source tool that connects LLMs (Language Learning Models) with editors. ECA aims to provide the best possible user experience for AI pair programming by utilizing a well-defined protocol, heavily influenced by the successful implementation of the LSP protocol.

## Installation

### Using Packer

To install `eca-nvim` with Packer, add the following to your Neovim configuration:

```lua
use({
  'editor-code-assistant/eca-nvim',
  requires = {
    { 'nvim-lua/plenary.nvim' },
  },
})
```

Local Installation is also supported. Clone the repository and add the path to your Packer plugins:

```lua
use({
  '<local-path>/eca-nvim',
  requires = {
    { 'nvim-lua/plenary.nvim' },
  },
})
```

### Other Installation Methods

Installation instructions using other package managers are TBD. Please note that this plugin is under active development, and instructions might change.

## Getting Started

To start the `eca-nvim` plugin, run the following command in Neovim:

```lua
:lua require('eca-nvim').run()
```

This command will install `eca` within the plugin directory if it's not already present. Note that this process can introduce UI lag since the asynchronous handling of this request is not yet implemented. In case of any issues, you can manually download eca. Ensure that you have Java installed at `/usr/bin/java`, or update the startup command in `server.lua`.

### API Key Setup

To use the plugin, set your OpenAI API key in the `OPENAI_API_KEY` environment variable at `server.lua`. You can generate an API key from [OpenAI's platform](https://platform.openai.com/settings/organization/api-keys).

## Contribution

Since this project is in the early stages, contributions and feedback are welcome. Stay tuned for more updates and improvements as we continue development.
