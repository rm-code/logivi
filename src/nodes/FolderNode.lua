--==================================================================================================
-- Copyright (C) 2014 - 2015 by Robert Machmer                                                     =
--                                                                                                 =
-- Permission is hereby granted, free of charge, to any person obtaining a copy                    =
-- of this software and associated documentation files (the "Software"), to deal                   =
-- in the Software without restriction, including without limitation the rights                    =
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell                       =
-- copies of the Software, and to permit persons to whom the Software is                           =
-- furnished to do so, subject to the following conditions:                                        =
--                                                                                                 =
-- The above copyright notice and this permission notice shall be included in                      =
-- all copies or substantial portions of the Software.                                             =
--                                                                                                 =
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR                      =
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,                        =
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE                     =
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER                          =
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,                   =
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN                       =
-- THE SOFTWARE.                                                                                   =
--==================================================================================================

local Node = require('src/nodes/Node');

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local FolderNode = {};

-- ------------------------------------------------
-- Constructor
-- ------------------------------------------------

function FolderNode.new(name, world, static, parent)
    local self = Node.new('folder', name);

    local children = {};
    local radius = 8;
    local collider = {};
    local ropeLength = 150;
    if parent then
        local parentBody = parent:getColliderBody();
        collider.body = love.physics.newBody(world, parentBody:getX() + love.math.random(-20, 20), parentBody:getY() + love.math.random(-20, 20), static and 'static' or 'dynamic');
    else
        collider.body = love.physics.newBody(world, love.graphics.getWidth() * 0.5, love.graphics.getHeight() * 0.5, static and 'static' or 'dynamic');
    end
    collider.shape = love.physics.newCircleShape(radius);
    collider.fixture = love.physics.newFixture(collider.body, collider.shape, 1);
    collider.fixture:setGroupIndex(-1);
    collider.body:setMass(1.0);
    if parent then
        local parentBody = parent:getColliderBody();
        love.physics.newRopeJoint(parentBody, collider.body, parentBody:getX(), parentBody:getY(), collider.body:getX(), collider.body:getY(), ropeLength, true);
    end
    self:setPosition(collider.body:getX(), collider.body:getY());

    -- ------------------------------------------------
    -- Private Functions
    -- ------------------------------------------------

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
    -- can be placed on each layer. This basically generates a
    -- blueprint of how the nodes need to be arranged.
    -- @param children
    --
    local function createOnionLayers(children)
        local MIN_ARC_SIZE = 15;

        local nodes = 0;
        local radius = -15; -- Radius of the circle around the folder node.
        local layers = {
            { radius = radius, amount = nodes }
        };

        -- Go through all child nodes of type 'file'.
        for i = 1, countFileNodes(children) do
            nodes = nodes + 1;

            -- Calculate the arc between the file nodes on the current layer.
            -- The more files are on it the smaller it gets.
            local arc = calcArc(layers[#layers].radius, 360 / nodes);

            -- If the arc is smaller than the allowed minimum we store the radius
            -- of the current layer and the number of nodes that can be placed
            -- on that layer and move to the next layer.
            if arc < MIN_ARC_SIZE then
                radius = radius + 15;

                -- Create a new layer.
                layers[#layers + 1] = { radius = radius, amount = 1 };
                nodes = 1;
            else
                layers[#layers].amount = nodes;
            end
        end

        return layers;
    end

    ---
    -- Distributes files nodes evenly on a circle around the parent node.
    -- @param children
    --
    local function plotCircle(children)
        -- Get a blueprint of how the file nodes need to be distributed amongst different layers.
        local layers = createOnionLayers(children);

        -- Update the position of the file nodes based on the previously calculated onion-layers.
        local count = 0;
        local layer = 1;
        for _, node in pairs(children) do
            if node:getType() == 'file' then
                count = count + 1;

                -- If we have more nodes on the current layer than allowed, we "move"
                -- the node to the next layer (this is why we reset the counter to one
                -- instead of zero).
                if count > layers[layer].amount then
                    layer = layer + 1;
                    count = 1;
                end

                -- Calculate the new position of the node on its layer around the folder node.
                local angle = 360 / layers[layer].amount;
                local x = (layers[layer].radius * math.cos((angle * (count - 1)) * (math.pi / 180)));
                local y = (layers[layer].radius * math.sin((angle * (count - 1)) * (math.pi / 180)));
                node:setPosition(x + collider.body:getX(), y + collider.body:getY());
            end
        end

        -- Adjust box2d collision body.
        if layers[#layers].radius ~= radius then
            collider.shape = love.physics.newCircleShape(layers[#layers].radius);
            collider.fixture = love.physics.newFixture(collider.body, collider.shape, 1);
            collider.fixture:setGroupIndex(-1);
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

        if parent then
            local siblings = parent:getChildren();

            for _, sibling in pairs(siblings) do
                if sibling:getType() == 'folder' and sibling ~= self then
                    local body = sibling:getColliderBody();

                    local dx = body:getX() - collider.body:getX();
                    local dy = body:getY() - collider.body:getY();
                    local len = math.sqrt(dx * dx + dy * dy);
                    local force = 400 * mass * mass / (len * len);

                    collider.body:applyForce(-force * dx, -force * dy);
                    body:applyForce(force * dx, force * dy);
                end
            end
        end
    end

    -- ------------------------------------------------
    -- Public Functions
    -- ------------------------------------------------

    function self:draw()
        for _, node in pairs(children) do
            if node:getType() == 'folder' then
                love.graphics.setColor(50, 50, 50);
                love.graphics.line(collider.body:getX(), collider.body:getY(), node:getColliderBody():getX(), node:getColliderBody():getY());
                love.graphics.setColor(255, 255, 255);
            end
            node:draw();
        end
        love.graphics.print(name, collider.body:getX() + 10, collider.body:getY());
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

        self:setPosition(collider.body:getX(), collider.body:getY());
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

    -- ------------------------------------------------
    -- Getters
    -- ------------------------------------------------

    function self:getNode(name)
        return children[name];
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

    function self:getChildren()
        return children;
    end

    return self;
end

-- ------------------------------------------------
-- Return Module
-- ------------------------------------------------

return FolderNode;
