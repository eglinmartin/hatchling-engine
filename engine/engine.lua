local Class = require("lib.class")
local Engine = Class{}

local EventManager = require("engine.event_manager")
local InputManager = require("engine.input_manager")
local RenderManager = require("engine.render_manager")
local SceneManager = require("engine.scene_manager")


function Engine:init()
    self.event_manager = EventManager(self)
    self.input_manager = InputManager(self)
    self.render_manager = RenderManager(self)
    self.scene_manager = SceneManager(self)
end


function Engine:update(dt)
    self.input_manager:update(dt)
    self.render_manager:update(dt)
    self.scene_manager:update(dt)
    self.input_manager.mouse_pressed = false
end


function Engine:keypressed(key)
    self.input_manager:keypressed(key)
end


function Engine:mousepressed(x, y, button)
    self.input_manager:mousepressed(x, y, button)
end


function Engine:mousereleased(x, y, button)
    self.input_manager:mousereleased(x, y, button)
end


function Engine:draw()
    self.render_manager:draw()
end


return Engine
