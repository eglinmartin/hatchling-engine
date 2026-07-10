-- entity.lua
local Class = require("lib.class")
local flux = require("lib.flux")

local Entity = Class{}


function Entity:init(scene, id, args)
    self.scene = scene
    self.engine = scene.engine
    self.id = id

    if type(args) ~= "table" then return end

    -- Create physical positions
    if args.x then self.x = args.x or 0 end
    if args.y then self.y = args.y or 0 end
    if args.w then self.width = args.w or 0 end
    if args.h then self.height = args.h or 0 end
    if args.s then self.scale = args.s or 1 end
    if args.r then self.rotation = args.r * (math.pi / 180) end

    -- Create theoretical positions
    self.shadow_x = self.x
    self.shadow_y = self.y
    self.original_x = self.x
    self.original_y = self.y
    
    -- Get interaction information
    if args.hoverable then self.hoverable = args.hoverable or false end
    if args.draggable then self.draggable = args.draggable or false end
    if args.clickable then self.clickable = args.clickable or false end

    -- Get sprite information
    if args.sprite_sheet then self.sprite_sheet = args.sprite_sheet end
    if args.sprite_tag then  self.sprite_tag = args.sprite_tag end
    if args.background then self.background = true or false end

    if args.depth then self.original_depth = args.depth or 255 end
    self.depth = self.original_depth

    -- input state
    self.hovered = false
    self.dragging = false
    self.clicked = false
    self.released = false

    if self.sprite_sheet and self.sprite_tag then
        self:create_sprite()
    end

    self.velocity = 0
end


function Entity:move(x, y)
    self.shadow_x = self.x
    self.shadow_y = self.y
    self.x = x
    self.y = y
    self:create_sprite()
end


function Entity:rescale(scale)
    self.scale = scale * (math.pi / 180)
    self:create_sprite()
end


function Entity:rotate(rotation)
    self.rotation = rotation * (math.pi / 180)
    self:create_sprite()
end


function Entity:create_sprite()
    -- Create sprite on screen
    if self.background then
        self.engine.render_manager:create_draw_object_background(
        self.id, self.sprite_sheet, self.sprite_tag, self.x, self.y, self.rotation, self.scale, self.depth
    )
    else
        self.engine.render_manager:create_draw_object_foreground(
            self.id, self.sprite_sheet, self.sprite_tag, self.x, self.y, self.rotation, self.scale, self.depth
        )
    end
end


function Entity:contains_point(mx, my)
    local half_width = self.width / 2
    local half_height = self.height / 2
    return mx > self.x - half_width and mx < self.x + half_width
       and my > self.y - half_height and my < self.y + half_height
end


function Entity:update(dt, mx, my, mouse_down, mouse_pressed)
    -- Update inputs
    self:update_input(dt, mx, my, mouse_down, mouse_pressed)
    self:update_sine_waves(dt)
    
    if self.x ~= self.xprevious or self.y ~= self.yprevious or self.scale ~= self.scaleprevious or self.rotation ~= self.rotationprevious then
        self:create_sprite()
    end

    self.xprevious = self.x
    self.yprevious = self.y
    self.scaleprevious = self.scale
    self.rotationprevious = self.rotation
end


function Entity:drag()
    self.x = self.engine.input_manager.mx
    self.y = self.engine.input_manager.my
    self.depth = 254
    
    love.mouse.setCursor(self.engine.render_manager.cursor_hand)
    self:create_sprite()
end


function Entity:update_input(dt, mx, my, mouse_down, mouse_pressed)
    local is_hovered = self:contains_point(mx, my)
    if is_hovered ~= self.hovered and self.hoverable then
        self.hovered = is_hovered
        if not self.dragging then
            if self.hovered then
                self:on_hover_start()
            else
                if not self.dragging then
                    self:on_hover_end()
                end
            end
        end
    end
    
    local is_clicked = is_hovered and mouse_pressed
    if is_clicked ~= self.clicked then
        self.clicked = is_clicked
        if self.clicked then 
            if self.clickable then
                self:on_click()
            end
        end
    end

    self.released = false

    local is_dragging = self.dragging and mouse_down
        or (is_hovered and mouse_pressed and not self.dragging)

    if is_dragging ~= self.dragging and self.draggable then
        self.dragging = is_dragging

        if self.dragging then
            self:on_drag_start()
        else
            self:on_drag_end()
        end
    end
    if self.dragging then
        self:drag()
    end
end


function Entity:clear_sprite()
    self.render_manager.draw_objects_foreground[self.id] = nil
end


function Entity:on_hover_start()
    flux.to(self, 0.25, {scale=1.1}):ease("expoout")
    love.mouse.setCursor(self.engine.render_manager.cursor_hand)
end


function Entity:on_hover_end()
    flux.to(self, 0.25, {scale=1}):ease("expoout")
    love.mouse.setCursor(self.engine.render_manager.cursor_arrow)
end


function Entity:on_click()
    if self.tween then self.tween:stop() end
    self.scale = 0.95
    local target_scale = self.hovered and 1.1 or 1
    self.tween = flux.to(self, 0.5, {scale=target_scale}):ease("expoout")
    self.scene:trigger(self.id)
end


function Entity:on_drag_start()
    if self.tween then self.tween:stop() end
    if self.x == self.xprevious and self.y == self.yprevious then
        self.original_x = self.x
        self.original_y = self.y
    end
    self.tween = flux.to(self, 0.5, {scale=1.25}):ease("expoout")
end


function Entity:on_drag_end()
    if self.tween then self.tween:stop() end
    self.dragging = false
    self.released = true
    self.release_x = self.x
    self.release_y = self.y

    if not self.hovered then
        love.mouse.setCursor(self.engine.render_manager.cursor_arrow)
    end

    local target_scale = self.hovered and 1.1 or 1
    self.tween = flux.to(self, 0.5, {x=self.original_x, y=self.original_y, scale=target_scale}):ease("expoout"):oncomplete(function() self.depth = self.original_depth end)
end


function Entity:start_sine_wave(var, args)
    args = args or {}
    self.sine_waves = self.sine_waves or {}
    self.sine_waves[var] = {
        origin     = self[var] or 0,
        amplitude  = args.amplitude or 20,
        frequency  = args.frequency or 1,
        phase      = args.phase or 0,
        offset     = args.offset or 0,
        time       = 0,
        paused     = args.paused or false,
    }
end


function Entity:pause_sine_wave(var)
    if not self.sine_waves then return end
    local sw = self.sine_waves[var]
    if sw then sw.paused = true end
end


function Entity:resume_sine_wave(var)
    if not self.sine_waves then return end
    local sw = self.sine_waves[var]
    if sw then sw.paused = false end
end


function Entity:stop_sine_wave(var)
    if not self.sine_waves then return end
    if var then
        self.sine_waves[var] = nil
    else
        self.sine_waves = nil
    end
end


function Entity:update_sine_waves(dt)
    if not self.sine_waves then return end

    for var, sw in pairs(self.sine_waves) do
        if not sw.paused then
            sw.time = sw.time + dt
            self[var] = sw.origin + sw.offset
                + sw.amplitude * math.sin(sw.time * sw.frequency * (2 * math.pi) + sw.phase)
        end
    end
end


return Entity
