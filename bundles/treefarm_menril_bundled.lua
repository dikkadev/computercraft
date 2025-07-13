-- ============================================================================
-- BUNDLED COMPUTERCRAFT SCRIPT: treefarm_menril
-- Generated: Sun Jul 13 22:30:38 CEST 2025
-- 
-- This file contains all dependencies bundled for single-file deployment
-- Original files: treefarm_menril.lua + dependencies
-- ============================================================================

-- === BUNDLED DEPENDENCIES ===

-- --- DEPENDENCY: dbg.lua ---
local dbg = {}

dbg.enabled = false

function dbg.setEnabled(enabled)
    dbg.enabled = enabled
end

function dbg.print(...)
    if dbg.enabled then
        local args = {...}
        local output = "[DBG] "
        for i, arg in ipairs(args) do
            if i > 1 then
                output = output .. " "
            end
            output = output .. tostring(arg)
        end
        print(output)
    end
end

function dbg.printf(format, ...)
    if dbg.enabled then
        print("[DBG] " .. string.format(format, ...))
    end
end

function dbg.inspect(name, value)
    if dbg.enabled then
        if type(value) == "table" then
            print("[DBG] " .. name .. ":")
            for k, v in pairs(value) do
                print("[DBG]   " .. tostring(k) .. " = " .. tostring(v))
            end
        else
            print("[DBG] " .. name .. " = " .. tostring(value))
        end
    end
end

function dbg.pos(mv)
    if dbg.enabled and mv then
        print("[DBG] Position: " .. mv.X .. "," .. mv.Y .. "," .. mv.Z .. " facing:" .. mv.heading)
    end
end

function dbg.fuel()
    if dbg.enabled then
        local fuel = turtle.getFuelLevel()
        print("[DBG] Fuel: " .. tostring(fuel))
    end
end

function dbg.inventory()
    if dbg.enabled then
        print("[DBG] Inventory:")
        for i = 1, 16 do
            local count = turtle.getItemCount(i)
            if count > 0 then
                local detail = turtle.getItemDetail(i)
                local name = detail and detail.name or "unknown"
                print("[DBG]   Slot " .. i .. ": " .. count .. "x " .. name)
            end
        end
    end
end


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

function movement.go(goalX, goalY, goalZ, stepExtraFunc)
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
            if stepExtraFunc then
                stepExtraFunc()
            end
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
            if stepExtraFunc then
                stepExtraFunc()
            end
        end
    end

    while movement.Z < goalZ do
        if not movement.up() then
            turtle.digUp()
            movement.up()
            if stepExtraFunc then
                stepExtraFunc()
            end
        end
    end

    while movement.Z > goalZ do
        if not movement.down() then
            turtle.digDown()
            movement.down()
            if stepExtraFunc then
                stepExtraFunc()
            end
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



-- === END BUNDLED DEPENDENCIES ===

-- === MAIN SCRIPT ===

local mv = movement
local pickup = pickup
local dbg = dbg

dbg.setEnabled(true)

local INTERVAL = 10
local SAPLING_SLOT = 1
local BONEMEAL_SLOT = 2

function isSapling(blockName)
    return blockName and blockName == "integrateddynamics:menril_sapling"
end

function isLog(blockName)
    return blockName and
        blockName:find("integrateddynamics:menril_log")
end

function hasGrown()
    local success, block = turtle.inspect()
    if not success then
        return false
    end
    return isLog(block.name)
end

function selectBonemeal()
    turtle.select(BONEMEAL_SLOT)
end

function selectSapling()
    turtle.select(SAPLING_SLOT)
end

function applyBonemeal()
    print("Applying bonemeal...")
    selectBonemeal()
    if turtle.getItemCount() > 0 then
        turtle.place()
        return true
    else
        print("No bonemeal available!")
        return false
    end
end

function plantSapling()
    print("Planting sapling...")
    selectSapling()
    if turtle.getItemCount() > 0 then
        turtle.place()
        return true
    else
        print("No saplings available!")
        return false
    end
end

function harvestTree3D()
    print("Harvesting 3D tree structure...")

    atTopPart = function()
        mv.turnTo(mv.HEAD.FW)
        local success, block = turtle.inspect()
        return success and isLog(block.name)
    end

    turtle.dig()
    mv.forward()


    turtle.dig()
    mv.forward()

    mv.tLeft()
    turtle.dig()
    mv.tRight()
    turtle.dig()
    mv.tRight()
    turtle.dig()

    mv.turnTo(mv.HEAD.FW)
    turtle.digUp()
    mv.up()

    doUp = function()
        if not turtle.detectUp() then
            return false
        end
        turtle.digUp()
        mv.up()
        return true
    end

    while doUp() do
        dbg.print("did up")
        if atTopPart() then
            turtle.dig()
            mv.tLeft()
            turtle.dig()
            mv.tLeft()
            turtle.dig()
            mv.tLeft()
            turtle.dig()
            mv.tLeft()
            dbg.print("did around")
        end
        dbg.print("next?")
    end
    dbg.print("Reached top of tree")

    mv.go0()
    mv.turnTo(mv.HEAD.FW)

    return true
end

function collectDrops()
    print("Collecting drops...")
    -- pickup.spiral(3, 2)
    pickup.grid(0, -4, 4, 2)
end

function printPos()
    print("@ ", mv.X, mv.Y, mv.Z)
end

function safeHome()
    print("Going home...")
    mv.go0()
    mv.turnTo(mv.HEAD.FW)
    print("Home position reached.")
end

function singleCycle()
    print("Starting tree farming cycle...")
    printPos()

    mv.forward()
    if hasGrown() then
        print("Tree has grown! Harvesting...")

        harvestTree3D()

        collectDrops()

        -- plantSapling()

        print("Tree harvested and replanted.")
        safeHome()
    else
        print("Tree not grown yet. Checking if sapling exists...")
        local success, block = turtle.inspect()

        if success and isSapling(block.name) then
            print("Sapling found.")
            -- print("Sapling found. Applying bonemeal...")
            -- applyBonemeal()
        else
            print("No sapling found. Planting new sapling...")
            plantSapling()
        end
        mv.back()
    end

end

-- local status, err = pcall(singleCycle)
-- if status then
--     print("Cycle completed successfully.")
-- else
--     print("FATAL: Going back to start pos")
--     mv.go0()
--     mv.turnTo(mv.HEAD.FW)
--     print("FATAL: Error occurred: " .. err)
-- end


while true do
    local status, err = pcall(singleCycle)
    if status then
        print("Cycle completed successfully.")
    else
        print("FATAL: Going back to start pos")
        mv.go0()
        mv.turnTo(mv.HEAD.FW)
        print("FATAL: Error occurred: " .. err)
        break
    end
    print("Waiting for next cycle...")
    os.sleep(INTERVAL)
end

-- ============================================================================
-- END BUNDLED SCRIPT: treefarm_menril
-- ============================================================================
