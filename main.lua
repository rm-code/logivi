local ScreenManager = require('lib/ScreenManager');
local MainScreen = require('src/MainScreen');

function love.load()
    ScreenManager.init(MainScreen.new());
end

function love.draw()
    ScreenManager.draw();
end

function love.update(dt)
    ScreenManager.update(dt);
end

--==================================================================================================
-- Created 01.10.14 - 11:01                                                                        =
--==================================================================================================