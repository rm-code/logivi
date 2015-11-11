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
