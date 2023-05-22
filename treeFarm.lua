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

-- Plant saplings function
function plantSaplings()
    print("Planting saplings")

    -- check for at least 5 saplings in slot 1
    while turtle.getItemCount(1) < 5 do
        print("Not enough saplings. Please refill and press enter to continue...")
        read()
    end

    if turtle.detect() then
        print("Something detected. Skipping planting saplings.")
        return false
    end
    turtle.select(1)
    forward()
    turtle.place()
    tRight()
    forward()
    tLeft()
    turtle.place()
    tRight()
    back()
    turtle.place()
    tLeft()
    back()
    turtle.place()
    return true
end

-- Apply bonemeal function
function applyBonemeal()
    slot2details = turtle.getItemDetail(2)
    if not slot2details then
        print("No bonemeal found. Skipping applying bonemeal.")
        return false
    end
    if slot2details.name == "minecraft:bone_meal" then
        turtle.select(2)
        local success, data = turtle.inspect()
        local start_block = data.name
        while true do
            local success, data = turtle.inspect()
            if data.name ~= start_block then -- break if tree has grown
                print("Tree has grown. Breaking the loop.")
                return true
            end
            if turtle.getItemCount() == 0 then -- break if bonemeal is empty
                print("Bonemeal is empty. Breaking the loop.")
                return false
            end
            turtle.place()
            print("Used bonemeal")
        end
    end
end

-- Harvest tree function
function harvestTree()
    print("Harvesting tree")
    local heightDiff = 0
    turtle.dig()
    forward()
    -- for i = 1, 30 do
    local shouldStop = false
    local lastLayer = false
    while not shouldStop do
        lastLayer = not turtle.detectUp()
        turtle.dig()
        if heightDiff % 2 == 1 then
            tLeft()
        else
            tRight()
        end
        turtle.dig()
        forward()
        if heightDiff % 2 == 0 then
            tLeft()
        else
            tRight()
        end
        turtle.dig()
        turtle.digUp()
        up()
        heightDiff = heightDiff + 1
        if lastLayer then
            print("Last layer reached.")
            shouldStop = true
        end
    end
end

-- Collect items function
function collectItems()
    print("Collecting fallen items")
    forward()
    forward()
    tRight()
    forward()

    turtle.select(1)

    -- Set the length of movement
    local move_length = 1
    local step = 0

    while true do
        -- Loop for each direction
        for i = 1, 2 do
            -- Loop for number of steps
            for j = 1, move_length do
                if step >= 49 then
                    return
                end

                -- Move forward and collect item
                forward()
                turtle.suck()

                -- Increment step
                step = step + 1
            end
            -- Turn right after each set of steps
            tRight()
        end
        -- Increment the move_length after completing a square movement
        move_length = move_length + 1
    end
end

-- Store items functions
function storeItems()
    startSlot = 2
    -- if bone_meal in slot 2, start emptying from slot 3
    slot2 = turtle.getItemDetail(2)
    if (slot2) and (turtle.getItemDetail(2).name == "minecraft:bone_meal") then
        startSlot = 3
    end
    print("Storing items")
    -- put everything else in the chest behind
    for i = startSlot, 16 do
        turtle.select(i)
        if turtle.getItemCount() > 0 then
            didDrop = turtle.dropDown()
            if not didDrop then
                print("Chest is full. Please empty the chest and press enter to continue...")
                read()
            end
        end
    end
end

-- Wait for tree to grow
function waitForTreeToGrow()
    print("Waiting for tree to grow...")
    local success, data = turtle.inspect()
    local start_block = data.name
    if string.find(start_block, "log") then
        print("Found some log, skipping waiting")
        return
    end
    while true do
        local success, data = turtle.inspect()
        if data.name ~= start_block then
            print("Tree has grown!")
            return
        end
        os.sleep(10)
    end
end

-- Clear screen
term.clear()

-- Initial Checks
print("Please ensure the following:")
print("1. At least 5 saplings in slot 1.")
print("2. Place output chest below the turtle")
print("3. Optional bonemeal in slot 2.")
print("Press enter to continue...")
read()

-- Main Loop
while true do
    if plantSaplings() then
        didBone = applyBonemeal()
        if not didBone then
            print("No bonemeal found. Skipping applying bonemeal.")
        end
    end
    waitForTreeToGrow()
    harvestTree()
    go(0, 0, 0)
    print("Waiting for items to fall")
    os.sleep(60 * 2)
    collectItems()
    go(0, 0, 0)
    storeItems()
end
