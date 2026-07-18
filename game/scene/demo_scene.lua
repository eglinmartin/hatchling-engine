local Class = require("engine.lib.class")
local Colours = require("game.constants.colours")
local CounterMoveable = require("game.entity.counter_moveable")
local Scene = require("engine.class.scene")

local DemoScene = Class{__includes = Scene}


function DemoScene:init(game, engine)
    Scene.init(self, game, engine)
end


function DemoScene:enter()
    Scene.enter(self)
    self:setup_keybinds()
    self:setup_events()

    self.engine:add_background("background", "background", "demo", 960, 540, 0, 1, 0)
    self.engine:add_text("text_version", "v" .. tostring(self.engine.version), self.game.font_gil_sans_ultra_bold_32, Colours.COLOR45, 1890, 1010, 0, 1, 2, "right")

    self.engine:create_entity("counter_draggable", {x=960, y=240, w=160, h=160, s=1, r=0, sprite_sheet="counters", sprite_tag="red", depth=155, hoverable=true, draggable=true, clickable=true})
    self.engine:create_entity("counter_clickable", {x=1280, y=240, w=160, h=160, s=1, r=0, sprite_sheet="counters", sprite_tag="green", depth=155, hoverable=true, clickable=true})
    self.engine:create_global_entity("counter_static", {x=1600, y=240, w=160, h=160, s=1, r=0, sprite_sheet="counters", sprite_tag="black", depth=155})
    
    self.counter_moveable = CounterMoveable(self, 1440, 580)

    self.engine:create_entity("counter_sine_wave", {x=1440, y=920, w=160, h=160, s=1, r=0, sprite_sheet="counters", sprite_tag="pink", depth=155, hoverable=true, clickable=true})
    self.counter_sine_wave = self.entities["counter_sine_wave"]
    self.counter_sine_wave:set_sine_wave('x', {amplitude = 160, frequency = 0.25})
end


function DemoScene:trigger(trigger_id)
    if trigger_id == "counter_clickable" then
        print('Clicked')
    elseif trigger_id == "counter_sine_wave" then
        if self.counter_sine_wave.sine_waves["x"] and not self.counter_sine_wave.sine_waves["x"].paused then
            self.counter_sine_wave:stop_sine_wave("x")
        else
            self.counter_sine_wave:start_sine_wave("x")
        end
    end
end


function DemoScene:setup_events()
    self.engine.event_manager:on(self.engine.event_manager.events["MOVE_LEFT"], self, function()
        self.counter_moveable:move_left()
    end)

    self.engine.event_manager:on(self.engine.event_manager.events["MOVE_RIGHT"], self, function()
        self.counter_moveable:move_right()
    end)

    self.engine.event_manager:on(self.engine.event_manager.events["SWITCH_SCREEN_SPLASH"], self, function()
        self.engine:switch_scene("SPLASH")
    end)
end


function DemoScene:setup_keybinds()
    self.engine:create_keybind(self, "left", "MOVE_LEFT")
    self.engine:create_keybind(self, "a", "MOVE_LEFT")
    self.engine:create_keybind(self, "right", "MOVE_RIGHT")
    self.engine:create_keybind(self, "d", "MOVE_RIGHT")
    self.engine:create_keybind(self, "f1", "SWITCH_SCREEN_SPLASH")
end


return DemoScene