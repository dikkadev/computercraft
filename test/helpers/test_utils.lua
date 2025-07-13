local test_utils = {}

function test_utils.setup_mocks()
    local mock_turtle = require("test.mocks.turtle")
    local mock_os = require("test.mocks.os")
    
    _G.turtle = mock_turtle
    _G.os = setmetatable(mock_os, {__index = _G.os})
    
    mock_turtle.reset()
    mock_os.reset()
    
    return mock_turtle, mock_os
end

function test_utils.visualize_pattern(positions, width, height)
    width = width or 10
    height = height or 10
    
    local grid = {}
    for y = -height, height do
        grid[y] = {}
        for x = -width, width do
            grid[y][x] = "."
        end
    end
    
    for i, pos in ipairs(positions) do
        local x, y = pos[1], pos[2]
        if grid[y] and grid[y][x] then
            grid[y][x] = tostring(i % 10)
        end
    end
    
    local lines = {}
    for y = height, -height, -1 do
        local line = ""
        for x = -width, width do
            line = line .. grid[y][x] .. " "
        end
        table.insert(lines, line)
    end
    
    return table.concat(lines, "\n")
end

function test_utils.assert_position_equals(expected_x, expected_y, expected_z, actual_position, message)
    message = message or "Position mismatch"
    assert.equals(expected_x, actual_position.X, message .. " (X coordinate)")
    assert.equals(expected_y, actual_position.Y, message .. " (Y coordinate)")
    assert.equals(expected_z, actual_position.Z, message .. " (Z coordinate)")
end

function test_utils.assert_heading_equals(expected_heading, actual_heading, message)
    message = message or "Heading mismatch"
    assert.equals(expected_heading, actual_heading, message)
end

function test_utils.create_test_world()
    local world = {}
    
    function world.set_block(x, y, z, block_type)
        local key = x .. "," .. y .. "," .. z
        turtle.world[key] = block_type
    end
    
    function world.clear()
        turtle.world = {}
    end
    
    function world.add_obstacle_wall(x, y_start, y_end, z)
        for y = y_start, y_end do
            world.set_block(x, y, z, "stone")
        end
    end
    
    return world
end

function test_utils.count_pattern_coverage(positions)
    local unique_positions = {}
    for _, pos in ipairs(positions) do
        local key = pos[1] .. "," .. pos[2]
        unique_positions[key] = true
    end
    
    local count = 0
    for _ in pairs(unique_positions) do
        count = count + 1
    end
    
    return count
end

function test_utils.assert_pattern_returns_to_start(positions)
    if #positions > 0 then
        local first_pos = positions[1]
        local last_pos = positions[#positions]
        assert.equals(first_pos[1], last_pos[1], "Pattern should return to start X position")
        assert.equals(first_pos[2], last_pos[2], "Pattern should return to start Y position")
    end
end

function test_utils.print_colored(text, color)
    local colors = {
        red = "\27[31m",
        green = "\27[32m",
        yellow = "\27[33m",
        blue = "\27[34m",
        magenta = "\27[35m",
        cyan = "\27[36m",
        white = "\27[37m",
        reset = "\27[0m"
    }
    
    print((colors[color] or "") .. text .. (colors.reset or ""))
end

function test_utils.create_mock_inventory()
    local inventory = {}
    
    function inventory.add_item(slot, name, count)
        turtle.inventory[slot] = {name = name, count = count}
    end
    
    function inventory.clear()
        for i = 1, 16 do
            turtle.inventory[i] = nil
        end
    end
    
    function inventory.fill_with_saplings(count)
        inventory.add_item(1, "minecraft:oak_sapling", count or 64)
    end
    
    function inventory.fill_with_bonemeal(count)
        inventory.add_item(2, "minecraft:bone_meal", count or 64)
    end
    
    return inventory
end

return test_utils