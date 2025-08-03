# Architecture Overview

This document provides a technical overview of the `eca-nvim` plugin architecture.

## Project Structure

The plugin follows a modular architecture:

- **`init.lua`**: Main entry point that imports all necessary components and orchestrates the plugin initialization
- **`handler.lua`**: Receives dependency injection and manages the communication flow between components
- **`protocols/`**: Contains protocol abstractions (instances of communication patterns)
  - `client.lua`: Manages RPC communication with the ECA server
  - `eca.lua`: Implements the ECA protocol specification
  - `executor.lua`: Handles task execution and queuing
- **`tools/`**: Static utility modules (no dependencies between them)
  - `config.lua`: Configuration management
  - `log.lua`: Logging utilities
  - `server.lua`: ECA server download and path management
- **`ui/`**: User interface components
  - `chat.lua`: Chat window implementation

**Important Notes:**
- `tools/` and `protocols/` modules are independent and don't depend on each other
- Only `init.lua` and `handler.lua` import from these modules

## Component Architecture

### Core Components

```
init.lua (Entry Point)
    ↓
handler.lua (Orchestrator)
    ↓
┌─────────────────┬─────────────────┬─────────────────┐
│   protocols/    │     tools/      │      ui/        │
│                 │                 │                 │
│ client.lua      │ config.lua      │ chat.lua        │
│ eca.lua         │ log.lua         │                 │
│ executor.lua    │ server.lua      │                 │
└─────────────────┴─────────────────┴─────────────────┘
```

### Component Responsibilities

#### Entry Point (`init.lua`)

- **Purpose**: Plugin initialization and dependency orchestration
- **Responsibilities**:
  - Import all necessary components
  - Apply user configuration
  - Create component instances
  - Initialize the handler with dependencies
  - Set up user commands and keymaps

#### Handler (`handler.lua`)

- **Purpose**: Main orchestrator that manages communication flow
- **Responsibilities**:
  - Receives dependency injection from init.lua
  - Manages ECA protocol communication
  - Handles UI state changes
  - Coordinates between protocols and UI

### Protocol Layer (`protocols/`)

The protocol layer contains abstractions for communication patterns and state management.

#### Client (`client.lua`)

- **Purpose**: RPC communication with the ECA server
- **Responsibilities**:
  - Establish and maintain server connection
  - Send requests and notifications
  - Handle connection lifecycle
  - Validate request/notification format

#### ECA (`eca.lua`)

- **Purpose**: ECA protocol implementation
- **Responsibilities**:
  - Implement ECA protocol specification
  - Manage model selection and configuration
  - Create protocol requests and notifications
  - Handle protocol event dispatching

#### Executor (`executor.lua`)

- **Purpose**: Task execution
- **Responsibilities**:
  - Queue and execute tasks sequentially
  - Provide task indexing

### Tools Layer (`tools/`)

Static utility modules with no interdependencies.

#### Config (`config.lua`)

- **Purpose**: Configuration management
- **Responsibilities**:
  - Store and retrieve user configuration
  - Merge default and user settings
  - Provide configuration access API

#### Log (`log.lua`)

- **Purpose**: Logging utilities
- **Responsibilities**:
  - Create and configure loggers
  - Support custom logging methods
  - Provide fallback logging options

#### Server (`server.lua`)

- **Purpose**: ECA server management
- **Responsibilities**:
  - Download ECA server JAR
  - Manage server file paths
  - Handle version checking

### UI Layer (`ui/`)

#### Chat (`chat.lua`)

- **Purpose**: Chat window interface
- **Responsibilities**:
  - Create and manage chat buffer
  - Handle window layout and sizing
  - Process message rendering

## Design Patterns

### Dependency Injection

The handler receives all its dependencies through constructor injection:

```lua
local handler = Handler.new(eca, chat, client, executor, logger)
```

### Protocol Abstraction

Protocol components abstract communication patterns:

```lua
-- ECA protocol creates requests
local ok, request = self.eca:prompt(text, opts, callback)

-- Client handles communication
local ok, err = self.client:request(request)
```

### Task Queue Pattern

The executor implements a sequential task queue:

```lua
self.executor:run(function(done)
  -- Task code here
  done() -- Signal completion
end)
```
