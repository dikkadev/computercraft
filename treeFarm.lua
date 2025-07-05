local mv = require("movement")
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
    mv.forward()
    turtle.place()
    mv.tRight()
    mv.forward()
    mv.tLeft()
    turtle.place()
    mv.tRight()
    mv.back()
    turtle.place()
    mv.tLeft()
    mv.back()
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
    mv.forward()
    -- for i = 1, 30 do
    local shouldStop = false
    local lastLayer = false
    while not shouldStop do
        lastLayer = not turtle.detectUp()
        turtle.dig()
        if heightDiff % 2 == 1 then
            mv.tLeft()
        else
            mv.tRight()
        end
        turtle.dig()
        mv.forward()
        if heightDiff % 2 == 0 then
            mv.tLeft()
        else
            mv.tRight()
        end
        turtle.dig()
        turtle.digUp()
        mv.up()
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
    mv.forward()
    mv.forward()
    mv.tRight()
    mv.forward()

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
                mv.forward()
                turtle.suck()

                -- Increment step
                step = step + 1
            end
            -- Turn right after each set of steps
            mv.tRight()
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
    mv.go(0, 0, 0)
    print("Waiting for items to fall")
    os.sleep(60 * 2)
    collectItems()
    mv.go(0, 0, 0)
    storeItems()
end
