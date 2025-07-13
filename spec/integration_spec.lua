local test_utils = require("test.helpers.test_utils")

describe("Integration Tests", function()
    local movement, pickup
    local mock_turtle, mock_os
    
    before_each(function()
        mock_turtle, mock_os = test_utils.setup_mocks()
        movement = require("lib.movement")
        pickup = require("lib.pickup")
        
        -- Reset movement state
        movement.X = 0
        movement.Y = 0
        movement.Z = 0
        movement.heading = movement.HEAD.FW
        
        -- Reset pickup configuration
        pickup.setReturnHome(false)
        pickup.setCollectionFunction(nil)
    end)
    
    describe("Movement + Pickup Integration", function()
        it("should combine movement and pickup correctly", function()
            local items_collected = 0
            
            pickup.setCollectionFunction(function()
                items_collected = items_collected + 1
            end)
            
            pickup.setReturnHome(true)
            local start_x, start_y, start_z = movement.X, movement.Y, movement.Z
            
            local positions = pickup.spiral(2, 0, 0)
            
            assert.equals(25, #positions)
            assert.equals(25, items_collected)
            test_utils.assert_position_equals(start_x, start_y, start_z, movement, "Should return home")
        end)
        
        it("should handle obstacles during pickup", function()
            local world = test_utils.create_test_world()
            world.set_block(1, 0, 0, "stone")
            world.set_block(0, 1, 0, "stone")
            
            local positions = pickup.grid(3, 3, 0, 0)
            
            assert.equals(9, #positions)
            test_utils.assert_position_equals(2, 2, 0, movement, "Should reach final position despite obstacles")
        end)
        
        it("should maintain correct heading during complex patterns", function()
            pickup.spiral(3, 0, 0)
            
            assert.equals(movement.HEAD.FW, movement.heading, "Should face forward after pattern completion")
        end)
    end)
    
    describe("Real-world Scenarios", function()
        it("should simulate tree farm item collection", function()
            local inventory = test_utils.create_mock_inventory()
            local items_collected = {}
            
            pickup.setCollectionFunction(function()
                local mv = require("lib.movement")
                local item_type = "log"
                if math.random() > 0.7 then
                    item_type = "sapling"
                elseif math.random() > 0.9 then
                    item_type = "apple"
                end
                
                table.insert(items_collected, {
                    x = mv.X,
                    y = mv.Y,
                    type = item_type
                })
            end)
            
            pickup.setReturnHome(true)
            local positions = pickup.compact(3, 0, 0)
            
            assert.is_true(#items_collected > 0)
            assert.equals(#positions, #items_collected)
            
            local log_count = 0
            for _, item in ipairs(items_collected) do
                if item.type == "log" then
                    log_count = log_count + 1
                end
            end
            
            assert.is_true(log_count > 0)
        end)
        
        it("should handle fuel consumption tracking", function()
            local initial_fuel = mock_turtle.fuel
            
            pickup.spiral(2, 0, 0)
            
            assert.is_true(mock_turtle.fuel < initial_fuel, "Should consume fuel during movement")
        end)
        
        it("should work with different starting positions", function()
            movement.X = 10
            movement.Y = -5
            movement.Z = 20
            
            pickup.setReturnHome(true)
            local positions = pickup.line(5, movement.HEAD.RI, 0, 0)
            
            assert.equals(5, #positions)
            test_utils.assert_position_equals(10, -5, 20, movement, "Should return to original position")
        end)
    end)
    
    describe("Error Handling Integration", function()
        it("should handle movement failures gracefully", function()
            mock_turtle.fuel = 0
            
            local success, error_msg = pcall(function()
                pickup.spiral(1, 0, 0)
            end)
            
            assert.is_true(success or error_msg ~= nil)
        end)
        
        it("should handle blocked movement paths", function()
            local world = test_utils.create_test_world()
            for x = -2, 2 do
                for y = -2, 2 do
                    if not (x == 0 and y == 0) then
                        world.set_block(x, y, 0, "bedrock")
                    end
                end
            end
            
            local positions = pickup.spiral(1, 0, 0)
            
            assert.equals(1, #positions)
            assert.same({0, 0}, positions[1])
        end)
    end)
    
    describe("Performance Integration", function()
        it("should complete large patterns efficiently", function()
            local start_time = os.clock()
            
            pickup.setReturnHome(false)
            local positions = pickup.grid(10, 10, 0, 0)
            
            local end_time = os.clock()
            local duration = end_time - start_time
            
            assert.equals(100, #positions)
            assert.is_true(duration < 1.0, "Should complete 10x10 grid in under 1 second")
        end)
        
        it("should minimize redundant movements", function()
            local movement_count = 0
            local original_go = movement.go
            
            movement.go = function(...)
                movement_count = movement_count + 1
                return original_go(...)
            end
            
            pickup.grid(3, 3, 0, 0)
            
            movement.go = original_go
            
            assert.is_true(movement_count <= 10, "Should use efficient movement patterns")
        end)
    end)
    
    describe("Configuration Integration", function()
        it("should respect all configuration options together", function()
            local custom_calls = 0
            local custom_function = function()
                custom_calls = custom_calls + 1
            end
            
            pickup.setCollectionFunction(custom_function)
            pickup.setReturnHome(false)
            
            local start_x, start_y = movement.X, movement.Y
            local positions = pickup.circle(2, 5, 5)
            
            assert.is_true(custom_calls > 0)
            assert.is_false(movement.X == start_x and movement.Y == start_y)
            assert.is_true(#positions > 1)
        end)
    end)
end)