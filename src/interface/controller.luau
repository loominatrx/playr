--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local lucide = require(ReplicatedStorage.Packages.lucide)
local fusionMaid = require(ReplicatedStorage.playr.util.fusionMaid)
local types = require(script.Parent.Parent.types)
local fusion = require(script.Parent.Parent.Parent.Packages.fusion)

local OnEvent = fusion.OnEvent
local Children = fusion.Children

type FixedButton = ImageButton & {
    UIAspectRatioConstraint: UIAspectRatioConstraint
}

type Controller = Frame & {
    UIListLayout: UIListLayout,
    PreviousButton: FixedButton,
    PlayPauseButton: FixedButton,
    NextButton: FixedButton
}

-- icons
local icons = {} do
    local _i = lucide.GetAllAssets(256)
    for _, asset in _i do
        icons[asset.IconName] = asset
    end
end
local function hookIconToEvent(name: string, image: { Image: string, ImageRectOffset: Vector2, ImageRectSize: Vector2 })
    return function()
        local icon = icons[name]
        image.ImageRectOffset = icon.ImageRectOffset
        image.ImageRectSize = icon.ImageRectSize
        image.Image = icon.Url
    end
end

return function(scope: types.FusionScope)
    return function(configuration: types.PlayrComponentConfiguration & { queueController: any })
        local sound = configuration.soundTarget
        local qc = configuration.queueController

        -- setup frontend
        local controller =  scope:New 'Frame' {
            Name = 'Controller',
            BackgroundTransparency = 1,
    
            Size = UDim2.fromScale(1, 0.175),

            [Children] = {
                scope:New 'UIListLayout' {
                    FillDirection = Enum.FillDirection.Horizontal,
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    Padding = UDim.new(0.05, 8),
                },

                scope:New 'ImageButton' {
                    Name = 'PreviousButton',
                    BackgroundTransparency = 1,
                    Size = UDim2.fromScale(1, 1),

                    [OnEvent 'Activated'] = function()
                        qc:playPrevious()
                    end,

                    [Children] = {
                        scope:New 'UIAspectRatioConstraint' {
                            AspectRatio = 1
                        }
                    }
                },

                scope:New 'ImageButton' {
                    Name = 'PlayPauseButton',
                    BackgroundTransparency = 1,
                    Size = UDim2.fromScale(1, 1),

                    [OnEvent 'Activated'] = function()
                        if sound.IsPlaying then
                            sound:Pause()
                        elseif sound.IsPaused then
                            sound:Resume()
                        end
                    end,

                    [Children] = {
                        scope:New 'UIAspectRatioConstraint' {
                            AspectRatio = 1
                        }
                    }
                },

                scope:New 'ImageButton' {
                    Name = 'NextButton',
                    BackgroundTransparency = 1,
                    Size = UDim2.fromScale(1, 1),

                    [OnEvent 'Activated'] = function()
                        qc:playNext()
                    end,

                    [Children] = {
                        scope:New 'UIAspectRatioConstraint' {
                            AspectRatio = 1
                        }
                    }
                }
            }
        } :: Controller

        -- setup hook
        local maid = fusionMaid.new(scope)
        hookIconToEvent('skip-back', controller.PreviousButton)()
        hookIconToEvent('skip-forward', controller.NextButton)()
        hookIconToEvent('pause', controller.PlayPauseButton)()

        maid:Mark(sound.Played:Connect(hookIconToEvent('pause', controller.PlayPauseButton)))
        maid:Mark(sound.Resumed:Connect(hookIconToEvent('pause', controller.PlayPauseButton)))
        maid:Mark(sound.Paused:Connect(hookIconToEvent('play', controller.PlayPauseButton)))
        maid:Mark(sound.Ended:Connect(hookIconToEvent('play', controller.PlayPauseButton)))
        maid:Mark(sound.Stopped:Connect(hookIconToEvent('play', controller.PlayPauseButton)))

        return controller
    end
end
