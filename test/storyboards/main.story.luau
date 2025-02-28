local ReplicatedStorage = game:GetService("ReplicatedStorage")

local fusion = require(ReplicatedStorage.Packages.fusion)
local defaultConfig = require(ReplicatedStorage.playr.defaultConfig)
local main = require(ReplicatedStorage.playr.interface.main)
local types = require(ReplicatedStorage.playr.types)

return { 
    fusion = fusion,
    story = function(props: {
     scope: types.FusionScope,
     target: Instance,
    })
         local scope = props.scope
         main(defaultConfig, scope, props.target)
    end,
 }