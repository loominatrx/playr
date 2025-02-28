local readableTime = {}

function readableTime.makeTimeReadable(t: number)
    local isNegative = false
    if t < 0 then
        t = math.abs(t)
        isNegative = true
    end

    t = math.round(t)

    local seconds = (t % 60)
    local minutes = math.floor(t / 60) % 60
    local hours = math.floor(t / 3600)

    local rt = if hours == 0 and minutes > 0 then
            ('%02i:%02i'):format(minutes, seconds)
        elseif hours > 0 then
            ('%02i:%02i:%02i'):format(hours, minutes, seconds)
        else
            ('00:%02i'):format(seconds)

    return isNegative and `-({rt})` or rt
end

return readableTime