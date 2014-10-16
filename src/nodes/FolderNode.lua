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

    local px, py = love.math.random(60, 1200), love.math.random(60, 700);
    local children = {};

    local function plotCircle(children, radius)
        local count = 0;
        for _, _ in pairs(children) do
            count = count + 1;
        end

        local angle = 360 / count;

        count = 0;
        for i, node in pairs(children) do
            count = count + 1;
            local x = (radius * math.cos((angle * (count - 1)) * (math.pi / 180)));
            local y = (radius * math.sin((angle * (count - 1)) * (math.pi / 180)));
            node:setPosition(x + px , y + py);
        end
    end

    function self:draw()
        for _, node in pairs(children) do
            love.graphics.line(px, py, node:getX(), node:getY());
            node:draw();
        end
        love.graphics.print(name, px + 10, py);
        love.graphics.draw(img, px - 8, py - 8);
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
            plotCircle(children, 50);
        end
    end

    function self:remove(name)
        children[name] = nil;
    end

    function self:getType()
        return 'folder';
    end

    function self:setPosition(nx, ny, r, an)
        if not r and not an then
            px, py = px, py;
        else
            px = px + r * math.cos(math.rad(an));
            py = py + r * math.sin(math.rad(an));
        end
    end

    function self:getX()
        return px;
    end

    function self:getY()
        return py;
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