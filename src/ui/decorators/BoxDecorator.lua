local BaseDecorator = require('src.ui.decorators.BaseDecorator');

local BoxDecorator = {};

---
-- @param t - The class table.
-- @param mode - The draw mode with which to render the box ('line' or 'fill').
-- @param rgba - The color to use when rendering the box.
-- @param x - The position of the decorator on the x-axis relative to its parent.
-- @param y - The position of the decorator on the y-axis relative to its parent.
-- @param w - The width of the decorator relative to its parent.
-- @param h - The height of the decorator relative to its parent.
-- @param fixedW - Determines wether to lock the width of the decorator or not.
-- @param fixedH - Determines wether to lock the height of the decorator or not.
-- @param fixedPosX - Determines wether to lock the position of the decorator or not.
-- @param fixedPosY - Determines wether to lock the position of the decorator or not.
--
local function new(t, mode, rgba, x, y, w, h, fixedW, fixedH, fixedPosX, fixedPosY)
    local self = BaseDecorator();

    function self:draw()
        self.child:draw();
        local px, py = self:getPosition();
        local pw, ph = self:getDimensions();
        love.graphics.setColor(rgba);
        love.graphics.rectangle(mode, px + x, py + y, pw + w, ph + h)
        love.graphics.setColor(255, 255, 255, 255);
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

return setmetatable(BoxDecorator, { __call = new });
