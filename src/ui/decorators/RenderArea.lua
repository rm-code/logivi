--==================================================================================================
-- Copyright (C) 2015 by Robert Machmer                                                            =
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

local BaseDecorator = require('src.ui.decorators.BaseDecorator');

local RenderArea = {};

---
-- @param t - The class table.
-- @param render - A function which receives the position from the scroll panel when it is called.
-- @param x - The position of the decorator on the x-axis relative to its parent.
-- @param y - The position of the decorator on the y-axis relative to its parent.
-- @param w - The width of the decorator. Determines the wrap limit for the rendered text.
-- @param h - The height of the decorator. Determines the scissor area of the decorator.
-- @param fixedW - Determines wether to lock the width of the decorator or not.
-- @param fixedH - Determines wether to lock the height of the decorator or not.
-- @param fixedPosX - Determines wether to lock the position of the decorator or not.
-- @param fixedPosY - Determines wether to lock the position of the decorator or not.
--
local function new(t, render, update, x, y, w, h, fixedW, fixedH, fixedPosX, fixedPosY)
    local self = BaseDecorator();

    local ox, oy = 0, 0;
    local minX, maxX, minY, maxY;

    function self:draw()
        self.child:draw();
        local px, py = self:getPosition();
        local pw, ph = self:getDimensions();
        love.graphics.setScissor(px + x, py + y, pw + w, ph + h);
        render(px + x + ox, py + y + oy);
        love.graphics.setScissor();
    end

    function self:update(dt)
        self.child:update(dt);
        minX, maxX, minY, maxY = update(dt);
    end

    function self:getContentOffset()
        return ox, oy;
    end

    function self:setContentOffset(nox, noy)
        ox, oy = nox, noy;

        local px, py = self:getPosition();
        local pw, ph = self:getDimensions();

        -- Deactivate scrolling if the text fits into the panel.
        if minX and maxX and minY and maxY then
            if maxX < pw + w then
                ox = minX;
            elseif px + x + ox + maxX < px + x + pw + w then
                ox = (px + x + pw + w) - (px + x + maxX);
            elseif ox > minX then
                ox = minX;
            end

            if maxY < ph + h then
                oy = minY;
            elseif py + y + oy + maxY < py + y + ph + h then
                oy = (py + y + ph + h) - (py + y + maxY);
            elseif oy > minY then
                oy = minY;
            end
        end
    end

    function self:setDimensions(nw, nh)
        local pw, ph = self:getDimensions();
        if fixedW then w = w + (pw - nw) end
        if fixedH then h = h + (ph - nh) end
        if fixedPosX then x = x - (pw - nw) end
        if fixedPosY then y = y - (ph - nh) end
        self.child:setDimensions(nw, nh);
    end

    return self;
end

return setmetatable(RenderArea, { __call = new });
