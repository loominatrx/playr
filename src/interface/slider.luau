--!strict
local fusion = require(script.Parent.Parent.Parent.Packages.fusion)
local util = script.Parent.Parent.util

local signal = require(util.signal)
local fusionMaid = require(util.fusionMaid)
local dragger = require(util.dragger)

local types = require(script.Parent.Parent.types)
local Children = fusion.Children
local peek = fusion.peek

type Slider = Frame & {
    UICorner: UICorner,
    SliderBar: Frame & {
        UICorner: UICorner
    },
    Dragger: Frame & {
        UICorner: UICorner,
        UIAspectRatioConstraint: UIAspectRatioConstraint
    },
}

local SLIDER_SPEED = 50
local SLIDER_DAMPING = 2

-- get around with luau strict errors
local function getAxisValue(vector: any, axis: string)
    return vector[axis]
end

function getBounds(slider: Slider, axis: string)
	local dragger = slider.Dragger
    
	local pos: Vector2 = getAxisValue(slider.AbsolutePosition, axis) + getAxisValue(dragger.AbsoluteSize, axis)/2
	local size: Vector2 = getAxisValue(slider.AbsoluteSize, axis) - getAxisValue(dragger.AbsoluteSize, axis)
	
	return pos, size
end

return function(scope: types.FusionScope)
    return function(configuration: types.SliderConfiguration)
        assert(configuration.axis == 'x' or configuration.axis == 'y', 'axis must be either \'x\' or \'y\'')
        assert(configuration.value >= 0 or configuration.value > 1, 'value must be greater than 0 and cannot be more than 1.')
        
        local axis = configuration.axis
        local controller = {}
        local value = scope:Value(configuration.value)
        local interval = scope:Value(configuration.interval or 0.001)
        
        controller.active = scope:Value(true)
        controller.value = value
        controller.interval = interval
        controller.clicked = signal.new()

        local function setUdim2(a: number, b: number)
            if (axis == 'y') then a, b = b, a end
            return UDim2.new(a, 0, b, 0)
        end

        local slider = scope:New 'Frame' {
            Name = configuration.name or 'Slider',
            BackgroundColor3 = Color3.new(1, 1, 1),
            BackgroundTransparency = 0.7,

            AnchorPoint = configuration.anchorPoint,
            Position = configuration.pos,

            Size = configuration.size,

            [Children] = {
                scope:New 'UICorner' {
                    CornerRadius = UDim.new(1, 0)
                },

                -- Fill bar
                scope:New 'Frame' {
                    Name = 'SliderBar',
                    BackgroundColor3 = Color3.new(1, 1, 1),
        
                    AnchorPoint = Vector2.new(0, 1),
                    Position = UDim2.fromScale(0, 1),
        
                    Size = scope:Spring(scope:Computed(function(use)
                        return setUdim2(use(value), 1)
                    end), SLIDER_SPEED, SLIDER_DAMPING),
        
                    [Children] = {
                        scope:New 'UICorner' {
                            CornerRadius = UDim.new(1, SLIDER_DAMPING)
                        },
                    }
                },

                -- Dragger
                scope:New 'Frame' {
                    Name = 'Dragger',
                    BackgroundColor3 = Color3.new(1, 1, 1),
                    BackgroundTransparency = 1,
        
                    AnchorPoint = Vector2.one * 0.5,
                    Position = scope:Spring(scope:Computed(function(use)
                        return setUdim2(use(value), 0.5)
                    end), SLIDER_SPEED, 1),
        
                    Size = UDim2.fromScale(1, 1),
        
                    [Children] = {
                        scope:New 'UICorner' {
                            CornerRadius = UDim.new(1, 0)
                        },

                        scope:New 'UIAspectRatioConstraint' {
                            AspectRatio = 1
                        }
                    }
                }
            }
        } :: Slider

        local bPos, bSize
        local function updateBounds()
            bPos, bSize = getBounds(slider, axis)
        end

        local maid = fusionMaid.new(scope)
        local dragTracker = dragger.new(scope, slider.Dragger)

        controller.dragger = dragTracker

        maid:Mark(slider:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateBounds))
        maid:Mark(slider:GetPropertyChangedSignal("AbsolutePosition"):Connect(updateBounds))
        maid:Mark(slider:GetPropertyChangedSignal("Parent"):Connect(updateBounds))


        maid:Mark(dragTracker.DragChanged:Connect(function(_, input)
            if peek(controller.active) then
                local t = (getAxisValue(input.Position, axis) - bPos) / bSize
                value:set(math.clamp(t, 0, 1))
            end
        end))
        
        maid:Mark(slider.InputBegan:Connect(function(input)
            if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
                local t = (getAxisValue(input.Position, axis) - bPos) / bSize
                local currentInterval = peek(interval)
                controller.clicked:Fire(math.clamp(t, 0, 1))
                if peek(controller.active) then	
                    t = math.floor((t / currentInterval) + 0.5) * currentInterval
                    value:set(math.clamp(t, 0, 1))
                end
            end
        end))

        return slider, controller
    end
end
