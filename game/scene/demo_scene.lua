local Class = require("lib.class")
local Colours = require("game.constants.colours")
local CounterMoveable = require("game.entity.counter_moveable")
local DemoScene = Class{}
local Entity = require("engine.entity")


function DemoScene:init(game, engine)
    self.game = game
    self.engine = engine
    self.entities = {}

    self.engine.scene_manager:create_keybind("MOVE_LEFT", "left", function() self.counter_moveable:move_left() end)
    self.engine.scene_manager:create_keybind("MOVE_LEFT", "a", function() self.counter_moveable:move_left() end)

    self.engine.scene_manager:create_keybind("MOVE_RIGHT", "right", function() self.counter_moveable:move_right() end)
    self.engine.scene_manager:create_keybind("MOVE_RIGHT", "d", function() self.counter_moveable:move_right() end)
end


function DemoScene:enter()
    self.engine.render_manager:create_draw_object_background("background", "background", "demo", 960, 540, 0, 1, 0)
    self.engine.render_manager:create_draw_object_foreground("logo", "logo", "logo", 200, 200, 0, 0.5, 1)
    self.engine.render_manager:create_text_object("text_title", "DEMO", self.game.font_gil_sans_ultra_bold_64, Colours.COLOR43, 360, 60, 0, 1, 2, "left")

    self.counter_draggable = Entity(self, "counter_draggable", {x=960, y=240, w=160, h=160, s=1, r=0, sprite_sheet="counters", sprite_tag="red", depth=155, hoverable=true, draggable=true})
    table.insert(self.entities, self.counter_draggable)
    self.engine.render_manager:create_text_object("text_draggable", "Draggable", self.game.font_gil_sans_ultra_bold_32, Colours.COLOR43, 960, 100, 0, 1, 2, "centre")

    self.counter_clickable = Entity(self, "counter_clickable", {x=1280, y=240, w=160, h=160, s=1, r=0, sprite_sheet="counters", sprite_tag="green", depth=155, hoverable=true, clickable=true})
    table.insert(self.entities, self.counter_clickable)
    self.engine.render_manager:create_text_object("text_clickable", "Clickable", self.game.font_gil_sans_ultra_bold_32, Colours.COLOR43, 1280, 100, 0, 1, 2, "centre")

    self.counter_static = Entity(self, "counter_static", {x=1600, y=240, w=160, h=160, s=1, r=0, sprite_sheet="counters", sprite_tag="black", depth=155})
    table.insert(self.entities, self.counter_static)
    self.engine.render_manager:create_text_object("text_static", "Static", self.game.font_gil_sans_ultra_bold_32, Colours.COLOR43, 1600, 100, 0, 1, 2, "centre")

    self.counter_moveable = CounterMoveable(self, 1440, 580)
    table.insert(self.entities, self.counter_moveable)
    self.engine.render_manager:create_text_object("text_moveable", "Moveable", self.game.font_gil_sans_ultra_bold_32, Colours.COLOR43, 1440, 440, 0, 1, 2, "centre")
    
    self.counter_sine_wave = Entity(self, "counter_sine_wave", {x=1440, y=920, w=160, h=160, s=1, r=0, sprite_sheet="counters", sprite_tag="pink", depth=155, hoverable=true, clickable=true})
    table.insert(self.entities, self.counter_sine_wave)
    self.counter_sine_wave:start_sine_wave('x', {amplitude = 160, frequency = 0.25, paused=true})
    self.engine.render_manager:create_text_object("text_sine_wave", "Static (Sine Wave)", self.game.font_gil_sans_ultra_bold_32, Colours.COLOR43, 1440, 780, 0, 1, 2, "centre")
end


function DemoScene:update(dt, mx, my, md, mp)
    for _, entity in pairs(self.entities) do
        entity:update(dt, mx, my, md, mp)
    end
end


function DemoScene:trigger(trigger_id)
    if trigger_id == "counter_clickable" then
        print('Clicked')
    elseif trigger_id == "counter_sine_wave" then
        if self.counter_sine_wave.sine_waves["x"] and not self.counter_sine_wave.sine_waves["x"].paused then
            self.counter_sine_wave:pause_sine_wave("x")
        else
            self.counter_sine_wave:resume_sine_wave("x")
        end
    end
end


function DemoScene:exit()
    self.engine.event_manager:remove_owner(self)
end


return DemoScene
