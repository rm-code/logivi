-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local Node = {};

-- ------------------------------------------------
-- Constructor
-- ------------------------------------------------

function Node.new(type, name, x, y)
    local self = {};

    local x, y = x, y;

    function self:update(dt) end

    function self:draw() end

    function self:setPosition(nx, ny)
        x, y = nx, ny;
    end

    function self:getX()
        return x;
    end

    function self:getY()
        return y;
    end

    function self:getName()
        return name;
    end

    function self:getType()
        return type;
    end

    return self;
end

-- ------------------------------------------------
-- Return Module
-- ------------------------------------------------

return Node;

--==================================================================================================
-- Created 16.10.14 - 14:47                                                                        =
--==================================================================================================