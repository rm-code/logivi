local ScreenManager = require('lib.screenmanager.ScreenManager');
local Screen = require('lib.screenmanager.Screen');
local LogLoader = require('src.logfactory.LogLoader');
local ButtonList = require('src.ui.ButtonList');
local Button = require('src.ui.components.Button');
local Header = require('src.ui.components.Header');
local StaticPanel = require('src.ui.components.StaticPanel');
local InputHandler = require('src.InputHandler');
local OpenFolderCommand = require('src.ui.commands.OpenFolderCommand');
local WatchCommand = require('src.ui.commands.WatchCommand');
local Resources = require('src.Resources');

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local SelectionScreen = {};

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local TEXT_FONT    = Resources.loadFont('SourceCodePro-Medium.otf', 15);
local DEFAULT_FONT = Resources.loadFont('default', 12);

local UI_ELEMENT_PADDING = 20;
local UI_ELEMENT_MARGIN  =  5;

-- ------------------------------------------------
-- Constructor
-- ------------------------------------------------

function SelectionScreen.new()
    local self = Screen.new();

    local config;
    local logList;

    local buttonList;
    local buttons;
    local header;
    local panel;

    local info = {};

    -- ------------------------------------------------
    -- Private Functions
    -- ------------------------------------------------

    ---
    -- Updates the project's window settings based on the config file.
    -- @param options
    --
    local function setWindowMode(options)
        local _, _, flags = love.window.getMode();

        -- Only update the window when the values are different from the ones set in the config file.
        if flags.fullscreen ~= options.fullscreen or flags.fullscreentype ~= options.fullscreenType or
                flags.vsync ~= options.vsync or flags.msaa ~= options.msaa or flags.display ~= options.display then

            flags.fullscreen = options.fullscreen;
            flags.fullscreentype = options.fullscreenType;
            flags.vsync = options.vsync;
            flags.msaa = options.msaa;
            flags.display = options.display;

            love.window.setMode(options.screenWidth, options.screenHeight, flags);

            local sw, sh = love.window.getDesktopDimensions();
            love.window.setPosition(sw * 0.5 - love.graphics.getWidth() * 0.5, sh * 0.5 - love.graphics.getHeight() * 0.5);
        end
    end

    -- ------------------------------------------------
    -- Public Functions
    -- ------------------------------------------------

    function self:init( param )
        config = param.config;

        -- Set the background color based on the option in the config file.
        love.graphics.setBackgroundColor(config.options.backgroundColor);
        setWindowMode(config.options);

        -- Intitialise LogLoader.
        logList = LogLoader.init();

        -- A scrollable list of buttons which can be used to select a certain log.
        buttonList = ButtonList.new(UI_ELEMENT_PADDING, UI_ELEMENT_PADDING, UI_ELEMENT_MARGIN);
        buttonList:init(self, logList);

        -- Load info about currently selected log.
        info = LogLoader.loadInfo(param and param.log or logList[1].name);

        local sw, sh = love.graphics.getDimensions();
        buttons = {
            Button.new(OpenFolderCommand.new(love.filesystem.getSaveDirectory()), 'Open', UI_ELEMENT_PADDING + (2 * UI_ELEMENT_MARGIN) + 220, sh - UI_ELEMENT_PADDING - 10 - UI_ELEMENT_PADDING - 40, 100, 40);
            Button.new(WatchCommand.new(self), 'Watch', sw - UI_ELEMENT_PADDING - 10 - 100, sh - UI_ELEMENT_PADDING - 10 - UI_ELEMENT_PADDING - 40, 100, 40);
        };

        header = Header.new(info.name, UI_ELEMENT_PADDING + (2 * UI_ELEMENT_MARGIN) + 200 + 25, UI_ELEMENT_PADDING + 25);
        panel = StaticPanel.new(UI_ELEMENT_PADDING + (2 * UI_ELEMENT_MARGIN) + buttonList:getButtonWidth(), UI_ELEMENT_PADDING, sw - (UI_ELEMENT_PADDING + (2 * UI_ELEMENT_MARGIN) + 200) - 20, sh - UI_ELEMENT_PADDING - 40);
    end

    function self:update(dt)
        buttonList:update(dt);
        for i = 1, #buttons do
            buttons[i]:update(dt);
        end
    end

    function self:resize(nw, nh)
        panel:setDimensions(nw - (UI_ELEMENT_PADDING + (2 * UI_ELEMENT_MARGIN) + 200) - 20, nh - UI_ELEMENT_PADDING - 40)
        buttons[1]:setPosition(UI_ELEMENT_PADDING + (2 * UI_ELEMENT_MARGIN) + 210, nh - UI_ELEMENT_PADDING - 10 - UI_ELEMENT_PADDING - 40);
        buttons[2]:setPosition(nw - UI_ELEMENT_PADDING - 10 - 100, nh - UI_ELEMENT_PADDING - 10 - UI_ELEMENT_PADDING - 40);
    end

    function self:draw()
        buttonList:draw();

        panel:draw();
        header:draw();

        love.graphics.setFont(TEXT_FONT);

        for i = 1, #buttons do
            buttons[i]:draw();
        end

        love.graphics.setFont(DEFAULT_FONT);
        love.graphics.print('Work in Progress (v' .. getVersion() .. ')', love.graphics.getWidth() - 180, love.graphics.getHeight() - UI_ELEMENT_PADDING);
    end

    function self:watchLog()
        ScreenManager.switch( 'main', { log = info.name, config = config } );
    end

    function self:selectLog(name)
        info = LogLoader.loadInfo(name);
        header = Header.new(info.name, UI_ELEMENT_PADDING + (2 * UI_ELEMENT_MARGIN) + 200 + 25, UI_ELEMENT_PADDING + 25);
    end

    function self:mousepressed(x, y, b)
        for i = 1, #buttons do
            buttons[i]:mousepressed(x, y, b);
        end
        buttonList:mousepressed(x, y, b);
    end

    function self:mousereleased(x, y, b)
        for i = 1, #buttons do
            buttons[i]:mousereleased(x, y, b);
        end
    end

    function self:wheelmoved(x, y)
        buttonList:wheelmoved(x, y);
    end

    function self:keypressed(key)
        if InputHandler.isPressed(key, config.keyBindings.exit) then
            love.event.quit();
        elseif InputHandler.isPressed(key, config.keyBindings.toggleFullscreen) then
            love.window.setFullscreen(not love.window.getFullscreen());
        end
    end

    function self:directorydropped(path)
        local name = path:match("/?([^/]+)$"); -- Use the folder's name to store the repo.

        config.repositories[name] = path;

        ScreenManager.switch( 'loading', { config = config } );
    end

    return self;
end

return SelectionScreen;
