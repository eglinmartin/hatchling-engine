local Class = require("engine.lib.class")
local Game = Class{}
local DemoScene = require("game.scene.demo_scene")
local SplashScene = require("game.scene.splash_scene")


function Game:init(engine)
    self.engine = engine

    self:load_fonts()
    self.engine.render_manager.shadow_offset = {8, 8}
    self.engine.render_manager.shadow_colour = {9/255, 10/255, 20/255}
    
    self.engine:add_scene("SPLASH", SplashScene(self, self.engine))
    self.engine:add_scene("DEMO", DemoScene(self, self.engine))
    self.engine:switch_scene("SPLASH")
end


function Game:load_fonts()
    self.font_gil_sans_ultra_bold_32 = love.graphics.newFont("game/font/GILSANUB.TTF", 32)
    self.font_gil_sans_ultra_bold_64 = love.graphics.newFont("game/font/GILSANUB.TTF", 64)
end


function Game:update(dt)
end


return Game
