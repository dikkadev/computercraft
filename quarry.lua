local mv = require("movement")
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
