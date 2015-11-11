local BaseDecorator = require('src.ui.decorators.BaseDecorator');

local Resizable = {};

---
-- @param t - The class table.
-- @param x - The position of the decorator on the x-axis relative to its parent.
-- @param y - The position of the decorator on the y-axis relative to its parent.
-- @param w - The width of the decorator relative to its parent.
-- @param h - The height of the decorator relative to its parent.
-- @param fixedW - Determines wether to lock the width of the decorator or not.
-- @param fixedH - Determines wether to lock the height of the decorator or not.
-- @param fixedPosX - Determines wether to lock the position of the decorator or not.
-- @param fixedPosY - Determines wether to lock the position of the decorator or not.
--
local function new(t, x, y, w, h, fixedW, fixedH, fixedPosX, fixedPosY)
    local self = BaseDecorator();

    local resize = false;

    function self:mousepressed(mx, my, b)
        local px, py = self:getPosition();
        local pw, ph = self:getDimensions();
        if b == 1 and px + x < mx and px + x + pw + w > mx and py + y < my and py + y + ph + h > my then
            resize = true;
            return;
        end
        self.child:mousepressed(mx, my, b);
    end

    function self:mousereleased(mx, my, b)
        resize = false;
        self.child:mousereleased(mx, my, b);
    end

    function self:mousemoved(mx, my, dx, dy)
        local px, py = self:getPosition();

        if resize then
            local px, py = self:getPosition();
            local pw, ph = self:getDimensions();
            local w, h = mx - px, my - py;
            self:setDimensions(w, h);
        else
            self.child:mousemoved(mx, my, dx, dy)
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

return setmetatable(Resizable, { __call = new });
