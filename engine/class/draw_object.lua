local Class = require("engine.lib.class")
local peachy = require("engine.lib.peachy")

local DrawObject = Class{}
local StaticSprite = require("engine.class.sprite_static")


function DrawObject:init(name, sprite, x, y, rot, scale, depth)
    self.name = name
    self.sprite = sprite
    self.depth = depth

    self.x = x
    self.y = y
    self.rot = rot * (math.pi / 180)
    if type(scale) == "table" then
        self.scale_x = scale[1]
        self.scale_y = scale[2]
    else
        self.scale_x = scale
        self.scale_y = scale
    end
    
    self.animation_speed = 0.1
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


function DrawObject:rescale_x(val)
    self.scale_x = val
end

function DrawObject:rescale_y(val)
    self.scale_y = val
end


function DrawObject:change_sprite(sprite_name, sprite_tag, base_path)
    local json_path = base_path .. "json/" .. sprite_name .. ".json"
    local image_path = base_path .. sprite_name .. ".png"

    if love.filesystem.getInfo(json_path) then
        self.sprite = peachy.new(json_path, love.graphics.newImage(image_path), sprite_tag)
    else
        self.sprite = StaticSprite(love.graphics.newImage(image_path))
    end
end


function DrawObject:update(dt)
    self.sprite:update(dt * self.animation_speed)
end


function DrawObject:set_animation_speed(speed)
    self.animation_speed = speed
end


return DrawObject
