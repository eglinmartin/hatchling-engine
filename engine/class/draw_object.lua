local Class = require("engine.lib.class")
local peachy = require("engine.lib.peachy")

local DrawObject = Class{}
local StaticSprite = require("engine.class.sprite_static")


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
    self.sprite:update(dt)
end


return DrawObject
