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

local Node = require('src/graph/Node');
local File = require('src/graph/File');

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local Graph = {};

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local ROOT = 'root/';
local MOD_ADD = 'A';
local MOD_COPY = 'C';
local MOD_DELETE = 'D';
local MOD_MODIFY = 'M';
local MOD_RENAME = 'R';
local MOD_CHANGE = 'T';
local MOD_UNMERGE = 'U';
local MOD_UNKNOWN = 'X';
local MOD_BROKEN_PAIRING = 'B';

-- Constants for force-directed layout.
local SPRING = -0.0008;
local CHARGE = 800;

-- ------------------------------------------------
-- Local Variables
-- ------------------------------------------------

local fileSprite = love.graphics.newImage('res/file.png');
local spritebatch = love.graphics.newSpriteBatch(fileSprite, 10000, 'stream');

-- ------------------------------------------------
-- Constructor
-- ------------------------------------------------

function Graph.new()
    local self = {};

    local nodes = { [ROOT] = Node.new(nil, ROOT, 300, 200, spritebatch); };
    local edges = {};

    -- ------------------------------------------------
    -- Local Functions
    -- ------------------------------------------------

    ---
    -- Creates a new node and stores it in our list, using the name
    -- as the identifier or returns an already existing node.
    -- @param parentPath
    -- @param nodePath
    -- @param x
    -- @param y
    --
    local function addNode(parentPath, nodePath)
        if not nodes[nodePath] then
            local nx = nodes[parentPath]:getX() + love.math.random(-15, 15);
            local ny = nodes[parentPath]:getY() + love.math.random(-15, 15);
            nodes[nodePath] = Node.new(nodes[parentPath], nodePath, nx, ny, spritebatch);
        end
        return nodes[nodePath];
    end

    ---
    -- Creates an edge between two nodes.
    -- @param nodeAPath
    -- @param nodeBPath
    --
    local function addEdge(nodeAPath, nodeBPath)
        edges[#edges + 1] = { a = nodeAPath, b = nodeBPath };
    end

    ---
    -- Returns the node of the specified path if it already exists.
    -- If the string is empty it points to the root node. If the path
    -- doesn't already belong to a node it creates nodes for each sub-
    -- folder in the path until it is done with the whole path. Then
    -- it returns the node for the the path.
    -- @param path
    --
    local function getNode(path)
        -- If we already have this path return it.
        if nodes[path] then
            return nodes[path];
        else
            local lastPos = 1;
            local node;
            while path:find('/') do
                local pos = path:find('/', lastPos);

                -- No more folders.
                if not pos then
                    break;
                end

                -- Get the parent folder from the path. The topmost folder
                -- will always have 'root' as a parent.
                local parentPath = path:sub(1, lastPos - 1);
                if parentPath == '' then
                    parentPath = ROOT;
                end

                -- Extract the folder path.
                local folderPath = path:sub(1, pos);
                lastPos = pos + 1;

                -- Add the folder node to our graph.
                node = addNode(parentPath, folderPath);
                addEdge(parentPath, folderPath);
            end
            return node;
        end
    end

    ---
    -- Remove dead node if it doesn't contain any files and only links
    -- to its parent.
    -- @param targetNode
    -- @param path
    --
    local function removeDeadNode(targetNode, path)
        if targetNode:getFileCount() == 0 then
            local edgeCount = 0;
            local edgeToRem;
            for i = 1, #edges do
                if nodes[edges[i].a] == targetNode or nodes[edges[i].b] == targetNode then
                    edgeCount = edgeCount + 1;
                    edgeToRem = i;
                end
            end

            if edgeCount == 1 then
                table.remove(edges, edgeToRem);
                nodes[path] = nil;
                -- print('DEL node [' .. path .. ']');
            end
        end
    end

    ---
    -- Attracts a node to a certain point on the screen.
    -- @param node
    -- @param x2
    -- @param y2
    --
    local function attract(node, x2, y2)
        local dx, dy = node:getX() - x2, node:getY() - y2;
        local distance = math.sqrt(dx * dx + dy * dy);
        distance = math.max(0.001, math.min(distance, 100));

        -- Normalise vector.
        dx = dx / distance;
        dy = dy / distance;

        -- Calculate spring force and apply it.
        local force = SPRING * distance;
        node:applyForce(dx * force, dy * force);
    end

    ---
    -- Repulses one node from another node based on their distance
    -- from each other and their mass.
    -- @param a
    -- @param b
    --
    local function repulse(a, b)
        -- Calculate distance vector.
        local dx, dy = a:getX() - b:getX(), a:getY() - b:getY();
        local distance = math.sqrt(dx * dx + dy * dy);
        distance = math.max(0.001, math.min(distance, 1000));

        -- Normalise vector.
        dx = dx / distance;
        dy = dy / distance;

        -- Calculate force's strength and apply it to the vector.
        local strength = CHARGE * ((a:getMass() * b:getMass()) / (distance * distance));
        dx = dx * strength;
        dy = dy * strength;

        a:applyForce(dx, dy);
    end

    -- ------------------------------------------------
    -- Public Functions
    -- ------------------------------------------------

    ---
    -- This function will take a git modifer and apply it to a file.
    -- If it encounters the 'A' modifier it will create a file at the
    -- specified path. If it encounters the 'D' modifier it will remove
    -- the file from the path. Nodes will be created and removed based
    -- along the way.
    -- @param modifier
    -- @param path
    -- @param file
    --
    function self:applyGitStatus(modifier, path, file)
        if path == '' then path = ROOT; end

        local targetNode = getNode(path);

        if modifier == MOD_ADD then
            return targetNode:addFile(file, File.new(file, targetNode:getX(), targetNode:getY()));
            -- print('ADD file [' .. file .. '] to node: ' .. path);
        elseif modifier == MOD_DELETE then
            local tmp = targetNode:removeFile(file);
            -- print('DEL file [' .. file .. '] from node: ' .. path);

            -- Remove the node if it doesn't contain files and only
            -- has a link to its parent.
            removeDeadNode(targetNode, path);
            return tmp;
        elseif modifier == MOD_MODIFY then
            return targetNode:modifyFile(file);
        end
    end

    function self:draw()
        for i = 1, #edges do
            love.graphics.setColor(100, 100, 100);
            love.graphics.line(nodes[edges[i].a]:getX(),
                nodes[edges[i].a]:getY(),
                nodes[edges[i].b]:getX(),
                nodes[edges[i].b]:getY());
            love.graphics.setColor(255, 255, 255);
        end
        love.graphics.draw(spritebatch);
    end

    function self:update(dt)
        spritebatch:clear();
        for idA, nodeA in pairs(nodes) do
            -- Attract nodes to the center of the screen.
            attract(nodeA, love.graphics.getWidth() * 0.5, love.graphics.getHeight() * 0.5);

            for idB, nodeB in pairs(nodes) do
                if nodeA ~= nodeB then
                    repulse(nodeA, nodeB);
                end
            end

            nodeA:damp(0.95);
            nodeA:update(dt);
        end
    end

    -- ------------------------------------------------
    -- Getters
    -- ------------------------------------------------

    function self:getBoundaries()
        local minX = nodes[ROOT]:getX();
        local maxX = nodes[ROOT]:getX();
        local minY = nodes[ROOT]:getY();
        local maxY = nodes[ROOT]:getY();

        for i, node in pairs(nodes) do
            local nx, ny = node:getPosition();

            if not minX or nx < minX then
                minX = nx;
            elseif not maxX or nx > maxX then
                maxX = nx;
            end
            if not minY or ny < minY then
                minY = ny;
            elseif not maxY or ny > maxY then
                maxY = ny;
            end
        end

        return minX, maxX, minY, maxY;
    end

    ---
    -- Returns the center of the graph. The center is calculated
    -- by forming a rectangle that encapsulates all nodes and then
    -- dividing its sides by two.
    --
    function self:getCenter()
        local minX, maxX, minY, maxY = self:getBoundaries();
        return minX + (maxX - minX) * 0.5, minY + (maxY - minY) * 0.5;
    end

    return self;
end

return Graph;
