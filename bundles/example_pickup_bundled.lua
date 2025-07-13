-- ============================================================================
-- BUNDLED COMPUTERCRAFT SCRIPT: example_pickup
-- Generated: Sun Jul 13 20:03:09 CEST 2025
-- 
-- This file contains all dependencies bundled for single-file deployment
-- Original files: example_pickup.lua + dependencies
-- ============================================================================

-- === BUNDLED DEPENDENCIES ===

-- --- DEPENDENCY: movement.lua ---
local movement = {}

movement.X = 0
movement.Y = 0
movement.Z = 0
movement.HEAD = {
    FW = 0,
    RI = 1,
    LE = 2,
    BK = 3
}
movement.DIR_NAMES = {
    [0] = "FW",
    [1] = "RI",
    [2] = "LE",
    [3] = "BK"
}
movement.heading = movement.HEAD.FW

function movement.forward()
    local didMove = turtle.forward()
    if not didMove then
        return false
    end
    if movement.heading == movement.HEAD.FW then
        movement.X = movement.X + 1
    elseif movement.heading == movement.HEAD.RI then
        movement.Y = movement.Y + 1
    elseif movement.heading == movement.HEAD.LE then
        movement.Y = movement.Y - 1
    elseif movement.heading == movement.HEAD.BK then
        movement.X = movement.X - 1
    end
    return true
end

function movement.back()
    local didMove = turtle.back()
    if not didMove then
        return false
    end
    if movement.heading == movement.HEAD.FW then
        movement.X = movement.X - 1
    elseif movement.heading == movement.HEAD.RI then
        movement.Y = movement.Y - 1
    elseif movement.heading == movement.HEAD.LE then
        movement.Y = movement.Y + 1
    elseif movement.heading == movement.HEAD.BK then
        movement.X = movement.X + 1
    end
    return true
end

function movement.up()
    local didMove = turtle.up()
    if not didMove then
        return false
    end
    movement.Z = movement.Z + 1
    return true
end

function movement.down()
    local didMove = turtle.down()
    if not didMove then
        return false
    end
    movement.Z = movement.Z - 1
    return true
end

function movement.tLeft()
    turtle.turnLeft()
    if movement.heading == movement.HEAD.FW then
        movement.heading = movement.HEAD.LE
    elseif movement.heading == movement.HEAD.RI then
        movement.heading = movement.HEAD.FW
    elseif movement.heading == movement.HEAD.LE then
        movement.heading = movement.HEAD.BK
    elseif movement.heading == movement.HEAD.BK then
        movement.heading = movement.HEAD.RI
    end
end

function movement.tRight()
    turtle.turnRight()
    if movement.heading == movement.HEAD.FW then
        movement.heading = movement.HEAD.RI
    elseif movement.heading == movement.HEAD.RI then
        movement.heading = movement.HEAD.BK
    elseif movement.heading == movement.HEAD.LE then
        movement.heading = movement.HEAD.FW
    elseif movement.heading == movement.HEAD.BK then
        movement.heading = movement.HEAD.LE
    end
end

function movement.turnTo(direction)
    if direction == movement.HEAD.FW then
        if movement.heading == movement.HEAD.RI then
            movement.tLeft()
        elseif movement.heading == movement.HEAD.LE then
            movement.tRight()
        elseif movement.heading == movement.HEAD.BK then
            movement.tLeft()
            movement.tLeft()
        end
    elseif direction == movement.HEAD.RI then
        if movement.heading == movement.HEAD.FW then
            movement.tRight()
        elseif movement.heading == movement.HEAD.LE then
            movement.tLeft()
            movement.tLeft()
        elseif movement.heading == movement.HEAD.BK then
            movement.tLeft()
        end
    elseif direction == movement.HEAD.LE then
        if movement.heading == movement.HEAD.FW then
            movement.tLeft()
        elseif movement.heading == movement.HEAD.RI then
            movement.tLeft()
            movement.tLeft()
        elseif movement.heading == movement.HEAD.BK then
            movement.tRight()
        end
    elseif direction == movement.HEAD.BK then
        if movement.heading == movement.HEAD.FW then
            movement.tLeft()
            movement.tLeft()
        elseif movement.heading == movement.HEAD.RI then
            movement.tRight()
        elseif movement.heading == movement.HEAD.LE then
            movement.tLeft()
        end
    end
end

function movement.moveTo(direction)
    movement.turnTo(direction)
    if not movement.forward() then
        turtle.dig()
        movement.forward()
    end
end

function movement.moveToS(direction)
    movement.turnTo(direction)
    if not movement.forwardS() then
        return false
    end
    return true
