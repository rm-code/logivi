local GraphLibraryNode = require('lib.graphoon.Graphoon').Node;
local FileManager = require('src.FileManager');
local File = require('src.graph.File');

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local Node = {};

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local SPRITE_SIZE = 24;
local SPRITE_SCALE_FACTOR = SPRITE_SIZE / 256;
local SPRITE_OFFSET = 128;
local MIN_ARC_SIZE = SPRITE_SIZE;

-- ------------------------------------------------
-- Constructor
-- ------------------------------------------------

---
-- Creates a new node object.
-- @param id          (string)      The id to use for this node.
-- @param x           (number)      The position at which to spawn the node along the x-axis.
-- @param y           (number)      The position at which to spawn the node along the y-axis.
-- @param anchor      (boolean)     Wether the node is anchored or not.
-- @param parent      (Node)        The node's parent node.
-- @param spritebatch (SpriteBatch) The spritebatch to use for drawing the node's files.
-- @param name        (string)      The node's name.
-- @return            (Node)        A new node instance.
--
function Node.new( id, x, y, anchor, parent, spritebatch, name )
    local self = GraphLibraryNode.new( id, x, y, anchor );

    -- ------------------------------------------------
    -- Local Variables
    -- ------------------------------------------------

    local childCount = 0;

    local files = {};
    local fileCount = 0;

    local radius = 0;

    -- ------------------------------------------------
    -- Local Functions
    -- ------------------------------------------------

    ---
    -- Calculates the arc between files on a layer for a certain angle.
    -- @param layerRadius (number) The current layer's radius.
    -- @param angle       (number) The angle between files on the same layer.
    -- @return            (number) The arc at which to place a certain file around the node.
    --
    local function calcArc( layerRadius, angle )
        return math.pi * layerRadius * ( angle / 180 );
    end

    ---
    -- Calculates how many layers we need and how many files can be placed on
    -- each layer. This basically generates a blueprint of how the files need to
    -- be arranged.
    -- @param count (number) The total amount of files in this node.
    -- @return      (table)  A table containing all layers around the node.
    -- @return      (number) The radius of the biggest layer.
    --
    local function createOnionLayers( count )
        local fileCounter = 0;
        local layerRadius = -SPRITE_SIZE; -- Radius of the circle around the node.
        local layers = {
            { radius = layerRadius, amount = fileCounter }
        };

        for _ = 1, count do
            fileCounter = fileCounter + 1;

            -- Calculate the arc between the file nodes on the current layer.
            -- The more files are on it the smaller it gets.
            local arc = calcArc( layers[#layers].radius, 360 / fileCounter );

            -- If the arc is smaller than the allowed minimum we store the radius
            -- of the current layer and the number of nodes that can be placed
            -- on that layer and move to the next layer.
            if arc < MIN_ARC_SIZE then
                layerRadius = layerRadius + SPRITE_SIZE;

                -- Create a new layer.
                layers[#layers + 1] = { radius = layerRadius, amount = 1 };
                fileCounter = 1;
            else
                layers[#layers].amount = fileCounter;
            end
        end

        return layers, layerRadius;
    end

    ---
    -- Calculates the new position of a file on its layer around the folder node.
    -- @param fileNumber     (number) The n-th file on the layer.
    -- @param layerFileCount (number) The total amount of files on the same layer.
    -- @param layerRadius    (number) The radius of the layer.
    -- @return               (number) The position of the file around the node along the x-axis.
    -- @return               (number) The position of the file around the node along the y-axis.
    --
    local function calculateFilePosition( fileNumber, layerFileCount, layerRadius )
        local angle = 360 / layerFileCount;
        local slice = angle * ( fileNumber - 1 ) * ( math.pi / 180 );
        local fx = layerRadius * math.cos( slice );
        local fy = layerRadius * math.sin( slice );
        return fx, fy;
    end

    ---
    -- Distributes files evenly on a circle around the parent node.
    -- @param count (number) The total amount of files in this node.
    -- @return      (number) The radius of the biggest layer around the node.
    --
    local function plotCircle( count )
        -- Sort files based on their extension before placing them.
        local toSort = {};
        for _, file in pairs( files ) do
            toSort[#toSort + 1] = { extension = file:getExtension(), file = file };
        end
        table.sort(toSort, function( a, b )
            return a.extension > b.extension;
        end)

        -- Get a blueprint of how the file nodes need to be distributed amongst different layers.
        local layers, maxradius = createOnionLayers( count );

        -- Update the position of the file nodes based on the previously calculated onion-layers.
        local fileNumber = 0;
        local layer = 1;
        for i = 1, #toSort do
            local file = toSort[i].file;
            fileNumber = fileNumber + 1;

            -- If we have more files on the current layer than allowed, we "move"
            -- the file to the next layer (this is why we reset the counter to one
            -- instead of zero).
            if fileNumber > layers[layer].amount then
                layer = layer + 1;
                fileNumber = 1;
            end

            -- Calculate the new position of the file on its layer around the folder node.
            file:setOffset( calculateFilePosition( fileNumber, layers[layer].amount, layers[layer].radius ));
        end
        return maxradius;
    end

    -- ------------------------------------------------
    -- Public Functions
    -- ------------------------------------------------

    ---
    -- Updates the node.
    -- @param dt (number) Time since the last update in seconds.
    --
    function self:update( dt )
        self:setMass( fileCount + childCount );
        for fileName, file in pairs( files ) do
            if file:isDead() then
                self:removeFile( fileName, file:getExtension() );
            end
            file:update(dt);
            file:setPosition( self:getPosition() );

            local color = file:getColor();
            spritebatch:setColor( color.r , color.g, color.b, color.a );

            spritebatch:add( file:getX(), file:getY(), 0, SPRITE_SCALE_FACTOR, SPRITE_SCALE_FACTOR, SPRITE_OFFSET, SPRITE_OFFSET );
        end
    end

    ---
    -- Adds a new file to the node.
    -- When the file already exists its modifier is set to "addition" and it is
    -- returned. When the file doesn't exist yet, its color and extension are
    -- requested from the FileManager and a new File object is created. After
    -- the file object has been added to the file list of this node, the layout
    -- of the files around the nodes is recalculated.
    -- @param fileName  (string) The name of the file to add.
    -- @param extension (string) The extension of the file to add.
    -- @return          (File)   The newly added File.
    --
    function self:addFile( fileName, extension )
        -- Exit early if the file already exists.
        if files[fileName] then
            files[fileName]:setState( 'add' );
            return files[fileName];
        end

        -- Get the file color and extension from the FileManager and create the actual file object.
        local color = FileManager.add( extension );
        files[fileName] = File.new( self:getX(), self:getY(), color, extension );
        files[fileName]:setState( 'add' );
        fileCount = fileCount + 1;

        -- Update layout of the files.
        radius = plotCircle( fileCount );
        return files[fileName];
    end

    ---
    -- Sets a file's modifier to deletion.
    -- @param name (string) The name of the file to modify.
    -- @return     (File)   The File marked for deletion.
    --
    function self:markFileForDeletion( fileName )
        local file = files[fileName];

        if not file then
            print('- Can not rem file: ' .. fileName .. ' - It doesn\'t exist.');
            return;
        end

        file:setState('del');

        return file;
    end

    ---
    -- Removes a file from the list of files for this node and notifies the
    -- FileManager that it also needs to be removed from the global file
    -- list. Once the file is removed, the layout of the files around the nodes
    -- is recalculated.
    -- @param fileName  (string) The name of the file to remove.
    -- @param extension (string) The extension of the file to remove.
    -- @return          (File)   The removed File.
    --
    function self:removeFile( fileName, extension )
        local file = files[fileName];

        if not file then
            print('- Can not rem file: ' .. fileName .. ' - It doesn\'t exist.');
            return;
        end

        FileManager.remove( extension );
        files[fileName] = nil;
        fileCount = fileCount - 1;

        radius = plotCircle( fileCount );
        return file;
    end

    ---
    -- Sets a file's modifier to "modification" and returns the file object.
    -- @param name (string) The file to modify.
    -- @return     (File)   The modified File.
    --
    function self:modifyFile( fileName )
        local file = files[fileName]
        if not file then
            print('~ Can not mod file: ' .. fileName .. ' - It doesn\'t exist.');
            return;
        end

        file:setState( 'mod' );
        return file;
    end

    ---
    -- Increments the child counter.
    --
    function self:incrementChildCount()
        childCount = childCount + 1;
    end

    ---
    -- Decrements the child counter.
    --
    function self:decrementChildCount()
        childCount = childCount - 1;
    end

    -- ------------------------------------------------
    -- Getters
    -- ------------------------------------------------

    ---
    -- Returns the node's name.
    -- @return (string) The node's name.
    --
    function self:getName()
        return name;
    end

    ---
    -- Returns the node's parent node.
    -- @return (Node) The node's parent.
    --
    function self:getParent()
        return parent;
    end

    ---
    -- Returns the node's maximum radius.
    -- @return (number) The node's maximum radius.
    --
    --
    function self:getRadius()
        return radius;
    end

    ---
    -- Returns true if the node doesn't contain any files and doesn't have any
    -- children.
    -- @return (boolean) True if the node is empty.
    --
    function self:isDead()
        return fileCount == 0 and childCount == 0;
    end

    return self;
end

return Node;
