local ScreenManager = require('lib.screenmanager.ScreenManager');
local Screen = require('lib.screenmanager.Screen');
local LogReader = require('src.logfactory.LogReader');
local LogLoader = require('src.logfactory.LogLoader');
local Camera = require('src.ui.CamWrapper');
local AuthorManager = require('src.AuthorManager');
local FileManager = require('src.FileManager');
local Graph = require('src.graph.Graph');
local FilePanel = require('src.ui.components.FilePanel');
local Timeline = require('src.ui.Timeline');
local InputHandler = require('src.InputHandler');
local Messenger = require( 'src.messenger.Messenger' );

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

local cameraZoomIn;
local cameraZoomOut;
local cameraRotateL;
local cameraRotateR;
local cameraN;
local cameraS;
local cameraE;
local cameraW;

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
    local config;

    -- ------------------------------------------------
    -- Private Functions
    -- ------------------------------------------------

    ---
    -- Assigns keybindings loaded from the config file to a
    -- local variable for faster access.
    --
    local function assignKeyBindings()
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

        cameraZoomIn = config.keyBindings.camera_zoomIn;
        cameraZoomOut = config.keyBindings.camera_zoomOut;
        cameraRotateL = config.keyBindings.camera_rotateL;
        cameraRotateR = config.keyBindings.camera_rotateR;
        cameraN = config.keyBindings.camera_n;
        cameraS = config.keyBindings.camera_s;
        cameraE = config.keyBindings.camera_e;
        cameraW = config.keyBindings.camera_w;
    end

    local function controlCamera( dt )
        if InputHandler.isDown( cameraZoomIn ) then
            camera:zoom( dt, 1 );
        elseif InputHandler.isDown( cameraZoomOut ) then
            camera:zoom( dt, -1 );
        end
        if InputHandler.isDown( cameraRotateL ) then
            camera:rotate( dt, -1 );
        elseif InputHandler.isDown( cameraRotateR ) then
            camera:rotate( dt, 1 );
        end
        if InputHandler.isDown( cameraW ) then
            camera:move( dt, -1, 0 );
        elseif InputHandler.isDown( cameraE ) then
            camera:move( dt, 1, 0 );
        end
        if InputHandler.isDown( cameraN ) then
            camera:move( dt, 0, -1 );
        elseif InputHandler.isDown( cameraS ) then
            camera:move( dt, 0, 1 );
        end
    end

    -- ------------------------------------------------
    -- Public Functions
    -- ------------------------------------------------

    function self:init( param )
        Messenger.clear();

        -- Store the name of the currently displayed log.
        log = param.log;

        config = param.config;
        local info = LogLoader.loadInfo( log );

        -- Load keybindings.
        assignKeyBindings( config );

        AuthorManager.init( info.aliases, config.options.showAuthors );

        -- Create the camera.
        camera = Camera.new();

        -- Load custom colors.
        FileManager.setColorTable( info.colors );

        graph = Graph.new( config.options.edgeWidth, config.options.showLabels );

        LogReader.init( LogLoader.load( log ), config.options.commitDelay, config.options.mode, config.options.autoplay );

        -- Create panel.
        filePanel = FilePanel.new( FileManager.draw, FileManager.update, 0, 0, 150, love.graphics.getHeight() - 40 );
        filePanel:setActive( config.options.showFileList );

        timeline = Timeline.new( config.options.showTimeline, LogReader.getTotalCommits(), LogReader.getCurrentDate() );

        -- Run one complete cycle of garbage collection.
        collectgarbage( 'collect' );
    end

    function self:draw()
        camera:draw(function()
            graph:draw( camera:getRotation(), camera:getScale() );
            AuthorManager.draw( camera:getRotation(), camera:getScale() );
        end);

        filePanel:draw();
        timeline:draw();
    end

    function self:update( dt )
        LogReader.update( dt );

        graph:update( dt );

        AuthorManager.update( dt, camera:getRotation() );
        filePanel:update( dt );
        timeline:update( dt );
        timeline:setCurrentCommit( LogReader.getCurrentIndex() );
        timeline:setCurrentDate( LogReader.getCurrentDate() );

        controlCamera( dt );

        camera:update( dt );
    end

    function self:close()
        FileManager.reset();
    end

    function self:keypressed( key )
        if InputHandler.isPressed( key, toggleAuthors ) then
            AuthorManager.setVisible( not AuthorManager.isVisible() );
        elseif InputHandler.isPressed( key, toggleFilePanel ) then
            filePanel:toggle();
        elseif InputHandler.isPressed( key, toggleLabels ) then
            graph:toggleLabels();
        elseif InputHandler.isPressed( key, toggleSimulation ) then
            LogReader.toggleSimulation();
        elseif InputHandler.isPressed( key, toggleRewind ) then
            LogReader.toggleRewind();
        elseif InputHandler.isPressed( key, loadNextCommit ) then
            LogReader.loadNextCommit();
        elseif InputHandler.isPressed( key, loadPrevCommit ) then
            LogReader.loadPrevCommit();
        elseif InputHandler.isPressed( key, toggleFullscreen ) then
            love.window.setFullscreen( not love.window.getFullscreen() );
        elseif InputHandler.isPressed( key, toggleTimeline ) then
            timeline:toggle();
        elseif InputHandler.isPressed( key, exit ) then
            ScreenManager.switch( 'selection', { log = log, config = config } );
        end
    end

    function self:mousepressed( x, y )
        local pos = timeline:getCommitAt( x, y );
        if pos then
            LogReader.setCurrentIndex( pos );
        end
    end

    function self:mousemoved( _, _, dx, dy )
        if love.mouse.isDown( 1 ) then
            camera:move( love.timer.getDelta(), dx * 0.5, dy * 0.5 );
        end
    end

    function self:wheelmoved( x, y )
        local mx, my = love.mouse.getPosition();
        if filePanel:intersects( mx, my ) then
            filePanel:wheelmoved( x, y );
        else
            camera:zoom( love.timer.getDelta(), y );
        end
    end

    function self:resize( nx, ny )
        timeline:resize( nx, ny );
    end

    return self;
end

-- ------------------------------------------------
-- Return Module
-- ------------------------------------------------

return MainScreen;
