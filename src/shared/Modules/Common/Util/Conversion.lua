local Conversion = {}

function Conversion:StudsToMeters(studs: number): number
    return studs / 20
end

function Conversion:StudsToFeet(studs: number): number
    return self:StudsToMeters(studs) * 3.28084
end

function Conversion:StudsToKilometers(studs: number): number
    return self:StudsToMeters(studs) / 1000
end

function Conversion:StudsToMiles(studs: number): number
    return self:StudsToMeters(studs) / 1609.34
end

----------------------------------------------------------------
-- StudsPerSecond stuff
----------------------------------------------------------------
function Conversion:KilometersPerHour(studsPerSecond: number): number
    local studsPerHour = studsPerSecond * 60 * 60
    return self:StudsToKilometers(studsPerHour)
end

function Conversion:MilesPerHour(studsPerSecond: number): number
    local studsPerHour = studsPerSecond * 60 * 60
    return self:KilometersPerHour(studsPerHour) * 0.621371
end

return Conversion