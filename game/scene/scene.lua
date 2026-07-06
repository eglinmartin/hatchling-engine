local Class = require("lib.class")
local Scene = Class{}


function Scene:init(engine)
    self.engine = engine

    self.engine.scene_manager:add_scene("scene", self)
end


function Scene:enter()
end


function Scene:update()
end


function Scene:trigger()
end


function Scene:exit()
    self.engine.event_manager:remove_owner(self)
end


return Scene
