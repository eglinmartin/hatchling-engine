local Class = require("engine.lib.class")

local TextObject = Class{}


function TextObject:init(name, text, font, colour, x, y, rot, scale, depth, align)
    self.name = name
    self.text = text
    self.font = font
    self.colour = colour
    self.depth = depth
    self.align = align
    
    self.x = x
    self.y = y
    self.rot = rot
    self.scale = scale
end


function TextObject:update(dt)
end


return TextObject
