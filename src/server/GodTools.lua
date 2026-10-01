-- Server-side handler for the RequestTool RemoteEvent. Validates input and
-- dispatches to TerrainManager / CivManager / DisasterManager. This is the
-- only place that trusts (validated) client input.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local ToolDefs = require(ReplicatedStorage.Shared.ToolDefs)
local TerrainManager = require(ServerScriptService.TerrainManager)
local CivManager = require(ServerScriptService.CivManager)
local DisasterManager = require(ServerScriptService.DisasterManager)

local GodTools = {}

local VALID_TOOLS = {}
for _, def in ipairs(ToolDefs) do
	VALID_TOOLS[def.key] = true
end

local COOLDOWN = 0.12

local function isValidVector(v)
	if typeof(v) ~= "Vector3" then
		return false
	end
	if v.X ~= v.X or v.Y ~= v.Y or v.Z ~= v.Z then -- NaN check
		return false
	end
	return math.abs(v.X) < 1e6 and math.abs(v.Y) < 1e6 and math.abs(v.Z) < 1e6
end

local function killFn(village, villager)
	CivManager:RemoveVillager(village, villager)
end

function GodTools.Init()
	local Remotes = ReplicatedStorage:WaitForChild("Remotes")
	local RequestTool = Remotes:WaitForChild("RequestTool")
	local lastUse = {}

	Players.PlayerRemoving:Connect(function(player)
		lastUse[player] = nil
	end)

	RequestTool.OnServerEvent:Connect(function(player, toolKey, position)
		if typeof(toolKey) ~= "string" or not VALID_TOOLS[toolKey] then
			return
		end
		if not isValidVector(position) then
			return
		end

		local now = os.clock()
		if lastUse[player] and now - lastUse[player] < COOLDOWN then
			return
		end
		lastUse[player] = now

		local x, z = TerrainManager.WorldToGrid(position)
		if not TerrainManager.GetTile(x, z) then
			return
		end

		if toolKey == "RaiseLand" then
			TerrainManager.RaiseLower(x, z, 1)
		elseif toolKey == "LowerLand" then
			TerrainManager.RaiseLower(x, z, -1)
		elseif toolKey == "PlaceWater" then
			TerrainManager.SetTileType(x, z, "Water")
		elseif toolKey == "PlantForest" then
			if TerrainManager.IsWalkable(x, z) then
				TerrainManager.SetTileType(x, z, "Forest")
			end
		elseif toolKey == "Flatten" then
			local tile = TerrainManager.GetTile(x, z)
			if tile and tile.Type ~= "Water" then
				TerrainManager.SetTileType(x, z, "Grass")
			end
		elseif toolKey == "SpawnVillage" then
			if TerrainManager.IsWalkable(x, z) then
				CivManager:SpawnVillage(TerrainManager.SnapToGround(position))
			end
		elseif toolKey == "Blessing" then
			DisasterManager.Blessing(CivManager.Villages, position, 20)
		elseif toolKey == "Lightning" then
			DisasterManager.Strike(CivManager.Villages, position, killFn)
		elseif toolKey == "Meteor" then
			DisasterManager.Explode(CivManager.Villages, position, 14, killFn)
		elseif toolKey == "Plague" then
			DisasterManager.Plague(CivManager.Villages, position, 24)
		elseif toolKey == "Earthquake" then
			DisasterManager.Earthquake(CivManager.Villages, position, 18)
		end
	end)
end

return GodTools
