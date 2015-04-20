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
local LogCreator = require('src.logfactory.LogCreator');
local LogLoader = require('src.logfactory.LogLoader');
local Tooltip = require('src.ui.Tooltip');
local Button = require('src.ui.Button');
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
    local saveDirButton;
    local infoPanel;

    local uiElementPadding = 20;
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

    function self:init(param)
        config = ConfigReader.init();

        -- Set the background color based on the option in the config file.
        love.graphics.setBackgroundColor(config.options.backgroundColor);
        setWindowMode(config.options);

        -- Create git logs for repositories specified in the config file.
        if LogCreator.isGitAvailable() then
            for name, path in pairs(config.repositories) do
                LogCreator.createGitLog(name, path);
                LogCreator.createInfoFile(name, path);
            end
        end

        -- Intitialise LogLoader.
        logList = LogLoader.init();

        -- A scrollable list of buttons which can be used to select a certain log.
        buttonList = ButtonList.new(uiElementPadding, uiElementPadding, uiElementMargin);
        buttonList:init(logList);

        -- The info panel which displays more information about a selected log.
        infoPanel = InfoPanel.new(uiElementPadding + (2 * uiElementMargin) + buttonList:getButtonWidth(), uiElementPadding);
        infoPanel:setInfo(LogLoader.loadInfo(param and param.log or logList[1].name));

        -- Create a button which opens the save directory.
        saveDirButton = Button.new('', uiElementPadding - 10, love.graphics.getHeight() - uiElementPadding - 10, uiElementPadding, uiElementPadding);
        saveDirButton:setTooltip(Tooltip.new('Opens the save directory', 10, 10, 180, 40));
    end

    function self:update(dt)
        buttonList:update(dt);
        infoPanel:update(dt);
        saveDirButton:update(dt, love.mouse.getPosition());
    end

    function self:resize(x, y)
        infoPanel:resize(x, y);
        saveDirButton:setPosition(uiElementPadding - 10, y - uiElementPadding - 10);
    end

    function self:draw()
        buttonList:draw();
        infoPanel:draw();
        saveDirButton:draw();
        love.graphics.print('Work in Progress (v' .. getVersion() .. ')', love.graphics.getWidth() - 180, love.graphics.getHeight() - uiElementPadding);
    end

    function self:mousepressed(x, y, b)
        local logId = buttonList:pressed(x, y, b);
        if logId then
            infoPanel:setInfo(LogLoader.loadInfo(logId));
        end

        logId = infoPanel:pressed(x, y, b);
        if logId and LogCreator.isGitAvailable() and config.repositories[logId] then
            local forceOverwrite = true;
            LogCreator.createGitLog(logId, config.repositories[logId], forceOverwrite);
            LogCreator.createInfoFile(logId, config.repositories[logId], forceOverwrite);
            infoPanel:setInfo(LogLoader.loadInfo(logId));
        end

        if saveDirButton:hasFocus() then
            love.system.openURL('file://' .. love.filesystem.getSaveDirectory());
        end
    end

    function self:keypressed(key)
        if InputHandler.isPressed(key, config.keyBindings.exit) then
            love.event.quit();
        elseif InputHandler.isPressed(key, config.keyBindings.toggleFullscreen) then
            love.window.setFullscreen(not love.window.getFullscreen());
        end
    end

    function self:quit()
        if ConfigReader.getConfig('options').removeTmpFiles then
            ConfigReader.removeTmpFiles();
        end
    end

    return self;
end

return SelectionScreen;
