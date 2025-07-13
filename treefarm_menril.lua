local mv = require("movement")
local pickup = require("pickup")
local dbg = require("dbg")

dbg.setEnabled(true)

local INTERVAL = 10
local SAPLING_SLOT = 1
local BONEMEAL_SLOT = 2

function isSapling(blockName)
    return blockName and blockName == "integrateddynamics:menril_sapling"
end

function isLog(blockName)
    return blockName and
        blockName:find("integrateddynamics:menril_log")
end

function hasGrown()
    local success, block = turtle.inspect()
    if not success then
        return false
    end
    return isLog(block.name)
end

function selectBonemeal()
    turtle.select(BONEMEAL_SLOT)
end

function selectSapling()
    turtle.select(SAPLING_SLOT)
end

function applyBonemeal()
    print("Applying bonemeal...")
    selectBonemeal()
    if turtle.getItemCount() > 0 then
        turtle.place()
        return true
    else
        print("No bonemeal available!")
        return false
    end
end

function plantSapling()
    print("Planting sapling...")
    selectSapling()
    if turtle.getItemCount() > 0 then
        turtle.place()
        return true
    else
        print("No saplings available!")
        return false
    end
end

function harvestTree3D()
    print("Harvesting 3D tree structure...")

    atTopPart = function()
        mv.turnTo(mv.HEAD.FW)
        local success, block = turtle.inspect()
        return success and isLog(block.name)
    end

    turtle.dig()
    mv.forward()


    turtle.dig()
    mv.forward()

    mv.tLeft()
    turtle.dig()
    mv.tRight()
    turtle.dig()
    mv.tRight()
    turtle.dig()

    mv.turnTo(mv.HEAD.FW)
    turtle.digUp()
    mv.up()

    doUp = function()
        if not turtle.detectUp() then
            return false
        end
        turtle.digUp()
        mv.up()
        return true
    end

    while doUp() do
        dbg.print("did up")
        if atTopPart() then
            turtle.dig()
            mv.tLeft()
            turtle.dig()
            mv.tLeft()
            turtle.dig()
            mv.tLeft()
            turtle.dig()
            mv.tLeft()
            dbg.print("did around")
        end
        dbg.print("next?")
    end
    dbg.print("Reached top of tree")

    mv.go0()
    mv.turnTo(mv.HEAD.FW)

    return true
end

function collectDrops()
    print("Collecting drops...")
    -- pickup.spiral(3, 2)
    pickup.grid(0, -4, 4, 2)
end

function printPos()
    print("@ ", mv.X, mv.Y, mv.Z)
end

function safeHome()
    print("Going home...")
    mv.go0()
    mv.turnTo(mv.HEAD.FW)
    print("Home position reached.")
end

function singleCycle()
    print("Starting tree farming cycle...")
    printPos()

    mv.forward()
    if hasGrown() then
        print("Tree has grown! Harvesting...")

        harvestTree3D()

        collectDrops()

        -- plantSapling()

        print("Tree harvested and replanted.")
        safeHome()
    else
        print("Tree not grown yet. Checking if sapling exists...")
        local success, block = turtle.inspect()

        if success and isSapling(block.name) then
            print("Sapling found.")
            -- print("Sapling found. Applying bonemeal...")
            -- applyBonemeal()
        else
            print("No sapling found. Planting new sapling...")
            plantSapling()
        end
        mv.back()
    end

end

-- local status, err = pcall(singleCycle)
-- if status then
--     print("Cycle completed successfully.")
-- else
--     print("FATAL: Going back to start pos")
--     mv.go0()
--     mv.turnTo(mv.HEAD.FW)
--     print("FATAL: Error occurred: " .. err)
-- end


while true do
    local status, err = pcall(singleCycle)
    if status then
        print("Cycle completed successfully.")
    else
        print("FATAL: Going back to start pos")
        mv.go0()
        mv.turnTo(mv.HEAD.FW)
        print("FATAL: Error occurred: " .. err)
        break
    end
    print("Waiting for next cycle...")
    os.sleep(INTERVAL)
end

