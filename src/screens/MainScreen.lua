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

local ScreenManager = require('lib.screenmanager.ScreenManager');
local Screen = require('lib.screenmanager.Screen');
local LogReader = require('src.logfactory.LogReader');
local LogLoader = require('src.logfactory.LogLoader');
local Camera = require('src.ui.CamWrapper');
local ConfigReader = require('src.conf.ConfigReader');
local AuthorManager = require('src.AuthorManager');
local FileManager = require('src.FileManager');
local Graph = require('src.graph.Graph');
local Panel = require('src.ui.Panel');
local Timeline = require('src.ui.Timeline');
local InputHandler = require('src.InputHandler');

-- ------------------------------------------------
-- Controls
-- ------------------------------------------------

local toggleAuthors;
local toggleFilePanel;
local toggleLabels;
local toggleTimeline;

local toggleSimulation;
local toggleRewind;
local loadNextCommit;
local loadPrevCommit;

local toggleFullscreen;

local exit;

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local MainScreen = {};

-- ------------------------------------------------
-- Constructor
-- ------------------------------------------------

function MainScreen.new()
    local self = Screen.new();

    local graph;
    local camera;
    local filePanel;
    local timeline;

    -- ------------------------------------------------
    -- Private Functions
    -- ------------------------------------------------

    ---
    -- Assigns keybindings loaded from the config file to a
    -- local variable for faster access.
    -- @param config
    --
    local function assignKeyBindings(config)
        toggleAuthors = config.keyBindings.toggleAuthors;
        toggleFilePanel = config.keyBindings.toggleFileList;
        toggleLabels = config.keyBindings.toggleLabels;
        toggleTimeline = config.keyBindings.toggleTimeline;

        toggleSimulation = config.keyBindings.toggleSimulation;
        toggleRewind = config.keyBindings.toggleRewind;
        loadNextCommit = config.keyBindings.loadNextCommit;
        loadPrevCommit = config.keyBindings.loadPrevCommit;

        toggleFullscreen = config.keyBindings.toggleFullscreen;

        exit = config.keyBindings.exit;
    end

    -- ------------------------------------------------
    -- Public Functions
    -- ------------------------------------------------

    function self:init()
        local config = ConfigReader.init();

        -- Load keybindings.
        assignKeyBindings(config);

        AuthorManager.init(config.aliases, config.avatars, config.options.showAuthors);

        -- Create the camera.
        camera = Camera.new();
        camera:assignKeyBindings(config);

        graph = Graph.new(config.options.edgeWidth, config.options.showLabels);
        graph:register(AuthorManager);
        graph:register(camera);

        -- Initialise LogReader and register observers.
        LogReader.init(LogLoader.loadActiveLog(), config.options.commitDelay, config.options.mode, config.options.autoplay);
        LogReader.register(AuthorManager);
        LogReader.register(graph);

        -- Create panel.
        filePanel = Panel.new(0, 0, 150, 400);
        filePanel:setVisible(config.options.showFileList);

        timeline = Timeline.new(config.options.showTimeline, LogReader.getTotalCommits(), LogReader.getCurrentDate());
    end

    function self:draw()
        camera:draw(function()
            graph:draw(camera:getRotation());
            AuthorManager.drawLabels(camera:getRotation());
        end);

        filePanel:draw(FileManager.draw);
        timeline:draw();
    end

    function self:update(dt)
        LogReader.update(dt);

        graph:update(dt);

        AuthorManager.update(dt);
        filePanel:update(dt);
        timeline:update(dt);
        timeline:setCurrentCommit(LogReader.getCurrentIndex());
        timeline:setCurrentDate(LogReader.getCurrentDate());

        camera:move(dt);
    end

    function self:quit()
        if ConfigReader.getConfig('options').removeTmpFiles then
            ConfigReader.removeTmpFiles();
        end
    end

    function self:keypressed(key)
        if InputHandler.isPressed(key, toggleAuthors) then
            AuthorManager.setVisible(not AuthorManager.isVisible());
        elseif InputHandler.isPressed(key, toggleFilePanel) then
            filePanel:setVisible(not filePanel:isVisible());
        elseif InputHandler.isPressed(key, toggleLabels) then
            graph:toggleLabels();
        elseif InputHandler.isPressed(key, toggleSimulation) then
            LogReader.toggleSimulation();
        elseif InputHandler.isPressed(key, toggleRewind) then
            LogReader.toggleRewind();
        elseif InputHandler.isPressed(key, loadNextCommit) then
            LogReader.loadNextCommit();
        elseif InputHandler.isPressed(key, loadPrevCommit) then
            LogReader.loadPrevCommit();
        elseif InputHandler.isPressed(key, toggleFullscreen) then
            love.window.setFullscreen(not love.window.getFullscreen());
        elseif InputHandler.isPressed(key, toggleTimeline) then
            timeline:toggle();
        elseif InputHandler.isPressed(key, exit) then
            ScreenManager.switch('selection');
        end
    end

    function self:mousepressed(x, y, b)
        filePanel:mousepressed(x, y, b);

        local pos = timeline:getCommitAt(x, y);
        if pos then
            LogReader.setCurrentIndex(pos);
        end
    end

    function self:mousereleased(x, y, b)
        filePanel:mousereleased(x, y, b);
    end

    function self:mousemoved(x, y, dx, dy)
        filePanel:mousemoved(x, y, dx, dy);
    end

    return self;
end

-- ------------------------------------------------
-- Return Module
-- ------------------------------------------------

return MainScreen;
