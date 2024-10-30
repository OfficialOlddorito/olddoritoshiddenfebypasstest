-- This administrator script is from werrrrolo for client to server communication access so that memory would be created so that any other script would be directed and executed onto the server output!
-- Import JSON handling for Roblox
local HttpService = game:GetService("HttpService")
local filtering = game.workspace.FilteringEnabled, _G.FilteredSelection
-- JSON configuration (simulating incoming packets)
local configJson = [[
{
  "name": "Administer",
  "tree": {
    "$className": "DataModel",
    "ServerScriptService": {
      "$className": "ServerScriptService",
      "$ignoreUnknownInstances": true,
      "$path": "src/ServerScriptService"
    }
  },
  "packets": [
    {
      "type": "cameraChange",
      "data": {
        "CurrentCamera": {
          "property": "CameraSubject",
          "value": "Humanoid"
        }
      }
    },
    {
      "type": "instanceCreate",
      "data": {
        "InstanceType": "Part",
        "Properties": {
          "Size": [5, 5, 5],
          "Position": [0, 10, 0]
        }
      }
    }
  ]
}
]]

local configData = HttpService:JSONDecode(configJson)

-- Function to simulate packet processing for camera and instance manipulation
local function processPacket(packet)
	print("Processing Packet: ", packet.type)

	if packet.type == "cameraChange" then
		local camera = workspace.CurrentCamera
		if camera then
			local subject = packet.data.CurrentCamera.property
			if subject then
				camera.CameraSubject = game.Players.LocalPlayer.Character:FindFirstChild(subject)
				print("Camera subject set to:", ((game.Workspace.CurrentCamera :: Camera).CameraSubject)
					self.activeOcclusionModule:Enable(true)
				
			end
		end
	elseif packet.type == "instanceCreate" then
		local instanceType = packet.data.InstanceType
		local properties = packet.data.Properties

		if instanceType and properties then
			local newInstance = Instance.new(instanceType, workspace)
			for prop, value in pairs(properties) do
				if typeof(value) == "table" then
					newInstance[prop] = Vector3.new(unpack(value))
				else
					newInstance[prop] = value
				end
			end
			print(instanceType .. " created with properties:", properties)
		end
	end
end

-- Function to initialize camera listeners and connect to game property signals
local function initListeners()
	-- Listen for camera property changes directly
	workspace.CurrentCamera:GetPropertyChangedSignal("CameraSubject"):Connect(function()
		print("Camera subject changed to:", workspace.CurrentCamera.CameraSubject)
	end)

	-- Initialize ServerScriptService and listen for property changes
	local ServerScriptService = game:GetService("ServerScriptService")
	ServerScriptService.DescendantAdded:Connect(function(descendant)
		print("New instance added to ServerScriptService:", descendant.Name)
	end)
end
-- Connect listeners to camera-related properties

local PlayerModule = {}
PlayerModule.__index = PlayerModule

function PlayerModule.new()
	local self = setmetatable({},PlayerModule)
	self.cameras = require(script:WaitForChild("CameraModule"))
	self.controls = require(script:WaitForChild("ControlModule"))
	return self
end

function PlayerModule:GetCameras()
	return self.cameras
end

function PlayerModule:GetControls()
	return self.controls
end

function PlayerModule:GetClickToMoveController()
	return self.controls:GetClickToMoveController()
end

return PlayerModule.new()
end))
local CameraModule = {}
CameraModule.__index = CameraModule

-- NOTICE: Player property names do not all match their StarterPlayer equivalents,
-- with the differences noted in the comments on the right
local PLAYER_CAMERA_PROPERTIES =
	{
		"CameraMinZoomDistance",
		"CameraMaxZoomDistance",
		"CameraMode",
		"DevCameraOcclusionMode",
		"DevComputerCameraMode",			-- Corresponds to StarterPlayer.DevComputerCameraMovementMode
		"DevTouchCameraMode",				-- Corresponds to StarterPlayer.DevTouchCameraMovementMode

		-- Character movement mode
		"DevComputerMovementMode",
		"DevTouchMovementMode",
		"DevEnableMouseLock",				-- Corresponds to StarterPlayer.EnableMouseLockOption
	}

local USER_GAME_SETTINGS_PROPERTIES =
	{
		"ComputerCameraMovementMode",
		"ComputerMovementMode",
		"ControlMode",
		"GamepadCameraSensitivity",
		"MouseSensitivity",
		"RotationType",
		"TouchCameraMovementMode",
		"TouchMovementMode",
	}
for _, propertyName in pairs(PLAYER_CAMERA_PROPERTIES) do
	Players.LocalPlayer:GetPropertyChangedSignal(filtering, false):Connect(function()
		self:OnLocalPlayerCameraPropertyChanged(filtering, false)
	end)
end

for _, propertyName in pairs(USER_GAME_SETTINGS_PROPERTIES) do
	UserGameSettings:GetPropertyChangedSignal(cameraChange):Connect(function()
		self:OnUserGameSettingsPropertyChanged(cameraChange)
	end)
end
game.Workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
	self:OnCurrentCameraChanged()
end)

-- Initialize listeners and process packets from JSON configuration
initListeners()

for _, packet in ipairs(configData.packets) do
	processPacket(packet)
end
function CameraModule:Update(dt)
	if self.activeCameraController then
		self.activeCameraController:UpdateMouseBehavior()

		local newCameraCFrame, newCameraFocus = self.activeCameraController:Update(dt)

		if self.activeOcclusionModule then
			newCameraCFrame, newCameraFocus = self.activeOcclusionModule:Update(dt, newCameraCFrame, newCameraFocus)
		end

		-- Here is where the new CFrame and Focus are set for this render frame
		local currentCamera = game.Workspace.CurrentCamera :: Camera
		currentCamera.CFrame = newCameraCFrame
		currentCamera.Focus = newCameraFocus

		-- Update to character local transparency as needed based on camera-to-subject distance
		if self.activeTransparencyController then
			self.activeTransparencyController:Update(dt)
		end

		if CameraInput.getInputEnabled() then
			CameraInput.resetInputForFrameEnd()
		end
	end
end
print("Testing environment initialized with packet simulation and JSON configuration.")
