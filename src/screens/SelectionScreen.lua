local ScreenManager = require('lib.screenmanager.ScreenManager');
local Screen = require('lib.screenmanager.Screen');
local Resources = require('src.Resources');
local RepositoryHandler = require('src.conf.RepositoryHandler');

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local EDGE_COLOR = { 60, 60, 60, 255 };

local SPRITE_SIZE = 24;
local SPRITE_SCALE_FACTOR = SPRITE_SIZE / 256;
local SPRITE_OFFSET = 128;

local LABEL_FONT   = Resources.loadFont( 'SourceCodePro-Medium.otf', 20 );
local DEFAULT_FONT = Resources.loadFont( 'default', 12 );
local FILE_SPRITE  = Resources.loadImage( 'file.png' );

local MESSAGE_FONT = Resources.loadFont( 'SourceCodePro-Medium.otf', 15 );
local NO_REPO_MESSAGE = "Add a repository by dragging its folder on this window!";
local CONFIG_FOLDER_MESSAGE = "Click on the node above to open the config folder!";

local HAND_CURSOR = love.mouse.getSystemCursor( 'hand' );

local VERSION_STRING = string.format( 'Version %s', getVersion() );

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local SelectionScreen = {};

-- ------------------------------------------------
-- Constructor
-- ------------------------------------------------

function SelectionScreen.new()
    local self = Screen.new();

    local graph;
    local colors;
    local config;

    local timer = 0;
    local alpha = 0;

    -- ------------------------------------------------
    -- Private Functions
    -- ------------------------------------------------

    ---
    -- Returns gradually changing values between 0 and 255 which can be used to
    -- make elements slowly pulsate.
    -- @param dt (number) The time since the last update in seconds.
    -- @return   (number) A value between 0 and 255.
    --
    local function pulsate( dt )
        timer = timer + dt;
        local sin = math.sin( timer );
        if sin < 0 then
            timer = 0;
            sin = 0;
        end
        return sin * 255;
    end

    ---
    -- Switches to fullscreen and loads the MainScreen.
    -- @param name (string) The name of the log to watch.
    --
    local function watchLog( name )
        love.window.setFullscreen( config.options.fullscreen, config.options.fullscreenType );
        ScreenManager.switch( 'main', { log = name, config = config } );
    end

    ---
    -- Changes the icon of the mouse cursor based on the element it is above.
    --
    local function updateMouseCursor()
        if graph:getNodeAt( love.mouse.getX(), love.mouse.getY(), 20 ) then
            love.mouse.setCursor( HAND_CURSOR );
        else
            love.mouse.setCursor();
        end
    end

    -- ------------------------------------------------
    -- Public Functions
    -- ------------------------------------------------

    ---
    -- Initialises the SelectionScreen.
    -- @param params (table) A table containing the configuration.
    --
    function self:init( params )
        graph = params.graph;
        colors = params.colors;
        config = params.config;
    end

    ---
    -- Updates the SelectionScreen.
    -- @param dt (number) The time since the last update in seconds.
    --
    function self:update( dt )
        graph:update( dt );
        alpha = pulsate( dt );

        updateMouseCursor();
    end

    ---
    -- Draws the SelectionScreen.
    --
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

        -- Shows info text if no repository can be found.
        if not RepositoryHandler.hasRepositories() then
            love.graphics.setFont( MESSAGE_FONT );
            love.graphics.setColor( 255, 255, 255, alpha );
            love.graphics.print( NO_REPO_MESSAGE, love.graphics.getWidth() * 0.5 - MESSAGE_FONT:getWidth( NO_REPO_MESSAGE ) * 0.5, love.graphics.getHeight() * 0.5 - 60 );
            love.graphics.print( CONFIG_FOLDER_MESSAGE, love.graphics.getWidth() * 0.5 - MESSAGE_FONT:getWidth( CONFIG_FOLDER_MESSAGE ) * 0.5, love.graphics.getHeight() * 0.5 + 60 - MESSAGE_FONT:getHeight( CONFIG_FOLDER_MESSAGE ) );
            love.graphics.setFont( DEFAULT_FONT );
            love.graphics.setColor( 255, 255, 255, 255 );
        end

        love.graphics.setColor( 255, 255, 255, 100 );
        love.graphics.print( VERSION_STRING, love.graphics.getWidth() - DEFAULT_FONT:getWidth( VERSION_STRING ) - 10, love.graphics.getHeight() - 20 );
        love.graphics.setColor( 255, 255, 255, 255 );
    end

    ---
    -- Handles mousereleased events.
    -- @param x (number) Mouse x position, in pixels.
    -- @param y (number) Mouse y position, in pixels.
    --
    function self:mousereleased( mx, my )
        local node = graph:getNodeAt( mx, my, 30 );
        if node then
            if node:getID() == '' then
                love.system.openURL( 'file://' .. love.filesystem.getSaveDirectory() );
            else
                watchLog( node:getID() );
            end
        end
    end

    ---
    -- Handles directorydropped events. When the user drags a folder on the
    -- application window the InputPanel is loaded.
    -- @param path (string) The path of the folder dropped on the window.
    --
    function self:directorydropped( path )
        ScreenManager.push( 'input', path, { config = config } );
    end

    ---
    -- Handles keypressed events.
    -- @param key (string) The pressed key.
    --
    function self:keypressed( key )
        if key == 'escape' then
            love.event.quit();
        end
    end

    return self;
end

return SelectionScreen;
