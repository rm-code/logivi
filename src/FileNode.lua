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

function FileNode.new(name, x, y)
    local self = {};

    local posX, posY = x, y;

    function self:draw()
        love.graphics.draw(img, posX, posY);
        -- love.graphics.rectangle('line', posX, posY, 16, 16);
        love.graphics.print(name, posX + 20, posY);
    end

    function self:update(dt)
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