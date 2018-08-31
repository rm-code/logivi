local Node = require('src.graph.Node');
local Resources = require('src.Resources');
local GraphLibrary = require('lib.graphoon.Graphoon').Graph;
local Messenger = require('src.messenger.Messenger');
local Utility = require( 'src.Utility' );

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local Graph = {};

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local EVENT = require('src.messenger.Event');

local ROOT_FOLDER = '';
local MOD_ADD     = 'A';
local MOD_DELETE  = 'D';
local MOD_MODIFY  = 'M';

local LABEL_FONT   = Resources.loadFont( 'SourceCodePro-Medium.otf', 20 );
local DEFAULT_FONT = Resources.loadFont( 'default', 12 );
local FILE_SPRITE  = Resources.loadImage( 'file.png' );

local EDGE_COLOR = { 60/255, 60/255, 60/255, 1 };

-- ------------------------------------------------
-- Constructor
-- ------------------------------------------------

---
-- Creates a new graph object.
-- @param edgeWidth  (number)  The width of the connecting edges.
-- @param showLabels (boolean) Wether or not to show labels.
-- @return           (Graph)   A new instance of the graph.
--
function Graph.new( edgeWidth, showLabels )
    local self = {};

    local spritebatch = love.graphics.newSpriteBatch( FILE_SPRITE, 10000, 'stream' );

    -- Create a new graph class.
    GraphLibrary.setNodeClass( Node ); -- Use custom class for Nodes.
    local graph = GraphLibrary.new();
    graph:addNode( ROOT_FOLDER, love.graphics.getWidth() * 0.5, love.graphics.getHeight() * 0.5, false, nil, spritebatch, ROOT_FOLDER );

    local subscription;

    -- ------------------------------------------------
    -- Local Functions
    -- ------------------------------------------------

    ---
    -- Spawns a new node.
    -- @param name     (string) The node's name based on the folder's name.
    -- @param id       (string) The node's unqiue id based on the folder's full path.
    -- @param parent   (Node)   The parent of the node to spawn.
    -- @param parentID (string) The parent's id.
    -- @return         (Node)   The newly spawned node.
    --
    local function spawnNode( name, id, parent, parentID )
        local parentX, parentY = parent:getPosition();
        local offsetX = love.math.random( 100 ) * Utility.randomSign();
        local offsetY = love.math.random( 100 ) * Utility.randomSign();
        return graph:addNode( id, parentX + offsetX, parentY + offsetY, false, parentID, spritebatch, name );
    end

    ---
    -- Removes a node from the graph.
    -- @param node (Node) The node to remove.
    --
    local function removeNode( node )
        local parent = graph:getNode( node:getParent() );
        if parent then
            parent:decrementChildCount();
            graph:removeNode( node );
        end
    end

    ---
    -- Creates all nodes belonging to a path if they don't exist yet.
    -- @param path (string) The path to resolve.
    -- @return     (Node)   The last node in the path.
    --
    local function createNodes( path )
        local parentID = ROOT_FOLDER;
        for folder in path:gmatch('[^/]+') do
            local nodeID = parentID .. '/' .. folder;
            -- Create the node if doesn't exist in the graph yet.
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
    -- @param path (string) The path to resolve.
    -- @return     (Node)   The last node in the path.
    --
    local function resolvePath( path )
        if graph:hasNode( path ) then
            return graph:getNode( path );
        end
        return createNodes( path );
    end

    ---
    -- This function will take a git modifier and apply it to a file.
    -- @param modifier  (string) The modifier to apply to the file.
    -- @param path      (string) The path pointing to the modified file.
    -- @param filename  (string) The file's name.
    -- @param extension (string) The file's extension.
    -- @param mode      (string) The current play mode.
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
            Messenger.publish( EVENT.GRAPH_UPDATE_FILE, modifiedFile, modifier );
        end
    end

    ---
    -- Small hacky fix to make sure empty nodes still have their labels at the
    -- correct position. This simply takes the node's radius and checks if it
    -- is 0 (if it has at least one file) or -24 (if it is empty).
    -- @see https://github.com/rm-code/logivi/issues/69
    -- @param node (Node)   The node for which to generate the radius.
    -- @return     (number) Returns the position at which the node's label should be placed.
    --
    local function getLabelRadius( node )
        local radius = node:getRadius();
        return ( radius == 0 or radius == -24 ) and 12 or radius;
    end

    -- ------------------------------------------------
    -- Public Functions
    -- ------------------------------------------------

    ---
    -- Draws the graph.
    -- @param camrot   (number) The current camera rotation.
    -- @param camscale (number) The current camera scale.
    --
    function self:draw( camrot, camscale )
        graph:draw( function( node )
            if showLabels then
                local x, y = node:getPosition();
                local radius = getLabelRadius( node );
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
            love.graphics.setColor( 1, 1, 1, 1 );
        end);
        love.graphics.draw( spritebatch );
    end

    ---
    -- Updates the graph.
    -- @param dt (number) The delta time passed since the last frame.
    --
    function self:update( dt )
        spritebatch:clear();
        graph:update( dt, function( node )
            node:update( dt )
            if node:isDead() then
                removeNode( node );
            end
        end);

        Messenger.publish( EVENT.GRAPH_UPDATE_CENTER, graph:getCenter() );
        Messenger.publish( EVENT.GRAPH_UPDATE_DIMENSIONS, graph:getBoundaries() );
    end

    ---
    -- Toggles folder labels.
    --
    function self:toggleLabels()
        showLabels = not showLabels;
    end

    function self:reset()
        Messenger.remove( subscription );
    end

    -- ------------------------------------------------
    -- Observed Events
    -- ------------------------------------------------

    subscription = Messenger.observe( EVENT.LOGREADER_CHANGED_FILE, function( ... )
        applyGitModifier( ... );
    end)

    return self;
end

return Graph;
