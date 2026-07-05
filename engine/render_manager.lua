local Class = require("lib.class")
local peachy = require("lib.peachy")
local rs = require("lib.resolution_solution")

local Colours = require("game.constants.colours")

local RenderManager = Class{}
local DrawObject = Class{}
local TextObject = Class{}


local shadowShader = love.graphics.newShader([[
    vec4 effect(vec4 color, Image tex, vec2 texCoords, vec2 screenCoords) {
        vec4 pixel = Texel(tex, texCoords);
        if (pixel.a == 0.0) {
            // Keep transparent pixels untouched
            return vec4(0.0, 0.0, 0.0, 0.0);
        }
        // Overwrite non-transparent pixels with outline color
        return vec4(color.rgb, pixel.a);
    }
]])

local Shaders = {
    SHADOW = shadowShader
}


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


function RenderManager:init(engine)
    self.engine = engine
    self:setup_events()
    self.colours = Colours

    -- self.font = love.graphics.newFont("assets/Curtel.ttf", 16)
    -- love.graphics.setFont(self.font)
    
    self.shadow_offset = {1, 1}
    self.shadow_colour = {0, 0, 0, 1}

    self.draw_objects_background = {}
    self.draw_objects_foreground = {}
    self.text_objects = {}
    self.image_cache = {}
end


function RenderManager:get_image(path)
    if not self.image_cache[path] then
        self.image_cache[path] = love.graphics.newImage(path)
    end
    return self.image_cache[path]
end


function RenderManager:setup_events()
    self.engine.event_manager:on(
        self.engine.event_manager.events.TOGGLE_FULLSCREEN, self, function()
            local fs = love.window.getFullscreen()
            if fs then
                rs.setMode(960, 540, {fullscreen = false})
            else
                rs.setMode(1920, 1080, {fullscreen = true})
            end
        end
    )
end


function RenderManager:clear_screen()
    self.draw_objects_background = {}
    self.draw_objects_foreground = {}
    self.text_objects = {}
end


function RenderManager:update(dt)
    for _, draw_object in pairs(self.draw_objects_background) do
       draw_object:update(dt)
    end

    for _, draw_object in pairs(self.draw_objects_foreground) do
       draw_object:update(dt)
    end
    
    for _, text_object in pairs(self.text_objects) do
       text_object:update(dt)
    end
end


function RenderManager:draw()
    rs.push()
    self:draw_background()
    self:draw_foreground()
    rs.pop()
end


function RenderManager:create_draw_object_background(sprite_id, sprite_name, sprite_tag, x, y, scale, rot, depth)
    self.draw_objects_background[sprite_id] =
        DrawObject(
            sprite_id,
            peachy.new(
                "game/bin/background/json/" .. sprite_name .. ".json",
                self:get_image("game/bin/background/" .. sprite_name .. ".png"),
                sprite_tag
            ),
            x, y, rot, scale, depth
        )
end


function RenderManager:create_draw_object_foreground(sprite_id, sprite_name, sprite_tag, x, y, scale, rot, depth)
    self.draw_objects_foreground[sprite_id] =
        DrawObject(
            sprite_id,
            peachy.new(
                "game/bin/sprite/json/" .. sprite_name .. ".json",
                self:get_image("game/bin/sprite/" .. sprite_name .. ".png"),
                sprite_tag
            ),
            x, y, rot, scale, depth
        )
end


function RenderManager:remove_draw_object_foreground(sprite_id)
    self.draw_objects_foreground[sprite_id] = nil
end


function RenderManager:create_text_object(text_id, string, font, colour, x, y, scale, rot, depth, align)
    self.text_objects[text_id] = TextObject(text_id, string, font, colour, x, y, scale, rot, depth, align)
end


function RenderManager:remove_text_object(text_id)
    self.text_objects[text_id] = nil
end


function RenderManager:draw_background()
    for _, draw_obj in pairs(self.draw_objects_background) do
        draw_obj.sprite:draw(
            draw_obj.x,
            draw_obj.y,
            draw_obj.rot,
            draw_obj.scale,
            draw_obj.scale,
            draw_obj.sprite:getWidth() / 2,
            draw_obj.sprite:getHeight() / 2
        )
    end
