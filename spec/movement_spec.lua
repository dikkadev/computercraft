local test_utils = require("test.helpers.test_utils")

describe("Movement Library", function()
    local movement
    local mock_turtle, mock_os
    
    before_each(function()
        mock_turtle, mock_os = test_utils.setup_mocks()
        movement = require("lib.movement")
    end)
    
    describe("Basic Movement", function()
        it("should update X coordinate when moving forward facing FW", function()
            movement.heading = movement.HEAD.FW
            movement.forward()
            assert.equals(1, movement.X)
            assert.equals(0, movement.Y)
        end)
        
        it("should update Y coordinate when moving forward facing RI", function()
            movement.heading = movement.HEAD.RI
            movement.forward()
            assert.equals(0, movement.X)
            assert.equals(1, movement.Y)
        end)
        
        it("should update coordinates correctly when moving back", function()
            movement.X = 5
            movement.Y = 3
            movement.heading = movement.HEAD.FW
            movement.back()
            assert.equals(4, movement.X)
            assert.equals(3, movement.Y)
        end)
        
        it("should update Z coordinate when moving up", function()
            movement.up()
            assert.equals(1, movement.Z)
        end)
        
        it("should update Z coordinate when moving down", function()
            movement.Z = 5
            movement.down()
            assert.equals(4, movement.Z)
        end)
    end)
    
    describe("Turning", function()
        it("should update heading when turning left", function()
            movement.heading = movement.HEAD.FW
            movement.tLeft()
            assert.equals(movement.HEAD.LE, movement.heading)
        end)
        
        it("should update heading when turning right", function()
            movement.heading = movement.HEAD.FW
            movement.tRight()
            assert.equals(movement.HEAD.RI, movement.heading)
        end)
        
        it("should wrap heading correctly when turning left from FW", function()
            movement.heading = movement.HEAD.FW
            movement.tLeft()
            assert.equals(movement.HEAD.LE, movement.heading)
        end)
        
        it("should wrap heading correctly when turning right from BK", function()
            movement.heading = movement.HEAD.BK
            movement.tRight()
            assert.equals(movement.HEAD.LE, movement.heading)
        end)
    end)
    
    describe("turnTo Function", function()
        it("should turn left when going from FW to LE", function()
            movement.heading = movement.HEAD.FW
            movement.turnTo(movement.HEAD.LE)
            assert.equals(movement.HEAD.LE, movement.heading)
        end)
        
        it("should turn right when going from FW to RI", function()
            movement.heading = movement.HEAD.FW
            movement.turnTo(movement.HEAD.RI)
            assert.equals(movement.HEAD.RI, movement.heading)
        end)
        
        it("should turn around when going from FW to BK", function()
            movement.heading = movement.HEAD.FW
            movement.turnTo(movement.HEAD.BK)
            assert.equals(movement.HEAD.BK, movement.heading)
        end)
        
        it("should not turn when already facing correct direction", function()
            movement.heading = movement.HEAD.RI
            movement.turnTo(movement.HEAD.RI)
            assert.equals(movement.HEAD.RI, movement.heading)
        end)
    end)
    
    describe("Pathfinding (go function)", function()
        it("should move to positive X coordinate", function()
            movement.go(3, 0, 0)
            test_utils.assert_position_equals(3, 0, 0, movement)
        end)
        
        it("should move to negative X coordinate", function()
            movement.X = 5
            movement.go(2, 0, 0)
            test_utils.assert_position_equals(2, 0, 0, movement)
        end)
        
        it("should move to positive Y coordinate", function()
            movement.go(0, 3, 0)
            test_utils.assert_position_equals(0, 3, 0, movement)
        end)
        
        it("should move to negative Y coordinate", function()
            movement.Y = 5
            movement.go(0, 2, 0)
            test_utils.assert_position_equals(0, 2, 0, movement)
        end)
        
        it("should move up to positive Z coordinate", function()
            movement.go(0, 0, 3)
            test_utils.assert_position_equals(0, 0, 3, movement)
        end)
        
        it("should move down to lower Z coordinate (bug fix test)", function()
            movement.Z = 5
            movement.go(0, 0, 2)
            test_utils.assert_position_equals(0, 0, 2, movement)
        end)
        
        it("should handle complex 3D movement", function()
            movement.go(3, -2, 4)
            test_utils.assert_position_equals(3, -2, 4, movement)
        end)
        
        it("should face forward after reaching destination", function()
            movement.go(5, 5, 5)
            assert.equals(movement.HEAD.FW, movement.heading)
        end)
    end)
    
    describe("Obstacle Handling", function()
        it("should dig through obstacles when moving forward", function()
            local world = test_utils.create_test_world()
            world.set_block(1, 0, 0, "stone")
            
            movement.go(2, 0, 0)
            test_utils.assert_position_equals(2, 0, 0, movement)
        end)
        
        it("should dig through obstacles when moving up", function()
            local world = test_utils.create_test_world()
            world.set_block(0, 0, 1, "stone")
            
            movement.go(0, 0, 2)
            test_utils.assert_position_equals(0, 0, 2, movement)
        end)
        
        it("should dig through obstacles when moving down", function()
            movement.Z = 5
            local world = test_utils.create_test_world()
            world.set_block(0, 0, 2, "stone")
            
            movement.go(0, 0, 1)
            test_utils.assert_position_equals(0, 0, 1, movement)
        end)
    end)
    
    describe("Utility Functions", function()
        it("should go to origin with go0", function()
            movement.X = 10
            movement.Y = -5
            movement.Z = 3
            movement.go0()
            test_utils.assert_position_equals(0, 0, 0, movement)
        end)
        
        it("should provide debug information", function()
            movement.X = 5
            movement.Y = -2
            movement.Z = 3
            movement.heading = movement.HEAD.RI
            
            local output = {}
            local original_print = print
            print = function(msg) table.insert(output, msg) end
            
            movement.debug()
            
            print = original_print
            
            assert.is_true(#output >= 2)
            assert.is_true(string.find(output[1], "5"))
            assert.is_true(string.find(output[1], "-2"))
            assert.is_true(string.find(output[1], "3"))
            assert.is_true(string.find(output[2], "RI"))
        end)
    end)
end)