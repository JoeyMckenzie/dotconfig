# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a LazyVim configuration repository - a Neovim editor setup using the LazyVim starter template. It manages plugins, keymaps, options, and Lua configurations for the editor.

### Key Technologies
- **Neovim**: Modern vim editor
- **LazyVim**: Plugin manager and configuration framework
- **Lua**: Configuration language

## Architecture and Structure

### Configuration Flow
1. **Entry point**: `init.lua` bootstraps the config by loading `lua/config/lazy.lua`
2. **Plugin manager**: `lua/config/lazy.lua` initializes lazy.nvim with plugin specifications
3. **Plugin specs**: All files in `lua/plugins/` are automatically loaded by lazy.nvim
4. **Configuration modules**: Loaded automatically by LazyVim
   - `lua/config/options.lua`: Vim options and settings
   - `lua/config/keymaps.lua`: Custom keybindings
   - `lua/config/autocmds.lua`: Autocommands

### Key Files and Responsibilities

- **`lua/config/options.lua`**: Sets `vim.g.lazyvim_php_lsp = "intelephense"` for PHP language server configuration
- **`lua/plugins/example.lua`**: Template examples showing how to configure and override LazyVim plugins (mostly disabled with `if true then return {} end`)
- **`lua/plugins/php.lua`**: PHP-specific tooling
  - conform.nvim: Formatter setup for PHP (pint, php_cs_fixer)
  - neotest: Testing framework with PHPUnit adapter support
- **`stylua.toml`**: Lua code formatting config (2-space indent, 120 column width)
- **`.neoconf.json`**: Neovim LSP configuration for lua_ls with neodev library

## Development Commands

### Neovim Testing
Since this is a Neovim config, testing happens in the editor itself:

```bash
# Start Neovim with this config
nvim

# Test plugin loading with startup profiling
nvim --startuptime startup.log

# Check for Lua syntax errors (run inside nvim)
:luacheck
```

### Code Formatting

```bash
# Format Lua files using stylua
stylua lua/

# Check formatting without changes
stylua --check lua/
```

### PHP Linting/Formatting (if PHP development files present)
- Formatters configured: pint and php_cs_fixer
- These are managed by conform.nvim and run via Neovim's format keybinds

## Plugin Management

### How Plugins Are Loaded
- lazy.nvim automatically discovers all `.lua` files in `lua/plugins/`
- Each file should return a plugin spec table or empty table
- Plugin specs can add new plugins, disable LazyVim plugins, or override configuration

### Common Plugin Configuration Patterns (from `lua/plugins/example.lua`)

**Adding a new plugin:**
```lua
return {
  { "plugin-author/plugin-name" },
}
```

**Disabling a LazyVim plugin:**
```lua
return {
  { "plugin-name", enabled = false },
}
```

**Overriding plugin options:**
```lua
return {
  {
    "plugin-name",
    opts = {
      -- options here
    },
  },
}
```

**Setting up language servers (LSP):**
Configure in `lua/config/options.lua` or create plugin specs in `lua/plugins/` that modify nvim-lspconfig

## Current Customizations

- **PHP Development**: Uses Intelephense as LSP, configured with conform and neotest for testing
- **Lua Formatting**: 2-space indentation, 120-character line width (stylua.toml)
- **LSP Support**: Python (pyright), TypeScript/JavaScript (tsserver), JSON, PHP (intelephense)
- **Treesitter Parsers**: Configured for common languages (bash, html, javascript, json, lua, markdown, python, regex, tsx, typescript, vim, yaml)

## Notes for Modifications

- Changes to `lua/config/` files take effect on Neovim restart
- Plugin specs in `lua/plugins/` also require restart
- Test plugin loading/functionality directly in the editor
- When adding new language support, typically need to configure both the LSP server and formatter
- The `lua/plugins/example.lua` file is mostly informational—remove example entries when adding real configurations
