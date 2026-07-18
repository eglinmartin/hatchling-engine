local Class = require("engine.lib.class")
local rs = require("engine.lib.resolution_solution")

local InputManager = Class{}


function InputManager:init(engine)
    self.engine = engine
    self.keybinds = {
        ["f11"] = engine.event_manager.events.TOGGLE_FULLSCREEN,
    }
    self.keybinds_by_owner = {}

    self.mx = 0
    self.my = 0

    self.mouse_down = false
    self.mouse_pressed = false
    self.mouse_released = false

    self.keys_down = {}
    self.keys_pressed = {}
    self.keys_released = {}
end


function InputManager:add_keybind(key, action)
    self.keybinds[key] = action
end


function InputManager:update(dt)
    local raw_mx, raw_my = love.mouse.getPosition()
    self.mx, self.my = rs.to_game(raw_mx, raw_my)
    self.mouse_down = love.mouse.isDown(1)

    -- self.mouse_pressed = false
    self.mouse_released = false
    self.keys_pressed = {}
    self.keys_released = {}

    for key, action in pairs(self.keybinds) do
        if love.keyboard.isDown(key) then
            self.engine.event_manager:trigger(action, dt)
        end
    end
end


function InputManager:keypressed(key)
    local event = self.keybinds[key]
    if event then
        self.engine.event_manager:trigger(event)
    end
end


function InputManager:remove_owner(owner)
    for _, key in ipairs(self.keybinds_by_owner[owner] or {}) do
        self:remove_keybind(key)
    end
    self.keybinds_by_owner[owner] = nil
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
