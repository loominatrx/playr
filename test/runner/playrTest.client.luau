local ReplicatedStorage = game:GetService("ReplicatedStorage")

local playr = require(ReplicatedStorage.playr)
local defaultConfig = require(ReplicatedStorage.playr.defaultConfig)

-- load playr with default settings
playr.initialize (defaultConfig)