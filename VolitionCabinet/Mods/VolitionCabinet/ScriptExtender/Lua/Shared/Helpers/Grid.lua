---@class HelperGrid: Helper
VCHelpers.Grid = _Class:Create("HelperGrid", Helper)
VCHelpers.Grid.Defaults = {
    -- How far away from the line describing the shortest move path that a valid position can be
    Deviation = 2,
    -- Increment with which to check along the move path
    Resolution = 0.25,
    -- Distance in addition to AiBoundsRadius that a character is calculated as occupying. This value closely mimics Larian's placements
    OccupyRadiusBias = 0.4,
    IgnoreHeight = true,
}
VCHelpers.Grid.AiFlags = {
    MovementBlock = 0x01,
    ProjectileBlock = 0x04,
    WalkThroughBlockCharacter = 0x10,
    ShootThroughBlockCharacter = 0x40,
    WalkThroughBlock = 0x80,
    ShootThroughBlock = 0x100,
    GroundSurfaceBlock = 0x200,
    CloudSurfaceBlock = 0x400,
    Dead = 0x1000,
    SurfaceExclude = 0x10000,
    Portal = 0x20000,
    Portal2 = 0x40000,
    SurfaceShapeFlood = 0x80000,
    Door = 0x100000,
    DoorNoShootThrough = 0x200000,
}
---@type table<Guid, {Destination:vec3, PreviousPos:vec3, Radius:number}>
VCHelpers.Grid.OccupiedRadii = {}

--[[
function VCHelpers.Grid:SetGrid()
    self.AiGrid = Ext.Entity.GetAiGrid()
end
--]]

---@param origin vec3
---@param target vec3
---@param ignoreHeight? boolean
---@return number
function VCHelpers.Grid:GetDistance(origin, target, ignoreHeight)
    ignoreHeight = ignoreHeight == nil and self.Defaults.IgnoreHeight or ignoreHeight
    return self:GetDistancePOW(origin, target, ignoreHeight)
end

function VCHelpers.Grid:GetDistancePOW(pos, position2, ignoreHeight)
    local xDiff = pos[1] - position2[1]
    local yDiff = ignoreHeight and 0 or (pos[2] - position2[2])
    local zDiff = pos[3] - position2[3]
    return math.sqrt((xDiff * xDiff) + (yDiff * yDiff) + (zDiff * zDiff))
end

---@param position1 vec3
---@param position2 vec3
---@return vec3
function VCHelpers.Grid:GetNormalizedVector(position1, position2)
    local direction = Ext.Math.Sub(position1, position2)
    local normal = Ext.Math.Normalize(direction)
    return normal
end

---@param origin vec3
---@param normal vec3
---@param distance number in meters
---@return vec3
function VCHelpers.Grid:FindPositionAlongNormal(origin, normal, distance)
    local pos = Ext.Math.Add(origin, { -normal[1] * distance, 0, -normal[3] * distance })
    return pos
end

---@param object IEoCServerObject
---@param rotation number Angle in degrees
---@param distance number
---@return vec3
function VCHelpers.Grid:FindPointRotatedFromObject(object, rotation, distance)
    local rotMat = Ext.Math.BuildRotation3({ 0, 1, 0 }, math.rad(rotation))
    local newRot = Ext.Math.Add(object.Rotation, rotMat)
    local pos = object.WorldPos
    local newPos = { pos[1] - newRot[7] * distance, pos[2], pos[3] - newRot[9] * distance }
    return newPos
end

---@param position vec3
---@return boolean
function VCHelpers.Grid:IsInMoveActionRadius(position)
    for _, move in pairs(self.OccupiedRadii) do
        local distance = self:GetDistance(position, move.Destination, false)
        if distance <= move.Radius then
            return true
        end
    end
    return false
end

--[[
---@param position vec3
---@return boolean
function VCHelpers.Grid:IsBlockedPosition(position)
    local flags = self.AiGrid:GetCellInfo(position[1], position[3]).Flags
    if flags & self.AiFlags.MovementBlock ~= 0
    or flags & self.AiFlags.WalkThroughBlock ~= 0
    or flags & self.AiFlags.WalkThroughBlockCharacter ~= 0
    or self:IsInMoveActionRadius(position) then
        return true
    end
    return false
end

---@param position vec3
---@param radius number
---@param resolution  number
---@return boolean
function VCHelpers.Grid:PositionCanAccommodateRadius(position, radius, resolution)
    local floodRadius = math.min(radius, resolution)
    repeat
        local floodPoints = math.pi * 2 * floodRadius / resolution
        for i = 0, floodPoints do
            local angle = 2 * math.pi / floodPoints * i
            local fx = position[1] + floodRadius * math.cos(angle)
            local fz = position[3] + floodRadius * math.sin(angle)
            local floodPos = {
                fx,
                self.AiGrid:GetHeight(fx, fz),
                fz
            }

            if self:IsBlockedPosition(floodPos) then
                return false
            end
        end
        floodRadius = floodRadius + resolution
    until floodRadius > radius
    return true
end

---@param position vec3
---@param radius? number
---@param resolution? number
---@param occupyRadius? number
---@return vec3|nil
function VCHelpers.Grid:FindValidPositionFromFlood(position, radius, resolution, occupyRadius)
    radius = radius or self.Defaults.Deviation
    resolution = resolution or self.Defaults.Resolution

    if not self:IsBlockedPosition(position) then
        if occupyRadius == nil or (occupyRadius ~= nil and self:PositionCanAccommodatedateRadius(position, occupyRadius, resolution)) then
            return position
        end
    end

    local floodRadius = math.min(radius, resolution)
    repeat
        local floodPoints = math.pi * 2 * floodRadius / resolution
        for i = 0, floodPoints do
            local angle = 2 * math.pi / floodPoints * i
            local fx = position[1] + floodRadius * math.cos(angle)
            local fz = position[3] + floodRadius * math.sin(angle)
            local floodPos = {fx, self.AiGrid:GetHeight(fx, fz), fz}

            if not self:IsBlockedPosition(floodPos) then
                if occupyRadius == nil or (occupyRadius ~= nil and self:PositionCanAccommodatedateRadius(floodPos, occupyRadius, resolution)) then
                    return floodPos
                end
            end
        end
        floodRadius = floodRadius + resolution
    until floodRadius > radius
end

---@param origin vec3
---@param normalVec vec3
---@param distance number
---@param occupyRadius number
---@param deviation? number
---@param distResolution? number
---@return vec3|nil
function VCHelpers.Grid:GetValidPositionAlongLine(origin, normalVec, distance, deviation, occupyRadius, distResolution)
	distResolution = distResolution or self.Defaults.Resolution
	self.AiGrid = Ext.Entity.GetAiGrid()
    while distance >= 0 do
        local x = (normalVec[1] * distance) + origin[1]
        local z = (normalVec[3] * distance) + origin[3]
        local y = self.AiGrid:GetHeight(x, z)
        local pos = self:FindValidPositionFromFlood({x,y,z}, deviation, distResolution, occupyRadius)
        if pos ~= nil then
            return pos
        end
        distance = distance - distResolution
    end
end
--]]
