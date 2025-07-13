-- ============================================================================
-- BUNDLED COMPUTERCRAFT SCRIPT: quarry
-- Generated: Sun Jul 13 20:02:54 CEST 2025
-- 
-- This file contains all dependencies bundled for single-file deployment
-- Original files: quarry.lua + dependencies
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


-- === END BUNDLED DEPENDENCIES ===

-- === MAIN SCRIPT ===

local mv = movement
-- Do a single layer (which is actually 2)
function doLayer()
    for col = 1, width do
        -- go front
        for row = 1, length do
            turtle.digDown()
            if row ~= length then
                turtle.dig()
                mv.forward()
            end
        end
        -- move over
        if col ~= width then
            if col % 2 ~= 0 then
                mv.tRight()
            else
                mv.tLeft()
            end
            turtle.dig()
            mv.forward()
            if col % 2 ~= 0 then
                mv.tRight()
            else
                mv.tLeft()
            end
        end
    end
    mv.go(0, 0, mv.Z)
end

-- check how many slots have items in them
function occupiedSlots()
    local slots = 0
    for i = 1, 16 do
        if turtle.getItemCount(i) > 0 then
            slots = slots + 1
        end
    end
    return slots
end

-- deposit items in chest and drop other items
function depositItems()
    print("Depositing items")
    mv.go(0, 0, 0)
    mv.turnTo(mv.HEAD.BK)
    for s = 1, 16 do
        -- if item is trash drop_down, else drop
        turtle.select(s)
        local item = turtle.getItemDetail()
        if item ~= nil then
            local isTrash = false
            for i = 1, #trash do
                if trash[i] == item.name then
                    isTrash = true
                end
            end
            if isTrash then
                turtle.dropDown()
            else
                turtle.drop()
            end
        end
    end
    mv.turnTo(mv.HEAD.FW)
end

trash = {}
-- scan all 'trash items'
--  scans all items in inventory and remembers them as trash
function scanTrash()
    print("Scanning trash")
    local t = {}
    for i = 1, 16 do
        turtle.select(i)
        local item = turtle.getItemDetail()
        if item ~= nil then
            table.insert(t, item.name)
        end
    end
    trash = t
end

-- Setting everything up
term.clear()
print("Length:")
length = tonumber(read())
print("Width:")
width = tonumber(read())
print("Layers (1 Layer = 2 Blocks):")
depth = tonumber(read())

term.clear()
print("Put an example of all the trash items in the inventory and press enter...")
read()
scanTrash()
for i = 1, 16 do
    turtle.select(i)
    turtle.drop()
end

term.clear()
print("Starting quarry " .. length .. "x" .. width .. "x" .. depth)

turtle.select(1)
turtle.digDown()
mv.down()

for layer = 1, depth do
    print("Starting layer " .. layer)
    doLayer()
    local zAfterLayer = mv.Z
    if occupiedSlots() > 11 then
        depositItems()
    end
    mv.go(0, 0, zAfterLayer)
    if layer ~= depth then
        turtle.digDown()
        mv.down()
        turtle.digDown()
        mv.down()
    end
end

-- ============================================================================
-- END BUNDLED SCRIPT: quarry
-- ============================================================================
