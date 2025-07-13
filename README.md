# ComputerCraft Automation Scripts

A collection of Lua scripts for ComputerCraft turtle automation, including mining, farming, and resource collection.

## Quick Start

### For ComputerCraft Deployment:
```bash
# Prepare files for ComputerCraft
./deploy.sh

# Then drag and drop files from deploy/ directory to ComputerCraft
# Or use pastebin method (see deployment section below)
```

### For Development/Testing:
```bash
# Run tests (requires luarocks and busted)
export PATH="$HOME/.luarocks/bin:$PATH"
export LUA_PATH="$HOME/.luarocks/share/lua/5.4/?.lua;$HOME/.luarocks/share/lua/5.4/?/init.lua;;"
export LUA_CPATH="$HOME/.luarocks/lib/lua/5.4/?.so;;"
busted
```

## Scripts

### Core Libraries
- **movement.lua** - Position tracking and pathfinding
- **pickup.lua** - Item collection patterns (spiral, grid, circle, line)

### Automation Scripts
- **quarry.lua** - Configurable mining with trash filtering
- **treefarm_2x2_simple.lua** - 2x2 tree farm automation
- **sugarCane.lua** - Sugar cane farming with paper crafting
- **certus3.lua** - Advanced Certus Quartz mining
- **certusQuartz.lua** - Simple Certus Quartz mining

## Deployment to ComputerCraft

### Method 1: Drag and Drop (Recommended)
1. Run `./deploy.sh` to prepare files
2. Open the `deploy/` directory
3. Drag and drop files to ComputerCraft computer

### Method 2: Pastebin/Wget
1. Upload files from `deploy/` to pastebin
2. In ComputerCraft:
   ```lua
   wget <pastebin-url> movement.lua
   wget <pastebin-url> pickup.lua
   wget <pastebin-url> your_script.lua
   ```

### Method 3: Direct Copy
Copy file contents from `deploy/` directory and paste into ComputerCraft editor.

## Usage Examples

### Basic Mining
```lua
-- In ComputerCraft
quarry
-- Follow prompts for dimensions and trash items
```

### Tree Farming
```lua
-- In ComputerCraft  
treefarm_2x2_simple
-- Ensure saplings in slot 1, optional bonemeal in slot 2
-- Place chest below turtle
```

### Using Pickup Library
```lua
local pickup = require("pickup")

-- Spiral collection pattern
pickup.spiral(3, 0, 0)  -- radius 3 around position 0,0

-- Grid collection pattern  
pickup.grid(5, 5, 0, 0)  -- 5x5 grid starting at 0,0

-- Custom collection function
pickup.setCollectionFunction(function()
    turtle.suck()
    turtle.suckUp()
    -- custom logic here
end)
```

## Development

### Project Structure
```
lib/                    # Core libraries (for development)
├── movement.lua        # Movement and pathfinding
└── pickup.lua          # Item collection patterns

spec/                   # Tests (busted framework)
├── movement_spec.lua   # Movement tests
├── pickup_spec.lua     # Pickup pattern tests
└── integration_spec.lua # Integration tests

test/                   # Test infrastructure
├── mocks/              # Mock turtle/os APIs
└── helpers/            # Test utilities

deploy/                 # ComputerCraft-ready files
├── movement.lua        # Flattened for CC compatibility
├── pickup.lua          # Flattened for CC compatibility
└── *.lua               # All scripts ready for deployment
```

### Testing
The project includes comprehensive tests that run without ComputerCraft:

```bash
# Install dependencies (one time)
luarocks install --local busted
luarocks install --local luacheck

# Run tests
busted

# Run linting
luacheck lib/ spec/
```

### Adding New Scripts
1. Create script in root directory
2. Use `require("lib.movement")` and `require("lib.pickup")` for development
3. Run `./deploy.sh` to prepare ComputerCraft-compatible versions
4. Test in ComputerCraft

## Features

### Movement Library
- Position tracking (X, Y, Z coordinates)
- Direction management (FW, RI, LE, BK)
- Smart pathfinding with obstacle clearing
- Bug fixes applied (original line 202 issue)

### Pickup Library  
- Multiple collection patterns:
  - **Spiral**: Expanding spiral from center point
  - **Grid**: Systematic row-by-row coverage
  - **Circle**: Circular collection pattern
  - **Line**: Linear collection in any direction
  - **Compact**: Dense square coverage
- Configurable collection functions
- Optional return-to-home behavior
- Pattern visualization for testing

### Error Handling
- Comprehensive mock system for testing
- Error recovery patterns (see certus3.lua)
- Fuel management considerations
- Obstacle detection and clearing

## Contributing

1. Make changes in `lib/` directory for libraries
2. Add tests in `spec/` directory
3. Run `busted` to verify tests pass
4. Run `./deploy.sh` to update deployment files
5. Test in ComputerCraft

## Known Issues

- Original movement.lua had bug at line 202 (fixed in lib version)
- Some scripts lack comprehensive error handling
- No fuel management in most scripts
- Pattern visualization only works in test environment