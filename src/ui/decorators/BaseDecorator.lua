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

local BaseDecorator = {};

function BaseDecorator.new()
    local self = {
        child = nil;
    };

    function self:draw()
        self.child:draw();
    end

    function self:update(dt)
        self.child:update(dt);
    end

    function self:intersects(cx, cy)
        return self.child:intersects(cx, cy);
    end

    function self:mousemoved(mx, my, dx, dy)
        self.child:mousemoved(mx, my, dx, dy);
    end

    function self:mousepressed(mx, my, b)
        self.child:mousepressed(mx, my, b);
    end

    function self:mousereleased(mx, my, b)
        self.child:mousereleased(mx, my, b);
    end

    function self:attach(nchild)
        if not self.child then
            self.child = nchild;
        else
            self.child:attach(nchild);
        end
    end

    function self:setPosition(nx, ny)
        self.child:setPosition(nx, ny);
    end

    function self:setDimensions(nw, nh)
        self.child:setDimensions(nw, nh)
    end

    function self:getPosition()
        return self.child:getPosition();
    end

    function self:getDimensions()
        return self.child:getDimensions();
    end

    return self;
end

return BaseDecorator;
