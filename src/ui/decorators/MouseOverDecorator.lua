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

local BaseDecorator = require('src.ui.decorators.BaseDecorator');

local MouseOverDecorator = {};

function MouseOverDecorator.new(highlightCol, x, y, w, h)
    local self = BaseDecorator.new();

    local mouseOver = true;

    function self:draw()
        self.child:draw();
        if mouseOver then
            local px, py = self:getPosition();
            local pw, ph = self.child:getDimensions();
            love.graphics.setColor(highlightCol);
            love.graphics.rectangle('fill', px + x, py + y, pw + w, ph + h);
            love.graphics.setColor(255, 255, 255, 255);
        end
    end

    function self:update(dt)
        self:intersects(love.mouse.getPosition());
    end

    function self:intersects(cx, cy)
        local px, py = self.child:getPosition();
        local pw, ph = self.child:getDimensions();

        if px + x < cx and px + x + pw + w > cx and py + y < cy and py + y + ph + h > cy then
            mouseOver = true;
            return true;
        else
            mouseOver = false;
            return self.child:intersects(cx, cy);
        end
    end

    return self;
end

return MouseOverDecorator;
