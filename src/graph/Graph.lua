local Node = require('src.graph.Node');
local Resources = require('src.Resources');
local GraphLibrary = require('lib.graphoon.Graphoon').Graph;

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local Graph = {};

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local ROOT_FOLDER = '';
local MOD_ADD = 'A';
local MOD_DELETE = 'D';
local MOD_MODIFY = 'M';

--[[
-- Unused git modifiers.
local MOD_COPY = 'C';
local MOD_RENAME = 'R';
local MOD_CHANGE = 'T';
local MOD_UNMERGE = 'U';
local MOD_UNKNOWN = 'X';
local MOD_BROKEN_PAIRING = 'B';
--]]

local EVENT_UPDATE_DIMENSIONS = 'GRAPH_UPDATE_DIMENSIONS';
local EVENT_UPDATE_CENTER = 'GRAPH_UPDATE_CENTER';
local EVENT_UPDATE_FILE = 'GRAPH_UPDATE_FILE';

-- ------------------------------------------------
-- Local Variables
-- ------------------------------------------------

local LABEL_FONT   = Resources.loadFont( 'SourceCodePro-Medium.otf', 20 );
local DEFAULT_FONT = Resources.loadFont( 'default', 12 );
local FILE_SPRITE  = Resources.loadImage( 'file.png' );

local EDGE_COLOR = { 60, 60, 60, 255 };

-- ------------------------------------------------
-- Constructor
-- ------------------------------------------------

function Graph.new( edgeWidth, showLabels )
    local self = {};

    local observers = {};

    local spritebatch = love.graphics.newSpriteBatch( FILE_SPRITE, 10000, 'stream' );

    -- Create a new graph class.
    GraphLibrary.setNodeClass( Node ); -- Use custom class for Nodes.
    local graph = GraphLibrary.new();
    graph:addNode( ROOT_FOLDER, love.graphics.getWidth() * 0.5, love.graphics.getHeight() * 0.5, true, nil, spritebatch, ROOT_FOLDER );

    -- ------------------------------------------------
    -- Local Functions
    -- ------------------------------------------------

    ---
    -- Returns a random sign (+ or -).
    --
    local function randomSign()
        return love.math.random( 0, 1 ) == 0 and -1 or 1;
    end

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
    -- Spawns a new node.
    -- @param name - The name of the node (the folder's name).
    -- @param id - The id of the node to spawn (the full path to the folder).
    -- @param parent - The parent of the node to spawn.
    -- @param parentID - The parent's id.
    --
    local function spawnNode( name, id, parent, parentID )
        local parentX, parentY = parent:getPosition();
        local offsetX = 100 * randomSign();
        local offsetY = 100 * randomSign();
        return graph:addNode( id, parentX + offsetX, parentY + offsetY, false, parentID, spritebatch, name );
    end

    ---
    -- Removes a node from the graph.
    -- @param node - The node to check.
    --
    local function removeNode( node )
        local parent = graph:getNode( node:getParent() );
        if parent then
            parent:decrementChildCount();
            graph:removeNode( node );
        end
    end

    ---
    -- Checks if the folders of a path already exist as nodes in the graph.
    -- If a folder doesn't exist yet, it will be created and connected to its
    -- parent by an edge.
    -- @param path - The path to resolve.
    --
    local function createNodes( path )
        local parentID = ROOT_FOLDER;
        for folder in path:gmatch('[^/]+') do
            local nodeID = parentID .. '/' .. folder;
            -- Create the path if doesn't exist in the graph yet.
            if not graph:hasNode( nodeID ) then
                local parentNode = graph:getNode( parentID );
                local newNode = spawnNode( folder, nodeID, parentNode, parentID );
                graph:connectNodes( parentNode, newNode );
                parentNode:incrementChildCount();
            end
            parentID = nodeID;
        end
        return graph:getNode( path );
    end

    ---
    -- Returns the node a path is pointng to. If the node doesn't exist in the
    -- graph yet, it will be created.
    -- @param path - The path to resolve.
    --
    local function resolvePath( path )
        if graph:hasNode( path ) then
            return graph:getNode( path );
        end
        return createNodes( path );
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
    -- @param extension
    -- @param mode
    --
    local function applyGitModifier( modifier, path, filename, extension, mode )
        local targetNode = resolvePath( path );

        local modifiedFile;
        if modifier == MOD_ADD then
            modifiedFile = targetNode:addFile( filename, extension );
        elseif modifier == MOD_DELETE then
            if mode == 'normal' then
                modifiedFile = targetNode:markFileForDeletion( filename );
            else
                modifiedFile = targetNode:removeFile( filename, extension );
            end
        elseif modifier == MOD_MODIFY then
            modifiedFile = targetNode:modifyFile( filename );
        end

        -- We only notify observers if the graph isn't modifed in fast forward / rewind mode.
        if mode == 'normal' and modifiedFile then
            notify( EVENT_UPDATE_FILE, modifiedFile, modifier );
        end
    end

    -- ------------------------------------------------
    -- Public Functions
    -- ------------------------------------------------

    function self:draw( camrot, camscale )
        graph:draw( function( node )
            if showLabels then
                local x, y = node:getPosition();
                local radius = node:getRadius();
                love.graphics.setFont( LABEL_FONT );
                love.graphics.print( node:getName(), x, y, -camrot, 1 / camscale, 1 / camscale, -radius * camscale, -radius * camscale );
                love.graphics.setFont( DEFAULT_FONT );
            end
        end,
        function( edge )
            love.graphics.setColor( EDGE_COLOR );
            love.graphics.setLineWidth( edgeWidth );
            love.graphics.line( edge.origin:getX(), edge.origin:getY(), edge.target:getX(), edge.target:getY() );
            love.graphics.setLineWidth( 1 );
            love.graphics.setColor( 255, 255, 255, 255 );
        end);
        love.graphics.draw( spritebatch );
    end

    function self:update( dt )
        spritebatch:clear();
        graph:update( dt, function( node )
            node:update( dt )
            if node:isDead() then
                removeNode( node );
            end
        end);

        notify( EVENT_UPDATE_CENTER, graph:getCenter() );
        notify( EVENT_UPDATE_DIMENSIONS, graph:getBoundaries() );
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
