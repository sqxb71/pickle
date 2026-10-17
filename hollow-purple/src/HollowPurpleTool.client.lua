-- LocalScript inside the "Hollow Purple" tool: sends the aim point to the server.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local tool = script.Parent
local folder = ReplicatedStorage:WaitForChild("HollowPurple")
local Config = require(folder:WaitForChild("Config"))
local Cast = folder:WaitForChild("Cast")

local mouse = Players.LocalPlayer:GetMouse()
local ready = true

tool.Activated:Connect(function()
	if not ready then
		return
	end
	ready = false
	mouse.TargetFilter = workspace:FindFirstChild("HollowPurpleFX")
	Cast:FireServer(mouse.Hit.Position)

	local baseTip = "Hollow Purple"
	for remaining = math.ceil(Config.Cooldown), 1, -1 do
		tool.ToolTip = string.format("%s (%ds)", baseTip, remaining)
		task.wait(1)
	end
	tool.ToolTip = baseTip
	ready = true
end)
