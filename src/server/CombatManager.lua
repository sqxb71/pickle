-- Simple proximity-based warfare: when two villages of different factions
-- are close enough, there's a per-tick chance of a skirmish where the
-- weaker side (population * randomness) loses a villager.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Config = require(ReplicatedStorage.Shared.Config)

local CombatManager = {}

function CombatManager.Resolve(villages, killFn)
	local n = #villages
	for i = 1, n do
		local a = villages[i]
		if a and #a.Villagers > 0 then
			for j = i + 1, n do
				local b = villages[j]
				if b and b.Faction ~= a.Faction and #b.Villagers > 0 then
					local dist = (a.Position - b.Position).Magnitude
					if dist < Config.COMBAT_RADIUS * 2 and math.random() < 0.15 then
						local aPower = #a.Villagers * math.random()
						local bPower = #b.Villagers * math.random()
						if aPower > bPower then
							killFn(b, b.Villagers[math.random(#b.Villagers)])
						else
							killFn(a, a.Villagers[math.random(#a.Villagers)])
						end
					end
				end
			end
		end
	end
end

return CombatManager
