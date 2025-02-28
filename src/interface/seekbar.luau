local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local fusionMaid = require(ReplicatedStorage.playr.util.fusionMaid)
local readableTime = require(ReplicatedStorage.playr.util.readableTime)
local fusion = require(script.Parent.Parent.Parent.Packages.fusion)
local slider = require(script.Parent.slider)
local types = require(script.Parent.Parent.types)

local Children = fusion.Children
local peek = fusion.peek

return function(scope: types.FusionScope)
    return function(config: types.PlayrComponentConfiguration)
        local seekbar, seekbarControl = slider (scope) {
            name = 'SeekbarSlider',
            axis = 'x',
    
            anchorPoint = Vector2.new(0, 1),
            pos = UDim2.fromScale(0, 1),
            size = UDim2.fromScale(1, 0.35),
            
            value = 0.5,
            interval = 0.001
        }

        local maid = fusionMaid.new(scope)
        local sound = config.soundTarget

        local function doSeek(value: number?)
            sound.TimePosition = sound.TimeLength * (if typeof(value) == 'number' then value else (peek(seekbarControl.value)))
        end

        local positionLabel = scope:New 'TextLabel' {
            Size = UDim2.fromScale(0.5, 0.65),
            Position = UDim2.new(),

            BackgroundTransparency = 1,
            Text = readableTime.makeTimeReadable(sound.TimePosition),
            TextColor3 = Color3.new(1, 1, 1),
            TextXAlignment = Enum.TextXAlignment.Left,
        } :: TextLabel

        local lengthLabel = scope:New 'TextLabel' {
            AnchorPoint = Vector2.new(1, 0),
            Size = UDim2.fromScale(0.5, 0.65),
            Position = UDim2.fromScale(1, 0),

            BackgroundTransparency = 1,
            Text = readableTime.makeTimeReadable(sound.TimeLength),
            TextColor3 = Color3.new(1, 1, 1),
            TextXAlignment = Enum.TextXAlignment.Right
        } :: TextLabel

        maid:Mark(seekbarControl.dragger.DragStop:Connect(doSeek))
        maid:Mark(seekbarControl.clicked:Connect(function(value)
            if not seekbarControl.dragger.IsDragging then
                doSeek(value)
            end
        end))

        maid:Mark(RunService.RenderStepped:Connect(function()
            if seekbarControl.dragger.IsDragging then return end
            local n = sound.TimePosition / sound.TimeLength
            if n ~= n then -- check if n is NaN by comparing n by itself
                n = 0 -- if it is, set n to 0 
            end
            seekbarControl.value:set(n)
        end))

        maid:Mark(RunService.RenderStepped:Connect(function()
            positionLabel.Text = readableTime.makeTimeReadable(sound.TimePosition)
            lengthLabel.Text = readableTime.makeTimeReadable(sound.TimeLength)
        end))

        return scope:New 'Frame' {
            Name = 'Seekbar',
            BackgroundTransparency = 1,
    
            Size = UDim2.fromScale(1, 0.2),

            [Children] = {
                positionLabel,
                lengthLabel,
                seekbar,
            }
        }
    end
end
