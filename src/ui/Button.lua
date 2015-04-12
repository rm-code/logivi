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

local Button = {};

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local LABEL_FONT = love.graphics.newFont('res/fonts/SourceCodePro-Medium.otf', 20);
local DEFAULT_FONT = love.graphics.newFont(12);

-- ------------------------------------------------
-- Constructor
-- ------------------------------------------------

function Button.new(id, x, y, w, h)
    local self = {};

    local focus;
    local col = { 100, 100, 100, 100 };
    local hlcol = { 150, 150, 150, 150 };

    local offsetY = y;

    -- ------------------------------------------------
    -- Private Functions
    -- ------------------------------------------------

    function self:draw(scrollOffset)
        love.graphics.setFont(LABEL_FONT);
        love.graphics.setColor(focus and hlcol or col);
        love.graphics.rectangle('fill', x, offsetY, w, h);
        love.graphics.setColor(255, 255, 255, 100);
        love.graphics.rectangle('line', x, offsetY, w, h);
        love.graphics.print(id, x + 10, offsetY + 10);
        love.graphics.setFont(DEFAULT_FONT);
    end

    function self:update(dt, mx, my)
        focus = x < mx and x + w > mx and offsetY < my and offsetY + h > my;
    end

    -- ------------------------------------------------
    -- Getters
    -- ------------------------------------------------

    function self:getId()
        return id;
    end

    function self:hasFocus()
        return focus;
    end

    -- ------------------------------------------------
    -- Setters
    -- ------------------------------------------------

    function self:setScrollOffset(noy)
        offsetY = y + noy;
    end

    return self;
end

return Button;