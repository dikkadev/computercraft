--[[

Library code to track turtle movement and go to specific position without GPS

]]--

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
