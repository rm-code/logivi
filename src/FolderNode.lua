-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local FolderNode = {};

-- ------------------------------------------------
-- Local Variables
-- ------------------------------------------------

local img = love.graphics.newImage('res/folderNode.png');

-- ------------------------------------------------
-- Constructor
-- ------------------------------------------------

function FolderNode.new(name)
    local self = {};

    local x, y = love.math.random(60, 1200), love.math.random(60, 700);
    local children = {};
    local amountOfChildren = 0;

    function self:draw()
        love.graphics.circle('line', x, y, 40);
        -- love.graphics.print(name, x + 20, y);

        for _, node in pairs(children) do
            if node:getType() == 'folder' then
                love.graphics.line(x, y, node:getX(), node:getY());
                node:draw();
            else
                node:draw();
            end
        end
        love.graphics.draw(img, x - 8, y - 8);
    end

    function self:update(dt)
        for _, node in pairs(children) do
            node:update(dt);
        end
    end

    function self:getNode(name)
        return children[name];
    end

    function self:append(name, node)
        if not children[name] then
            children[name] = node;
            if children[name]:getType() == 'file' then
                children[name]:setPosition(x, y, 40, amountOfChildren * 40);
            else
                children[name]:setPosition(x, y, 200, amountOfChildren * 40);
            end
            amountOfChildren = amountOfChildren + 1;
        end
    end

    function self:getType()
        return 'folder';
    end

    function self:setPosition(px, py, r, an)
        if not r and not an then
            x, y = px, py;
        else
            x = px + r * math.cos(math.rad(an));
            y = py + r * math.sin(math.rad(an));
        end
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

return FolderNode;

--==================================================================================================
-- Created 02.10.14 - 16:49                                                                        =
--==================================================================================================