-- ===== MOVEMENT CODE =====
X = 0 -- forwards/backwards offset
Y = 0 -- left/right offset; right => + | left => -
Z = 0 -- up/down offset
HEAD = {
    FW = 0,
    RI = 1,
    LE = 2,
    BK = 3
}
heading = HEAD.FW

function forward()
    local didMove = turtle.forward()
    if not didMove then
        return false
    end
    if heading == HEAD.FW then
        X = X + 1
    elseif heading == HEAD.RI then
        Y = Y + 1
    elseif heading == HEAD.LE then
        Y = Y - 1
    elseif heading == HEAD.BK then
        X = X - 1
    end
    return true
end

function back(iters)
    local didMove = turtle.back()
    if not didMove then
        return false
    end
    if heading == HEAD.FW then
        X = X - 1
    elseif heading == HEAD.RI then
        Y = Y - 1
    elseif heading == HEAD.LE then
        Y = Y + 1
    elseif heading == HEAD.BK then
        X = X + 1
    end
    return true
end

function up(iters)
    local didMove = turtle.up()
    if not didMove then
        return false
    end
    Z = Z + 1
    return true
end

function down(iters)
    local didMove = turtle.down()
    if not didMove then
        return false
    end
    Z = Z - 1
    return true
end

function tLeft()
    turtle.turnLeft()
    if heading == HEAD.FW then
        heading = HEAD.LE
    elseif heading == HEAD.RI then
        heading = HEAD.FW
    elseif heading == HEAD.LE then
        heading = HEAD.BK
    elseif heading == HEAD.BK then
        heading = HEAD.RI
    end
end

function tRight()
    turtle.turnRight()
    if heading == HEAD.FW then
        heading = HEAD.RI
    elseif heading == HEAD.RI then
        heading = HEAD.BK
    elseif heading == HEAD.LE then
        heading = HEAD.FW
    elseif heading == HEAD.BK then
        heading = HEAD.LE
    end
end

function turnTo(direction)
    if direction == HEAD.FW then
        if heading == HEAD.RI then
            tLeft()
        elseif heading == HEAD.LE then
            tRight()
        elseif heading == HEAD.BK then
            tLeft()
            tLeft()
        end
    elseif direction == HEAD.RI then
        if heading == HEAD.FW then
            tRight()
        elseif heading == HEAD.LE then
            tLeft()
            tLeft()
        elseif heading == HEAD.BK then
            tLeft()
        end
    elseif direction == HEAD.LE then
        if heading == HEAD.FW then
            tLeft()
        elseif heading == HEAD.RI then
            tLeft()
            tLeft()
        elseif heading == HEAD.BK then
            tRight()
        end
    elseif direction == HEAD.BK then
        if heading == HEAD.FW then
            tLeft()
            tLeft()
        elseif heading == HEAD.RI then
            tLeft()
        elseif heading == HEAD.LE then
            tRight()
        end
    end
end

function go(goalX, goalY, goalZ)
    print("Going to " .. goalX .. ", " .. goalY .. ", " .. goalZ)
    print("Currently at " .. X .. ", " .. Y .. ", " .. Z)

    -- correct x
    while goalX ~= X do
        local deltaX = goalX - X

        if deltaX > 0 then
            goalHeading = HEAD.FW
        elseif deltaX < 0 then
            goalHeading = HEAD.BK
        end

        turnTo(goalHeading)

        -- Move forward to the goal
        if not forward() then
            turtle.dig()
            forward()
        end
    end

    while goalY ~= Y do
        local deltaY = goalY - Y

        if deltaY > 0 then
            goalHeading = HEAD.RI
        elseif deltaY < 0 then
            goalHeading = HEAD.LE
        end

        turnTo(goalHeading)

        -- Move forward to the goal
        if not forward() then
            turtle.dig()
            forward()
        end
    end

    -- goto correct height
    while Z < goalZ do
        if not up() then
            turtle.digUp()
            up()
        end
    end

    while Z > goalZ do
        if not down() then
            turtle.digDown()
            up()
        end
    end

    turnTo(HEAD.FW)

end

-- ====== MOVEMENT END =====

-- Do a single layer (which is actually 2)
function doLayer()
    for col = 1, width do
        -- go front
        for row = 1, length do
            turtle.digDown()
            if row ~= length then
                turtle.dig()
                forward()
            end
        end
        -- move over
        if col ~= width then
            if col % 2 ~= 0 then
                tRight()
            else
                tLeft()
            end
            turtle.dig()
            forward()
            if col % 2 ~= 0 then
                tRight()
            else
                tLeft()
            end
        end
    end
    go(0, 0, Z)
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
    go(0, 0, 0)
    turnTo(HEAD.BK)
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
    turnTo(HEAD.FW)
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
down()

for layer = 1, depth do
    print("Starting layer " .. layer)
    doLayer()
    local zAfterLayer = Z
    if occupiedSlots() > 11 then
        depositItems()
    end
    go(0, 0, zAfterLayer)
    if layer ~= depth then
        turtle.digDown()
        down()
        turtle.digDown()
        down()
    end
end
