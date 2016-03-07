local ScreenManager = require('lib.screenmanager.ScreenManager');
local Screen = require('lib.screenmanager.Screen');
local RepositoryHandler = require('src.conf.RepositoryHandler');
local Resources = require('src.Resources');

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

    local function watchLog( name )
        love.window.setFullscreen( config.options.fullscreen, config.options.fullscreenType );
        ScreenManager.switch( 'main', { log = name, config = config } );
    end

    function self:init( params )
        graph = params.graph;
        colors = params.colors;
        config = params.config;
    end

    function self:update( dt )
        graph:update( dt );
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
    end

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

    function self:directorydropped( path )
        local name = path:match( '[\\/]?([^\\/]+)$' );
        RepositoryHandler.add( name, path );
        ScreenManager.switch( 'loading', { config = config } );
    end

    return self;
end

return SelectionScreen;
