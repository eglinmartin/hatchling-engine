local Class = require("engine.lib.class")
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
