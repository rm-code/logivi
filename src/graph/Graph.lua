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

local Node = require('src.graph.Node');
local File = require('src.graph.File');

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
    local root = nodes[ROOT];

    local minX, maxX, minY, maxY = root:getX(), root:getX(), root:getY(), root:getY();

    -- ------------------------------------------------
    -- Local Functions
    -- ------------------------------------------------

    ---
    -- @param minX - The current minimum x position.
    -- @param maxX - The current maximum y position.
    -- @param minY - The current minimum x position.
    -- @param maxY - The current maximum y position.
    -- @param nx - The new x position to check.
    -- @param ny - The new y position to check.
    --
    local function updateBoundaries(minX, maxX, minY, maxY, nx, ny)
        return math.min(nx, minX), math.max(nx, maxX), math.min(ny, minY), math.max(ny, maxY);
    end

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
            local parent = nodes[parentPath];
            nodes[nodePath] = Node.new(parent, nodePath,
                parent:getX() + love.math.random(5, 40) * (love.math.random(0, 1) == 0 and -1 or 1),
                parent:getY() + love.math.random(5, 40) * (love.math.random(0, 1) == 0 and -1 or 1),
                spritebatch);
            parent:addChild(nodePath, nodes[nodePath]);
        end
        return nodes[nodePath];
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
        if targetNode:getFileCount() == 0 and targetNode:getChildCount() == 0 then
            nodes[path]:kill();
            nodes[path] = nil;
            -- print('DEL node [' .. path .. ']');
        end
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
        root:draw();
        love.graphics.draw(spritebatch);
    end

    function self:update(dt)
        minX, maxX, minY, maxY = root:getX(), root:getX(), root:getY(), root:getY();

        spritebatch:clear();
        for _, nodeA in pairs(nodes) do
            for _, nodeB in pairs(nodes) do
                if nodeA ~= nodeB then
                    if nodeA:isConnectedTo(nodeB) then
                        nodeA:attract(nodeB);
                    end
                    nodeA:repel(nodeB);
                end
            end

            nodeA:damp(0.95);
            nodeA:update(dt);
            local nx, ny = nodeA:move(dt);
            minX, maxX, minY, maxY = updateBoundaries(minX, maxX, minY, maxY, nx, ny);
        end
    end

    -- ------------------------------------------------
    -- Getters
    -- ------------------------------------------------

    ---
    -- Returns the center of the graph. The center is calculated
    -- by forming a rectangle that encapsulates all nodes and then
    -- dividing its sides by two.
    --
    function self:getCenter()
        return minX + (maxX - minX) * 0.5, minY + (maxY - minY) * 0.5;
    end

    return self;
end

return Graph;
