-- Owns the tile grid: generation, lookup, and all terraforming mutations.
-- Tiles are rendered as plain anchored Parts (no voxel Terrain service) so
-- they're cheap to mutate per-tile from god tools and the simulation.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Config = require(ReplicatedStorage.Shared.Config)
local TerrainTypes = require(ReplicatedStorage.Shared.TerrainTypes)

local TerrainManager = {}
TerrainManager.Tiles = {}

local tileFolder
local unitsFolder

local function heightToStuds(h)
	return 2 + h
end

local function computeWorldPos(x, z, height)
	local gx = (x - Config.GRID_SIZE / 2) * Config.TILE_SIZE
	local gz = (z - Config.GRID_SIZE / 2) * Config.TILE_SIZE
	local thickness = heightToStuds(height)
	return Vector3.new(gx, thickness / 2, gz), thickness
end

function TerrainManager.Init()
	tileFolder = workspace:FindFirstChild("WorldTiles")
	if not tileFolder then
		tileFolder = Instance.new("Folder")
		tileFolder.Name = "WorldTiles"
		tileFolder.Parent = workspace
	end

	unitsFolder = workspace:FindFirstChild("WorldUnits")
	if not unitsFolder then
		unitsFolder = Instance.new("Folder")
		unitsFolder.Name = "WorldUnits"
		unitsFolder.Parent = workspace
	end
end

local function classify(elevation, moisture)
	if elevation < -0.15 then
		return "Water"
	elseif elevation < -0.05 then
		return "Sand"
	elseif elevation > 0.42 then
		return "Snow"
	elseif elevation > 0.28 then
		return "Mountain"
	elseif moisture > 0.15 then
		return "Forest"
	else
		return "Grass"
	end
end

function TerrainManager.Generate()
	local seedX = math.random(0, 10000)
	local seedZ = math.random(0, 10000)
	local size = Config.GRID_SIZE

	for x = 0, size - 1 do
		TerrainManager.Tiles[x] = {}
		for z = 0, size - 1 do
			local elevation = math.noise(x * 0.07 + seedX, z * 0.07 + seedZ)
			local moisture = math.noise(x * 0.15 + seedZ, z * 0.15 + seedX)
			local key = classify(elevation, moisture)
			local heightVal = TerrainTypes[key].height

			local part = Instance.new("Part")
			part.Anchored = true
			part.Name = string.format("Tile_%d_%d", x, z)
			part.TopSurface = Enum.SurfaceType.Smooth
			part.BottomSurface = Enum.SurfaceType.Smooth
			local pos, thickness = computeWorldPos(x, z, heightVal)
			part.Size = Vector3.new(Config.TILE_SIZE - 0.2, thickness, Config.TILE_SIZE - 0.2)
			part.Position = pos
			part.Color = TerrainTypes[key].color
			part.Parent = tileFolder

			TerrainManager.Tiles[x][z] = { Type = key, Height = heightVal, Part = part }
		end
	end
end

function TerrainManager.GetTile(x, z)
	local column = TerrainManager.Tiles[x]
	if not column then
		return nil
	end
	return column[z]
end

function TerrainManager.WorldToGrid(worldPos)
	local size = Config.GRID_SIZE
	local x = math.floor(worldPos.X / Config.TILE_SIZE + size / 2 + 0.5)
	local z = math.floor(worldPos.Z / Config.TILE_SIZE + size / 2 + 0.5)
	return x, z
end

function TerrainManager.GridToWorldPos(x, z)
	local tile = TerrainManager.GetTile(x, z)
	local heightVal = tile and tile.Height or 0
	local gx = (x - Config.GRID_SIZE / 2) * Config.TILE_SIZE
	local gz = (z - Config.GRID_SIZE / 2) * Config.TILE_SIZE
	return Vector3.new(gx, heightToStuds(heightVal) + 1, gz)
end

function TerrainManager.SnapToGround(worldPos)
	local x, z = TerrainManager.WorldToGrid(worldPos)
	local tile = TerrainManager.GetTile(x, z)
	local heightVal = tile and tile.Height or 0
	return Vector3.new(worldPos.X, heightToStuds(heightVal) + 1, worldPos.Z)
end

function TerrainManager.SetTileType(x, z, key)
	local tile = TerrainManager.GetTile(x, z)
	if not tile or not TerrainTypes[key] then
		return
	end
	tile.Type = key
	tile.Height = TerrainTypes[key].height
	local pos, thickness = computeWorldPos(x, z, tile.Height)
	tile.Part.Size = Vector3.new(Config.TILE_SIZE - 0.2, thickness, Config.TILE_SIZE - 0.2)
	tile.Part.Position = pos
	tile.Part.Color = TerrainTypes[key].color
end

