-- engine/class/static_sprite.lua
local Class = require("engine.lib.class")
local StaticSprite = Class{}


function StaticSprite:init(image)
    self.image = image
end


function StaticSprite:update(dt)
end


function StaticSprite:draw(x, y, rot, sx, sy, ox, oy)
    love.graphics.draw(self.image, x, y, rot, sx, sy, ox, oy)
end


function StaticSprite:getWidth()
    return self.image:getWidth()
end


function StaticSprite:getHeight()
    return self.image:getHeight()
end


return StaticSprite