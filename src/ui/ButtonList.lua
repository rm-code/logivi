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

local Button = require('src.ui.components.Button');
local SelectItemCommand = require('src.ui.commands.SelectItemCommand');

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local ButtonList = {};

-- ------------------------------------------------
-- Constructor
-- ------------------------------------------------

function ButtonList.new(offsetX, offsetY, margin)
    local self = {};

    local buttons;

    local scrollSpeed = 20;
    local buttonW = 200;
    local buttonH = 40;
    local listLength = 0;

    -- ------------------------------------------------
    -- Public Functions
    -- ------------------------------------------------

    function self:init(screen, logList)
        buttons = {};
        for i, log in ipairs(logList) do
            buttons[#buttons + 1] = Button.new(SelectItemCommand.new(screen, log.name),
                log.name, offsetX, offsetY + (i - 1) * (buttonH) + margin * (i - 1), buttonW, buttonH);
        end

        listLength = listLength + offsetY + (#buttons - 1) * (buttonH) + margin * (#buttons - 1);
    end

    function self:draw()
        love.graphics.setScissor(offsetX, offsetY, buttonW, love.graphics.getHeight() - offsetY * 3);
        for _, button in ipairs(buttons) do
            button:draw(scrollOffset);
        end
        love.graphics.setScissor();
    end

    function self:update(dt)
        for _, button in ipairs(buttons) do
            button:update(dt);
        end
    end

    function self:scroll(mx, my, scrollOffset)
        -- Deactivate scrolling if the list is smaller than the screen
        if listLength < love.graphics.getHeight() - offsetY * 2 then
            return;
        end

        for _, button in ipairs(buttons) do
            local px, py = button:getPosition();
            button:setPosition(px, py + scrollOffset);
        end
    end

    function self:mousepressed(x, y, b)
        for _, button in ipairs(buttons) do
            button:mousepressed(x, y, b);
        end
    end

    function self:wheelmoved(x, y)
        if offsetX < love.mouse.getX() and offsetX + buttonW > love.mouse.getX() then
            if y < 0 then
                self:scroll(x, y, scrollSpeed);
            else
                self:scroll(x, y, -scrollSpeed);
            end
        end
    end

    function self:getButtonWidth()
        return buttonW;
    end

    return self;
end

return ButtonList;
