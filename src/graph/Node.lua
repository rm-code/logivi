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
        local fileCounter = 0;
        local radius = -SPRITE_SIZE; -- Radius of the circle around the node.
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
                radius = radius + SPRITE_SIZE;

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
        -- Sort files based on their extension before placing them.
        local toSort = {};
        for _, file in pairs(files) do
            toSort[#toSort + 1] = { extension = file:getExtension(), file = file };
        end
        table.sort(toSort, function(a, b)
            return a.extension > b.extension;
        end)

        -- Get a blueprint of how the file nodes need to be distributed amongst different layers.
        local layers, maxradius = createOnionLayers(count);

        -- Update the position of the file nodes based on the previously calculated onion-layers.
        local fileCounter = 0;
        local layer = 1;
        for i = 1, #toSort do
            local file = toSort[i].file;
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

    function self:update( dt )
        self:setMass( 0.015 * ( childCount + math.log( math.max( SPRITE_SIZE, radius ) )));
        for name, file in pairs( files ) do
            if file:isDead() then
                self:removeFile( name, file:getExtension() );
            end
            file:update(dt);
            file:setPosition( self:getPosition() );

            local color = file:getColor();
            spritebatch:setColor( color.r, color.g, color.b, color.a );

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
    -- @param name - The name of the file to add.
    -- @param extension - The extension of the file to add.
    --
    function self:addFile(name, extension)
        -- Exit early if the file already exists.
        if files[name] then
            files[name]:setState('add');
            return files[name];
        end

        -- Get the file color and extension from the FileManager and create the actual file object.
        local color = FileManager.add(name, extension);
        files[name] = File.new( self:getX(), self:getY(), color, extension);
        files[name]:setState('add');
        fileCount = fileCount + 1;

        -- Update layout of the files.
        radius = plotCircle(files, fileCount);
        return files[name];
    end

    ---
    -- Sets a file's modifier to deletion.
    -- @param name - The name of the file to modify.
    --
    function self:markFileForDeletion(name)
        local file = files[name];

        if not file then
            print('- Can not rem file: ' .. name .. ' - It doesn\'t exist.');
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
    -- @param name - The name of the file to remove.
    -- @param extension - The extension of the file to remove.
    --
    function self:removeFile(name, extension)
        local file = files[name];

        if not file then
            print('- Can not rem file: ' .. name .. ' - It doesn\'t exist.');
            return;
        end

        -- Store a reference to the file which can be returned
        -- after the file has been removed from the table.
        FileManager.remove(name, extension);
        files[name] = nil;
        fileCount = fileCount - 1;

        radius = plotCircle(files, fileCount);
        return file;
    end

    ---
    -- Sets a file's modifier to "modification" and returns the file object.
    -- @param name - The file to modify.
    --
    function self:modifyFile(name)
        local file = files[name]
        if not file then
            print('~ Can not mod file: ' .. name .. ' - It doesn\'t exist.');
            return;
        end

        file:setState('mod');
        return file;
    end

    function self:incrementChildCount()
        childCount = childCount + 1;
    end

    function self:decrementChildCount()
        childCount = childCount - 1;
    end

    -- ------------------------------------------------
    -- Getters
    -- ------------------------------------------------

    function self:getName()
        return name;
    end

    function self:getParent()
        return parent;
    end

    function self:getRadius()
        return radius;
    end

    ---
    -- Returns true if the node doesn't contain any files and doesn't have any
    -- children.
    --
    function self:isDead()
        return fileCount == 0 and childCount == 0;
    end

    return self;
end

return Node;
