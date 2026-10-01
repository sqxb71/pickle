-- Drives simulation ticks off Heartbeat, honoring a shared pause/speed
-- state that any player can toggle (the world is a single shared sandbox).
-- Also broadcasts lightweight stats to all clients once a second.

local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Config = require(ReplicatedStorage.Shared.Config)
local CivManager = require(ServerScriptService.CivManager)

local SimClock = {}
SimClock.Paused = false
SimClock.Speed = 1

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local SpeedControl = Remotes:WaitForChild("SpeedControl")
local WorldState = Remotes:WaitForChild("WorldState")

SpeedControl.OnServerEvent:Connect(function(_player, action)
	if action == "PauseToggle" then
		SimClock.Paused = not SimClock.Paused
	elseif action == "Speed1" then
		SimClock.Speed = 1
	elseif action == "Speed2" then
		SimClock.Speed = 2
	elseif action == "Speed4" then
		SimClock.Speed = 4
	end
end)

function SimClock.Init()
	local accumulator = 0
	local statAccumulator = 0

	RunService.Heartbeat:Connect(function(dt)
		if not SimClock.Paused then
			accumulator += dt * SimClock.Speed
			while accumulator >= Config.TICK_INTERVAL do
				accumulator -= Config.TICK_INTERVAL
				CivManager:Tick()
			end
		end

		statAccumulator += dt
		if statAccumulator >= 1 then
			statAccumulator = 0
			local stats = CivManager:GetStats()
			stats.Paused = SimClock.Paused
			stats.Speed = SimClock.Speed
			WorldState:FireAllClients(stats)
		end
	end)
end

return SimClock
