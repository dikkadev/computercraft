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

-- checks if we can craft paper from sugar_cane
function checkCraft()
    local slots = {}
    for i = 1, 16 do
        slots[i] = turtle.getItemDetail(i)
    end
    -- check first 3 slots are sugar cane
    if slots[1] ~= nil then
        if slots[1].name ~= "minecraft:sugar_cane" then
            print("Slot 1 is not sugar cane")
            return false
        end
    else
        print("Slot 1 is empty")
        return false
    end
    if slots[2] ~= nil then
        if slots[2].name ~= "minecraft:sugar_cane" then
            print("Slot 2 is not sugar cane")
            return false
        end
    else
        print("Slot 2 is empty")
        return false
    end
    if slots[3] ~= nil then
        if slots[3].name ~= "minecraft:sugar_cane" then
            print("Slot 3 is not sugar cane")
            return false
        end
    else
        print("Slot 3 is empty")
        return false
    end

    -- check if all other slots are empty
    otherEmpty = true
    for i = 4, 16 do
        if slots[i] ~= nil then
            otherEmpty = false
        end
    end
    if not otherEmpty then
        print("Other slots are not empty")
        return false
    end
    return turtle.craft(0)
end

-- distribute items
function distributeItems()
    print("Distributing items...")
    local slots = {}
    for i = 1, 3 do
        slots[i] = turtle.getItemDetail(i)
    end
    -- check if all slots are sugar cane or empty
    for i = 1, 3 do
        if slots[i] ~= nil then
            if slots[i].name ~= "minecraft:sugar_cane" then
                print("Slot " .. i .. " is not sugar cane")
                return false
            end
        end
    end

    local totalItems = 0
    for i = 1, 3 do
        totalItems = totalItems + turtle.getItemCount(i)
    end

    if totalItems > 64 * 3 then
        print("Too many items")
        return false
    end

    local itemsPerSlot = math.floor(totalItems / 3)
    local remainder = totalItems % 3
    for i = 1, 3 do
        turtle.select(i)
        local itemInSlot = turtle.getItemCount(i)
        if itemInSlot > itemsPerSlot then
            turtle.transferTo(i + 1, itemInSlot - itemsPerSlot)
        end
    end
    turtle.select(4)
    turtle.transferTo(1)
    return true
end

-- compact items in top 3 slots
function compactItems()
    print("Compacting items...")
    for i = 2, 16 do
        turtle.select(i)
        while turtle.getItemCount() ~= 0 do
            local goalSlot = 1
            local didTransfer = turtle.transferTo(goalSlot)
            while not didTransfer do
                goalSlot = goalSlot + 1
                didTransfer = turtle.transferTo(goalSlot)
            end
            if goalSlot == turtle.getSelectedSlot() then
                break
            end
        end
    end
end

-- craft paper
function craft()
    print("Crafting...")
    turtle.select(16)
    turtle.craft(21)
end

function deposit()
    turtle.select(16)
    turtle.dropDown()
end

-- ============= Start

TURN_RIGHT_BLOCK = "minecraft:cobbled_deepslate"
TURN_LEFT_BLOCK = "minecraft:cobblestone"
END_BLOCK = "minecraft:dirt"

term.clear()
-- ask user if tool is already equiped
print("Is a hoe already equiped? (y/n)")
local input = io.read()
if input == "n" then
    print("Please put it in slot 16 and press enter...")
    read()
    turtle.select(16)
    turtle.equipLeft()
end

term.clear()

-- main loop
while true do
    turtle.select(1)
    go(0, 0, 1)
    turtle.dig()
    forward()

    while true do
        local success, blockBelowData = turtle.inspectDown()
        if success then
            if blockBelowData.name == TURN_RIGHT_BLOCK then
                tRight()
            elseif blockBelowData.name == TURN_LEFT_BLOCK then
                tLeft()
            elseif blockBelowData.name == END_BLOCK then
                up()
                up()
                break
            end
        end
        turtle.dig()
        turtle.suckDown()
        forward()
    end

    go(0, 0, 0)
    compactItems()
    distributeItems()
    while checkCraft() do
        craft()
        deposit()
    end
end
