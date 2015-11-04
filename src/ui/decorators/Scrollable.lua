local BaseDecorator = require('src.ui.decorators.BaseDecorator');

local Scrollable = {};

local MAX_VELOCITY = 8;
local SCROLL_SPEED = 2;
local DAMPING = 8;

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

    local scrollVelocity = 0;

    function self:update(dt)
        -- Reduce the scrolling velocity over time.
        if scrollVelocity < -0.5 then
            scrollVelocity = scrollVelocity + dt * DAMPING;
        elseif scrollVelocity > 0.5 then
            scrollVelocity = scrollVelocity - dt * DAMPING;
        else
            scrollVelocity = 0;
        end

        -- Clamp velocity to prevent too fast scrolling.
        scrollVelocity = math.max(-MAX_VELOCITY, math.min(scrollVelocity, MAX_VELOCITY));

        -- Update the position of the scrolled content.
        local ox, oy = self.child:getContentOffset();
        self.child:setContentOffset(ox, oy + scrollVelocity);

        self.child:update(dt);
    end

    function self:wheelmoved(x, y)
        local mx, my = love.mouse.getPosition();
        local px, py = self:getPosition();
        local pw, ph = self:getDimensions();

        -- Check if the mousepointer is over the scroll panel before applying scroll.
        if px + x < mx and px + x + pw + w > mx and py + y < my and py + y + ph + h > my then
            if y < 0 then
                scrollVelocity = scrollVelocity > 0 and 0 or scrollVelocity;
                scrollVelocity = scrollVelocity - SCROLL_SPEED;
            elseif y > 0 then
                scrollVelocity = scrollVelocity < 0 and 0 or scrollVelocity;
                scrollVelocity = scrollVelocity + SCROLL_SPEED;
            end
        end

        self.child:wheelmoved(mx, my, b);
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

return setmetatable(Scrollable, { __call = new });
