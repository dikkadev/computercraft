local mock_turtle = {}

mock_turtle.position = {x = 0, y = 0, z = 0}
mock_turtle.facing = 0
mock_turtle.inventory = {}
mock_turtle.selectedSlot = 1
mock_turtle.world = {}
mock_turtle.fuel = 1000

for i = 1, 16 do
    mock_turtle.inventory[i] = nil
end

function mock_turtle.forward()
    local newX, newY = mock_turtle.position.x, mock_turtle.position.y
    
    if mock_turtle.facing == 0 then
        newX = newX + 1
    elseif mock_turtle.facing == 1 then
        newY = newY + 1
    elseif mock_turtle.facing == 2 then
        newX = newX - 1
    elseif mock_turtle.facing == 3 then
        newY = newY - 1
    end
    
    local blockKey = newX .. "," .. newY .. "," .. mock_turtle.position.z
    if mock_turtle.world[blockKey] then
        return false
    end
    
    mock_turtle.position.x = newX
    mock_turtle.position.y = newY
    mock_turtle.fuel = mock_turtle.fuel - 1
    return true
end

function mock_turtle.back()
    local newX, newY = mock_turtle.position.x, mock_turtle.position.y
    
    if mock_turtle.facing == 0 then
        newX = newX - 1
    elseif mock_turtle.facing == 1 then
        newY = newY - 1
    elseif mock_turtle.facing == 2 then
        newX = newX + 1
    elseif mock_turtle.facing == 3 then
        newY = newY + 1
    end
    
    local blockKey = newX .. "," .. newY .. "," .. mock_turtle.position.z
    if mock_turtle.world[blockKey] then
        return false
    end
    
    mock_turtle.position.x = newX
    mock_turtle.position.y = newY
    mock_turtle.fuel = mock_turtle.fuel - 1
    return true
end

function mock_turtle.up()
    local blockKey = mock_turtle.position.x .. "," .. mock_turtle.position.y .. "," .. (mock_turtle.position.z + 1)
    if mock_turtle.world[blockKey] then
        return false
    end
    
    mock_turtle.position.z = mock_turtle.position.z + 1
    mock_turtle.fuel = mock_turtle.fuel - 1
    return true
end

function mock_turtle.down()
    local blockKey = mock_turtle.position.x .. "," .. mock_turtle.position.y .. "," .. (mock_turtle.position.z - 1)
    if mock_turtle.world[blockKey] then
        return false
    end
    
    mock_turtle.position.z = mock_turtle.position.z - 1
    mock_turtle.fuel = mock_turtle.fuel - 1
    return true
end

function mock_turtle.turnLeft()
    mock_turtle.facing = (mock_turtle.facing - 1) % 4
    return true
end

function mock_turtle.turnRight()
    mock_turtle.facing = (mock_turtle.facing + 1) % 4
    return true
end

function mock_turtle.dig()
    local x, y, z = mock_turtle.position.x, mock_turtle.position.y, mock_turtle.position.z
    
    if mock_turtle.facing == 0 then
        x = x + 1
    elseif mock_turtle.facing == 1 then
        y = y + 1
    elseif mock_turtle.facing == 2 then
        x = x - 1
    elseif mock_turtle.facing == 3 then
        y = y - 1
    end
    
    local blockKey = x .. "," .. y .. "," .. z
    if mock_turtle.world[blockKey] then
        mock_turtle.world[blockKey] = nil
        return true
    end
    return false
end

function mock_turtle.digUp()
    local blockKey = mock_turtle.position.x .. "," .. mock_turtle.position.y .. "," .. (mock_turtle.position.z + 1)
    if mock_turtle.world[blockKey] then
        mock_turtle.world[blockKey] = nil
        return true
    end
    return false
end

function mock_turtle.digDown()
    local blockKey = mock_turtle.position.x .. "," .. mock_turtle.position.y .. "," .. (mock_turtle.position.z - 1)
    if mock_turtle.world[blockKey] then
        mock_turtle.world[blockKey] = nil
        return true
    end
    return false
end

