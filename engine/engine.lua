local Class = require("engine.lib.class")
local Engine = Class{}

local EventManager = require("engine.event_manager")
local InputManager = require("engine.input_manager")
local RenderManager = require("engine.render_manager")
local SceneManager = require("engine.scene_manager")

local VERSION = 0.1

---@alias RGBA number[] # {r, g, b, a}, each channel 0-1


--- Initialize engine and managers
function Engine:init()
    self.version = VERSION
    self.event_manager = EventManager(self)
    self.input_manager = InputManager(self)
    self.render_manager = RenderManager(self)
    self.scene_manager = SceneManager(self)
end


--- Update all managers in game engine
--- @param dt   number  Time in seconds since the last update
function Engine:update(dt)
    self.input_manager:update(dt)
    self.render_manager:update(dt)
    self.scene_manager:update(dt)
    self.input_manager.mouse_pressed = false
end


--- Add a sprite object to the foreground draw queue in render manager.
---@param sprite_id     string  ID for sprite object used for querying - must be unique
---@param sprite_name   string  Name of sprite png file
---@param sprite_tag    string  Tag of sprite in aseprite json
---@param x             number  X position on screen
---@param y             number  Y position on screen
---@param scale         number  Scale factor
---@param rot           number  Angle of rotation in degrees
---@param depth         number  Draw order depth (255 highest, 0 lowest)
function Engine:add_sprite(sprite_id, sprite_name, sprite_tag, x, y, scale, rot, depth)
    self.render_manager:create_draw_object_foreground(sprite_id, sprite_name, sprite_tag, x, y, scale, rot, depth)
end


--- Add a text object to the foreground draw queue in render manager.
---@param text_id       string      ID for text object used for querying - must be unique
---@param string        string      Text to write on screen
---@param font          love.Font   Font used for text drawing
---@param colour        RGBA        Text colour from colours constants file
---@param x             number      X position on screen
---@param y             number      Y position on screen
---@param scale         number      Scale factor
---@param rot           number      Angle of rotation in degrees
---@param depth         number      Draw order depth (255 highest, 0 lowest)
---@param align         string      Alignment of text - left, centre or right
function Engine:add_text(text_id, string, font, colour, x, y, scale, rot, depth, align)
    self.render_manager:create_text_object(text_id, string, font, colour, x, y, scale, rot, depth, align)
end


--- Add a background object to the draw queue in render manager.
---@param background_id     string  ID for background object used for querying - must be unique
---@param background_name   string  Name of background png file
---@param background_tag    string  Tag of background in aseprite json
---@param x                 number  X position on screen
---@param y                 number  Y position on screen
---@param scale             number  Scale factor
---@param rot               number  Angle of rotation in degrees
---@param depth             number  Draw order depth (255 highest, 0 lowest)
function Engine:add_background(background_id, background_name, background_tag, x, y, scale, rot, depth)
    self.render_manager:create_draw_object_background(background_id, background_name, background_tag, x, y, scale, rot, depth)
end


return Engine
