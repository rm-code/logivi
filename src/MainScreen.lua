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
    local root = FolderNode.new();
    local author = '';
    local date = '';

    local spawnX = 20;
    local spawnY = 40;

    ---
    -- @param path
    --
    local function splitFilePath(path)
        local subfolders = {};
        while path:find('/') do
            local pos = path:find('/');

            -- Store the subfolder name.
            subfolders[#subfolders + 1] = path:sub(1, pos - 1);
            print(subfolders[#subfolders]);

            -- Restart the loop with the path minus the previous folder.
            path = path:sub(pos + 1);
        end
        print(path);
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
            target:append(subfolders[i], FolderNode.new());

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
            spawnY = spawnY + 15;
            if spawnY > love.graphics.getHeight() - 30 then
                spawnY = 55;
                spawnX = spawnX + 400;
            end
            target:append(fileName, FileNode.new(fileName, spawnX, spawnY));
        end
    end

    local function nextCommit()
        if index == #commits then
            return;
        end
        index = index + 1;

        author = commits[index].author;
        date = commits[index].date;

        print('===============================================');
        print(author .. '-' .. date);
        for i = 1, #commits[index] do
            print('-----------------------------------------------');

            local change = commits[index][i];
            print(change.modifier .. " - " .. change.path);

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
    end

    function self:draw()
        love.graphics.print(date, 20, 20);
        love.graphics.print(author, 400, 20);
        root:draw();
    end

    local timer = 0;
    function self:update(dt)
        timer = timer + dt;
        if timer > 0.5 then
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