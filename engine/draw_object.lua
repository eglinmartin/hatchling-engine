local Class = require("engine.lib.class")
local peachy = require("engine.lib.peachy")

local DrawObject = Class{}


function DrawObject:init(name, sprite, x, y, scale, rot, depth)
    self.name = name
    self.sprite = sprite
    self.depth = depth
    
    self.x = x
    self.y = y
    self.scale = scale
    self.rot = rot * (math.pi / 180)
end


function DrawObject:move(x, y)
    self.x = x
    self.y = y
end


function DrawObject:resize(scale)
    self.scale = scale
end


function DrawObject:rotate(rot)
    self.rot = rot * (math.pi / 180)
end


function DrawObject:change_sprite(sprite_name, sprite_tag)
    self.sprite = peachy.new(
        "bin/json/" .. sprite_name .. ".json",
        love.graphics.newImage("bin/sprites/" .. sprite_name .. ".png"),
        sprite_tag
    )
end


function DrawObject:update(dt)
    self.sprite:update(dt)
end


return DrawObject
