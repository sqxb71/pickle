-- Bootstraps the world: generates terrain, seeds a few starting villages,
-- then wires up god tools and starts the simulation clock.

local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Config = require(ReplicatedStorage.Shared.Config)
local TerrainManager = require(ServerScriptService.TerrainManager)
local CivManager = require(ServerScriptService.CivManager)
local GodTools = require(ServerScriptService.GodTools)
local SimClock = require(ServerScriptService.SimClock)

TerrainManager.Init()
TerrainManager.Generate()

local spawned = 0
local attempts = 0
while spawned < 3 and attempts < 300 do
	attempts += 1
	local x = math.random(4, Config.GRID_SIZE - 5)
	local z = math.random(4, Config.GRID_SIZE - 5)
	local tile = TerrainManager.GetTile(x, z)
	if tile and tile.Type == "Grass" then
		CivManager:SpawnVillage(TerrainManager.GridToWorldPos(x, z))
		spawned += 1
	end
end

GodTools.Init()
SimClock.Init()
