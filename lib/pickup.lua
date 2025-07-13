local pickup = {}

local mv = require("lib.movement")

pickup.config = {
    return_home = true,
    collection_function = nil
}

function pickup.setReturnHome(enabled)
    pickup.config.return_home = enabled
end

function pickup.setCollectionFunction(func)
    pickup.config.collection_function = func
end

local function defaultCollectionFunction()
    turtle.suck()
    turtle.suckUp()
    turtle.suckDown()
end

local function deepCollect()
    for i = 1, 4 do
        turtle.suck()      -- front
        turtle.suckUp()    -- above
        turtle.suckDown()  -- below
        mv.tRight()        -- rotate to next side
    end
    -- restore heading to forward
    mv.tLeft()
end

local function collectAtPosition()
    if pickup.config.collection_function then
        pickup.config.collection_function()
    else
        defaultCollectionFunction()
    end
end

local function suckForward()
    turtle.suck()
    turtle.suckUp()
    turtle.suckDown()
end

function pickup.spiral(radius, startX, startY)
    startX = startX or 0
    startY = startY or 0

    local homeX, homeY, homeZ = mv.X, mv.Y, mv.Z
    local positions = {}

    -- go to center once
    mv.go(startX, startY, mv.Z)
    table.insert(positions, {mv.X, mv.Y})
    suckForward()

    if radius <= 0 then
        if pickup.config.return_home then mv.go(homeX, homeY, homeZ) end
        return positions
    end

    local dirs = { mv.HEAD.FW, mv.HEAD.RI, mv.HEAD.BK, mv.HEAD.LE }
    local dirIdx = 1
    local stepLen = 1
    local totalLegs = radius * 2

    for leg = 1, totalLegs do
        local legDir = dirs[dirIdx]
        -- the “outward” side is the next direction in the spiral
        local outDir = dirs[(dirIdx % #dirs) + 1]

        mv.turnTo(legDir)
        for i = 1, stepLen do
            mv.forward()
            table.insert(positions, {mv.X, mv.Y})

            -- collect in front
            suckForward()
            -- swing out once
            mv.turnTo(outDir)
            suckForward()
            -- restore heading
            mv.turnTo(legDir)
        end

        -- next leg
        dirIdx = dirIdx % #dirs + 1
        if leg % 2 == 0 then stepLen = stepLen + 1 end
    end

    if pickup.config.return_home then mv.go(homeX, homeY, homeZ) end
    return positions
end

--- Covers every integer (x,y) in the rectangle between (x1,y1) and (x2,y2).
--  If any mv.forward() fails, aborts and returns home immediately.
--  Returns list of positions visited.
function pickup.grid(x1, y1, x2, y2)
    -- determine bounds
    local minX, maxX = math.min(x1, x2), math.max(x1, x2)
    local minY, maxY = math.min(y1, y2), math.max(y1, y2)

    -- remember home
    local homeX, homeY, homeZ = mv.X, mv.Y, mv.Z
    local positions = {}

    -- jump to start corner once
    mv.go(minX, minY, mv.Z, suckForward)
    table.insert(positions, {mv.X, mv.Y})
    suckForward()

    -- height and width
    local width  = maxX - minX + 1
    local height = maxY - minY + 1

    for row = 0, height - 1 do
        local y = minY + row
        -- decide direction this row (even=row → east, odd=row → west)
        local facing = (row % 2 == 0) and mv.HEAD.FW or mv.HEAD.BK
        mv.turnTo(facing)

        -- how many steps to take in X (minus the one we're already on)
        local steps = width - 1
        for i = 1, steps do
            if not mv.forward() then
                -- blocked: go home and bail
                mv.go(homeX, homeY, homeZ)
                return positions
            end
            table.insert(positions, {mv.X, mv.Y})
            suckForward()
        end

        -- at end of row, if there's another row, move north one
        if row < height - 1 then
            mv.turnTo(mv.HEAD.RI)  -- north
            if not mv.forward() then
                mv.go(homeX, homeY, homeZ)
                return positions
            end
            table.insert(positions, {mv.X, mv.Y})
            suckForward()
        end
    end

    if pickup.config.return_home then
        mv.go(homeX, homeY, homeZ)
    end
    return positions
end

function pickup.circle(radius, startX, startY)
    startX = startX or 0
    startY = startY or 0
    
    local positions = {}
    local homeX, homeY, homeZ = mv.X, mv.Y, mv.Z
    
    mv.go(startX, startY, mv.Z)
    table.insert(positions, {startX, startY})
    collectAtPosition()
    
    for r = 1, radius do
        for angle = 0, 359, 45 do
            local radian = math.rad(angle)
            local x = startX + math.floor(r * math.cos(radian) + 0.5)
            local y = startY + math.floor(r * math.sin(radian) + 0.5)
            
            local already_visited = false
            for _, pos in ipairs(positions) do
                if pos[1] == x and pos[2] == y then
                    already_visited = true
                    break
                end
            end
            
            if not already_visited then
                mv.go(x, y, mv.Z)
                table.insert(positions, {x, y})
                collectAtPosition()
            end
        end
    end
    
    if pickup.config.return_home then
        mv.go(homeX, homeY, homeZ)
    end
    
    return positions
end

function pickup.line(length, direction, startX, startY)
    startX = startX or 0
    startY = startY or 0
    direction = direction or mv.HEAD.FW
    
    local positions = {}
    local homeX, homeY, homeZ = mv.X, mv.Y, mv.Z
    
    local dx, dy = 0, 0
    if direction == mv.HEAD.FW then
        dx = 1
    elseif direction == mv.HEAD.RI then
        dy = 1
    elseif direction == mv.HEAD.BK then
        dx = -1
    elseif direction == mv.HEAD.LE then
        dy = -1
    end
    
    for i = 0, length - 1 do
        local x = startX + i * dx
        local y = startY + i * dy
        
        mv.go(x, y, mv.Z)
        table.insert(positions, {x, y})
        collectAtPosition()
    end
    
    if pickup.config.return_home then
        mv.go(homeX, homeY, homeZ)
    end
    
    return positions
end

function pickup.compact(radius, startX, startY)
    startX = startX or 0
    startY = startY or 0
    
    local positions = {}
    local homeX, homeY, homeZ = mv.X, mv.Y, mv.Z
    
    local visited = {}
    
    for r = 0, radius do
        for x = startX - r, startX + r do
            for y = startY - r, startY + r do
                local key = x .. "," .. y
                if not visited[key] and math.abs(x - startX) <= r and math.abs(y - startY) <= r then
                    visited[key] = true
                    mv.go(x, y, mv.Z)
                    table.insert(positions, {x, y})
                    collectAtPosition()
                end
            end
        end
    end
    
    if pickup.config.return_home then
        mv.go(homeX, homeY, homeZ)
    end
    
    return positions
end

return pickup
