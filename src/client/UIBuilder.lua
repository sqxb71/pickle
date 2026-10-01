-- Builds the whole HUD programmatically: top bar (pause/speed/stats),
-- a civilization leaderboard, and the bottom tool hotbar.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ToolDefs = require(ReplicatedStorage.Shared.ToolDefs)

local UIBuilder = {}

local function corner(parent, radius)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, radius or 6)
	c.Parent = parent
	return c
end

function UIBuilder.Build()
	local player = Players.LocalPlayer
	local playerGui = player:WaitForChild("PlayerGui")

	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "CivSimUI"
	screenGui.ResetOnSpawn = false
	screenGui.IgnoreGuiInset = true
	screenGui.Parent = playerGui

	-- Top bar
	local topBar = Instance.new("Frame")
	topBar.Name = "TopBar"
	topBar.Size = UDim2.new(1, 0, 0, 50)
	topBar.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
	topBar.BackgroundTransparency = 0.25
	topBar.BorderSizePixel = 0
	topBar.Parent = screenGui

	local topLayout = Instance.new("UIListLayout")
	topLayout.FillDirection = Enum.FillDirection.Horizontal
	topLayout.Padding = UDim.new(0, 8)
	topLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	topLayout.Parent = topBar

	local topPadding = Instance.new("UIPadding")
	topPadding.PaddingLeft = UDim.new(0, 10)
	topPadding.PaddingTop = UDim.new(0, 6)
	topPadding.Parent = topBar

	local function makeTopButton(text)
		local btn = Instance.new("TextButton")
		btn.Size = UDim2.new(0, 90, 0, 36)
		btn.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
		btn.TextColor3 = Color3.new(1, 1, 1)
		btn.Font = Enum.Font.GothamBold
		btn.TextScaled = true
		btn.Text = text
		btn.Parent = topBar
		corner(btn)
		return btn
	end

	local pauseBtn = makeTopButton("Pause")
	local speed1Btn = makeTopButton("1x")
	local speed2Btn = makeTopButton("2x")
	local speed4Btn = makeTopButton("4x")

	local statsLabel = Instance.new("TextLabel")
	statsLabel.Size = UDim2.new(0, 460, 0, 36)
	statsLabel.BackgroundTransparency = 1
	statsLabel.TextColor3 = Color3.new(1, 1, 1)
	statsLabel.Font = Enum.Font.Gotham
	statsLabel.TextScaled = true
	statsLabel.TextXAlignment = Enum.TextXAlignment.Left
	statsLabel.Text = "Population: 0 | Villages: 0"
	statsLabel.Parent = topBar

	-- Leaderboard
	local leaderboard = Instance.new("Frame")
	leaderboard.Name = "Leaderboard"
	leaderboard.Size = UDim2.new(0, 220, 0, 180)
	leaderboard.Position = UDim2.new(1, -230, 0, 60)
	leaderboard.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
	leaderboard.BackgroundTransparency = 0.25
	leaderboard.Parent = screenGui
	corner(leaderboard, 8)

	local lbPadding = Instance.new("UIPadding")
	lbPadding.PaddingLeft = UDim.new(0, 8)
	lbPadding.PaddingTop = UDim.new(0, 8)
	lbPadding.Parent = leaderboard

	local lbLayout = Instance.new("UIListLayout")
	lbLayout.Padding = UDim.new(0, 2)
	lbLayout.SortOrder = Enum.SortOrder.LayoutOrder
	lbLayout.Parent = leaderboard

	local lbTitle = Instance.new("TextLabel")
	lbTitle.Size = UDim2.new(1, -10, 0, 24)
	lbTitle.BackgroundTransparency = 1
	lbTitle.TextColor3 = Color3.new(1, 1, 1)
	lbTitle.Font = Enum.Font.GothamBold
	lbTitle.TextScaled = true
	lbTitle.TextXAlignment = Enum.TextXAlignment.Left
	lbTitle.Text = "Civilizations"
	lbTitle.LayoutOrder = 0
	lbTitle.Parent = leaderboard

	-- Hotbar
	local hotbar = Instance.new("Frame")
	hotbar.Name = "Hotbar"
	hotbar.Size = UDim2.new(0, 0, 0, 64)
	hotbar.AutomaticSize = Enum.AutomaticSize.X
	hotbar.AnchorPoint = Vector2.new(0.5, 1)
	hotbar.Position = UDim2.new(0.5, 0, 1, -16)
	hotbar.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
	hotbar.BackgroundTransparency = 0.2
	hotbar.Parent = screenGui
	corner(hotbar, 10)

	local hbLayout = Instance.new("UIListLayout")
	hbLayout.FillDirection = Enum.FillDirection.Horizontal
	hbLayout.Padding = UDim.new(0, 6)
	hbLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	hbLayout.Parent = hotbar

	local hbPadding = Instance.new("UIPadding")
	hbPadding.PaddingLeft = UDim.new(0, 8)
	hbPadding.PaddingRight = UDim.new(0, 8)
	hbPadding.Parent = hotbar

	local toolButtons = {}
	for _, def in ipairs(ToolDefs) do
		local btn = Instance.new("TextButton")
		btn.Name = def.key
		btn.Size = UDim2.new(0, 86, 0, 48)
		btn.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
		btn.TextColor3 = Color3.new(1, 1, 1)
		btn.Font = Enum.Font.GothamBold
		btn.TextScaled = true
		btn.Text = def.label
		btn.Parent = hotbar
		corner(btn)
		toolButtons[def.key] = btn
	end

	local selectedLabel = Instance.new("TextLabel")
	selectedLabel.Size = UDim2.new(0, 320, 0, 24)
	selectedLabel.AnchorPoint = Vector2.new(0.5, 1)
	selectedLabel.Position = UDim2.new(0.5, 0, 1, -86)
	selectedLabel.BackgroundTransparency = 1
	selectedLabel.TextColor3 = Color3.new(1, 1, 1)
	selectedLabel.TextStrokeTransparency = 0.3
	selectedLabel.Font = Enum.Font.GothamBold
	selectedLabel.TextScaled = true
	selectedLabel.Text = "Tool: None (pick one below, then click the world)"
	selectedLabel.Parent = screenGui

	return {
		ScreenGui = screenGui,
		PauseButton = pauseBtn,
		Speed1Button = speed1Btn,
		Speed2Button = speed2Btn,
		Speed4Button = speed4Btn,
		StatsLabel = statsLabel,
		Leaderboard = leaderboard,
		ToolButtons = toolButtons,
		SelectedLabel = selectedLabel,
	}
end

return UIBuilder