end


function RenderManager:draw_foreground()
    -- Build a unified depth-sorted list of all renderable objects
    local render_list = {}
    for _, obj in pairs(self.draw_objects_foreground) do
        table.insert(render_list, { type = "sprite", obj = obj })
    end
    for _, obj in pairs(self.text_objects) do
        table.insert(render_list, { type = "text", obj = obj })
    end
    table.sort(render_list, function(a, b)
        return a.obj.depth < b.obj.depth
    end)

    -- Draw shadows
    for _, entry in ipairs(render_list) do
        if entry.type == "sprite" then
            local draw_obj = entry.obj
            self:draw_shadow(
                draw_obj.sprite,
                draw_obj.x,
                draw_obj.y,
                draw_obj.rot,
                draw_obj.scale,
                draw_obj.sprite:getWidth() / 2,
                draw_obj.sprite:getHeight() / 2
            )
        end
    end

    -- Draw sprites and text interweaved, sorted by depth
    for _, entry in ipairs(render_list) do
        if entry.type == "sprite" then
            local draw_obj = entry.obj
            love.graphics.setColor(1, 1, 1, 1)
            draw_obj.sprite:draw(
                draw_obj.x,
                draw_obj.y,
                draw_obj.rot,
                draw_obj.scale,
                draw_obj.scale,
                draw_obj.sprite:getWidth() / 2,
                draw_obj.sprite:getHeight() / 2
            )

        elseif entry.type == "text" then
            local text_obj = entry.obj
            local text_scale = text_obj.scale
            
            love.graphics.setFont(text_obj.font)
            love.graphics.setColor(self.shadow_colour)
            local shadow_offsets = {{2, 0}, {2, 1}, {2, 2}, {1, 2}, {0, 2}}
            for i = 1, #shadow_offsets do
                local ox = shadow_offsets[i][1] * text_scale
                local oy = shadow_offsets[i][2] * text_scale - 6
                self:draw_characters(text_obj.text, text_obj.x + ox, text_obj.y + oy, text_scale, text_obj.align, text_obj.font)
            end

            love.graphics.setColor({0, 0, 0})
            local outline_offsets = {{1, 0}, {1, 1}, {0, 1}, {-1, 1}, {-1, 0}, {-1, -1}, {0, -1}, {1, -1}}
            for i = 1, #outline_offsets do
                local ox = outline_offsets[i][1] * text_scale
                local oy = outline_offsets[i][2] * text_scale
                self:draw_characters(text_obj.text, text_obj.x + ox, text_obj.y + oy - 6, text_scale, text_obj.align, text_obj.font)
            end

            love.graphics.setColor(text_obj.colour)
            self:draw_characters(text_obj.text, text_obj.x, text_obj.y - 6, text_scale, text_obj.align, text_obj.font)
        end
    end

    love.graphics.setColor(1, 1, 1, 1)
end


function RenderManager:draw_characters(text, x, y, scale, align, font)
    if align ~= 'left' then
        local totalWidth = 0
        for i = 1, #text do
            local char = text:sub(i, i)
            totalWidth = totalWidth + font:getWidth(char) * scale
        end
        if align == 'centre' then
            x = x - totalWidth / 2
        elseif align == 'right' then
            x = x - totalWidth
        end
    end

    for i = 1, #text do
        local char = text:sub(i, i)
        love.graphics.print(char, x, y, 0, scale, scale)
        x = x + font:getWidth(char) * scale
    end
end


function RenderManager:set_shadow_colour(colour)
    self.shadow_colour = colour
end


function RenderManager:draw_shadow(anim, x, y, rot, scale, ox, oy)
    love.graphics.setShader(Shaders["SHADOW"])
    love.graphics.setColor(self.shadow_colour)
    anim:draw(x + self.shadow_offset[1], y + self.shadow_offset[2], rot, scale, scale, ox, oy)
    love.graphics.setShader()
    love.graphics.setColor(1, 1, 1, 1)
end


return RenderManager
