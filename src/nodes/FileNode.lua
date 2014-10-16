-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local FileNode = {};

-- ------------------------------------------------
-- Local Variables
-- ------------------------------------------------

local img = love.graphics.newImage('res/fileNode.png');

-- ------------------------------------------------
-- Constructor
-- ------------------------------------------------

function FileNode.new(name)
    local self = {};

    local x, y;
    local r;

    function self:draw()
        if x and y then
            love.graphics.draw(img, x - 8, y - 8);
            --  love.graphics.print(name, x + 10, y);
        end
    end

    function self:update(dt) end

    function self:setPosition(nx, ny)
        x, y = nx, ny;
    end

    function self:getType()
        return 'file';
    end

    function self:getX()
        return x;
    end

    function self:getY()
        return y;
    end

    return self;
end

-- ------------------------------------------------
-- Return Module
-- ------------------------------------------------

return FileNode;

--==================================================================================================
-- Created 01.10.14 - 14:41                                                                        =
--==================================================================================================