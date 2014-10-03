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
            -- love.graphics.rectangle('line', posX, posY, 16, 16);
            -- love.graphics.print(name, x, y);
        end
    end

    function self:update(dt) end

    function self:setPosition(px, py, r, an)
        x = px + r * math.cos(math.rad(an));
        y = py + r * math.sin(math.rad(an));
    end

    function self:getType()
        return 'file';
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