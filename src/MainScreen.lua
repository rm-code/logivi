local Screen = require('lib/Screen');
local FileHandler = require('src/FileHandler');
local FolderNode = require('src/FolderNode');
local FileNode = require('src/FileNode');

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local MainScreen = {};

-- ------------------------------------------------
-- Constructor
-- ------------------------------------------------

function MainScreen.new()
    local self = Screen.new();

    local commits;
    local index = 0;
    local root = FolderNode.new('root');
    local author = '';
    local date = '';

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
            target:append(subfolders[i], FolderNode.new(subfolders[i]));

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
        if modifier == 'A' then -- Add file
            target:append(fileName, FileNode.new(fileName));
        end
    end

    local function nextCommit()
        if index == #commits then
            return;
        end
        index = index + 1;

        author = commits[index].author;
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
        local log = FileHandler.loadFile('tmplog.txt');
        commits = FileHandler.splitCommits(log);

        root:setPosition(love.graphics.getWidth() * 0.5, love.graphics.getHeight() * 0.5);
    end

    function self:draw()
        love.graphics.print(date, 20, 20);
        love.graphics.print(author, 400, 20);
        root:draw();
    end

    local timer = 0;
    function self:update(dt)
        timer = timer + dt;
        if timer > 0.0 then
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