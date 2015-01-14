local Node = require('src/nodes/Node');

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

function FileNode.new(name, color)
    local self = Node.new('file', name);

    function self:draw()
        love.graphics.setColor(color);
        love.graphics.draw(img, self:getX() - 8, self:getY() - 8);
        love.graphics.setColor(255, 255, 255);
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