function TerrainManager.RaiseLower(x, z, delta)
	local tile = TerrainManager.GetTile(x, z)
	if not tile then
		return
	end

	local newHeight = math.clamp(tile.Height + delta, -1, 6)
	local key = tile.Type
	if tile.Type ~= "Water" then
		if newHeight > 4 then
			key = "Snow"
		elseif newHeight > 2.5 then
			key = "Mountain"
		elseif newHeight < -0.5 then
			key = "Sand"
		elseif tile.Type == "Mountain" or tile.Type == "Snow" or tile.Type == "Sand" then
			key = "Grass"
		end
	end

	tile.Type = key
	tile.Height = newHeight
	local pos, thickness = computeWorldPos(x, z, newHeight)
	tile.Part.Size = Vector3.new(Config.TILE_SIZE - 0.2, thickness, Config.TILE_SIZE - 0.2)
	tile.Part.Position = pos
	tile.Part.Color = TerrainTypes[key].color
end

function TerrainManager.IsWalkable(x, z)
	local tile = TerrainManager.GetTile(x, z)
	if not tile then
		return false
	end
	return TerrainTypes[tile.Type].walkable
end

function TerrainManager.IsWalkableNear(worldPos)
	local x, z = TerrainManager.WorldToGrid(worldPos)
	return TerrainManager.IsWalkable(x, z)
end

function TerrainManager.ClampToWorld(worldPos)
	local half = (Config.GRID_SIZE / 2 - 2) * Config.TILE_SIZE
	local x = math.clamp(worldPos.X, -half, half)
	local z = math.clamp(worldPos.Z, -half, half)
	return Vector3.new(x, worldPos.Y, z)
end

function TerrainManager.FindNearestResourceTile(fromPos, radius, resourceKey)
	local x0, z0 = TerrainManager.WorldToGrid(fromPos)
	local tileRadius = math.ceil(radius / Config.TILE_SIZE)
	local best, bestDist = nil, math.huge

	for dx = -tileRadius, tileRadius do
		for dz = -tileRadius, tileRadius do
			local tile = TerrainManager.GetTile(x0 + dx, z0 + dz)
			if tile then
				local matches = (resourceKey == "wood" and tile.Type == "Forest")
					or (resourceKey == "food" and (tile.Type == "Grass" or tile.Type == "Forest"))
				if matches then
					local worldPos = TerrainManager.GridToWorldPos(x0 + dx, z0 + dz)
					local dist =
						(Vector3.new(worldPos.X, 0, worldPos.Z) - Vector3.new(fromPos.X, 0, fromPos.Z)).Magnitude
					if dist < bestDist and dist <= radius then
						bestDist = dist
						best = { x = x0 + dx, z = z0 + dz, Type = tile.Type, Position = worldPos }
					end
				end
			end
		end
	end

	return best
end

function TerrainManager.BurnArea(position, radius)
	local x0, z0 = TerrainManager.WorldToGrid(position)
	local tileRadius = math.ceil(radius / Config.TILE_SIZE)
	for dx = -tileRadius, tileRadius do
		for dz = -tileRadius, tileRadius do
			local tile = TerrainManager.GetTile(x0 + dx, z0 + dz)
			if tile and (tile.Type == "Forest" or tile.Type == "Grass") then
				local worldPos = TerrainManager.GridToWorldPos(x0 + dx, z0 + dz)
				local dist = (Vector3.new(worldPos.X, 0, worldPos.Z) - Vector3.new(position.X, 0, position.Z)).Magnitude
				if dist <= radius then
					TerrainManager.SetTileType(x0 + dx, z0 + dz, "Burnt")
				end
			end
		end
	end
end

function TerrainManager.IgniteAt(position)
	local x, z = TerrainManager.WorldToGrid(position)
	local tile = TerrainManager.GetTile(x, z)
	if tile and tile.Type == "Forest" then
		TerrainManager.SetTileType(x, z, "Burnt")
	end
end

function TerrainManager.Quake(position, radius)
	local x0, z0 = TerrainManager.WorldToGrid(position)
	local tileRadius = math.ceil(radius / Config.TILE_SIZE)
	for dx = -tileRadius, tileRadius do
		for dz = -tileRadius, tileRadius do
			local tile = TerrainManager.GetTile(x0 + dx, z0 + dz)
			if tile and tile.Type ~= "Water" then
				local worldPos = TerrainManager.GridToWorldPos(x0 + dx, z0 + dz)
				local dist = (Vector3.new(worldPos.X, 0, worldPos.Z) - Vector3.new(position.X, 0, position.Z)).Magnitude
				if dist <= radius then
					TerrainManager.RaiseLower(x0 + dx, z0 + dz, math.random(-2, 1))
				end
			end
		end
	end
end

return TerrainManager
