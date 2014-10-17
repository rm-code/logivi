local Node = require('src/nodes/Node');

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
    local self = Node.new('folder', name);

    local children = {};

    ---
    -- Counts the amount of children nodes that represent files.
    --
    -- @param children
    --
    local function countFileNodes(children)
        local count = 0;
        for _, node in pairs(children) do
            if node:getType() == 'file' then
                count = count + 1;
            end
        end
        return count;
    end

    local function calcArc(radius, angle)
        return math.pi * radius * (angle / 180);
    end

    ---
    -- Distributes files nodes evenly on a circle around the parent node.
    -- @param children
    -- @param radius
    --
    -- TODO radius based on amount of files?
    -- TODO multiple circles if they get too big
    local function plotCircle(children)
        local angle = 360 / countFileNodes(children);

        local count = 0;
        local radius = 15;
        local arc = calcArc(radius, angle);

        while arc < 20 do
            radius = radius * 2;
            arc = calcArc(radius, angle);
        end

        for _, node in pairs(children) do
            if node:getType() == 'file' then
                count = count + 1;
                local x = (radius * math.cos((angle * (count - 1)) * (math.pi / 180)));
                local y = (radius * math.sin((angle * (count - 1)) * (math.pi / 180)));
                node:setPosition(x + self:getX(), y + self:getY());
            elseif not node:getX() or not node:getY() then
                node:setPosition(love.math.random(60, 1200), love.math.random(60, 700));
            end
        end
    end

    function self:draw()
        for _, node in pairs(children) do
            if node:getType() == 'folder' then
                love.graphics.setColor(50, 50, 50);
                love.graphics.line(self:getX(), self:getY(), node:getX(), node:getY());
                love.graphics.setColor(255, 255, 255);
            end
            node:draw();
        end
        love.graphics.print(name, self:getX() + 10, self:getY());
        love.graphics.draw(img, self:getX() - 8, self:getY() - 8);
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
            plotCircle(children);
        end
    end

    function self:remove(name)
        children[name] = nil;
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