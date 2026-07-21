local Class = require("engine.lib.class")
local Engine = Class{}

local EventManager = require("engine.manager.event_manager")
local InputManager = require("engine.manager.input_manager")
local RenderManager = require("engine.manager.render_manager")
local SceneManager = require("engine.manager.scene_manager")

local Entity = require("engine.class.entity")

local VERSION = 0.1

---@alias RGBA number[] # {r, g, b, a}, each channel 0-1
---@alias EventAction string  # One of the values defined in Events (see engine/event_manager.lua)
---@alias Scene string  # One of the values defined in Events (see engine/event_manager.lua)


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
    self.scene_manager:update(dt, self.input_manager.mx, self.input_manager.my, self.input_manager.mouse_down, self.input_manager.mouse_pressed)
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


--- Create a new entity in the current scene
---@param id    string  Unique ID for the entity to be queried
---@param args  table   Table of arguments used to construct the entity
function Engine:create_entity(id, args)
    self.scene_manager:create_entity(id, args, "local")
end


--- Register an existing entity in the current scene
---@param id    string  Unique ID for the entity to be queried
function Engine:register_entity(id, entity)
    self.scene_manager:register_entity(id, entity, "local")
end


--- Remove an existing entity from the current scene
---@param id    string  Entity ID
function Engine:remove_entity(id)
    self.scene_manager:remove_global_entity(id, "local")
end


--- Create a new global entity in the scene manager
---@param id    string  Unique ID for the entity to be queried
---@param args  table   Table of arguments used to construct the entity
function Engine:create_global_entity(id, args)
    self.scene_manager:create_entity(id, args, "global")
end


--- Remove an existing global entity from the scene manager
---@param id    string  Unique ID for the entity to be queried
function Engine:register_global_entity(id, entity)
    self.scene_manager:register_entity(id, entity, "global")
end


--- Remove an existing global entity from the scene manager
---@param id    string  Entity ID
function Engine:remove_global_entity(id)
    self.scene_manager:remove_global_entity(id, "global")
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


--- Add a keybind into the current scene
--- @param scene    string          Name of the scene that owns the event
--- @param key      string          Keyboard key to be pressed
--- @param event    EventAction     Event to be triggered
function Engine:create_keybind(scene, key, event)
    self.scene_manager:create_keybind(scene, key, event)
end


--- Add a scene to the game
--- @param name     string  Unique name of scene
--- @param scene    Scene   Scene instance
function Engine:add_scene(name, scene)
    self.scene_manager:add_scene(name, scene)
end


--- Switch game scene
--- @param name     string  Unique name of scene
function Engine:switch_scene(name)
    self.scene_manager:switch_scene(name)
end


return Engine
