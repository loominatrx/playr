-- type annotations
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local fusion = require(ReplicatedStorage.Packages.fusion)

local types = {}

export type AudioTrack = {
    title: string?,
    artist: string?,
    cover: string?,

    audioId: number
}

export type PlayrComponentConfiguration = {
    soundTarget: Sound
}

export type PlayerConfiguration = {
    tracks: {AudioTrack}
}

export type Config = {}

export type SliderConfiguration = {
    name: string?, 

    axis: string,

    anchorPoint: Vector2,
    pos: UDim2,
    size: UDim2,

    value: number,
    interval: number?,
}

export type FusionScope = typeof(fusion.scoped(fusion))

return types