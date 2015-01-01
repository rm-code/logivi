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

    ---
    -- Calculates the arc for a certain angle.
    -- @param radius
    -- @param angle
    --
    local function calcArc(radius, angle)
        return math.pi * radius * (angle / 180);
    end

    ---
    -- Calculates how many layers we need and how many file nodes
    -- can be placed on each layer.
    --
    local function createOnionLayers()
        local MIN_ARC_SIZE = 15;

        local amount = 0;
        local radius = 15; -- Radius of the circle around the folder node.
        local layers = {
            { radius = radius, amount = amount }
        };
        local angle, arc;

        -- Go through all child nodes of type 'file'.
        for _, node in pairs(children) do
            if node:getType() == 'file' then
                amount = amount + 1;

                -- Calculate the arc between the file nodes on the current layer.
                -- The more files are on it the smaller it gets.
                angle = 360 / amount;
                arc = calcArc(layers[#layers].radius, angle);

                -- If the arc is smaller than the minimum arc size we store the radius
                -- of the current layer and the number of nodes that can be placed
                -- on that layer.
                if arc < MIN_ARC_SIZE then
                    layers[#layers + 1] = { radius = radius, amount = amount - 1};
                    amount = 0;
                    radius = radius + 15;
                else
                    layers[#layers].amount = amount;
                end
            end
        end

        return layers;
    end

    ---
    -- Distributes files nodes evenly on a circle around the parent node.
    --
    -- @param children
    --
    local function plotCircle(children)
        -- Determine how the file nodes need to be distributed amongst different layers.
        local layers = createOnionLayers();

        -- Update the position of the file nodes based on the onion-layers.
        local count = 0;
        local layer = 1;
        for _, node in pairs(children) do
            if node:getType() == 'file' then
                count = count + 1;

                -- As long as the amount of nodes on the current layer is smaller or 
                -- the calculated amount we keep adding them to this layer.
                -- If we pass this threshold we add a new layer and reset the counter. 
                if count <= layers[layer].amount then
                    local angle = 360 / layers[layer].amount;

                    local x = (layers[layer].radius * math.cos((angle * (count - 1)) * (math.pi / 180)));
                    local y = (layers[layer].radius * math.sin((angle * (count - 1)) * (math.pi / 180)));
                    node:setPosition(x + collider.body:getX(), y + collider.body:getY());
                else
                    layer = layer + 1;
                    count = 0;
                end
            end
        end

        -- Adjust box2d collision body.
        if layers[#layers].radius ~= radius then
            collider.shape = love.physics.newCircleShape(layers[#layers].radius);
            collider.fixture = love.physics.newFixture(collider.body, collider.shape, 1);
            collider.body:setMass(1.0);
            radius = layers[#layers].radius;
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
