-- Wires hotbar buttons to a "selected tool" and mouse clicks on world tiles
-- to the RequestTool remote. Also renders incoming WorldState stat updates.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ToolDefs = require(ReplicatedStorage.Shared.ToolDefs)

local InputHandler = {}

function InputHandler.Init(ui)
	local player = Players.LocalPlayer
	local mouse = player:GetMouse()
	local Remotes = ReplicatedStorage:WaitForChild("Remotes")
	local RequestTool = Remotes:WaitForChild("RequestTool")
	local SpeedControl = Remotes:WaitForChild("SpeedControl")
	local WorldState = Remotes:WaitForChild("WorldState")

	local selectedTool = nil

	local function selectTool(key, label)
		selectedTool = key
		for toolKey, btn in pairs(ui.ToolButtons) do
			btn.BackgroundColor3 = (toolKey == key) and Color3.fromRGB(90, 140, 230) or Color3.fromRGB(45, 45, 55)
		end
		ui.SelectedLabel.Text = "Tool: " .. label
	end

	for _, def in ipairs(ToolDefs) do
		local btn = ui.ToolButtons[def.key]
		btn.MouseButton1Click:Connect(function()
			selectTool(def.key, def.label)
		end)
	end

	mouse.Button1Down:Connect(function()
		if not selectedTool then
			return
		end
		local target = mouse.Hit
		if not target then
			return
		end
		local worldTiles = workspace:FindFirstChild("WorldTiles")
		if mouse.Target and worldTiles and mouse.Target:IsDescendantOf(worldTiles) then
			RequestTool:FireServer(selectedTool, target.Position)
		end
	end)

	ui.PauseButton.MouseButton1Click:Connect(function()
		SpeedControl:FireServer("PauseToggle")
	end)
	ui.Speed1Button.MouseButton1Click:Connect(function()
		SpeedControl:FireServer("Speed1")
	end)
	ui.Speed2Button.MouseButton1Click:Connect(function()
		SpeedControl:FireServer("Speed2")
	end)
	ui.Speed4Button.MouseButton1Click:Connect(function()
		SpeedControl:FireServer("Speed4")
	end)

	WorldState.OnClientEvent:Connect(function(stats)
		ui.StatsLabel.Text = string.format(
			"Population: %d | Villages: %d | Speed: %s",
			stats.TotalPopulation,
			stats.TotalVillages,
			stats.Paused and "Paused" or (tostring(stats.Speed) .. "x")
		)
		ui.PauseButton.Text = stats.Paused and "Resume" or "Pause"

		for _, child in ipairs(ui.Leaderboard:GetChildren()) do
			if child:IsA("TextLabel") and child.Name == "FactionRow" then
				child:Destroy()
			end
		end

		for i, f in ipairs(stats.Factions) do
			if i > 6 then
				break
			end
			local row = Instance.new("TextLabel")
			row.Name = "FactionRow"
			row.Size = UDim2.new(1, -10, 0, 20)
			row.BackgroundTransparency = 1
			row.Font = Enum.Font.Gotham
			row.TextScaled = true
			row.TextXAlignment = Enum.TextXAlignment.Left
			row.TextColor3 = Color3.new(f.Color[1], f.Color[2], f.Color[3])
			row.Text = string.format("%s - %d", f.Name, f.Population)
			row.LayoutOrder = i
			row.Parent = ui.Leaderboard
		end
	end)
end

return InputHandler
