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
    local date = '';
    local previousAuthor;
    local world;
    local commitTimer = 0;

    -- ------------------------------------------------
    -- Private Functions
    -- ------------------------------------------------

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
    -- Checks if a folder contains a certain file. This is
    -- to prevent crashes when trying to modify or delete a file
    -- that hasn't been added yet. This might happen due to merge
    -- commits.
    -- @param target
    -- @param fileName
    -- @param modifier
    --
    local function setFileModifier(target, fileName, modifier)
        local file = target:getNode(fileName);
        if file then
            file:setModified(true);
        else
            print(fileName .. ' could not be accessed with ' .. modifier .. '-Modifier.');
        end
        return file;
    end

    ---
    -- @param target
    -- @param fileName
    --
    local function modifyFileNodes(target, fileName, modifier)
        if modifier == MODIFIER_ADD then -- Add file
            local color = FileManager.add(fileName);
            target:append(fileName, FileNode.new(fileName, color));
            return setFileModifier(target, fileName, modifier);
        elseif modifier == MODIFIER_MODIFY then
            return setFileModifier(target, fileName, modifier);
        elseif modifier == MODIFIER_DELETE then
            local file = setFileModifier(target, fileName, modifier);
            FileManager.remove(fileName);
            target:remove(fileName);
            return file;
        end
    end

    local function nextCommit()
        if index == #commits then
            return;
        end
        index = index + 1;

        local commitAuthor = AuthorManager.add(commits[index].author);
        previousAuthor = commitAuthor; -- Store author so we can reset him when the next commit is loaded.

        date = string.format("%02d:%02d:%02d - %02d-%02d-%04d",
            commits[index].date.hour, commits[index].date.min, commits[index].date.sec,
            commits[index].date.day, commits[index].date.month, commits[index].date.year);

        for i = 1, #commits[index] do
            local change = commits[index][i];

            -- Split up the file path into subfolders.
            local subfolders, file = splitFilePath(change.path);

            -- Create sub folders if necessary and return the bottom
            -- most node of that file path, to which we will append the
            -- actual file.
            local target = createSubFolders(root, subfolders);

            -- Create the file node at the bottom of the current path tree.
            file = modifyFileNodes(target, file, change.modifier);

            -- Add a link from the file to the author of the commit.
            commitAuthor:addLink(file);
        end
    end

    -- ------------------------------------------------
    -- Public Functions
    -- ------------------------------------------------

    function self:init()
        AuthorManager.init();

        commits = LogReader.loadLog(LOG_FILE);

        world = love.physics.newWorld(0.0, 0.0, true);
        love.physics.setMeter(8); -- In our world 1m == 8px

        root = FolderNode.new('root', world, true);
    end

    function self:draw()
        love.graphics.print(date, 20, 20);
        FileManager.draw();
        AuthorManager.drawList();

        camera:set();
        root:draw();
        AuthorManager.drawLabels();
        camera:unset();
    end

    function self:update(dt)
        world:update(dt) --this puts the world into motion

        camera:checkEdges(root);
        camera:update(dt);

        commitTimer = commitTimer + dt;
        if commitTimer > 0.2 then
            -- Reset links of the previous author.
            if previousAuthor then
                previousAuthor:resetLinks();
            end
            nextCommit();
            commitTimer = 0;
        end

        root:update(dt);

        AuthorManager.update(dt);
    end

    return self;
end

-- ------------------------------------------------
-- Return Module
-- ------------------------------------------------

return MainScreen;
