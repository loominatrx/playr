--!strict
local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local lucide = require(ReplicatedStorage.Packages.lucide)
local promise = require(script.Parent.Parent.Parent.Packages.promise)
local fusion = require(script.Parent.Parent.Parent.Packages.fusion)
local util = script.Parent.Parent.util

local fusionMaid = require(util.fusionMaid)
local types = require(script.Parent.Parent.types)
local Children = fusion.Children

type TrackInfoFrame = Frame & {
    UIListLayout: UIListLayout,
    UIFlexItem: UIFlexItem,
    Title: TextLabel,
    ArtistName: TextLabel
}

type CoverFrame = ImageLabel & {
    UIStroke: UIStroke,
    UICorner: UICorner,
    UIAspectRatioConstraint: UIAspectRatioConstraint,

    PlaceholderIcon: ImageLabel
}

return function(scope: types.FusionScope)
    return function(config: types.PlayrComponentConfiguration & {tracks: {types.AudioTrack}})
        -- vars
        local maid = fusionMaid.new(scope)
        local sound = config.soundTarget
        local placeholder_icon = lucide.GetAsset('disc-3')

        -- func
        local function getAudioTrackInfoFromId(id: number)
            return promise.new(function(resolve, reject)
                local track do
                    for _, v in config.tracks do
                        if v.audioId == id then
                            track = v
                            break
                        end
                    end
                    if track == nil then
                        reject('no track info associated with said id found.')
                    end
                end

                if track.title == nil or track.artist == nil then
                    local success, info = pcall(MarketplaceService.GetProductInfo, MarketplaceService, track.audioId)
                    if not success then reject(info) end

                    print(info)
                    if track.title == nil then
                        track.title = info.Name
                    end
                    if track.artist == nil then
                        track.artist = info.Creator.Name
                    end
                end

                if track.cover == nil then
                    track.cover = ''
                end

                resolve(track)
            end)
        end

        local cover = scope:New 'ImageLabel' {
            Name = 'AlbumCover',
            BackgroundTransparency = 0,
            BackgroundColor3 = Color3.fromRGB(26, 26, 26),
            Size = UDim2.fromScale(1, 1),

            [Children] = {
                scope:New 'UIAspectRatioConstraint' {
                    AspectRatio = 1
                },

                scope:New 'UICorner' {
                    CornerRadius = UDim.new(0.05, 4)
                },
    
                scope:New 'UIStroke' {
                    Color = Color3.fromRGB(84, 84, 84),
                    Thickness = 2
                },

                scope:New 'ImageLabel' {
                    Name = 'PlaceholderIcon',
                    BackgroundTransparency = 1,

                    AnchorPoint = Vector2.one * 0.5,
                    Position = UDim2.fromScale(0.5, 0.5),
                    Size = UDim2.fromScale(0.5, 0.5),

                    Visible = false,

                    Image = placeholder_icon.Url,
                    ImageRectSize = placeholder_icon.ImageRectSize,
                    ImageRectOffset = placeholder_icon.ImageRectOffset
                }
            }
        } :: CoverFrame

        local trackInfo = scope:New 'Frame' {
            BackgroundTransparency = 1,
            Size = UDim2.fromScale(1, 1),

            [Children] = {
                scope:New 'UIListLayout' {
                    FillDirection = Enum.FillDirection.Vertical,
                    SortOrder = Enum.SortOrder.LayoutOrder,
                },

                scope:New 'UIFlexItem' {
                    FlexMode = Enum.UIFlexMode.Fill
                },

                scope:New 'TextLabel' {
                    Name = 'Title',
                    Size = UDim2.fromScale(1, 0.5),
                    BackgroundTransparency = 1,

                    Text = 'Title',
                    TextScaled = true,
                    TextColor3 = Color3.new(1, 1, 1),
                    TextXAlignment = Enum.TextXAlignment.Left,
                },

                scope:New 'TextLabel' {
                    Name = 'ArtistName',
                    Size = UDim2.fromScale(1, 0.3),
                    BackgroundTransparency = 1,

                    Text = 'Artist Name',
                    TextScaled = true,
                    TextColor3 = Color3.new(1, 1, 1),
                    TextXAlignment = Enum.TextXAlignment.Left,
                },
            }
        } :: TrackInfoFrame

        maid:Mark(cover:GetPropertyChangedSignal('Image'):Connect(function()
            cover.PlaceholderIcon.Visible = true

            if cover.Image ~= 'rbxassetid://' and not cover.IsLoaded then
                while cover.IsLoaded == false do
                    task.wait()
                end
                cover.PlaceholderIcon.Visible = false
            end
        end))

        local function onSoundChange()
            trackInfo.Title.Text = 'Loading...'
            trackInfo.ArtistName.Text = 'Loading...'

            -- run this code a frame after.
            task.defer(function()
                local soundId = (sound.SoundId):gsub('^rbxassetid://', '')
                getAudioTrackInfoFromId(tonumber(soundId) :: number):andThen(function(track: types.AudioTrack)
                    trackInfo.Title.Text = track.title or 'unknown title'
                    trackInfo.ArtistName.Text = track.artist or 'unknown artist'
                    cover.Image = 'rbxassetid://' .. tostring(track.cover or 0)
                end)
            end)
        end

        maid:Mark(sound:GetPropertyChangedSignal('SoundId'):Connect(onSoundChange))
        onSoundChange()

        return scope:New 'Frame' {
            Name = 'TrackInfo',
            BackgroundTransparency = 1,
    
            Size = UDim2.fromScale(1, 1),
            [Children] = {
                scope:New 'UIListLayout' {
                    FillDirection = Enum.FillDirection.Horizontal,
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    Padding = UDim.new(0.025, 8)
                },

                cover,
                trackInfo,

                scope:New 'UIPadding' {
                    PaddingLeft = UDim.new(0, 2),
                    PaddingRight = UDim.new(0, 2),
                    PaddingTop = UDim.new(0, 2),
                    PaddingBottom = UDim.new(0, 2),
                },

                scope:New 'UIFlexItem' {
                    FlexMode = Enum.UIFlexMode.Fill
                },
            }
        }
    end
end
