local mv = require("movement")

local INTERVAL = 60

-- -- OLD CODE
-- function shouldDig()
--     success, block = turtle.inspect()
--     return success and block.name == "ae2:quartz_cluster"
-- end
--
-- function doDir(direction)
--     print("Trying direction: ", mv.DIR_NAMES[direction])
--     mv.turnTo(direction)
--     if shouldDig() then
--         turtle.dig()
--     end
-- end
--
-- while true do
--     print("Checking for quartz clusters...")
--
--     doDir(mv.HEAD.FW)
--     os.sleep(1)
--     doDir(mv.HEAD.RI)
--     os.sleep(1)
--     doDir(mv.HEAD.LE)
--
--     print("Waiting for next check...")
--     os.sleep(INTERVAL)
-- end

function shouldDig()
    success, block = turtle.inspect()
    return success and block.name == "ae2:quartz_cluster"
end

function doDir(direction)
    print("Trying direction: ", mv.DIR_NAMES[direction])
    mv.turnTo(direction)
    success, block = turtle.inspect()
    if success and block.name == "ae2:quartz_cluster" then
        turtle.dig()
    end
end

function doDownUp(dir)
    if dir == "down" then
        print("Trying direction: down")
        success, block = turtle.inspectDown()
        if success and block.name == "ae2:quartz_cluster" then
            turtle.digDown()
        end
    else
        print("Trying direction: up")
        success, block = turtle.inspectUp()
        if success and block.name == "ae2:quartz_cluster" then
            turtle.digUp()
        end
    end
end

function printPos()
    -- print("@ ", mv.X, mv.Y, mv.Z)
end

function safeHome()
    print("Going home...")
    mv.up()
    mv.go0()
    mv.turnTo(mv.HEAD.FW)
    print("Home position reached.")
end

function singleRound()
    print("Starting single round of Certus Quartz mining...")
    printPos()

    mv.tLeft()
    mv.forward()
    doDownUp("down")
    printPos()

    mv.turnTo(mv.HEAD.LE)
    mv.forward()
    mv.tRight()
    mv.forward()
    doDownUp("down")
    doDir(mv.HEAD.RI)
    printPos()

    mv.turnTo(mv.HEAD.FW)
    mv.forward()
    doDownUp("down")
    doDir(mv.HEAD.RI)
    printPos()

    mv.turnTo(mv.HEAD.FW)
    mv.forward()
    mv.tRight()
    mv.forward()
    doDownUp("down")
    printPos()

    mv.turnTo(mv.HEAD.RI)
    mv.forward()
    mv.tRight()
    mv.forward()
    doDownUp("down")
    printPos()

    mv.turnTo(mv.HEAD.RI)
    mv.forward()
    doDownUp("down")
    doDir(mv.HEAD.BK)
    printPos()

    mv.turnTo(mv.HEAD.LE)
    mv.forward()
    mv.turnTo(mv.HEAD.BK)
    mv.forward()
    doDownUp("down")
    printPos()

    mv.forward()

    mv.turnTo(mv.HEAD.RI)
    mv.forward()
    doDownUp("down")
    printPos()

    mv.turnTo(mv.HEAD.RI)
    mv.forward()
    mv.tLeft()
    mv.forward()
    doDownUp("down")

    -- os.sleep(3)
    -- safeHome()

    safeHome()
end

while true do
    local status, err = pcall(singleRound)
    if status then
        -- no errors
        print("Round completed successfully.")
        -- break
    else
        print("FATAL: Going back to start pos")
        mv.go0()
        mv.turnTo(mv.HEAD.FW)
        print("FATAL: Error occurred: " .. err)
        break
    end

    print("Waiting for next round...")
    os.sleep(INTERVAL)
end