function mock_turtle.inspect()
    local x, y, z = mock_turtle.position.x, mock_turtle.position.y, mock_turtle.position.z
    
    if mock_turtle.facing == 0 then
        x = x + 1
    elseif mock_turtle.facing == 1 then
        y = y + 1
    elseif mock_turtle.facing == 2 then
        x = x - 1
    elseif mock_turtle.facing == 3 then
        y = y - 1
    end
    
    local blockKey = x .. "," .. y .. "," .. z
    local block = mock_turtle.world[blockKey]
    if block then
        return true, {name = block}
    end
    return false
end

function mock_turtle.inspectUp()
    local blockKey = mock_turtle.position.x .. "," .. mock_turtle.position.y .. "," .. (mock_turtle.position.z + 1)
    local block = mock_turtle.world[blockKey]
    if block then
        return true, {name = block}
    end
    return false
end

function mock_turtle.inspectDown()
    local blockKey = mock_turtle.position.x .. "," .. mock_turtle.position.y .. "," .. (mock_turtle.position.z - 1)
    local block = mock_turtle.world[blockKey]
    if block then
        return true, {name = block}
    end
    return false
end

function mock_turtle.select(slot)
    if slot >= 1 and slot <= 16 then
        mock_turtle.selectedSlot = slot
        return true
    end
    return false
end

function mock_turtle.getItemCount(slot)
    slot = slot or mock_turtle.selectedSlot
    local item = mock_turtle.inventory[slot]
    return item and item.count or 0
end

function mock_turtle.getItemDetail(slot)
    slot = slot or mock_turtle.selectedSlot
    return mock_turtle.inventory[slot]
end

function mock_turtle.transferTo(targetSlot, amount)
    local sourceSlot = mock_turtle.selectedSlot
    local sourceItem = mock_turtle.inventory[sourceSlot]
    local targetItem = mock_turtle.inventory[targetSlot]
    
    if not sourceItem then
        return false
    end
    
    amount = amount or sourceItem.count
    
    if targetItem and targetItem.name ~= sourceItem.name then
        return false
    end
    
    if not targetItem then
        mock_turtle.inventory[targetSlot] = {
            name = sourceItem.name,
            count = math.min(amount, sourceItem.count)
        }
    else
        targetItem.count = targetItem.count + math.min(amount, sourceItem.count)
    end
    
    sourceItem.count = sourceItem.count - math.min(amount, sourceItem.count)
    if sourceItem.count <= 0 then
        mock_turtle.inventory[sourceSlot] = nil
    end
    
    return true
end

function mock_turtle.drop(amount)
    return true
end

function mock_turtle.dropDown(amount)
    return true
end

function mock_turtle.dropUp(amount)
    return true
end

function mock_turtle.suck(amount)
    return true
end

function mock_turtle.suckDown(amount)
    return true
end

function mock_turtle.suckUp(amount)
    return true
end

function mock_turtle.place()
    return true
end

function mock_turtle.placeUp()
    return true
end

function mock_turtle.placeDown()
    return true
end

function mock_turtle.detect()
    local success, _ = mock_turtle.inspect()
    return success
end

function mock_turtle.detectUp()
    local success, _ = mock_turtle.inspectUp()
    return success
end

function mock_turtle.detectDown()
    local success, _ = mock_turtle.inspectDown()
    return success
end

function mock_turtle.craft(amount)
    return true
end

function mock_turtle.equipLeft()
    return true
end

function mock_turtle.equipRight()
    return true
end

function mock_turtle.getSelectedSlot()
    return mock_turtle.selectedSlot
end

function mock_turtle.reset()
    mock_turtle.position = {x = 0, y = 0, z = 0}
    mock_turtle.facing = 0
    mock_turtle.selectedSlot = 1
    mock_turtle.world = {}
    mock_turtle.fuel = 1000
    for i = 1, 16 do
        mock_turtle.inventory[i] = nil
    end
end

function mock_turtle.setBlock(x, y, z, blockType)
    local blockKey = x .. "," .. y .. "," .. z
    mock_turtle.world[blockKey] = blockType
end

function mock_turtle.addItem(slot, name, count)
    mock_turtle.inventory[slot] = {name = name, count = count}
end

return mock_turtle