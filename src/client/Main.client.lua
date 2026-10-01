local CameraController = require(script.Parent.CameraController)
local UIBuilder = require(script.Parent.UIBuilder)
local InputHandler = require(script.Parent.InputHandler)

CameraController.Init()
local ui = UIBuilder.Build()
InputHandler.Init(ui)
