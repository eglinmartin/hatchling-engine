local Class = require("engine.lib.class")
local Scene = require("engine.class.scene")

local SplashScene = Class{__includes = Scene}


function SplashScene:init(game, engine)
    Scene.init(self, game, engine)
end


function SplashScene:enter()
    Scene.enter(self)
    self:setup_keybinds()
    self:setup_events()

    self.engine:add_background("background_splash", "background_splash", "demo", 960, 540, 0, 1, 0)
end


function SplashScene:setup_keybinds()
    self.engine:create_keybind(self, "f2", "SWITCH_SCREEN_DEMO")
end


function SplashScene:setup_events()
    self.engine.event_manager:on(self.engine.event_manager.events["SWITCH_SCREEN_DEMO"], self, function()
        self.engine:switch_scene("DEMO")
    end)
end


return SplashScene

