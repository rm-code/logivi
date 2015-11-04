local BaseDecorator = {};

local function new()
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

    local meta = {};

    function meta.__index(table, key)
        if key ~= 'child' and self.child then
            return self.child[key];
        end
    end

    return setmetatable(self, meta);
end

return setmetatable(BaseDecorator, { __call = new });
