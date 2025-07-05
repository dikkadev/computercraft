local mv = require("movement")
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
    mv.go(0, 0, 1)
    turtle.dig()
    mv.forward()

    while true do
        local success, blockBelowData = turtle.inspectDown()
        if success then
            if blockBelowData.name == TURN_RIGHT_BLOCK then
                mv.tRight()
            elseif blockBelowData.name == TURN_LEFT_BLOCK then
                mv.tLeft()
            elseif blockBelowData.name == END_BLOCK then
                mv.up()
                mv.up()
                break
            end
        end
        turtle.dig()
        turtle.suckDown()
        mv.forward()
    end

    mv.go(0, 0, 0)
    compactItems()
    distributeItems()
    while checkCraft() do
        craft()
        deposit()
    end
end
