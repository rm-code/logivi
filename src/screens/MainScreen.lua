local ScreenManager = require('lib.screenmanager.ScreenManager');
local Screen = require('lib.screenmanager.Screen');
local LogReader = require('src.logfactory.LogReader');
local LogLoader = require('src.logfactory.LogLoader');
local Camera = require('src.ui.CamWrapper');
local AuthorManager = require('src.authors.AuthorManager');
local FileManager = require('src.FileManager');
local Graph = require('src.graph.Graph');
local FilePanel = require('src.ui.FilePanel');
local Timeline = require('src.ui.Timeline');
local InputHandler = require('src.InputHandler');
local RepositoryInfos = require('src.RepositoryInfos');

-- ------------------------------------------------
-- Controls
-- ------------------------------------------------

local toggleAuthorIcons;
local toggleAuthorLabels;
local toggleFilePanel;
local toggleFileLabels;
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
-- Constants
-- ------------------------------------------------

local FIXED_TIMESTEP = 0.016;

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
    -- Assigns keybindings loaded from the config file to a local variable for
    -- faster access.
    --
    local function assignKeyBindings()
        toggleAuthorIcons = config.keyBindings.toggleAuthorIcons;
        toggleAuthorLabels = config.keyBindings.toggleAuthorLabels;
        toggleFilePanel = config.keyBindings.toggleFileList;
        toggleFileLabels = config.keyBindings.toggleFileLabels;
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

    ---
    -- Updates the camera controls.
    -- @param dt (number) Time since the last update in seconds.
    --
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

    ---
    -- Initialises the MainScreen.
    -- @param params (table) A table containing the configuration.
    --
    function self:init( params )
        LogLoader.init();

        -- Store the name of the currently displayed log.
        log = params.log;

        config = params.config;

        -- Load the info file belonging to the git log.
        local info = RepositoryInfos.loadInfo( log );

        -- Load keybindings.
        assignKeyBindings( config );

        AuthorManager.init( info.aliases, config.options.showAuthorIcons, config.options.showAuthorLabels );

        -- Set custom colors.
        FileManager.setColorTable( info.colors );

        -- Create the graph.
        graph = Graph.new( config.options.edgeWidth, config.options.showFileLabels );

        -- Create the camera.
        camera = Camera.new();
        camera:setPosition( love.graphics.getWidth() * 0.5, love.graphics.getHeight() * 0.5 );

        -- Initialise the LogReader which handles the loading and "playing" of commits from a git log.
        LogReader.init( LogLoader.load( log ), config.options.commitDelay, config.options.mode, config.options.autoplay );

        -- Create the file panel.
        filePanel = FilePanel.new( config.options.showFileList, 0, 0, 150, love.graphics.getHeight() - 40 );

        -- Create the timeline.
        timeline = Timeline.new( config.options.showTimeline, LogReader.getTotalCommits(), LogReader.getCurrentDate() );

        -- Run one complete cycle of garbage collection.
        collectgarbage( 'collect' );
    end

    ---
    -- Draws the MainScreen.
    --
    function self:draw()
        camera:draw( function()
            graph:draw( camera:getRotation(), camera:getScale() );
            AuthorManager.draw( camera:getRotation(), camera:getScale() );
        end);

        filePanel:draw();
        timeline:draw();
    end

    ---
    -- Updates the MainScreen.
    -- @param dt (number) The time since the last update in seconds.
    --
    function self:update( dt )
        LogReader.update( dt );

        graph:update( FIXED_TIMESTEP );

        AuthorManager.update( FIXED_TIMESTEP, camera:getRotation() );

        filePanel:setTotalFiles( FileManager.getTotalFiles() );
        filePanel:setSortedList( FileManager.getSortedList() );
        filePanel:update( dt );

        timeline:setCurrentCommit( LogReader.getCurrentIndex() );
        timeline:setCurrentDate( LogReader.getCurrentDate() );
        timeline:update( dt );

        controlCamera( dt );

        camera:update( dt );
    end

    ---
    -- Called when the MainScreen closes.
    --
    function self:close()
        FileManager.reset();
        graph:reset();
        camera:reset();
    end

    ---
    -- Handle keypressed events.
    -- @param key (string) The pressed key.
    --
    function self:keypressed( key )
        if InputHandler.isPressed( key, toggleAuthorIcons ) then
            AuthorManager.toggleIcons();
        elseif InputHandler.isPressed( key, toggleFilePanel ) then
            filePanel:toggle();
        elseif InputHandler.isPressed( key, toggleFileLabels ) then
            graph:toggleLabels();
        elseif InputHandler.isPressed( key, toggleAuthorLabels ) then
            AuthorManager.toggleLabels();
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
            love.window.setFullscreen( false );
            ScreenManager.switch( 'loading', { log = log, config = config } );
        end
    end

    ---
    -- Handles mousepressed events.
    -- @param x (number) The position of the mouse click along the x-axis.
    -- @param _ (number) The position of the mouse click along the y-axis (unused).
    --
    function self:mousepressed( x, _ )
        local pos = timeline:getCommitAt( x );
        if pos then
            LogReader.setCurrentIndex( pos );
        end
    end

    ---
    -- Handles mousemoved events
    -- @param x  (number) Mouse x position.
    -- @param y  (number) Mouse y position.
    -- @param dx (number) The amount moved along the x-axis since the last time
    --                     love.mousemoved was called.
    -- @param dy (number) The amount moved along the y-axis since the last time
    --                     love.mousemoved was called.
    --
    function self:mousemoved( _, _, dx, dy )
        if love.mouse.isDown( 1 ) then
            camera:move( love.timer.getDelta(), dx * 0.5, dy * 0.5 );
        end
    end

    ---
    -- Handles mouse wheel events.
    -- @param x (number) Amount of horizontal mouse wheel movement.
    -- @param y (number) Amount of vertical mouse wheel movement.
    --
    function self:wheelmoved( x, y )
        local mx, my = love.mouse.getPosition();
        if filePanel:intersects( mx, my ) then
            filePanel:scroll( x, y );
        else
            camera:zoom( love.timer.getDelta(), y );
        end
    end

    ---
    -- Handles resize events called when the screen size changes.
    -- @param w (number) The new width, in pixels.
    -- @param h (number) The new height, in pixels.
    --
    function self:resize( w, h )
        timeline:resize( w, h );
    end

    return self;
end

-- ------------------------------------------------
-- Return Module
-- ------------------------------------------------

return MainScreen;
