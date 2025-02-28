--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local fusionMaid = require(script.Parent.fusionMaid)
local types = require(ReplicatedStorage.playr.types)
local signal = require(script.Parent.signal)

-- based on https://github.com/EgoMoose/Rbx-Gui-Library/blob/master/src/GuiLib/Classes/Dragger.lua
-- modified to work with Fusion

local VALID_PRESS = {
    [Enum.UserInputType.MouseButton1] = true,
    [Enum.UserInputType.Touch] = true
}

local VALID_MOVEMENT = {
	[Enum.UserInputType.MouseMovement] = true;
	[Enum.UserInputType.Touch] = true;
}

local DraggerClass = {}
DraggerClass.__index = DraggerClass
DraggerClass.__type = "Dragger"

function DraggerClass:__tostring()
	return DraggerClass.__type
end

-- Public Constructors

function DraggerClass.new(scope: types.FusionScope, element: GuiObject)
	local self = setmetatable({}, DraggerClass)

    self.__attachedScope = scope
	self.Element = element
	self.IsDragging = false
	self.DragChanged = signal.new()
	self.DragStart = signal.new()
	self.DragStop = signal.new()
	
	init(self)
	
	return self
end

function init(self)
	local lastMousePosition: Vector3 = Vector3.new()
    local element: GuiObject = self.Element
    local maid = fusionMaid.new(self.__attachedScope)

	maid:Mark(element.InputBegan:Connect(function(input: InputObject)
		if (VALID_PRESS[input.UserInputType]) then
			lastMousePosition = input.Position
			self.IsDragging = true
			self.DragStart:Fire()
		end
	end))
	
	maid:Mark(UserInputService.InputEnded:Connect(function(input: InputObject)
		if (VALID_PRESS[input.UserInputType]) then
			self.IsDragging = false
			self.DragStop:Fire()
		end
	end))
	
	maid:Mark(UserInputService.InputChanged:Connect(function(input: InputObject)
		if (self.IsDragging) then
			if (VALID_MOVEMENT[input.UserInputType]) then
				local delta = input.Position - lastMousePosition
				lastMousePosition = input.Position
				self.DragChanged:Fire(element, input, delta)
			end
		end
	end))
end

return DraggerClass