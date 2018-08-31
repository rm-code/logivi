local ScreenManager = require('lib.screenmanager.ScreenManager');
local Screen = require('lib.screenmanager.Screen');
local ConfigReader = require('src.conf.ConfigReader');
local RepositoryHandler = require('src.conf.RepositoryHandler');
local GraphLibrary = require('lib.graphoon.Graphoon').Graph;
local Resources = require('src.Resources');
local Utility = require( 'src.Utility' );

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local BUTTON_OK = 'Ok';
local BUTTON_HELP = 'Help (online)';

local URL_INSTRUCTIONS = 'https://github.com/rm-code/logivi#generating-git-logs-automatically';

local WARNING_TITLE_NO_GIT   = 'Git is not available';
local WARNING_MESSAGE_NO_GIT = 'LoGiVi can\'t find git in your PATH. This means LoGiVi won\'t be able to create git logs automatically, but can still be used to view pre-generated logs.';

local WARNING_TITLE_NO_REPO   = 'Not a valid git repository';
local WARNING_MESSAGE_NO_REPO = 'The path "%s" does not point to a valid git repository.';

local SPRITE_SIZE = 24;
local SPRITE_SCALE_FACTOR = SPRITE_SIZE / 256;
local SPRITE_OFFSET = 128;

local LABEL_FONT   = Resources.loadFont( 'SourceCodePro-Medium.otf', 20 );
local DEFAULT_FONT = Resources.loadFont( 'default', 12 );
local FILE_SPRITE  = Resources.loadImage( 'file.png' );

local VERSION_STRING = string.format( 'Version %s', getVersion() );

local LOADING_STRING = 'Loading';
local LOADING_DOTS = {
    '',
    ' .',
    ' . .',
    ' . . .'
}
local LOADING_DOT_TIME = 0.15;

local EDGE_COLOR = { 60/255, 60/255, 60/255, 1 };

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local LoadingScreen = {};

-- ------------------------------------------------
-- Constructor
-- ------------------------------------------------

function LoadingScreen.new()
    local self = Screen.new();

    local config;
    local thread;
    local graph;

    local dots;
    local dotTimer;
    local dotIndex;

    local loadingTimer;

    local colors;

    -- ------------------------------------------------
    -- Private Functions
    -- ------------------------------------------------

    ---
    -- Updates the dot-animation indicating the running loading operations.
    -- @param dt (number) Time since the last update in seconds.
    --
    local function updateLoadingDots( dt )
        if dotTimer > LOADING_DOT_TIME then
            dotIndex = dotIndex == #LOADING_DOTS and 1 or dotIndex + 1;
            dots = LOADING_DOTS[dotIndex];
            dotTimer = 0;
        end
        dotTimer = dotTimer + dt;
    end

    ---
    -- Shows warning messages to the user in case something goes wrong while
    -- loading a repository.
    -- @param error (table) A table containing infos about the error.
    --
    local function handleThreadErrors( error )
        if error.msg == 'git_not_found' then
            local pressedbutton = love.window.showMessageBox( WARNING_TITLE_NO_GIT, WARNING_MESSAGE_NO_GIT, { BUTTON_OK, BUTTON_HELP, enterbutton = 1, escapebutton = 1 }, 'warning', false );
            if pressedbutton == 2 then
                love.system.openURL( URL_INSTRUCTIONS );
            end
        elseif error.msg == 'no_repository' then
            love.window.showMessageBox( WARNING_TITLE_NO_REPO, string.format( WARNING_MESSAGE_NO_REPO, error.data ), 'warning', false );
            RepositoryHandler.remove( error.name );
        end
    end

    ---
    -- Adds a new node to the graph representing the loaded repository.
    -- @param info (table) A table containing infos about the loaded repository.
    --
    local function addNewNode( info )
        colors[info] = {
            love.math.random( 0, 255 )/255,
            love.math.random( 0, 255 )/255,
            love.math.random( 0, 255 )/255
        };
        local spawnX = love.graphics.getWidth()  * 0.5 + Utility.randomSign() * love.math.random( 5, 15 );
        local spawnY = love.graphics.getHeight() * 0.5 + Utility.randomSign() * love.math.random( 5, 15 );
        graph:addNode( info, spawnX, spawnY);
        graph:connectIDs( '', info );
    end

    -- ------------------------------------------------
    -- Public Functions
    -- ------------------------------------------------

    ---
    -- Initialises the loading screen.
    -- @param param (table) A table containing certain parameters passed from a
    --                       previous screen / state.
    --
    function self:init( param )
        config = ( param and param.config ) or ConfigReader.init();

        love.window.setMode( config.options.screenWidth, config.options.screenHeight, { borderless = true, msaa = config.options.msaa, vsync = config.options.vsync } );

        RepositoryHandler.init();

        graph = GraphLibrary.new();
        graph:addNode( '', love.graphics.getWidth() * 0.5, love.graphics.getHeight() * 0.5, true );

        thread = love.thread.newThread( 'src/logfactory/LogCreationThread.lua' );
        thread:start( RepositoryHandler.getRepositories() );

        dotIndex = 1;
        dotTimer = 0;
        dots = LOADING_DOTS[dotIndex];

        loadingTimer = 0;

        colors = {
            [''] = { 1, 1, 1 }
        };
    end

    ---
    -- Updates the loading screen and its elements.
    -- @param dt (number) Time since the last update in seconds.
    --
    function self:update( dt )
        graph:update( dt );

        local threadError = thread:getError();
        assert( not threadError, threadError );

        local errChannel = love.thread.getChannel( 'error' );
        local err = errChannel:pop();
        if err then
            handleThreadErrors( err );
        end

        local infoChannel = love.thread.getChannel( 'info' );
        local info = infoChannel:pop();
        if info then
            addNewNode( info );
        end

        if not thread:isRunning() then
            ScreenManager.switch( 'selection', { config = config, graph = graph, colors = colors } );
        end

        loadingTimer = loadingTimer + dt;

        updateLoadingDots( dt );
    end

    ---
    -- Draws the loading screen.
    --
    function self:draw()
        graph:draw( function( node )
            local x, y = node:getPosition();
            love.graphics.setColor( colors[node:getID()] );
            love.graphics.draw( FILE_SPRITE, x, y, 0, SPRITE_SCALE_FACTOR, SPRITE_SCALE_FACTOR, SPRITE_OFFSET, SPRITE_OFFSET );
            love.graphics.setColor( 1, 1, 1 );
            love.graphics.setFont( LABEL_FONT );
            love.graphics.print( node:getID(), x, y, 0, 1, 1, -16, -16 );
            love.graphics.setFont( DEFAULT_FONT );
        end,
        function( edge )
            love.graphics.setColor( EDGE_COLOR );
            love.graphics.setLineWidth( 5 );
            love.graphics.line( edge.origin:getX(), edge.origin:getY(), edge.target:getX(), edge.target:getY() );
            love.graphics.setLineWidth( 1 );
            love.graphics.setColor( 1, 1, 1, 1 );
        end);

        love.graphics.print( LOADING_STRING, 10, love.graphics.getHeight() - 20 );
        love.graphics.print( dots, DEFAULT_FONT:getWidth( LOADING_STRING ) + 10, love.graphics.getHeight() - 20 );
        love.graphics.print( VERSION_STRING, love.graphics.getWidth() - DEFAULT_FONT:getWidth( VERSION_STRING ) - 10, love.graphics.getHeight() - 20 );
    end

    return self;
end

return LoadingScreen;
