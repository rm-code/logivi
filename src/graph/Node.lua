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

local Node = {};

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local FORCE_MAX = 4;

local SPRITE_SIZE = 0.45;
local SPRITE_OFFSET = 15;

local FORCE_SPRING = -0.005;
local FORCE_CHARGE = 10000000;

local LABEL_FONT = love.graphics.newFont('res/fonts/SourceCodePro-Medium.otf', 20);
local DEFAULT_FONT = love.graphics.newFont(12);

-- ------------------------------------------------
-- Constructor
-- ------------------------------------------------

function Node.new(parent, path, name, x, y, spritebatch)
    local self = {};

    -- ------------------------------------------------
    -- Local Variables
    -- ------------------------------------------------

    local children = {};
    local childCount = 0;

    local files = {};
    local fileCount = 0;

    local speed = 64;

    local posX, posY = x, y;
    local velX, velY = 0, 0;
    local accX, accY = 0, 0;

    local radius = 0;

    -- ------------------------------------------------
    -- Public Functions
    -- ------------------------------------------------

    ---
    -- Clamps a value to a certain range.
    -- @param min
    -- @param val
    -- @param max
    --
    local function clamp(min, val, max)
        return math.max(min, math.min(val, max));
    end

    ---
    -- @param fx
    -- @param fy
    --
    local function applyForce(fx, fy)
        accX = clamp(-FORCE_MAX, accX + fx, FORCE_MAX);
        accY = clamp(-FORCE_MAX, accY + fy, FORCE_MAX);
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
    -- Calculates how many layers we need and how many files
    -- can be placed on each layer. This basically generates a
    -- blueprint of how the files need to be arranged.
    --
    local function createOnionLayers(count)
        local MIN_ARC_SIZE = 15;

        local fileCounter = 0;
        local radius = -15; -- Radius of the circle around the node.
        local layers = {
            { radius = radius, amount = fileCounter }
        };

        for i = 1, count do
            fileCounter = fileCounter + 1;

            -- Calculate the arc between the file nodes on the current layer.
            -- The more files are on it the smaller it gets.
            local arc = calcArc(layers[#layers].radius, 360 / fileCounter);

            -- If the arc is smaller than the allowed minimum we store the radius
            -- of the current layer and the number of nodes that can be placed
            -- on that layer and move to the next layer.
            if arc < MIN_ARC_SIZE then
                radius = radius + 15;

                -- Create a new layer.
                layers[#layers + 1] = { radius = radius, amount = 1 };
                fileCounter = 1;
            else
                layers[#layers].amount = fileCounter;
            end
        end

        return layers, radius;
    end

    ---
    -- Distributes files nodes evenly on a circle around the parent node.
    -- @param files
    --
    local function plotCircle(files, count)
        -- Get a blueprint of how the file nodes need to be distributed amongst different layers.
        local layers, maxradius = createOnionLayers(count);

        -- Update the position of the file nodes based on the previously calculated onion-layers.
        local fileCounter = 0;
        local layer = 1;
        for _, file in pairs(files) do
            fileCounter = fileCounter + 1;

            -- If we have more files on the current layer than allowed, we "move"
            -- the file to the next layer (this is why we reset the counter to one
            -- instead of zero).
            if fileCounter > layers[layer].amount then
                layer = layer + 1;
                fileCounter = 1;
            end

            -- Calculate the new position of the file on its layer around the folder node.
            local angle = 360 / layers[layer].amount;
            local x = (layers[layer].radius * math.cos((angle * (fileCounter - 1)) * (math.pi / 180)));
            local y = (layers[layer].radius * math.sin((angle * (fileCounter - 1)) * (math.pi / 180)));
            file:setOffset(x, y);
        end
        return maxradius;
    end

    -- ------------------------------------------------
    -- Public Functions
    -- ------------------------------------------------

    function self:addChild(name, folder)
        children[name] = folder;
        childCount = childCount + 1;
        return children[name];
    end

    function self:removeChild(name)
        children[name] = nil;
        childCount = childCount - 1;
    end

    function self:draw(ewidth, camrot, showlabel)
        if showlabel then
            love.graphics.setFont(LABEL_FONT);
            love.graphics.print(name, posX, posY, -camrot, 1, 1, -radius, -radius);
            love.graphics.setFont(DEFAULT_FONT);
        end
        for _, node in pairs(children) do
            love.graphics.setColor(255, 255, 255, 55);
            love.graphics.setLineWidth(ewidth);
            love.graphics.line(posX, posY, node:getX(), node:getY());
            love.graphics.setLineWidth(1);
            love.graphics.setColor(255, 255, 255, 255);
            node:draw(ewidth, camrot, showlabel);
        end
    end

    function self:update(dt)
        -- Update files.
        for _, file in pairs(files) do
            file:update(dt);
            file:setPosition(posX, posY);
            spritebatch:setColor(file:getColor());
            spritebatch:add(file:getX(), file:getY(), 0, SPRITE_SIZE, SPRITE_SIZE, SPRITE_OFFSET, SPRITE_OFFSET);
        end
    end

    function self:addFile(name, file)
        if files[name] then
            print('+ Can not add file: ' .. name .. ' - It already exists.');
            return;
        end

        files[name] = file;
        files[name]:setModified(true);
        fileCount = fileCount + 1;

        -- Update layout of the files.
        radius = plotCircle(files, fileCount);
        return files[name];
    end

    function self:removeFile(name)
        if not files[name] then
            print('- Can not rem file: ' .. name .. ' - It doesn\'t exist.');
            return;
        end

        -- Store a reference to the file which can be returned
        -- after the file has been removed from the table.
        local tmp = files[name];
        files[name]:setModified(true);
        files[name]:remove();
        files[name] = nil;
        fileCount = fileCount - 1;

        -- Update layout of the files.
        radius = plotCircle(files, fileCount);
        return tmp;
    end

    function self:modifyFile(name)
        if not files[name] then
            print('~ Can not mod file: ' .. name .. ' - It doesn\'t exist.');
            return;
        end

        files[name]:setModified(true);
        return files[name];
    end

    ---
    -- Apply the calculated acceleration to the node.
    --
    function self:move(dt)
        velX = velX + accX * dt * speed;
        velY = velY + accY * dt * speed;

        posX = posX + velX;
        posY = posY + velY;

        accX, accY = 0, 0;
        return posX, posY;
    end

    function self:damp(f)
        velX, velY = velX * f, velY * f;
    end

    ---
    -- Attracts the node towards nodeB based on a spring force.
    -- @param nodeB
    --
    function self:attract(nodeB)
        local dx, dy = posX - nodeB:getX(), posY - nodeB:getY();
        local distance = math.sqrt(dx * dx + dy * dy);

        -- Normalise vector.
        dx = dx / distance;
        dy = dy / distance;

        -- Calculate spring force and apply it.
        local force = FORCE_SPRING * distance;
        applyForce(dx * force, dy * force);
    end

    ---
    -- Repels the node from nodeB.
    -- @param nodeB
    --
    function self:repel(nodeB)
        -- Calculate distance vector.
        local dx, dy = posX - nodeB:getX(), posY - nodeB:getY();
        local distance = math.sqrt(dx * dx + dy * dy);

        -- Normalise vector.
        dx = dx / distance;
        dy = dy / distance;

        -- Calculate force's strength and apply it to the vector.
        local strength = FORCE_CHARGE * ((self:getMass() * nodeB:getMass()) / (distance * distance));
        dx = dx * strength;
        dy = dy * strength;

        applyForce(dx, dy);
    end

    -- ------------------------------------------------
    -- Getters
    -- ------------------------------------------------

    function self:getFileCount()
        return fileCount;
    end

    function self:getChildCount()
        return childCount;
    end

    function self:getPosition()
        return posX, posY;
    end

    function self:getX()
        return posX;
    end

    function self:getY()
        return posY;
    end

    function self:getPath()
        return path;
    end

    function self:getParent()
        return parent;
    end

    function self:getMass()
        return 0.01 * (childCount + math.log(math.max(15, radius)));
    end

    function self:isConnectedTo(node)
        if parent == node then
            return true;
        end
        for _, child in pairs(children) do
            if node == child then
                return true;
            end
        end
    end

    return self;
end

return Node;
