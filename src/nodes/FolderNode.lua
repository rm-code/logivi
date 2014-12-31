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

function FolderNode.new(name, world, static, parent)
    local self = Node.new('folder', name);

    local children = {};
    local radius = 8;
    local collider = {}
    if parent then
        local parentBody = parent:getColliderBody();
        collider.body = love.physics.newBody(world, parentBody:getX() + love.math.random(-10, 10), parentBody:getY() + love.math.random(-10, 10), static and 'static' or 'dynamic');
    else
        collider.body = love.physics.newBody(world, love.graphics.getWidth() * 0.5, love.graphics.getHeight() * 0.5, static and 'static' or 'dynamic');
    end
    collider.shape = love.physics.newCircleShape(radius);
    collider.fixture = love.physics.newFixture(collider.body, collider.shape, 1);
    collider.body:setMass(1.0);
    if parent then
        local parentBody = parent:getColliderBody();
        love.physics.newRopeJoint(parentBody, collider.body, parentBody:getX(), parentBody:getY(), collider.body:getX(), collider.body:getY(), 150, true);
    end

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
    -- 
    -- @param children
    local function plotCircle(children)
        local MIN_ARC_SIZE = 15;

        -- Calculate the radius of each circle around the folder node.
        -- Increase the radius if the arc between files becomes too small.
        local noNodes = 0;
        local layer_radius = 15; -- Radius of the circle around the folder node.
        local layers = { { r = layer_radius, n = noNodes } };

        local arc;
        local angle;

        for _, node in pairs(children) do
            if node:getType() == 'file' then
                noNodes = noNodes + 1;

                -- Calculate the arc between nodes.
                angle = 360 / noNodes;
                arc = calcArc(layers[#layers].r, angle);

                -- If arc is smaller than the minimum arc size we store the radius
                -- of that circle and the number of nodes on that circle.
                if arc < MIN_ARC_SIZE then
                    layers[#layers + 1] = { r = layer_radius, n = noNodes - 1};
                    noNodes = 0;
                    layer_radius = layer_radius + 15;
                else
                    layers[#layers].n = noNodes;
                end
            end
        end

        -- Only update the position of the file nodes based on the position of their parent folder node.
        local count = 0;
        local layer = 1;
        for _, node in pairs(children) do
            if node:getType() == 'file' then
                count = count + 1;

                if count <= layers[layer].n then
                    angle = 360 / layers[layer].n;

                    local x = (layers[layer].r * math.cos((angle * (count - 1)) * (math.pi / 180)));
                    local y = (layers[layer].r * math.sin((angle * (count - 1)) * (math.pi / 180)));
                    node:setPosition(x + collider.body:getX(), y + collider.body:getY());
                else
                    layer = layer + 1;
                    count = 0;
                end
            end
        end

        -- Adjust box2d collision body.
        if layers[#layers].r ~= radius then
            collider.shape = love.physics.newCircleShape(layers[#layers].r);
            collider.fixture = love.physics.newFixture(collider.body, collider.shape, 1);
            collider.body:setMass(1.0);
            radius = layers[#layers].r;
        end
    end

    local function repel()
        local mass = 2;

        for _, node in pairs(children) do
            if node:getType() == 'folder' then
                local body = node:getColliderBody();

                local dx = body:getX() - collider.body:getX();
                local dy = body:getY() - collider.body:getY();
                local len = math.sqrt(dx * dx + dy * dy);
                local force = 400 * mass * mass / (len * len);

                collider.body:applyForce(-force * dx, -force * dy);
                body:applyForce(force * dx, force * dy);
            end
        end
    end

    function self:draw()
        love.graphics.setColor(0, 200, 0, 100);
        love.graphics.circle("fill", collider.body:getX(), collider.body:getY(), collider.shape:getRadius());
        love.graphics.setColor(255, 255, 255);

        for _, node in pairs(children) do
            if node:getType() == 'folder' then
                love.graphics.setColor(50, 50, 50);
                love.graphics.line(collider.body:getX(), collider.body:getY(), node:getColliderBody():getX(), node:getColliderBody():getY());
                love.graphics.setColor(255, 255, 255);
            end
            node:draw();
        end
        love.graphics.print(name, collider.body:getX() + 10, collider.body:getY());
        love.graphics.draw(img, collider.body:getX() - 8, collider.body:getY() - 8);
    end

    function self:update(dt)
        plotCircle(children);
        repel();
        for name, node in pairs(children) do
            if node:getType() == 'folder' and node:getChildrenCount() == 0 then
                children[name] = nil;
            end
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

    function self:getColliderBody()
        return collider.body;
    end

    function self:getChildrenCount()
        local count = 0;
        for _, _ in pairs(children) do
            count = count + 1;
        end
        return count;
    end

    return self;
end

-- ------------------------------------------------
-- Return Module
-- ------------------------------------------------

return FolderNode;
