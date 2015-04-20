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

local Button = require('src.ui.Button');

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

    local scrollOffset = 0;
    local scrollSpeed = 20;
    local buttonW = 200;
    local buttonH = 40;
    local listLength = 0;

    -- ------------------------------------------------
    -- Public Functions
    -- ------------------------------------------------

    function self:init(logList)
        buttons = {};
        for i, log in ipairs(logList) do
            buttons[#buttons + 1] = Button.new(log.name, offsetX, offsetY + (i - 1) * (buttonH) + margin * (i - 1), buttonW, buttonH);
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
        local mx, my = love.mouse.getPosition();
        for _, button in ipairs(buttons) do
            button:setOffset(0, scrollOffset);
            button:update(dt, mx, my);
        end
    end

    function self:scroll(mx, my, scrollFactor)
        -- Deactivate scrolling if the list is smaller than the screen.
        if listLength < love.graphics.getHeight() - offsetY * 2 then
            return;
        end

        if offsetX < mx and offsetX + buttonW > mx then
            scrollOffset = scrollOffset + scrollFactor;

            if scrollOffset >= 0 then
                -- Stop at top of the list.
                scrollOffset = 0;
            elseif (scrollOffset + listLength) <= (love.graphics.getHeight() - offsetY * 2 - buttonH) then
                -- Stop at bottom of the list.
                scrollOffset = love.graphics.getHeight() - offsetY * 2 - buttonH - listLength;
            end
        end
    end

    function self:pressed(x, y, b)
        if b == 'wu' then
            self:scroll(x, y, -scrollSpeed);
        elseif b == 'wd' then
            self:scroll(x, y, scrollSpeed);
        elseif b == 'l' then
            for _, button in ipairs(buttons) do
                if button:hasFocus() then
                    print('Select log: ' .. button:getId());
                    return button:getId();
                end
            end
        end
    end

    function self:getButtonWidth()
        return buttonW;
    end

    return self;
end

return ButtonList;
