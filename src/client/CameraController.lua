-- A WorldBox/RTS-style top-down camera: WASD pans, scroll wheel zooms.

local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local CameraController = {}

function CameraController.Init()
	local camera = workspace.CurrentCamera
	camera.CameraType = Enum.CameraType.Scriptable

	local focus = Vector3.new(0, 0, 0)
	local height = 120
	local minHeight, maxHeight = 40, 260
	local panSpeed = 60

	local function updateCamera()
		-- The tiny Z offset keeps the look vector from being exactly parallel
		-- to world-up, which would otherwise make the camera's orientation
		-- singular when looking straight down.
		camera.CFrame = CFrame.new(focus + Vector3.new(0, height, 0.001), focus)
	end

	updateCamera()

	UserInputService.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseWheel then
			height = math.clamp(height - input.Position.Z * 10, minHeight, maxHeight)
			updateCamera()
		end
	end)

	RunService.RenderStepped:Connect(function(dt)
		local move = Vector3.new(0, 0, 0)
		if UserInputService:IsKeyDown(Enum.KeyCode.W) then
			move += Vector3.new(0, 0, -1)
		end
		if UserInputService:IsKeyDown(Enum.KeyCode.S) then
			move += Vector3.new(0, 0, 1)
		end
		if UserInputService:IsKeyDown(Enum.KeyCode.A) then
			move += Vector3.new(-1, 0, 0)
		end
		if UserInputService:IsKeyDown(Enum.KeyCode.D) then
			move += Vector3.new(1, 0, 0)
		end

		if move.Magnitude > 0 then
			focus += move.Unit * panSpeed * dt * (height / 120)
			updateCamera()
		end
	end)
end

return CameraController
