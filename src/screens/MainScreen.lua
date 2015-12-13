local ScreenManager = require('lib.screenmanager.ScreenManager');
local Screen = require('lib.screenmanager.Screen');
local LogReader = require('src.logfactory.LogReader');
local LogLoader = require('src.logfactory.LogLoader');
local Camera = require('src.ui.CamWrapper');
local ConfigReader = require('src.conf.ConfigReader');
local AuthorManager = require('src.AuthorManager');
local FileManager = require('src.FileManager');
local Graph = require('src.graph.Graph');
local FilePanel = require('src.ui.components.FilePanel');
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

local camera_zoomIn;
local camera_zoomOut;
local camera_rotateL;
local camera_rotateR;
local camera_n;
local camera_s;
local camera_e;
local camera_w;

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
    local log;

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

        camera_zoomIn = config.keyBindings.camera_zoomIn;
        camera_zoomOut = config.keyBindings.camera_zoomOut;
        camera_rotateL = config.keyBindings.camera_rotateL;
        camera_rotateR = config.keyBindings.camera_rotateR;
        camera_n = config.keyBindings.camera_n;
        camera_s = config.keyBindings.camera_s;
        camera_e = config.keyBindings.camera_e;
        camera_w = config.keyBindings.camera_w;
    end

    local function controlCamera(dt)
        if InputHandler.isDown(camera_zoomIn) then
            camera:zoom(dt, 1);
        elseif InputHandler.isDown(camera_zoomOut) then
            camera:zoom(dt, -1);
        end
        if InputHandler.isDown(camera_rotateL) then
            camera:rotate(dt, -1);
        elseif InputHandler.isDown(camera_rotateR) then
            camera:rotate(dt, 1);
        end
        if InputHandler.isDown(camera_w) then
            camera:move(dt, -1, 0);
        elseif InputHandler.isDown(camera_e) then
            camera:move(dt, 1, 0);
        end
        if InputHandler.isDown(camera_n) then
            camera:move(dt, 0, -1);
        elseif InputHandler.isDown(camera_s) then
            camera:move(dt, 0, 1);
        end
    end

    -- ------------------------------------------------
    -- Public Functions
    -- ------------------------------------------------

    function self:init(param)
        -- Store the name of the currently displayed log.
        log = param.log;

        local config = ConfigReader.init();
        local info = LogLoader.loadInfo(log);

        -- Load keybindings.
        assignKeyBindings(config);

        AuthorManager.init(info.aliases, info.avatars, config.options.showAuthors);

        -- Create the camera.
        camera = Camera.new();

        -- Load custom colors.
        FileManager.setColorTable(info.colors);

        graph = Graph.new(config.options.edgeWidth, config.options.showLabels);
        graph:register(AuthorManager);
        graph:register(camera);

        -- Initialise LogReader and register observers.
        LogReader.init(LogLoader.load(log), config.options.commitDelay, config.options.mode, config.options.autoplay);
        LogReader.register(AuthorManager);
        LogReader.register(graph);

        -- Create panel.
        filePanel = FilePanel.new(FileManager.draw, FileManager.update, 0, 0, 150, love.graphics.getHeight() - 40);
        filePanel:setActive(config.options.showFileList);

        timeline = Timeline.new(config.options.showTimeline, LogReader.getTotalCommits(), LogReader.getCurrentDate());

        -- Run one complete cycle of garbage collection.
        collectgarbage('collect');
    end

    function self:draw()
        camera:draw(function()
            graph:draw(camera:getRotation(), camera:getScale());
            AuthorManager.drawLabels(camera:getRotation(), camera:getScale());
        end);

        filePanel:draw();
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

        controlCamera(dt);

        camera:update(dt);
    end

    function self:close()
        FileManager.reset();
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
            filePanel:toggle();
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
            ScreenManager.switch('selection', { log = log });
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

    function self:wheelmoved(x, y)
        filePanel:wheelmoved(x, y);
    end

    function self:resize(nx, ny)
        timeline:resize(nx, ny);
    end

    return self;
end

-- ------------------------------------------------
-- Return Module
-- ------------------------------------------------

return MainScreen;
