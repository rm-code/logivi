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
local Button = require('src.ui.Button');

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local InfoPanel = {};

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local HEADER_FONT = love.graphics.newFont('res/fonts/SourceCodePro-Bold.otf', 35);
local DEFAULT_FONT = love.graphics.newFont(12);

-- ------------------------------------------------
-- Constructor
-- ------------------------------------------------

function InfoPanel.new(x, y)
    local self = {};

    local info = {};
    local watchButton = Button.new('Watch', love.graphics.getWidth() - 20 - 80 - 5, love.graphics.getHeight() - 85, 80, 40);

    -- ------------------------------------------------
    -- Public Functions
    -- ------------------------------------------------

    function self:update(dt)
        watchButton:update(dt, love.mouse.getPosition());
    end

    function self:draw()
        love.graphics.setColor(100, 100, 100, 100);
        love.graphics.rectangle('fill', x, y, love.graphics.getWidth() - x - 20, love.graphics.getHeight() - y - 40);
        love.graphics.setColor(255, 255, 255, 100);
        love.graphics.rectangle('line', x, y, love.graphics.getWidth() - x - 20, love.graphics.getHeight() - y - 40);
        love.graphics.setFont(HEADER_FONT);
        love.graphics.setColor(0, 0, 0, 100);
        love.graphics.print(info.name, x + 25, y + 25);
        love.graphics.setColor(255, 100, 100, 255);
        love.graphics.print(info.name, x + 20, y + 20);
        love.graphics.setColor(255, 255, 255, 255);
        love.graphics.setFont(DEFAULT_FONT);

        watchButton:draw();
    end

    function self:pressed(x, y, b)
        if b == 'l' then
            if watchButton:hasFocus() then
                ScreenManager.switch('main', { log = info.name });
            end
        end
    end

    function self:resize(nx, ny)
        watchButton:setPosition(nx - 20 - 80 - 5, ny - 85);
    end

    -- ------------------------------------------------
    -- Setters
    -- ------------------------------------------------

    function self:setInfo(name)
        info.name = name or '';
    end

    return self;
end

return InfoPanel;
