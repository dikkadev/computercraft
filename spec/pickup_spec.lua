local test_utils = require("test.helpers.test_utils")

describe("Pickup Library", function()
    local pickup
    local mock_turtle, mock_os
    
    before_each(function()
        mock_turtle, mock_os = test_utils.setup_mocks()
        pickup = require("lib.pickup")
        
        -- Reset pickup configuration
        pickup.setReturnHome(false)
        pickup.setCollectionFunction(nil)
        
        -- Reset movement state
        local movement = require("lib.movement")
        movement.X = 0
        movement.Y = 0
        movement.Z = 0
        movement.heading = movement.HEAD.FW
    end)
    
    describe("Configuration", function()
        it("should allow setting return home behavior", function()
            pickup.setReturnHome(true)
            assert.is_true(pickup.config.return_home)
            
            pickup.setReturnHome(false)
            assert.is_false(pickup.config.return_home)
        end)
        
        it("should allow setting custom collection function", function()
            local custom_called = false
            local custom_function = function()
                custom_called = true
            end
            
            pickup.setCollectionFunction(custom_function)
            pickup.spiral(1, 0, 0)
            
            assert.is_true(custom_called)
        end)
    end)
    
    describe("Spiral Pattern", function()
        it("should handle radius 0 (single position)", function()
            local positions = pickup.spiral(0, 0, 0)
            
            assert.equals(1, #positions)
            assert.same({0, 0}, positions[1])
        end)
        
        it("should create correct spiral pattern for radius 1", function()
            local positions = pickup.spiral(1, 0, 0)
            
            assert.equals(9, #positions)
            assert.same({0, 0}, positions[1])
            
            local coverage = test_utils.count_pattern_coverage(positions)
            assert.equals(9, coverage)
        end)
        
        it("should create correct spiral pattern for radius 2", function()
            local positions = pickup.spiral(2, 0, 0)
            
            assert.equals(25, #positions)
            assert.same({0, 0}, positions[1])
            
            local coverage = test_utils.count_pattern_coverage(positions)
            assert.equals(25, coverage)
        end)
        
        it("should start from specified position", function()
            local positions = pickup.spiral(1, 5, -3)
            
            assert.same({5, -3}, positions[1])
        end)
        
        it("should visualize correctly", function()
            local positions = pickup.spiral(1, 0, 0)
            local visualization = test_utils.visualize_pattern(positions, 2, 2)
            
            print("\n[TEST] Spiral Pattern (radius 1):")
            print(visualization)
            
            assert.is_string(visualization)
            assert.is_true(#visualization > 0)
        end)
    end)
    
    describe("Grid Pattern", function()
        it("should create correct grid pattern", function()
            local positions = pickup.grid(3, 2, 0, 0)
            
            assert.equals(6, #positions)
            
            local expected_positions = {
                {0, 0}, {1, 0}, {2, 0},
                {2, 1}, {1, 1}, {0, 1}
            }
            
            for i, expected in ipairs(expected_positions) do
                assert.same(expected, positions[i], "Position " .. i .. " mismatch")
            end
        end)
        
        it("should handle single row", function()
            local positions = pickup.grid(4, 1, 0, 0)
            
            assert.equals(4, #positions)
            assert.same({0, 0}, positions[1])
            assert.same({3, 0}, positions[4])
        end)
        
        it("should handle single column", function()
            local positions = pickup.grid(1, 4, 0, 0)
            
            assert.equals(4, #positions)
            assert.same({0, 0}, positions[1])
            assert.same({0, 3}, positions[4])
        end)
        
        it("should start from specified position", function()
            local positions = pickup.grid(2, 2, 10, 20)
            
            assert.same({10, 20}, positions[1])
            assert.same({11, 20}, positions[2])
            assert.same({11, 21}, positions[3])
            assert.same({10, 21}, positions[4])
        end)
        
        it("should visualize correctly", function()
            local positions = pickup.grid(3, 3, 0, 0)
            local visualization = test_utils.visualize_pattern(positions, 2, 2)
            
            print("\n[TEST] Grid Pattern (3x3):")
            print(visualization)
            
            assert.is_string(visualization)
        end)
    end)
    
    describe("Circle Pattern", function()
        it("should handle radius 0", function()
            local positions = pickup.circle(0, 0, 0)
            
            assert.equals(1, #positions)
            assert.same({0, 0}, positions[1])
        end)
        
        it("should create circular pattern", function()
            local positions = pickup.circle(2, 0, 0)
            
            assert.is_true(#positions > 1)
            assert.same({0, 0}, positions[1])
            
            local coverage = test_utils.count_pattern_coverage(positions)
            assert.is_true(coverage >= 5)
        end)
        
        it("should visualize correctly", function()
            local positions = pickup.circle(2, 0, 0)
            local visualization = test_utils.visualize_pattern(positions, 3, 3)
            
            print("\n[TEST] Circle Pattern (radius 2):")
            print(visualization)
            
            assert.is_string(visualization)
        end)
    end)
    
    describe("Line Pattern", function()
        it("should create horizontal line", function()
            local mv = require("lib.movement")
            local positions = pickup.line(4, mv.HEAD.FW, 0, 0)
            
            assert.equals(4, #positions)
            assert.same({0, 0}, positions[1])
            assert.same({1, 0}, positions[2])
            assert.same({2, 0}, positions[3])
            assert.same({3, 0}, positions[4])
        end)
        
        it("should create vertical line", function()
            local mv = require("lib.movement")
            local positions = pickup.line(3, mv.HEAD.RI, 0, 0)
            
            assert.equals(3, #positions)
            assert.same({0, 0}, positions[1])
            assert.same({0, 1}, positions[2])
            assert.same({0, 2}, positions[3])
        end)
        
        it("should handle single position", function()
            local mv = require("lib.movement")
            local positions = pickup.line(1, mv.HEAD.FW, 5, 5)
            
            assert.equals(1, #positions)
            assert.same({5, 5}, positions[1])
        end)
    end)
    
    describe("Compact Pattern", function()
        it("should create compact square pattern", function()
            local positions = pickup.compact(1, 0, 0)
            
            assert.equals(9, #positions)
            
            local coverage = test_utils.count_pattern_coverage(positions)
            assert.equals(9, coverage)
        end)
        
        it("should handle radius 0", function()
            local positions = pickup.compact(0, 0, 0)
            
            assert.equals(1, #positions)
            assert.same({0, 0}, positions[1])
        end)
        
        it("should visualize correctly", function()
            local positions = pickup.compact(2, 0, 0)
            local visualization = test_utils.visualize_pattern(positions, 3, 3)
            
            print("\n[TEST] Compact Pattern (radius 2):")
            print(visualization)
            
            assert.is_string(visualization)
        end)
    end)
    
    describe("Return Home Behavior", function()
        it("should return to starting position when enabled", function()
            local mv = require("lib.movement")
            mv.X, mv.Y, mv.Z = 10, 20, 30
            
            pickup.setReturnHome(true)
            pickup.spiral(1, 0, 0)
            
            test_utils.assert_position_equals(10, 20, 30, mv, "Should return to original position")
        end)
        
        it("should not return to starting position when disabled", function()
            local mv = require("lib.movement")
            mv.X, mv.Y, mv.Z = 10, 20, 30
            
            pickup.setReturnHome(false)
            pickup.spiral(1, 0, 0)
            
            assert.is_false(mv.X == 10 and mv.Y == 20 and mv.Z == 30)
        end)
    end)
    
    describe("Collection Function Integration", function()
        it("should call collection function at each position", function()
            local call_count = 0
            local positions_called = {}
            
            pickup.setCollectionFunction(function()
                call_count = call_count + 1
                local mv = require("lib.movement")
                table.insert(positions_called, {mv.X, mv.Y})
            end)
            
            local positions = pickup.grid(2, 2, 0, 0)
            
            assert.equals(4, call_count)
            assert.equals(4, #positions_called)
        end)
        
        it("should use default collection function when none set", function()
            pickup.setCollectionFunction(nil)
            
            local positions = pickup.spiral(1, 0, 0)
            
            assert.equals(9, #positions)
        end)
    end)
end)