--!strict
type Array<T> = {[number]: T}

local queue = {}
queue.__index = queue

function queue.new(hook: Sound)
    local self = setmetatable({}, queue)
    self.originalQueue = {} :: Array<number>
    self.queue = {} :: Array<number?>
    self.currentIndex = 1
    self.loop = false
    self.shuffle = false
    self.history = {} :: Array<number> -- Stores played songs for backtracking
    self.sound = hook
    return self
end

function queue:addSong(song: number)
    table.insert(self.originalQueue, song)
    table.insert(self.queue, song)
end

function queue:playNext(): number?
    local sound: Sound = self.sound
    if self.currentIndex <= #self.queue then
        local song: number = self.queue[self.currentIndex]
        table.insert(self.history, self.currentIndex) -- Store history
        self.currentIndex = self.currentIndex + 1

        --selene: allow(multiple_statements)
        if sound.IsPlaying or sound.IsPaused then sound:Stop() end
        sound.SoundId = `rbxassetid://{song}`
        return song
    elseif self.loop then
        if self.shuffle then
            self:shuffleQueue()
        else
            self.queue = {table.unpack(self.originalQueue)}
        end
        self.currentIndex = 1
        return self:playNext() :: number
    else
        return nil
    end
end

function queue:playPrevious(): number?
    local sound: Sound = self.sound
    if #self.history > 0 then
        self.currentIndex = table.remove(self.history) :: number -- Go back in history
        local song = self.queue[self.currentIndex]

        sound.SoundId = `rbxassetid://{song}`
        return song
    elseif self.loop then
        self.currentIndex = #self.queue -- Wrap to last song if looping
        local song = self.queue[self.currentIndex]

        sound.SoundId = `rbxassetid://{song}`
        return song
    else
        return nil -- No previous song
    end
end

function queue:shuffleQueue()
    self.queue = {table.unpack(self.originalQueue)}
    for i = #self.queue, 2, -1 do
        local j = math.random(i)
        self.queue[i], self.queue[j] = self.queue[j], self.queue[i]
    end
    self.history = {} -- Reset history when shuffling
end

function queue:setLoop(loopEnabled)
    self.loop = loopEnabled
end

function queue:setShuffle(shuffleEnabled)
    self.shuffle = shuffleEnabled
    if self.shuffle then
        self:shuffleQueue()
    else
        self.queue = {table.unpack(self.originalQueue)}
    end
    self.currentIndex = 1
    self.history = {} -- Reset history when changing shuffle mode
end

return queue