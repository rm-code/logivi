local Screen = require('lib/Screen');
local LogReader = require('src/LogReader');
local FolderNode = require('src/nodes/FolderNode');
local FileNode = require('src/nodes/FileNode');
local Camera = require('lib/Camera');
local AuthorManager = require('src/AuthorManager');
local FileManager = require('src/FileManager');

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local LOG_FILE = 'log.txt';
local MODIFIER_ADD = 'A';
local MODIFIER_COPY = 'C';
local MODIFIER_DELETE = 'D';
local MODIFIER_MODIFY = 'M';
local MODIFIER_RENAME = 'R';
local MODIFIER_CHANGE = 'T';
local MODIFIER_UNMERGE = 'U';
local MODIFIER_UNKNOWN = 'X';
local MODIFIER_BROKEN_PAIRING = 'B';

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local MainScreen = {};

-- ------------------------------------------------
-- Constructor
-- ------------------------------------------------

function MainScreen.new()
    local self = Screen.new();

    local camera = Camera.new();
    local commits;
    local root;
    local index = 0;
    local author = '';
    local date = '';
    local world;

    ---
    -- @param path
    --
    local function splitFilePath(path)
        local subfolders = {};
        while path:find('/') do
            local pos = path:find('/');

            -- Store the subfolder name.
            subfolders[#subfolders + 1] = path:sub(1, pos - 1);

            -- Restart the loop with the path minus the previous folder.
            path = path:sub(pos + 1);
        end
        return subfolders, path;
    end

    ---
    -- @param target
    -- @param subfolders
    --
    local function createSubFolders(target, subfolders)
        for i = 1, #subfolders do
            -- Append a new folder node to the parent if there isn't a node
            -- for that folder yet.
            target:append(subfolders[i], FolderNode.new(subfolders[i], world, false, target));

            -- Make the newly added node the new target.
            target = target:getNode(subfolders[i]);
        end
        -- Return the last node in the tree.
        return target;
    end

    ---
    -- @param target
    -- @param fileName
    --
    local function modifyFileNodes(target, fileName, modifier)
        if modifier == MODIFIER_ADD then -- Add file
            local color = FileManager.add(fileName);
            target:append(fileName, FileNode.new(fileName, color));
        elseif modifier == MODIFIER_MODIFY then
            local file = target:getNode(fileName);
            file:setModified(true);
        elseif modifier == MODIFIER_DELETE then
            FileManager.remove(fileName);
            target:remove(fileName);
        end
    end

    local function nextCommit()
        if index == #commits then
            return;
        end
        index = index + 1;

        author = commits[index].author;
        AuthorManager.add(author);

        date = commits[index].date;

        for i = 1, #commits[index] do
            local change = commits[index][i];

            -- Split up the file path into subfolders.
            local subfolders, file = splitFilePath(change.path);

            -- Create sub folders if necessary and return the bottom
            -- most node of that file path, to which we will append the
            -- actual file.
            local target = createSubFolders(root, subfolders);

            -- Create the file node at the bottom of the current path tree.
            modifyFileNodes(target, file, change.modifier);
        end
    end

    function self:init()
        AuthorManager.init();

        commits = LogReader.loadLog(LOG_FILE);

        world = love.physics.newWorld(0.0, 0.0, true);
        love.physics.setMeter(8); -- In our world 1m == 8px

        root = FolderNode.new('root', world, true);
    end

    function self:draw()
        love.graphics.print(date, 20, 20);
        love.graphics.print(author, 400, 20);
        AuthorManager.draw();
        FileManager.draw();

        camera:set();
        root:draw();
        camera:unset();
    end

    local timer = 0;
    function self:update(dt)
        world:update(dt) --this puts the world into motion

        camera:checkEdges(root);
        camera:update(dt);

        timer = timer + dt;
        if timer > 0.2 then
            nextCommit();
            timer = 0;
        end

        root:update(dt);
    end

    return self;
end

-- ------------------------------------------------
-- Return Module
-- ------------------------------------------------

return MainScreen;

--==================================================================================================
-- Created 01.10.14 - 13:18                                                                        =
--==================================================================================================
