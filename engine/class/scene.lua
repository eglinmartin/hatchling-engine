local Class = require("engine.lib.class")
local Scene = Class{}


function Scene:init(game, engine)
    self.game = game
    self.engine = engine
    self.entities = {}
end


function Scene:enter()
    self.entities = {}
    
    love.mouse.setCursor(self.engine.render_manager.cursor_arrow)
    self.global_entities = self.engine.scene_manager.global_entities
end


function Scene:update(dt, mx, my, md, mp)
    for _, entity in pairs(self.entities) do
        entity:update(dt, mx, my, md, mp)
    end
end


function Scene:setup_keybinds()
end


function Scene:setup_events()
end


function Scene:trigger(trigger_id)
end


function Scene:exit()
    self.engine.event_manager:remove_owner(self)
    self.engine.input_manager:remove_owner(self)
    self.engine.render_manager:clear_screen()
end


return Scene