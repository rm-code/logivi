local Node = require('src.graph.Node');
local Resources = require('src.Resources');

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local Graph = {};

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local ROOT_FOLDER = 'root';
local MOD_ADD = 'A';
local MOD_COPY = 'C';
local MOD_DELETE = 'D';
local MOD_MODIFY = 'M';
local MOD_RENAME = 'R';
local MOD_CHANGE = 'T';
local MOD_UNMERGE = 'U';
local MOD_UNKNOWN = 'X';
local MOD_BROKEN_PAIRING = 'B';

local EVENT_UPDATE_CENTER = 'GRAPH_UPDATE_CENTER';
local EVENT_UPDATE_FILE = 'GRAPH_UPDATE_FILE';

-- ------------------------------------------------
-- Local Variables
-- ------------------------------------------------

local fileSprite  = Resources.loadImage('file.png');
local spritebatch = love.graphics.newSpriteBatch(fileSprite, 10000, 'stream');

-- ------------------------------------------------
-- Constructor
-- ------------------------------------------------

function Graph.new(ewidth, showLabels)
    local self = {};

    local observers = {};

    local nodes = { [ROOT_FOLDER] = Node.new(nil, ROOT_FOLDER, ROOT_FOLDER, 300, 200, spritebatch); };
    local root = nodes[ROOT_FOLDER];

    local minX, maxX, minY, maxY = root:getX(), root:getX(), root:getY(), root:getY();

    -- ------------------------------------------------
    -- Local Functions
    -- ------------------------------------------------

    ---
    -- Notify observers about the event.
    -- @param event
    -- @param ...
    --
    local function notify(event, ...)
        for i = 1, #observers do
            observers[i]:receive(event, ...);
        end
    end

    ---
    -- @param minX - The current minimum x position.
    -- @param maxX - The current maximum y position.
    -- @param minY - The current minimum x position.
    -- @param maxY - The current maximum y position.
    -- @param nx - The new x position to check.
    -- @param ny - The new y position to check.
    --
    local function updateBoundaries(minX, maxX, minY, maxY, radius, nx, ny)
        return math.min(nx - radius, minX), math.max(nx + radius, maxX), math.min(ny - radius, minY), math.max(ny + radius, maxY);
    end

    ---
    -- Returns the center of the graph. The center is calculated
    -- by forming a rectangle that encapsulates all nodes and then
    -- dividing its sides by two.
    --
    local function updateCenter()
        return minX + (maxX - minX) * 0.5, minY + (maxY - minY) * 0.5;
    end

    ---
    -- Creates a new node and stores it in our list, using the name
    -- as the identifier or returns an already existing node.
    -- @param parentPath
    -- @param nodePath
    -- @param x
    -- @param y
    --
    local function addNode(parentPath, nodePath, folder)
        if not nodes[nodePath] then
            local parent = nodes[parentPath];
            nodes[nodePath] = Node.new(parent, nodePath, folder,
                parent:getX() + love.math.random(5, 40) * (love.math.random(0, 1) == 0 and -1 or 1),
                parent:getY() + love.math.random(5, 40) * (love.math.random(0, 1) == 0 and -1 or 1),
                spritebatch);
            parent:addChild(nodePath, nodes[nodePath]);
        end
        return nodes[nodePath], nodePath;
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
        if nodes[path] then
            return nodes[path];
        else
            local node;
            local ppath = ROOT_FOLDER;
            for part in path:gmatch('[^/]+') do
                if part ~= ROOT_FOLDER then
                    node, ppath = addNode(ppath, ppath .. '/' .. part, part);
                end
            end
            return node;
        end
    end

    ---
    -- Checks if a node is dead. A node is considered dead if it doesn't contain
    -- any files and doesn't link to any other nodes except for its own parent.
    -- @param node - The node to check.
    --
    local function removeDeadNode(node)
        if node:isDead() then
            -- print('DEL node [' .. path .. ']');
            local parent = node:getParent();
            if parent then
                local path = node:getPath();
                parent:removeChild(path);
                nodes[path] = nil;
            end
        end
    end

    ---
    -- This function will take a git modifier and apply it to a file.
    -- If it encounters the 'A' modifier it will create a file at the
    -- specified path. If it encounters the 'D' modifier it will remove
    -- the file from the path. Nodes will be created and removed based
    -- along the way.
    -- @param modifier
    -- @param path
    -- @param filename
    --
    local function applyGitModifier(modifier, path, filename, mode)
        local targetNode = getNode(path);

        local modifiedFile;
        if modifier == MOD_ADD then
            modifiedFile = targetNode:addFile(filename);
        elseif modifier == MOD_DELETE then
            if mode == 'normal' then
                modifiedFile = targetNode:markFileForDeletion(filename);
            else
                modifiedFile = targetNode:removeFile(filename);
            end
        elseif modifier == MOD_MODIFY then
            modifiedFile = targetNode:modifyFile(filename);
        end

        -- We only notify observers if the graph isn't modifed in fast forward / rewind mode.
        if mode == 'normal' and modifiedFile then
            notify(EVENT_UPDATE_FILE, modifiedFile, modifier);
        end
    end

    -- ------------------------------------------------
    -- Public Functions
    -- ------------------------------------------------

    function self:draw(camrot)
        root:draw(ewidth);
        love.graphics.draw(spritebatch);

        if showLabels then
            root:drawLabel(camrot);
        end
    end

    function self:update(dt)
        minX, maxX, minY, maxY = root:getX(), root:getX(), root:getY(), root:getY();

        spritebatch:clear();
        for _, nodeA in pairs(nodes) do
            for _, nodeB in pairs(nodes) do
                nodeA:calculateForces(nodeB);
            end

            -- Remove the node if it doesn't contain files and only
            -- has a link to its parent.
            removeDeadNode(nodeA);

            minX, maxX, minY, maxY = updateBoundaries(minX, maxX, minY, maxY, nodeA:getRadius(), nodeA:update(dt));
        end

        notify(EVENT_UPDATE_CENTER, updateCenter());
    end

    ---
    -- Activate / Deactivate folder labels.
    --
    function self:toggleLabels()
        showLabels = not showLabels;
    end

    ---
    -- Register an observer.
    -- @param observer
    --
    function self:register(observer)
        observers[#observers + 1] = observer;
    end

    ---
    -- Receives a notification from an observable.
    -- @param event
    -- @param ...
    --
    function self:receive(event, ...)
        if event == 'LOGREADER_CHANGED_FILE' then
            applyGitModifier(...)
        end
    end

    return self;
end

return Graph;
