
-- based on https://github.com/EgoMoose/Rbx-Gui-Library/blob/master/src/GuiLib/Utilities/Maid.lua
-- made to work alongside fusion's scope system

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local types = require(ReplicatedStorage.playr.types)

-- CONSTANTS

type CustomObject = {[any]: any} & { ['Destroy']: () -> nil }
type CustomConnection = {[any]: any} &  {['Disconnect']: () -> nil}
type CleanableItem = () -> nil | RBXScriptConnection | Instance | CustomObject | CustomConnection

-- Class

local MaidClass = {}
MaidClass.__index = MaidClass
MaidClass.__type = "FusionMaid"

function MaidClass:__tostring()
	return MaidClass.__type
end

-- Public Constructors

function MaidClass.new(scope: types.FusionScope)
	local self = setmetatable({}, MaidClass)
    self.__attachedScope = scope
	return self
end

-- Public Methods

function MaidClass:Mark(item: CleanableItem)
	table.insert(self.__attachedScope, item)
end

function MaidClass:Unmark(item: CleanableItem)
	local index = table.find(self.__attachedScope, item)
    if index then
        table.remove(self.__attachedScope, index)
    end
end

-- This will attempt to EXPLICITLY CALL `scope:doCleanup()`
function MaidClass:Cleanup()
	self.__attachedScope:doCleanup()
end

--

return MaidClass