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

function movement.go(goalX, goalY, goalZ, stepExtraFunc)
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
            if stepExtraFunc then
                stepExtraFunc()
            end
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
            if stepExtraFunc then
                stepExtraFunc()
            end
        end
    end

    while movement.Z < goalZ do
        if not movement.up() then
            turtle.digUp()
            movement.up()
            if stepExtraFunc then
                stepExtraFunc()
            end
        end
    end

    while movement.Z > goalZ do
        if not movement.down() then
            turtle.digDown()
            movement.down()
            if stepExtraFunc then
                stepExtraFunc()
            end
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