end

function movement.go(goalX, goalY, goalZ)
    print("Going to " .. goalX .. ", " .. goalY .. ", " .. goalZ)
    print("Currently at " .. movement.X .. ", " .. movement.Y .. ", " .. movement.Z)

    while goalX ~= movement.X do
        local deltaX = goalX - movement.X

        if deltaX > 0 then
            goalHeading = movement.HEAD.FW
        elseif deltaX < 0 then
            goalHeading = movement.HEAD.BK
        end

        movement.turnTo(goalHeading)

        if not movement.forward() then
            turtle.dig()
            movement.forward()
        end
    end

    while goalY ~= movement.Y do
        local deltaY = goalY - movement.Y

        if deltaY > 0 then
            goalHeading = movement.HEAD.RI
        elseif deltaY < 0 then
            goalHeading = movement.HEAD.LE
        end

        movement.turnTo(goalHeading)

        if not movement.forward() then
            turtle.dig()
            movement.forward()
        end
    end

    while movement.Z < goalZ do
        if not movement.up() then
            turtle.digUp()
            movement.up()
        end
    end

    while movement.Z > goalZ do
        if not movement.down() then
            turtle.digDown()
            movement.down()
        end
    end

    movement.turnTo(movement.HEAD.FW)
end

function movement.go0()
    movement.go(0, 0, 0)
end

function movement.debug()
    -- print debug info, pos and heading
    print("Position: (" .. movement.X .. ", " .. movement.Y .. ", " .. movement.Z .. ")")
    print("Heading: " .. movement.DIR_NAMES[movement.heading])
end

return movement


-- --- DEPENDENCY: pickup.lua ---
local pickup = {}

local mv = movement

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

local function collectAtPosition()
    if pickup.config.collection_function then
        pickup.config.collection_function()
    else
        defaultCollectionFunction()
    end
end

function pickup.spiral(radius, startX, startY)
    startX = startX or 0
    startY = startY or 0
    
    local positions = {}
    local homeX, homeY, homeZ = mv.X, mv.Y, mv.Z
    
    mv.go(startX, startY, mv.Z)
    table.insert(positions, {startX, startY})
    collectAtPosition()
    
    if radius <= 0 then
        if pickup.config.return_home then
            mv.go(homeX, homeY, homeZ)
        end
        return positions
    end
    
    local x, y = startX, startY
    local dx, dy = 1, 0
    local steps = 1
    local step_count = 0
    local direction_changes = 0
    
    while direction_changes < radius * 2 do
        for i = 1, steps do
            x = x + dx
            y = y + dy
            
            mv.go(x, y, mv.Z)
            table.insert(positions, {x, y})
            collectAtPosition()
            
            step_count = step_count + 1
            if step_count >= (2 * radius + 1) * (2 * radius + 1) - 1 then
                break
            end
        end
        
        if step_count >= (2 * radius + 1) * (2 * radius + 1) - 1 then
            break
        end
        
        if dx == 1 and dy == 0 then
            dx, dy = 0, 1
        elseif dx == 0 and dy == 1 then
            dx, dy = -1, 0
            steps = steps + 1
        elseif dx == -1 and dy == 0 then
            dx, dy = 0, -1
        elseif dx == 0 and dy == -1 then
            dx, dy = 1, 0
            steps = steps + 1
        end
        
        direction_changes = direction_changes + 1
    end
    
    if pickup.config.return_home then
        mv.go(homeX, homeY, homeZ)
    end
    
    return positions
end

function pickup.grid(width, height, startX, startY)
    startX = startX or 0
    startY = startY or 0
    
    local positions = {}
    local homeX, homeY, homeZ = mv.X, mv.Y, mv.Z
    
    for row = 0, height - 1 do
        local y = startY + row
        
        if row % 2 == 0 then
            for col = 0, width - 1 do
                local x = startX + col
                mv.go(x, y, mv.Z)
                table.insert(positions, {x, y})
                collectAtPosition()
            end
        else
            for col = width - 1, 0, -1 do
                local x = startX + col
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
-- === END BUNDLED DEPENDENCIES ===

-- === MAIN SCRIPT ===

local mv = $dep
local pickup = $dep

print("Example: Using pickup library")

pickup.setReturnHome(true)

print("Collecting in spiral pattern...")
pickup.spiral(3, 0, 0)

print("Collecting in grid pattern...")
pickup.grid(5, 5, 10, 10)

print("Done!")

-- ============================================================================
-- END BUNDLED SCRIPT: example_pickup
-- ============================================================================
