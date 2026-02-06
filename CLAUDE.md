# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

MobStats is a Vanilla WoW 1.12.1 and Turtle WoW addon that displays mob statistics in human-friendly form in game tooltips. The addon is written in Lua and follows a Domain-Driven Design architecture.

## Architecture

The codebase is organized into distinct layers:

- **src/Boot.lua**: Entry point that sets up the global MobStats namespace with environment isolation
- **src/Infrastructure/**: Contains GameAPI.lua which wraps WoW's native API functions for unit information
- **src/Domain/**: Value objects for game concepts (Armor, Damage, Melee, MobLevel, Resistance)
- **src/Application/**: ApplicationService that orchestrates domain logic and data transformation
- **src/Presentation/**: UI layer with TooltipController, TooltipInterface, specialized Drawers, and Locale translations

## Key Components

- **ApplicationService**: Central orchestrator that fetches raw game data via GameAPI, converts it to domain objects, and returns DTOs for presentation
- **GameAPI**: Infrastructure layer that wraps WoW's UnitResistance, UnitLevel, UnitDamage, etc. APIs
- **Domain Value Objects**: Immutable objects with business logic (e.g., ArmorVO calculates damage reduction percentages)
- **Tooltip System**: Hooks into GameTooltip's OnShow event to inject mob stats when mousing over enemies
- **Locale System**: `src/Presentation/Locale/` contains per-language string tables. `enUS.lua` defines the base `L` table; other locales override individual keys. Supported: deDE, enUS, esES, frFR, koKR, ptBR, ruRU, zhCN, zhTW

## File Loading Order

The MobStats.toc file defines the exact loading order of Lua files, which is critical for proper initialization.

## Environment Isolation

All files use `setfenv(1, MobStats)` to work within the addon's isolated namespace rather than the global WoW environment.

## Type Annotations

The codebase uses EmmyLua-style type annotations extensively for development tooling support.

## Testing

The project includes a comprehensive test suite using LuaUnit.

Test files are auto-discovered: any `*Test.lua` file under `src/Tests/` is loaded automatically.

### Test Structure

```
src/Tests/
├── Unit/                          # Isolated component tests
│   ├── Domain/                    # Domain value object tests
│   └── Presentation/
│       └── Drawers/               # UI drawer tests
├── Integration/                   # Cross-layer tests
│   └── Application/
├── Smoke/                         # Smoke tests
│   └── Presentation/
│       └── Locale/                # Locale completeness checks
├── Support/                       # Test utilities
│   └── Mocks/
└── RunTests.lua                   # Test entry point (discovery, runner, coverage)
```

### Test Conventions

- Use exact assertions (assertEquals) rather than partial matches (assertStrContains) to ensure output format is exactly as expected
- All tests should verify wrap parameter and call count for tooltip interactions
- Test files should restore any modified global state in tearDown() methods
