-- player.lua
local Class = require("engine.lib.class")
local Entity = require("engine.entity")
local flux = require("engine.lib.flux")
local Counter = Class{__includes = Entity}


function Counter:init(scene, x, y)
    self.base_y = y
    Entity.init(self, scene, "counter_moveable", {x=x, y=self.base_y, w=160, h=160, s=1, r=0, sprite_sheet="counters", sprite_tag="blue", depth=155, hoverable=true, draggable=true})

    self.velocity_x = 0
    self.max_speed = 1000
    self.acceleration = 5000

    self.held_left = false
    self.held_right = false

    self.min_x = 1280
    self.max_x = 1600
end


function Counter:move_left()
    self.held_left = true
end


function Counter:move_right()
    self.held_right = true
end


function Counter:update(dt, mx, my, mouse_down, mouse_pressed)
    self:move_on_axis(dt)
    Entity.update(self, dt, mx, my, mouse_down, mouse_pressed)
end


function Counter:move_on_axis(dt)
    if self.held_left and not self.held_right then
        if self.xtween then self.xtween:stop() end
        self.velocity_x = math.max(self.velocity_x - self.acceleration * dt, -self.max_speed)

    elseif self.held_right and not self.held_left then
        if self.xtween then self.xtween:stop() end
        self.velocity_x = math.min(self.velocity_x + self.acceleration * dt, self.max_speed)

    elseif not self.held_left and not self.held_right then
        self.velocity_x = 0
        if self.xtween then self.xtween:stop() end
        self.xtween = flux.to(self, 0.25, {x=1440})
    
    else
        self.velocity_x = 0
    end

    if self.velocity_x ~= 0 then
        local new_x = self.x + self.velocity_x * dt
        new_x = math.max(self.min_x, math.min(self.max_x, new_x))
        if new_x ~= self.x then
            Entity.move(self, new_x, self.y)
        else
            self.velocity_x = 0
        end
    end

    -- reset each frame; move_left/move_right re-set them if the key's still down
    self.held_left = false
    self.held_right = false
end


function Counter:drag()
    Entity.drag(self)

    if self.x < self.min_x then
        self.x = self.min_x
    elseif self.x > self.max_x then
        self.x = self.max_x
    end
    
    self.y = self.base_y
    self.scale = 1

    self:create_sprite()
end


function Counter:draw()
    Entity.draw(self)
end


return Counter
