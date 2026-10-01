local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Config = require(ReplicatedStorage.Shared.Config)

local Village = {}
Village.__index = Village

function Village.new(faction, position)
	local self = setmetatable({}, Village)
	self.Faction = faction
	self.Position = position
	self.Radius = Config.VILLAGE_RADIUS
	self.Food = Config.VILLAGE_START_FOOD
	self.Villagers = {}
	self.Houses = {}
	self.BlessedUntil = 0
	self.PlagueTicks = 0
	self.Anchor = nil
	self.Label = nil
	return self
end

function Village:CreateAnchor()
	local folder = workspace:FindFirstChild("WorldUnits")
	local anchor = Instance.new("Part")
	anchor.Name = "VillageAnchor"
	anchor.Size = Vector3.new(0.2, 0.2, 0.2)
	anchor.Transparency = 1
	anchor.CanCollide = false
	anchor.Anchored = true
	anchor.Position = self.Position + Vector3.new(0, 8, 0)
	anchor.Parent = folder

	local billboard = Instance.new("BillboardGui")
	billboard.Size = UDim2.new(0, 160, 0, 36)
	billboard.AlwaysOnTop = true
	billboard.Parent = anchor

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, 0, 1, 0)
	label.BackgroundTransparency = 1
	label.TextColor3 = Color3.new(1, 1, 1)
	label.TextStrokeTransparency = 0
	label.Font = Enum.Font.GothamBold
	label.TextScaled = true
	label.Text = self.Faction.Name
	label.Parent = billboard

	self.Anchor = anchor
	self.Label = label
end

function Village:UpdateLabel()
	if self.Label then
		self.Label.Text = string.format("%s (%d)", self.Faction.Name, #self.Villagers)
		self.Label.TextColor3 = self.Faction.Color
	end
end

function Village:AddVillager(villager)
	table.insert(self.Villagers, villager)
	if #self.Villagers % 3 == 0 then
		self:BuildHouse()
	end
end

function Village:BuildHouse()
	local folder = workspace:FindFirstChild("WorldUnits")
	if not folder then
		return
	end

	local angle = math.random() * math.pi * 2
	local r = math.random(4, math.max(5, self.Radius - 2))
	local pos = self.Position + Vector3.new(math.cos(angle) * r, 0, math.sin(angle) * r)

	local base = Instance.new("Part")
	base.Name = "House"
	base.Size = Vector3.new(4, 3, 4)
	base.Anchored = true
	base.CanCollide = false
	base.Material = Enum.Material.Wood
	base.Color = Color3.fromRGB(150, 110, 70)
	base.Position = pos + Vector3.new(0, 1.5, 0)
	base.Parent = folder

	local flag = Instance.new("Part")
	flag.Name = "Flag"
	flag.Size = Vector3.new(0.3, 2, 0.3)
	flag.Anchored = true
	flag.CanCollide = false
	flag.Color = self.Faction.Color
	flag.Position = pos + Vector3.new(0, 4, 0)
	flag.Parent = folder

	table.insert(self.Houses, base)
	table.insert(self.Houses, flag)
end

function Village:Destroy()
	for _, villager in ipairs(self.Villagers) do
		villager:Kill()
	end
	self.Villagers = {}

	for _, house in ipairs(self.Houses) do
		house:Destroy()
	end
	self.Houses = {}

	if self.Anchor then
		self.Anchor:Destroy()
		self.Anchor = nil
	end
end

return Village
