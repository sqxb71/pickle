# Graph Report - pickle  (2026-10-15)

## Corpus Check
- 19 files · ~5,124 words
- Verdict: corpus is large enough that graph structure adds value.
- Unclassified: 1 file(s) not represented in the graph (top: (none) 1)

## Summary
- 93 nodes · 163 edges · 12 communities (6 shown, 6 thin omitted)
- Extraction: 83% EXTRACTED · 17% INFERRED · 0% AMBIGUOUS · INFERRED: 28 edges (avg confidence: 0.85)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `6da73e2e`
- Run `git rev-parse HEAD` and compare to check if the graph is stale.
- Run `graphify update .` after code changes (no API cost).

## Community Hubs (Navigation)
- TerrainManager.lua
- CivManager.lua
- GodTools.Init
- replicatedstorage_shared_config
- CivSim
- replicatedstorage_shared_tooldefs
- Villager.lua

## God Nodes (most connected - your core abstractions)
1. `GodTools.Init()` - 13 edges
2. `TerrainManager.GetTile()` - 11 edges
3. `TerrainManager.WorldToGrid()` - 8 edges
4. `TerrainManager.SnapToGround()` - 8 edges
5. `CivManager:TryMigrate()` - 7 edges
6. `TerrainManager.SetTileType()` - 7 edges
7. `CivSim` - 7 edges
8. `TerrainManager.GridToWorldPos()` - 6 edges
9. `TerrainManager.BurnArea()` - 6 edges
10. `TerrainManager.Quake()` - 6 edges

## Surprising Connections (you probably didn't know these)
- `CivManager:SpawnVillage()` --calls--> `Village.new()`  [INFERRED]
  src/server/CivManager.lua → src/server/Village.lua
- `CivManager:SpawnVillagerInVillage()` --calls--> `TerrainManager.SnapToGround()`  [INFERRED]
  src/server/CivManager.lua → src/server/TerrainManager.lua
- `CivManager:SpawnVillagerInVillage()` --calls--> `Villager.new()`  [INFERRED]
  src/server/CivManager.lua → src/server/Villager.lua
- `CivManager:TryMigrate()` --calls--> `TerrainManager.ClampToWorld()`  [INFERRED]
  src/server/CivManager.lua → src/server/TerrainManager.lua
- `CivManager:TryMigrate()` --calls--> `TerrainManager.IsWalkableNear()`  [INFERRED]
  src/server/CivManager.lua → src/server/TerrainManager.lua

## Import Cycles
- None detected.

## Communities (12 total, 6 thin omitted)

### Community 0 - "TerrainManager.lua"
Cohesion: 0.27
Nodes (16): classify(), computeWorldPos(), heightToStuds(), TerrainManager.BurnArea(), TerrainManager.FindNearestResourceTile(), TerrainManager.Generate(), TerrainManager.GetTile(), TerrainManager.GridToWorldPos() (+8 more)

### Community 1 - "CivManager.lua"
Cohesion: 0.18
Nodes (11): CivManager:CreateFaction(), CivManager:DestroyVillage(), CivManager:RemoveVillager(), CivManager:SpawnVillage(), CivManager:SpawnVillagerInVillage(), CivManager:Tick(), CivManager:TickVillage(), CivManager:TryMigrate() (+3 more)

### Community 2 - "GodTools.Init"
Cohesion: 0.20
Nodes (9): DisasterManager.Blessing(), DisasterManager.Earthquake(), DisasterManager.Explode(), DisasterManager.Plague(), DisasterManager.Strike(), villagersNear(), GodTools.Init(), isValidVector() (+1 more)

### Community 3 - "replicatedstorage_shared_config"
Cohesion: 0.20
Nodes (3): CombatManager.Resolve(), Village:AddVillager(), Village:BuildHouse()

### Community 4 - "CivSim"
Cohesion: 0.25
Nodes (7): CivSim, Controls, Ideas for extending this, Project layout, Running it in Roblox Studio, Tuning, What it does

### Community 6 - "Villager.lua"
Cohesion: 0.60
Nodes (3): Villager:_Loop(), Villager:MoveTo(), Villager.new()

## Knowledge Gaps
- **6 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `GodTools.Init()` connect `GodTools.Init` to `TerrainManager.lua`?**
  _High betweenness centrality (0.099) - this node is a cross-community bridge._
- **Are the 11 inferred relationships involving `GodTools.Init()` (e.g. with `DisasterManager.Blessing()` and `DisasterManager.Earthquake()`) actually correct?**
  _`GodTools.Init()` has 11 INFERRED edges - model-reasoned connections that need verification._
- **Why does `TerrainManager.SnapToGround()` connect `TerrainManager.lua` to `CivManager.lua`, `GodTools.Init`, `Villager.lua`?**
  _High betweenness centrality (0.049) - this node is a cross-community bridge._
- **Are the 4 inferred relationships involving `TerrainManager.SnapToGround()` (e.g. with `CivManager:SpawnVillagerInVillage()` and `CivManager:TryMigrate()`) actually correct?**
  _`TerrainManager.SnapToGround()` has 4 INFERRED edges - model-reasoned connections that need verification._
- **Are the 3 inferred relationships involving `CivManager:TryMigrate()` (e.g. with `TerrainManager.ClampToWorld()` and `TerrainManager.IsWalkableNear()`) actually correct?**
  _`CivManager:TryMigrate()` has 3 INFERRED edges - model-reasoned connections that need verification._