-- Top-level simulation state: all factions and villages, population growth,
-- starvation, plague progression, migration/expansion, and the per-tick
-- entry point driven by SimClock.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Config = require(ReplicatedStorage.Shared.Config)
local Faction = require(ServerScriptService.Faction)
local Village = require(ServerScriptService.Village)
local Villager = require(ServerScriptService.Villager)
local TerrainManager = require(ServerScriptService.TerrainManager)
local CombatManager = require(ServerScriptService.CombatManager)

local CivManager = {}
CivManager.Factions = {}
CivManager.Villages = {}
CivManager.NextFactionId = 1
CivManager.TotalVillagerCount = 0

function CivManager:CreateFaction()
	local faction = Faction.new(self.NextFactionId)
	self.NextFactionId += 1
	self.Factions[faction.Id] = faction
	return faction
end

function CivManager:SpawnVillage(position, faction)
	faction = faction or self:CreateFaction()
	local village = Village.new(faction, position)
	village:CreateAnchor()
	table.insert(faction.Villages, village)
	table.insert(self.Villages, village)

	for _ = 1, Config.VILLAGE_START_POP do
		self:SpawnVillagerInVillage(village)
	end
	village:UpdateLabel()

	return village
end

function CivManager:SpawnVillagerInVillage(village)
	if self.TotalVillagerCount >= Config.MAX_TOTAL_VILLAGERS then
		return nil
	end

	local angle = math.random() * math.pi * 2
	local r = math.random(0, 6)
	local pos = village.Position + Vector3.new(math.cos(angle) * r, 0, math.sin(angle) * r)
	pos = TerrainManager.SnapToGround(pos)

	local villager = Villager.new(village, pos)
	village:AddVillager(villager)
	self.TotalVillagerCount += 1
	village:UpdateLabel()

	return villager
end

function CivManager:RemoveVillager(village, villager)
	local idx = table.find(village.Villagers, villager)
	if not idx then
		return
	end
	table.remove(village.Villagers, idx)
	villager:Kill()
	self.TotalVillagerCount -= 1
	village:UpdateLabel()

	if #village.Villagers <= 0 then
		self:DestroyVillage(village)
	end
end

function CivManager:DestroyVillage(village)
	village:Destroy()

	local vIdx = table.find(self.Villages, village)
	if vIdx then
		table.remove(self.Villages, vIdx)
	end

	local faction = village.Faction
	local fIdx = table.find(faction.Villages, village)
	if fIdx then
		table.remove(faction.Villages, fIdx)
	end
end

function CivManager:TryMigrate(village)
	local faction = village.Faction
	local angle = math.random() * math.pi * 2
	local dist = math.random(Config.MIGRATION_DISTANCE_MIN, Config.MIGRATION_DISTANCE_MAX)
	local newPos = village.Position + Vector3.new(math.cos(angle) * dist, 0, math.sin(angle) * dist)
	newPos = TerrainManager.ClampToWorld(newPos)

	if not TerrainManager.IsWalkableNear(newPos) then
		return
	end

	local migrants = math.min(3, #village.Villagers - 2)
	if migrants < 2 then
		return
	end

	for _ = 1, migrants do
		local v = village.Villagers[1]
		if v then
			self:RemoveVillager(village, v)
		end
	end

	newPos = TerrainManager.SnapToGround(newPos)
	self:SpawnVillage(newPos, faction)
end

function CivManager:TickVillage(village)
	local n = #village.Villagers
	if n == 0 then
		return
	end

	village.Food -= n * Config.FOOD_CONSUMPTION_PER_VILLAGER
	if village.Food < 0 then
		village.Food = 0
		if math.random() < 0.25 and #village.Villagers > 0 then
			local victim = village.Villagers[math.random(#village.Villagers)]
			self:RemoveVillager(village, victim)
		end
	end

	if village.PlagueTicks and village.PlagueTicks > 0 then
		village.PlagueTicks -= 1
		if math.random() < 0.4 and #village.Villagers > 0 then
			local victim = village.Villagers[math.random(#village.Villagers)]
			self:RemoveVillager(village, victim)
		end
	end

	if #village.Villagers == 0 then
		return
	end

	local growthThreshold = Config.VILLAGE_FOOD_PER_GROWTH
	if village.BlessedUntil and village.BlessedUntil > os.clock() then
		growthThreshold *= 0.6
	end

	if village.Food >= growthThreshold and #village.Villagers < Config.VILLAGE_POP_CAP then
		village.Food -= growthThreshold
		self:SpawnVillagerInVillage(village)
	end

	if #village.Villagers >= Config.VILLAGE_POP_CAP then
		self:TryMigrate(village)
	end
end

function CivManager:Tick()
	for _, village in ipairs(table.clone(self.Villages)) do
		self:TickVillage(village)
	end

	CombatManager.Resolve(self.Villages, function(village, villager)
		self:RemoveVillager(village, villager)
	end)
end

function CivManager:GetStats()
	local totalPop = 0
	local factionStats = {}

	for _, faction in pairs(self.Factions) do
		local pop = 0
		for _, village in ipairs(faction.Villages) do
			pop += #village.Villagers
		end
		if pop > 0 then
			table.insert(factionStats, {
				Name = faction.Name,
				Color = { faction.Color.R, faction.Color.G, faction.Color.B },
				Population = pop,
				Villages = #faction.Villages,
			})
		end
		totalPop += pop
	end

	table.sort(factionStats, function(a, b)
		return a.Population > b.Population
	end)

	return {
		TotalPopulation = totalPop,
		TotalVillages = #self.Villages,
		Factions = factionStats,
	}
end

return CivManager
