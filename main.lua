local Game = require("src.game")

local game

function love.load()
    love.graphics.setBackgroundColor(0.12, 0.15, 0.18)
    love.math.setRandomSeed(os.time())
    game = Game.new()
end

function love.update(dt)
    game:update(dt)
end

function love.draw()
    game:draw()
end

function love.mousepressed(x, y, button)
    if button == 1 then
        game:onMousePressed(x, y)
    end
end

function love.keypressed(key)
    if key == "escape" then
        love.event.quit()
    else
        game:onKeyPressed(key)
    end
end
