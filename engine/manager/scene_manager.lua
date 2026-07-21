local Class = require("engine.lib.class")
local Entity = require("engine.class.entity")
local SceneManager = Class{}


function SceneManager:init(engine, game)
    self.engine = engine
    self.game = game

    self.global_entities = {}
    self.scenes = {}
    self.current_scene = nil
end


function SceneManager:add_scene(name, scene)
    self.scenes[name] = scene
end


function SceneManager:create_entity(id, args, scope)
    local entities_handler = self.current_scene.entities
    if scope == 'global' then
        entities_handler = self.global_entities
    end

    entities_handler = entities_handler or {}
    for _, e in ipairs(entities_handler) do
        if e.id == id then
            return
        end
    end
    entities_handler[id] = Entity(self.current_scene, id, args)
end


function SceneManager:register_entity(id, entity, scope)
    local entities_handler = self.current_scene.entities
    if scope == 'global' then
        entities_handler = self.global_entities
    end
    entities_handler[id] = entity
end


function SceneManager:remove_entity(id, scope)
    local entities_handler = self.current_scene.entities
    if scope == 'global' then
        entities_handler = self.global_entities
    end
    entities_handler[id] = nil
end


function SceneManager:switch_scene(name)
    local scene = self.scenes[name]
    if not scene then
        error("SceneManager:switch_scene - no scene registered under name '" .. tostring(name) .. "'")
    end

    if self.current_scene and self.current_scene.exit then
        self.current_scene:exit()
    end

    self.current_scene = scene
    if self.current_scene.enter then
        self.current_scene:enter()
    end

    for _, entity in pairs(self.global_entities) do
        entity:create_sprite()
    end
end


function SceneManager:update(dt, mx, my, md, mp)
    if self.current_scene and self.current_scene.update then
        self.current_scene:update(dt, mx, my, md, mp)
    end
    
    for _, entity in pairs(self.global_entities) do
        entity:update(dt, mx, my, md, mp)
    end
end


function SceneManager:create_keybind(owner, key, event)
    self.engine.event_manager:add_event(event)
    self.engine.input_manager:add_keybind(key, self.engine.event_manager.events[event], owner)
end



function SceneManager:draw()
    if self.current_scene and self.current_scene.draw then
        self.current_scene:draw()
    end
end


return SceneManager
