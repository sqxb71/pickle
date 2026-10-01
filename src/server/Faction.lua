local Faction = {}
Faction.__index = Faction

local NAMES = {
	"Ardonia", "Belmara", "Cressfall", "Drakmoor", "Eldwyn", "Fenros",
	"Gravenna", "Hollowmere", "Ikaris", "Juno", "Korrath", "Lysandra",
	"Myrrow", "Nordholt", "Oakhaven", "Pyreth",
}

function Faction.new(id)
	local self = setmetatable({}, Faction)
	self.Id = id

	local baseName = NAMES[((id - 1) % #NAMES) + 1]
	local suffixIndex = math.floor((id - 1) / #NAMES)
	self.Name = suffixIndex > 0 and (baseName .. " " .. tostring(suffixIndex + 1)) or baseName

	-- Golden-angle hue spread so consecutive factions get visually distinct colors.
	self.Color = Color3.fromHSV((id * 0.37) % 1, 0.6, 0.95)
	self.Villages = {}

	return self
end

return Faction
