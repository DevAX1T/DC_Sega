local Format = {}

function Format:Pad(num: number, size: number): string
    local s = tostring(num)
    while #s < size do
        s = "0" .. s
    end
    return s
end

--- returns padded number with decimals. ex: padDecimal(1.18687358, 2) => 1.19
--- @param num number to be padded.
--- @param decimals number places to be added.
--- @returns number with decimals padded.
function Format:PadDecimal(num: number, decimals: number): number
    local d = 10 ^ decimals
    return math.round(num * d) / d
end

function Format:StandardClock(seconds: number, padding: number?): string
    local secondsLeft = seconds % 60
    local minutesLeft = (seconds - secondsLeft) / 60
    local hoursLeft = (minutesLeft - minutesLeft % 60) / 60
    return ('%s:%s:%s'):format(self:Pad(hoursLeft, padding or 2), self:Pad(minutesLeft % 60, padding or 2), self:Pad(secondsLeft, padding or 2))
end

--- @param seconds number to calculate clock string.
--- @param padding number of zeros to pad in front of clock string.
--- @returns seconds formatted in minutes and seconds.
function Format:SmallClock(seconds: number, padding: number?): string
    local secondsLeft = seconds % 60
    local minutesLeft = (seconds - secondsLeft) / 60
    return ('%s:%s'):format(self:Pad(minutesLeft, padding or 2), self:Pad(secondsLeft, padding or 2))
end

--- @param seconds number to calculate clock string.
--- @returns seconds formatted in hours and minutes. (use for larger numbers).
function Format:LargeClock(seconds: number): string
    local hours = math.round((seconds - (seconds % 3600)) / 3600)
    local minutes = math.round((seconds % 3600) / 60)

    return ('%sh %sm'):format(self:Pad(hours, 2), self:Pad(minutes, 2))
end

--[[

    @returns Tuple<number, number, number>: (hours, minutes, seconds)
]]
function Format:GetTimes(seconds: number): (number, number, number)
    local hours = math.round((seconds - (seconds % 3600)) / 3600)
    local minutes = math.round((seconds % 3600) / 60)
    local secondsLeft = seconds % 60
    return hours, minutes, secondsLeft
end


return Format