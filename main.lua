local ScreenManager = require('lib/ScreenManager');
local MainScreen = require('src/MainScreen');

function love.load()
    ScreenManager.init(MainScreen.new());
end

function love.draw()
    ScreenManager.draw();

    love.graphics.print(string.format("FT: %.3f ms", 1000 * love.timer.getAverageDelta()), 10, love.window.getHeight() - 60);
    love.graphics.print(string.format("FPS: %.3f fps", love.timer.getFPS()), 10, love.window.getHeight() - 40);
    love.graphics.print(string.format("MEM: %.3f kb", collectgarbage("count")), 10, love.window.getHeight() - 20);
end

function love.update(dt)
    ScreenManager.update(dt);
end

--==================================================================================================
-- Created 01.10.14 - 11:01                                                                        =
--==================================================================================================