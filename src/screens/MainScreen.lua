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

local Screen = require('lib/screenmanager/Screen');
local LogReader = require('src/LogReader');
local Camera = require('lib/Camera');
local ConfigReader = require('src/ConfigReader');
local AuthorManager = require('src/AuthorManager');
local FileManager = require('src/FileManager');
local Graph = require('src/graph/Graph');

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local LOG_FILE = 'log.txt';

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
    local index = 0;
    local date = '';
    local previousAuthor;
    local commitTimer = 0;
    local graph;

    -- ------------------------------------------------
    -- Private Functions
    -- ------------------------------------------------

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

            -- Modify the graph based on the git file status we read from the log.
            local file = graph:applyGitStatus(change.modifier, change.path, change.file);

            -- Add a link from the file to the author of the commit.
            commitAuthor:addLink(file);
        end
    end

    -- ------------------------------------------------
    -- Public Functions
    -- ------------------------------------------------

    function self:init()
        ConfigReader.init();

        -- Set the background color based on the option in the config file.
        love.graphics.setBackgroundColor(ConfigReader.getConfig('options').backgroundColor);
        love.window.setMode(ConfigReader.getConfig('options').screenWidth, ConfigReader.getConfig('options').screenHeight);

        AuthorManager.init(ConfigReader.getConfig('aliases'), ConfigReader.getConfig('avatars'));

        commits = LogReader.loadLog(LOG_FILE);

        graph = Graph.new();
    end

    function self:draw()
        love.graphics.print(date, 20, 20);
        FileManager.draw();
        AuthorManager.drawList();

        camera:set();
        graph:draw();
        AuthorManager.drawLabels();
        camera:unset();
    end

    function self:update(dt)
        local minX, maxX, minY, maxY = graph:getBoundaries();
        camera:track(minX + (maxX - minX) * 0.5, minY + (maxY - minY) * 0.5, 3, dt);

        commitTimer = commitTimer + dt;
        if commitTimer > 0.2 then
            -- Reset links of the previous author.
            if previousAuthor then
                previousAuthor:resetLinks();
            end
            nextCommit();
            commitTimer = 0;
        end

        graph:update(dt);

        AuthorManager.update(dt);
    end

    function self:quit()
        if ConfigReader.getConfig('options').removeTmpFiles then
            ConfigReader.removeTmpFiles();
        end
    end

    return self;
end

-- ------------------------------------------------
-- Return Module
-- ------------------------------------------------

return MainScreen;
