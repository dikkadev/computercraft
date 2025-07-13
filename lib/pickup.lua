local pickup = {}

local mv = require("lib.movement")

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