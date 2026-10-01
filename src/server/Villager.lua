-- A single population unit. Rendered as one small anchored Part that is
-- tweened around rather than physically simulated (cheap for a few hundred
-- of these at once). Each villager runs its own coroutine that alternates
-- between wandering and gathering resources for its village.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local TweenService = game:GetService("TweenService")
local Config = require(ReplicatedStorage.Shared.Config)
local TerrainManager = require(ServerScriptService.TerrainManager)

local Villager = {}
Villager.__index = Villager

function Villager.new(village, position)
	local folder = workspace:FindFirstChild("WorldUnits")

	local part = Instance.new("Part")
	part.Name = "Villager"
	part.Size = Vector3.new(1, 2, 1)
	part.Color = village.Faction.Color
	part.Material = Enum.Material.SmoothPlastic
	part.CanCollide = false
	part.Anchored = true
	part.Position = position
	part.Parent = folder

	local self = setmetatable({}, Villager)
	self.Part = part
	self.Village = village
	self.Alive = true
	self.CurrentTween = nil

	task.spawn(function()
		self:_Loop()
	end)

	return self
end

function Villager:MoveTo(target)
	if not self.Alive or not self.Part then
		return
	end
	local dist = (target - self.Part.Position).Magnitude
	if dist < 0.5 then
		return
	end
	local duration = math.clamp(dist / Config.VILLAGER_SPEED, 0.3, 8)
	local tween = TweenService:Create(self.Part, TweenInfo.new(duration, Enum.EasingStyle.Linear), { Position = target })
	self.CurrentTween = tween
	tween:Play()
	tween.Completed:Wait()
end

function Villager:_Loop()
	task.wait(math.random() * 2)
	while self.Alive do
		local village = self.Village
		if not village or not village.Position then
			break
		end

		local roll = math.random()
		if roll < 0.55 then
			local angle = math.random() * math.pi * 2
			local r = math.random(2, math.max(3, village.Radius - 2))
			local target = village.Position + Vector3.new(math.cos(angle) * r, 0, math.sin(angle) * r)
			target = TerrainManager.SnapToGround(target)
			self:MoveTo(target)
			if not self.Alive then
				break
			end
			task.wait(math.random(2, 4))
		else
			local resourceKey = math.random() < 0.5 and "wood" or "food"
			local tile = TerrainManager.FindNearestResourceTile(village.Position, village.Radius, resourceKey)
			if tile then
				self:MoveTo(tile.Position)
				if not self.Alive then
					break
				end
				task.wait(1 + math.random())
				village.Food += Config.GATHER_AMOUNT
				if tile.Type == "Forest" and math.random() < 0.06 then
					TerrainManager.SetTileType(tile.x, tile.z, "Grass")
				end
			else
				task.wait(1.5)
			end
		end
	end
end

function Villager:Kill()
	self.Alive = false
	if self.CurrentTween then
		pcall(function()
			self.CurrentTween:Cancel()
		end)
	end
	if self.Part then
		self.Part:Destroy()
		self.Part = nil
	end
end

return Villager
