local Class = require("lib.class")
local Colours = require("game.constants.colours")
local DemoScene = Class{}
local Entity = require("engine.entity")


function DemoScene:init(game, engine)
    self.game = game
    self.engine = engine
    self.entities = {}
    self.entities["player"] = self.player
end


function DemoScene:enter()
    self.engine.render_manager:create_draw_object_background("background", "background", "demo", 960, 540, 0, 1, 0)
    self.engine.render_manager:create_draw_object_foreground("logo", "logo", "logo", 200, 200, 0, 0.5, 1)
    self.engine.render_manager:create_text_object("text_title", "DEMO", self.game.font_gil_sans_ultra_bold_64, Colours.COLOR43, 360, 60, 0, 1, 2, "left")

    self.counter_draggable = Entity(self, "counter_draggable", {x=960, y=240, w=128, h=128, s=1, r=0, sprite_sheet="counters", sprite_tag="red", depth=155, hoverable=true, draggable=true})
    table.insert(self.entities, self.counter_draggable)
    self.engine.render_manager:create_text_object("text_draggable", "Draggable", self.game.font_gil_sans_ultra_bold_32, Colours.COLOR43, 960, 100, 0, 1, 2, "centre")
end


function DemoScene:update(dt, mx, my, md, mp)
    for _, entity in pairs(self.entities) do
        entity:update(dt, mx, my, md, mp)
    end
end


function DemoScene:exit()
    self.engine.event_manager:remove_owner(self)
end


return DemoScene
