local BaseDecorator = require('src.ui.decorators.BaseDecorator');

local TextLabel = {};

---
-- @param t - The class table.
-- @param text - The text to display.
-- @param rgba - The color to use when rendering text.
-- @param font - The font to use when rendering text.
-- @param x - The position of the decorator on the x-axis relative to its parent.
-- @param y - The position of the decorator on the y-axis relative to its parent.
-- @param fixedW - Determines wether to lock the width of the decorator or not.
-- @param fixedH - Determines wether to lock the height of the decorator or not.
-- @param fixedPosX - Determines wether to lock the position of the decorator or not.
-- @param fixedPosY - Determines wether to lock the position of the decorator or not.
--
local function new(t, text, rgba, font, x, y, fixedPosX, fixedPosY)
    local self = BaseDecorator();

    function self:draw()
        self.child:draw();
        local px, py = self:getPosition();
        love.graphics.setFont(font);
        love.graphics.setColor(rgba);
        love.graphics.print(text, px + x, py + y);
        love.graphics.setColor(255, 255, 255, 255);
    end

    function self:setDimensions(nw, nh)
        local pw, ph = self:getDimensions();
        if fixedPosX then x = x - (pw - nw) end
        if fixedPosY then y = y - (ph - nh) end
        self.child:setDimensions(nw, nh);
    end

    return self;
end

return setmetatable(TextLabel, { __call = new });
