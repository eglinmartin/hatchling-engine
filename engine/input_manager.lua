local Class = require("lib.class")
local rs = require("lib.resolution_solution")

local InputManager = Class{}


function InputManager:init(engine)
    self.engine = engine
    self.keybinds = {
        ["f11"] = engine.event_manager.events.TOGGLE_FULLSCREEN,
    }

    self.mx = 0
    self.my = 0

    self.mouse_down = false
    self.mouse_pressed = false
    self.mouse_released = false

    self.keys_down = {}
    self.keys_pressed = {}
    self.keys_released = {}
end


function InputManager:update(dt)
    local raw_mx, raw_my = love.mouse.getPosition()
    self.mx, self.my = rs.to_game(raw_mx, raw_my)
    self.mouse_down = love.mouse.isDown(1)

    -- self.mouse_pressed = false
    self.mouse_released = false
    self.keys_pressed = {}
    self.keys_released = {}
end


function InputManager:keypressed(key)
    local event = self.keybinds[key]
    if event then
        self.engine.event_manager:trigger(event)
    end
end


function InputManager:mousepressed(x, y, button)
    if button == 1 then
        self.mouse_pressed = true
        -- self.engine.event_manager:trigger(self.engine.event_manager.events.MOUSEPRESSED, x, y)
    end
end


function InputManager:mousereleased(x, y, button)
    if button == 1 then
        -- self.engine.event_manager:trigger(self.engine.event_manager.events.MOUSERELEASED, x, y)
    end
end


return InputManager
