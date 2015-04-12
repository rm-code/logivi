--==================================================================================================
-- Copyright (C) 2014 - 2015 by Robert Machmer                                                     =
--                                                                                                 =
-- Permission is hereby granted, free of charge, to any person obtaining a copy                    =
-- of this software and associated documentation files (the "Software"), to deal                   =
-- in the Software without restriction, including without limitation the rights                    =
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell                       =
-- copies of the Software, and to permit persons to whom the Software is                           =
-- furnished to do so, subject to the following conditions:                                        =
--                                                                                                 =
-- The above copyright notice and this permission notice shall be included in                      =
-- all copies or substantial portions of the Software.                                             =
--                                                                                                 =
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR                      =
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,                        =
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE                     =
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER                          =
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,                   =
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN                       =
-- THE SOFTWARE.                                                                                   =
--==================================================================================================

local ScreenManager = require('lib.screenmanager.ScreenManager');
local Screen = require('lib.screenmanager.Screen');
local LogLoader = require('src.logfactory.LogLoader');
local Button = require('src.ui.Button');

local SelectionScreen = {};

function SelectionScreen.new()
    local self = Screen.new();

    local logList;
    local buttons;
    local buttonH = 40;
    local buttonW = 200;
    local margin = 5;

    function self:init()
        -- Intitialise LogLoader.
        logList = LogLoader.init();

        buttons = {};
        for i, log in ipairs(logList) do
            buttons[#buttons + 1] = Button.new(log.name, 20, 20 + (i - 1) * (buttonH) + margin * i, buttonW, buttonH);
        end
    end

    function self:update(dt)
        local mx, my = love.mouse.getPosition();
        for _, button in ipairs(buttons) do
            button:update(dt, mx, my);
        end
    end

    function self:draw()
        for _, button in ipairs(buttons) do
            button:draw();
        end
        love.graphics.print('Work in Progress (v' .. getVersion() .. ')', 20, love.graphics.getHeight() - 30);
    end

    function self:mousepressed(x, y, b)
        for _, button in ipairs(buttons) do
            if button:hasFocus() then
                LogLoader.setActiveLog(button:getId());
                ScreenManager.switch('main');
            end
        end
    end

    return self;
end

return SelectionScreen;
