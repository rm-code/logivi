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
            local change = commits[index][i];

            print(change.mod .. " - " .. change.path);
            if not root:getNode(change.path) then
                spawnY = spawnY + 15;
                if spawnY > love.graphics.getHeight() - 30 then
                    spawnY = 55;
                    spawnX = spawnX + 400;
                end
                root:append(change.path, FileNode.new(change.path, spawnX, spawnY));
            end
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