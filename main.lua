local flux = require("lib.flux")
local rs = require("lib.resolution_solution")
local Engine = require("engine.engine")
local Game = require("game.game")


if arg and arg[2] == "debug" then
    local ok, dbg = pcall(require, "lldebugger")
    if ok then dbg.start() end
end


function love.load()
    GAME_SIZE = {1920, 1080}
    WINDOW_SIZE = {960, 540}

    rs.conf({game_width = GAME_SIZE[1], game_height = GAME_SIZE[2], pixel_perfect = true})
    rs.setMode(WINDOW_SIZE[1], WINDOW_SIZE[2], {fullscreen = false})

    ENGINE = Engine()
    GAME = Game(ENGINE)
end


function love.update(dt)
    ENGINE:update(dt)
    GAME:update(dt)
    flux.update(dt)
end


function love.draw()
    ENGINE:draw()
end


function love.resize(w, h)
    rs.resize(w, h)
end


function love.keypressed(key)
    ENGINE:keypressed(key)
end


function love.mousepressed(x, y, button)
    ENGINE:mousepressed(x, y, button)
end


function love.mousereleased(x, y, button)
    ENGINE:mousereleased(x, y, button)
end


if lldebugger then
    local love_errorhandler = love.errorhandler
    function love.errorhandler(msg)
        error(msg, 2)
    end
end

