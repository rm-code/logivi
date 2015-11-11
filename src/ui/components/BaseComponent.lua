local BaseComponent = {};

local function new(t, x, y, w, h)
    local self = {};

    function self:draw()
        return;
    end

    function self:update(dt)
        return;
    end

    function self:intersects(cx, cy)
        if x < cx and x + w > cx and y < cy and y + h > cy then
            return true;
        end
    end

    function self:mousemoved(mx, my, dx, dy)
        return;
    end

    function self:mousepressed(mx, my, b)
        return;
    end

    function self:mousereleased(mx, my, b)
        return;
    end

    function self:wheelmoved(x, y)
        return;
    end

    function self:setPosition(nx, ny)
        x, y = nx, ny;
    end

    function self:setDimensions(nw, nh)
        w, h = nw, nh
    end

    function self:getPosition()
        return x, y;
    end

    function self:getDimensions()
        return w, h;
    end

    return self;
end

return setmetatable(BaseComponent, { __call = new });
