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

local BoxDecorator = {};

---
-- Allows to deactivate all public functions inherited from the base decorator.
--
local function new()
    local self = BaseDecorator();

    local active = true;

    function self:draw()
        if not active then return end
        self.child:draw();
    end

    function self:update(dt)
        if not active then return end
        self.child:update(dt);
    end

    function self:intersects(cx, cy)
        if not active then return end
        return self.child:intersects(cx, cy);
    end

    function self:mousemoved(mx, my, dx, dy)
        if not active then return end
        self.child:mousemoved(mx, my, dx, dy);
    end

    function self:mousepressed(mx, my, b)
        if not active then return end
        self.child:mousepressed(mx, my, b);
    end

    function self:mousereleased(mx, my, b)
        if not active then return end
        self.child:mousereleased(mx, my, b);
    end

    function self:setPosition(nx, ny)
        if not active then return end
        self.child:setPosition(nx, ny);
    end

    function self:setDimensions(nw, nh)
        if not active then return end
        self.child:setDimensions(nw, nh)
    end

    function self:getPosition()
        if not active then return end
        return self.child:getPosition();
    end

    function self:getDimensions()
        if not active then return end
        return self.child:getDimensions();
    end

    function self:toggle()
        active = not active;
    end

    function self:setActive(nactive)
        active = nactive;
    end

    function self:isActive()
        return active;
    end

    return self;
end

return setmetatable(BoxDecorator, { __call = new });
