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

local Screen = require('lib.screenmanager.Screen');
local LogLoader = require('src.logfactory.LogLoader');
local ButtonList = require('src.ui.ButtonList');
local InfoPanel = require('src.ui.InfoPanel');
local ConfigReader = require('src.conf.ConfigReader');
local InputHandler = require('src.InputHandler');

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local SelectionScreen = {};

-- ------------------------------------------------
-- Constructor
-- ------------------------------------------------

function SelectionScreen.new()
    local self = Screen.new();

    local config;
    local logList;
    local buttonList;
    local infoPanel;

    local uiElementOffsetX = 20;
    local uiElementOffsetY = 20;
    local uiElementMargin = 5;

    -- ------------------------------------------------
    -- Private Functions
    -- ------------------------------------------------

    ---
    -- Updates the project's window settings based on the config file.
    -- @param options
    --
    local function setWindowMode(options)
        local _, _, flags = love.window.getMode();

        flags.fullscreen = options.fullscreen;
        flags.fullscreentype = options.fullscreenType;
        flags.vsync = options.vsync;
        flags.msaa = options.msaa;
        flags.display = options.display;

        love.window.setMode(options.screenWidth, options.screenHeight, flags);

        local sw, sh = love.window.getDesktopDimensions();
        love.window.setPosition(sw * 0.5 - love.graphics.getWidth() * 0.5, sh * 0.5 - love.graphics.getHeight() * 0.5);
    end

    -- ------------------------------------------------
    -- Public Functions
    -- ------------------------------------------------

    function self:init()
        config = ConfigReader.init();

        -- Set the background color based on the option in the config file.
        love.graphics.setBackgroundColor(config.options.backgroundColor);
        setWindowMode(config.options);

        -- Intitialise LogLoader.
        logList = LogLoader.init();

        -- A scrollable list of buttons which can be used to select a certain log.
        buttonList = ButtonList.new(uiElementOffsetX, uiElementOffsetY, uiElementMargin);
        buttonList:init(logList);

        -- The info panel which displays more information about a selected log.
        infoPanel = InfoPanel.new(uiElementOffsetX + (2 * uiElementMargin) + buttonList:getButtonWidth(), uiElementOffsetY);
        infoPanel:setInfo(logList[1].name);
    end

    function self:update(dt)
        buttonList:update(dt);
        infoPanel:update(dt);
    end

    function self:draw()
        buttonList:draw();
        infoPanel:draw();
        love.graphics.print('Work in Progress (v' .. getVersion() .. ')', uiElementOffsetX, love.graphics.getHeight() - uiElementOffsetY);
    end

    function self:mousepressed(x, y, b)
        buttonList:pressed(x, y, b, infoPanel);
        infoPanel:pressed(x, y, b, infoPanel);
    end

    function self:keypressed(key)
        if InputHandler.isPressed(key, config.keyBindings.exit) then
            love.event.quit();
        end
    end

    return self;
end

return SelectionScreen;
