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

-- ------------------------------------------------
-- Constructor
-- ------------------------------------------------

function Graph.new()
    local self = {};

    local nodes = { [ROOT] = Node.new(ROOT, 300, 200); };
    local edges = {};

    -- ------------------------------------------------
    -- Local Functions
    -- ------------------------------------------------

    ---
    -- Creates a new node and stores it in our list, using the name
    -- as the identifier or returns an already existing node.
    -- @param pname - The parent's name.
    -- @param name
    -- @param x
    -- @param y
    --
    local function addNode(parent, name)
        if not nodes[name] then
            nodes[name] = Node.new(name, nodes[parent]:getX() + love.math.random(-100, 100), nodes[parent]:getY() + love.math.random(-100, 100));
        end
        return nodes[name];
    end

    ---
    -- Creates an edge between two nodes.
    -- @param a
    -- @param b
    --
    local function addEdge(a, b)
        edges[#edges + 1] = { a = a, b = b };
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
                local parent = path:sub(1, lastPos - 1);
                if parent == '' then
                    parent = ROOT;
                end

                -- Extract the folder path.
                local folder = path:sub(1, pos);
                lastPos = pos + 1;

                -- Add the folder node to our graph.
                node = addNode(parent, folder);
                addEdge(parent, folder);
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
        for _, node in pairs(nodes) do
            node:draw();
        end
    end

    function self:update(dt)
        for _, node in pairs(nodes) do
            node:update(dt);
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
