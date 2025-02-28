-- service
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- player
local player = Players.LocalPlayer
local playerGui = player.PlayerGui

-- modules
local main = require(script.interface.main)
local fusion = require(ReplicatedStorage.Packages.fusion)

-- types
local types = require(script.types)

-- init
local function initialize(config: types.PlayerConfiguration)
    local scope: types.FusionScope = fusion.scoped(fusion)
    local container = scope:New 'ScreenGui' {
        Name = 'playr',

        IgnoreGuiInset = true,
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,

        SafeAreaCompatibility = Enum.SafeAreaCompatibility.None,
        ScreenInsets = Enum.ScreenInsets.DeviceSafeInsets,

        -- prevent roblox from localizing content due to its broken translation
        -- that may cause people to be confused. uncomment this if you want it, though.
        -- AutoLocalize = false,

        Parent = playerGui,
    }

    main(config, scope, container)

    return container, scope
end

return setmetatable({
    initialize = initialize
}, {
    __call = function(_, config: types.PlayerConfiguration)
        return function(scope: types.FusionScope)
            return main(config, scope)
        end
    end
})