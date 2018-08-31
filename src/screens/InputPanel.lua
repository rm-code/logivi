local ScreenManager = require('lib.screenmanager.ScreenManager');
local Screen = require('lib.screenmanager.Screen');
local Resources = require('src.Resources');
local RepositoryHandler = require('src.conf.RepositoryHandler');

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local INFO_FONT  = Resources.loadFont( 'SourceCodePro-Medium.otf', 10 );
local LABEL_FONT = Resources.loadFont( 'SourceCodePro-Medium.otf', 13 );

local PANEL_WIDTH  = 280;
local PANEL_HEIGHT =  60;
local MAX_LENGTH   =  30;

local BG_COLOR = { 60/255, 60/255, 60/255 };

local INPUT_MESSAGE = "Please enter a name for the repository:";

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local InputPanel = {};

-- ------------------------------------------------
-- Constructor
-- ------------------------------------------------

function InputPanel.new()
    local self = Screen.new();

    local input = {};
    local index = 1;
    local text = '';
    local config;
    local path;

    -- ------------------------------------------------
    -- Public Functions
    -- ------------------------------------------------

    ---
    -- Initialises the InputPanel.
    -- @param npath  (string) The path to the directory which was dropped on the application window.
    -- @param params (table)  A table containing the general configuration of LoGiVi.
    --
    function self:init( npath, params )
        path = npath;
        config = params.config;
    end

    ---
    -- Draws the InputPanel.
    --
    function self:draw()
        local sw, sh = love.graphics.getDimensions();

        local x = sw * 0.5 - PANEL_WIDTH * 0.5;
        local y = sh * 0.5 - PANEL_HEIGHT * 0.5;

        love.graphics.setColor( 0, 0, 0, 200 );
        love.graphics.rectangle( 'fill' , 0, 0, sw, sh );
        love.graphics.setColor( BG_COLOR );
        love.graphics.rectangle( 'fill', x, y, PANEL_WIDTH, PANEL_HEIGHT, 20, 20, 20 );
        love.graphics.setColor( 255, 255, 255 );
        love.graphics.setFont( INFO_FONT );
        love.graphics.print( INPUT_MESSAGE , x + 20, y + 15 );
        love.graphics.setFont( LABEL_FONT );
        love.graphics.print( text, x + 20, y + 35 );
    end

    ---
    -- Handles keypressed events.
    -- @param key (string) The pressed key.
    --
    function self:keypressed( key )
        if key == 'escape' then
            ScreenManager.pop();
        end
        if key == 'backspace' then
            self:remove();
        end
        if key == 'return' then
            RepositoryHandler.add( text, path );
            ScreenManager.switch( 'loading', { config = config } );
        end
    end

    ---
    -- Handles textinput events.
    -- @param txt (string) The user's text input.
    --
    function self:textinput( txt )
        if index < MAX_LENGTH then
            table.insert( input, index, txt );
            text = table.concat( input );
            index = index + 1;
        end
    end

    ---
    -- Removes the last character in the input table.
    --
    function self:remove()
        index = math.max( 1, index - 1 );
        table.remove( input, index );
        text = table.concat( input );
    end

    return self;
end

return InputPanel;
