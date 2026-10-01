-- Area-effect "god power" disasters: fire, lightning, plague, earthquakes,
-- and blessings. These operate directly on the live village/villager lists
-- and on the terrain grid.

local ServerScriptService = game:GetService("ServerScriptService")
local TerrainManager = require(ServerScriptService.TerrainManager)

local DisasterManager = {}

local function villagersNear(villages, position, radius)
	local list = {}
	for _, village in ipairs(villages) do
		for _, v in ipairs(village.Villagers) do
			if v.Part and (v.Part.Position - position).Magnitude <= radius then
				table.insert(list, { village = village, villager = v })
			end
		end
	end
	return list
end

function DisasterManager.Explode(villages, position, radius, killFn)
	local hits = villagersNear(villages, position, radius)
	for _, hit in ipairs(hits) do
		if math.random() < 0.8 then
			killFn(hit.village, hit.villager)
		end
	end
	TerrainManager.BurnArea(position, radius)
end

function DisasterManager.Strike(villages, position, killFn)
	local hits = villagersNear(villages, position, 4)
	if #hits > 0 then
		local hit = hits[math.random(#hits)]
		killFn(hit.village, hit.villager)
	end
	TerrainManager.IgniteAt(position)
end

function DisasterManager.Plague(villages, position, radius)
	for _, village in ipairs(villages) do
		if (village.Position - position).Magnitude <= radius then
			village.PlagueTicks = (village.PlagueTicks or 0) + 10
		end
	end
end

function DisasterManager.Earthquake(villages, position, radius)
	TerrainManager.Quake(position, radius)
	for _, village in ipairs(villages) do
		if (village.Position - position).Magnitude <= radius and #village.Houses > 0 and math.random() < 0.5 then
			local idx = math.random(#village.Houses)
			local h = table.remove(village.Houses, idx)
			if h then
				h:Destroy()
			end
		end
	end
end

function DisasterManager.Blessing(villages, position, radius)
	for _, village in ipairs(villages) do
		if (village.Position - position).Magnitude <= radius then
			village.BlessedUntil = os.clock() + 45
			village.Food += 10
		end
	end
end

return DisasterManager
