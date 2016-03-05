local ScreenManager = require('lib.screenmanager.ScreenManager');
local Screen = require('lib.screenmanager.Screen');
local ConfigReader = require('src.conf.ConfigReader');
local GraphLibrary = require('lib.graphoon.Graphoon').Graph;
local Resources = require('src.Resources');

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local BUTTON_OK = 'Ok';
local BUTTON_HELP = 'Help (online)';

local URL_INSTRUCTIONS = 'https://github.com/rm-code/logivi#generating-git-logs-automatically';

local WARNING_TITLE_NO_GIT   = 'Git is not available';
local WARNING_MESSAGE_NO_GIT = 'LoGiVi can\'t find git in your PATH. This means LoGiVi won\'t be able to create git logs automatically, but can still be used to view pre-generated logs.';

local WARNING_TITLE_NO_REPO   = 'Not a valid git repository';
local WARNING_MESSAGE_NO_REPO = 'The path "%s" does not point to a valid git repository. Make sure you have specified the full path in the settings file.';

local SPRITE_SIZE = 24;
local SPRITE_SCALE_FACTOR = SPRITE_SIZE / 256;
local SPRITE_OFFSET = 128;

local LABEL_FONT   = Resources.loadFont( 'SourceCodePro-Medium.otf', 20 );
local DEFAULT_FONT = Resources.loadFont( 'default', 12 );
local FILE_SPRITE  = Resources.loadImage( 'file.png' );

local LOADING_DOT = ' .';
local LOADING_MAX_LENGTH = 6;
local LOADING_DOT_TIME = 0.2;

local LOADING_TIME = 2;

local EDGE_COLOR = { 60, 60, 60, 255 };

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

    local loadingTimer;

    local colors;

    -- ------------------------------------------------
    -- Private Functions
    -- ------------------------------------------------

    ---
    -- Returns a random sign (+ or -).
    --
    local function randomSign()
        return love.math.random( 0, 1 ) == 0 and -1 or 1;
    end

    local function updateDots( dt )
        if dotTimer > LOADING_DOT_TIME then
            if dots:len() >= LOADING_MAX_LENGTH then
                dots = '';
            else
                dots = dots .. LOADING_DOT;
            end
            dotTimer = 0;
        end
        dotTimer = dotTimer + dt;
    end

    -- ------------------------------------------------
    -- Public Functions
    -- ------------------------------------------------

    function self:init( param )
        config = ( param and param.config ) or ConfigReader.init();

        graph = GraphLibrary.new();
        graph:addNode( '', love.graphics.getWidth() * 0.5, love.graphics.getHeight() * 0.5, true );

        thread = love.thread.newThread( "src/logfactory/CreateLogsThread.lua" );
        thread:start( config.repositories );

        dots = '';
        dotTimer = 0;

        loadingTimer = 0;

        colors = {
            [''] = { 255, 255, 255 }
        };
    end

    function self:update( dt )
        graph:update( dt );

        local threadError = thread:getError()
        assert( not threadError, threadError );

        local errChannel = love.thread.getChannel( 'error' );
        local err = errChannel:pop();
        if err then
            if err.msg == 'git_not_found' then
                -- Show a warning to the user.
                local pressedbutton = love.window.showMessageBox(WARNING_TITLE_NO_GIT, WARNING_MESSAGE_NO_GIT, { BUTTON_OK, BUTTON_HELP, enterbutton = 1, escapebutton = 1 }, 'warning', false);
                if pressedbutton == 2 then
                    love.system.openURL(URL_INSTRUCTIONS);
                end
            elseif err.msg == 'no_repository' then
                love.window.showMessageBox(WARNING_TITLE_NO_REPO, string.format(WARNING_MESSAGE_NO_REPO, err.data), 'warning', false);
            end
        end

        local infoChannel = love.thread.getChannel( 'info' );
        local info = infoChannel:pop();
        if info then
            colors[info] = {
                love.math.random( 0, 255 ),
                love.math.random( 0, 255 ),
                love.math.random( 0, 255 )
            };
            graph:addNode( info, love.graphics.getWidth() * 0.5 + randomSign() * love.math.random( 5, 15 ), love.graphics.getHeight() * 0.5 + randomSign() * love.math.random( 5, 15 ));
            graph:connectIDs( '', info );
        end

        if not thread:isRunning() and loadingTimer > LOADING_TIME then
            ScreenManager.switch( 'selection', { config = config, graph = graph, colors = colors } );
        end

        loadingTimer = loadingTimer + dt;

        updateDots( dt );
    end

    function self:draw()
        graph:draw( function( node )
            local x, y = node:getPosition();
            love.graphics.setColor( colors[node:getID()] );
            love.graphics.draw( FILE_SPRITE, x, y, 0, SPRITE_SCALE_FACTOR, SPRITE_SCALE_FACTOR, SPRITE_OFFSET, SPRITE_OFFSET );
            love.graphics.setColor( 255, 255, 255 );
            love.graphics.setFont( LABEL_FONT );
            love.graphics.print( node:getID(), x, y, 0, 1, 1, -16, -16 );
            love.graphics.setFont( DEFAULT_FONT );
        end,
        function( edge )
            love.graphics.setColor( EDGE_COLOR );
            love.graphics.setLineWidth( 5 );
            love.graphics.line( edge.origin:getX(), edge.origin:getY(), edge.target:getX(), edge.target:getY() );
            love.graphics.setLineWidth( 1 );
            love.graphics.setColor( 255, 255, 255, 255 );
        end);

        love.graphics.print( 'Loading' .. dots, 10, love.graphics.getHeight() - 20 );
    end

    return self;
end

return LoadingScreen;
