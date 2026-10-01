# CivSim

A Roblox "god game" civilization simulator in the spirit of WorldBox: a
top-down shared sandbox where every player wields terraforming and disaster
tools over a world of procedurally-generated tribes that grow, expand, and
fight each other on their own.

## What it does

- **Procedural terrain** — a 48x48 tile grid generated with Perlin noise
  (water, sand, grass, forest, mountain, snow).
- **Living civilizations** — villages spawn with a handful of villagers,
  gather food and wood, grow population, build huts, starve if food runs
  out, found new colonies when they get crowded, and skirmish with rival
  factions that wander too close.
- **God tools** (bottom hotbar, click a tool then click the world):
  Raise/Lower Land, Flatten, Water, Plant Forest, Found Village, Bless,
  Lightning, Meteor, Plague, Earthquake.
- **Shared sim controls** — Pause and 1x/2x/4x speed in the top bar, plus a
  live population/leaderboard HUD.
- **Top-down RTS camera** — WASD to pan, scroll wheel to zoom.

Everything is server-authoritative: the server owns the terrain grid, all
villagers, and resolves every tool request, so the world stays consistent
across every player in the server.

## Project layout

This is a [Rojo](https://rojo.space/) project — the source of truth is the
Lua in `src/`, not a `.rbxl` binary.

```
default.project.json       Rojo project manifest (instance tree + remotes)
src/shared/                ReplicatedStorage.Shared — config, terrain types, tool list
src/server/                ServerScriptService — terrain gen, civ sim, god tools, sim clock
src/client/                StarterPlayerScripts — camera, HUD, input handling
```

Key server modules:

| Module | Responsibility |
| --- | --- |
| `TerrainManager` | Tile grid generation, lookup, and all terraforming mutations |
| `Faction` / `Village` / `Villager` | Civilization data model and per-villager AI loop |
| `CivManager` | Growth, starvation, plague progression, migration, tick loop |
| `CombatManager` | Proximity-based skirmishes between rival villages |
| `DisasterManager` | Meteor/lightning/plague/earthquake/blessing effects |
| `GodTools` | Validates and dispatches `RequestTool` remote calls |
| `SimClock` | Pause/speed state and the Heartbeat-driven tick loop |

## Running it in Roblox Studio

1. Install [Rojo](https://rojo.space/docs/v7/getting-started/installation/)
   (via [Aftman](https://github.com/LPGhatguy/aftman): `aftman add rojo-rbx/rojo`,
   then `aftman install`), and the matching **Rojo Studio plugin**.
2. From the repo root, start the Rojo server:
   ```
   rojo serve
   ```
3. In Studio, open the Rojo plugin panel and click **Connect** to live-sync
   into a new/empty place.
4. Press **Play** (or **Play here**) — the world generates and simulation
   starts immediately with three starting villages.

Alternatively, build a standalone place file without a live session:

```
rojo build -o CivSim.rbxlx
```

then open `CivSim.rbxlx` directly in Studio.

## Controls

- **WASD** — pan camera
- **Scroll wheel** — zoom
- **Hotbar button, then left-click the world** — apply the selected god tool
- **Pause / 1x / 2x / 4x** — control simulation speed (shared by all players)

## Tuning

Nearly every gameplay number (grid size, population cap, growth rate, combat
radius, migration distance, etc.) lives in `src/shared/Config.lua` — that's
the first place to look to make villages grow faster, wars more frequent, or
the world bigger.

## Ideas for extending this

- Replace block-pawn villagers with rigged NPC models and real pathfinding
  for a more "alive" look.
- Add per-player god mana/cooldowns so disasters aren't spammable in a
  multiplayer server.
- Persist world state with `DataStoreService` so a server's civilization
  survives a restart.
- Tech progression per faction (farming → bronze → iron) that changes
  growth rate, combat power, and building visuals.
