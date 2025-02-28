--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local queue = require(ReplicatedStorage.playr.queue)
local types = require(script.Parent.Parent.types)
local fusion = require(script.Parent.Parent.Parent.Packages.fusion)

-- Components
local trackInfo = require(script.Parent.trackInfo)
local controller = require(script.Parent.controller)
local seekbar = require(script.Parent.seekbar)
local Children = fusion.Children

return function(config: types.PlayerConfiguration, scope: types.FusionScope, parent: Instance?)
    local sound = scope:New 'Sound' {
        Name = 'playrSound',
        SoundId = '',
        Parent = parent,
    } :: Sound

    -- setup control
    local q = queue.new(sound)
    sound:GetPropertyChangedSignal('SoundId'):Connect(function()
        sound:Stop()
        task.defer(function()
            if not sound.IsLoaded then
                sound.Loaded:Wait()
            end
            sound:Play()
        end)
    end)

    sound.Ended:Connect(function()
        sound.TimePosition = 0
        q:playNext()
    end)

    for _, track in config.tracks do
        q:addSong(track.audioId)
    end

    q:setLoop(true)
    q:playNext()

    return scope:New 'CanvasGroup' {
        Active = true,
        BackgroundColor3 = Color3.fromRGB(46, 46, 46),

        Size = UDim2.new(0.2, 150, 0.175, 50),

        Position = UDim2.new(1, -12, 0, 64),
        AnchorPoint = Vector2.new(1, 0),

        Parent = parent,

        [Children] = {
            -- layout
            trackInfo (scope) {
                soundTarget = sound,
                tracks = config.tracks
            },

            scope:New 'Frame' {
                Name = 'Divider',
                BackgroundTransparency = 1,
        
                Size = UDim2.new(1, 0, 0, 2),
            },

            controller (scope) {
                soundTarget = sound,
                queueController = q
            },

            seekbar (scope) {
                soundTarget = sound
            },

            -- styling
            scope:New 'UIAspectRatioConstraint' {
                AspectRatio = 2.25 / 1
            },

            scope:New 'UICorner' {
                CornerRadius = UDim.new(0.05, 4)
            },

            scope:New 'UIStroke' {
                Color = Color3.fromRGB(84, 84, 84),
                Thickness = 2
            },

            scope:New 'UIPadding' {
                PaddingLeft = UDim.new(0.025, 4),
                PaddingRight = UDim.new(0.025, 4),
                PaddingTop = UDim.new(0.05, 4),
                PaddingBottom = UDim.new(0.05, 4),
            },

            scope:New 'UIListLayout' {
                FillDirection = Enum.FillDirection.Vertical,
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(0, 4)
            }
        }
    }
end
