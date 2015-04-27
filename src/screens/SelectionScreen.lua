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

local ScreenManager = require('lib.screenmanager.ScreenManager');
local Screen = require('lib.screenmanager.Screen');
local LogCreator = require('src.logfactory.LogCreator');
local LogLoader = require('src.logfactory.LogLoader');
local Button = require('src.ui.Button');
local ButtonList = require('src.ui.ButtonList');
local ConfigReader = require('src.conf.ConfigReader');
local InputHandler = require('src.InputHandler');

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local SelectionScreen = {};

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local HEADER_FONT = love.graphics.newFont('res/fonts/SourceCodePro-Bold.otf', 35);
local TEXT_FONT = love.graphics.newFont('res/fonts/SourceCodePro-Medium.otf', 15);
local DEFAULT_FONT = love.graphics.newFont(12);

-- ------------------------------------------------
-- Constructor
-- ------------------------------------------------

function SelectionScreen.new()
    local self = Screen.new();

    local config;
    local logList;
    local buttonList;
    local saveDirButton;
    local watchButton;
    local refreshButton;

    local uiElementPadding = 20;
    local uiElementMargin = 5;

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

        -- Load info about currently selected log.
        info = LogLoader.loadInfo(param and param.log or logList[1].name);

        -- Create a button which opens the save directory.
        saveDirButton = Button.new('Open', uiElementPadding + (3 * uiElementMargin) + buttonList:getButtonWidth(), love.graphics.getHeight() - 85, 100, 40);
        watchButton = Button.new('Watch', love.graphics.getWidth() - 20 - 80 - 5, love.graphics.getHeight() - 85, 80, 40);
        refreshButton = Button.new('Refresh', love.graphics.getWidth() - (20 + 80 + 5) * 2, love.graphics.getHeight() - 85, 100, 40);
    end

    function self:update(dt)
        buttonList:update(dt);
        saveDirButton:update(dt, love.mouse.getPosition());
        watchButton:update(dt, love.mouse.getPosition());
        refreshButton:update(dt, love.mouse.getPosition());
    end

    function self:resize(nx, ny)
        saveDirButton:setPosition(uiElementPadding + (3 * uiElementMargin) + buttonList:getButtonWidth(), ny - 85);
        watchButton:setPosition(nx - 20 - 80 - 5, ny - 85);
        refreshButton:setPosition(nx - (20 + 80 + 5) * 2, ny - 85);
    end

    function self:draw()
        buttonList:draw();
        saveDirButton:draw();
        love.graphics.print('Work in Progress (v' .. getVersion() .. ')', love.graphics.getWidth() - 180, love.graphics.getHeight() - uiElementPadding);

        local x = uiElementPadding + (2 * uiElementMargin) + buttonList:getButtonWidth();
        local y = uiElementPadding;
        love.graphics.setColor(100, 100, 100, 100);
        love.graphics.rectangle('fill', x, y, love.graphics.getWidth() - x - 20, love.graphics.getHeight() - y - 40);
        love.graphics.setColor(255, 255, 255, 100);
        love.graphics.rectangle('line', x, y, love.graphics.getWidth() - x - 20, love.graphics.getHeight() - y - 40);

        love.graphics.setFont(HEADER_FONT);
        love.graphics.setColor(0, 0, 0, 100);
        love.graphics.print(info.name, x + 25, y + 25);
        love.graphics.setColor(255, 100, 100, 255);
        love.graphics.print(info.name, x + 20, y + 20);
        love.graphics.setColor(255, 255, 255, 255);

        love.graphics.setFont(TEXT_FONT);
        love.graphics.print('First commit:  ' .. info.firstCommit, x + 25, y + 100);
        love.graphics.print('Latest commit: ' .. info.latestCommit, x + 25, y + 125);
        love.graphics.print('Total commits: ' .. info.totalCommits, x + 25, y + 150);

        love.graphics.setFont(DEFAULT_FONT);

        watchButton:draw();
        refreshButton:draw();
    end

    function self:mousepressed(x, y, b)
        if b == 'l' then
            if watchButton:hasFocus() then
                ScreenManager.switch('main', { log = info.name });
            elseif refreshButton:hasFocus() then
                if info.name and LogCreator.isGitAvailable() and config.repositories[info.name] then
                    local forceOverwrite = true;
                    LogCreator.createGitLog(info.name, config.repositories[info.name], forceOverwrite);
                    LogCreator.createInfoFile(info.name, config.repositories[info.name], forceOverwrite);
                    info = LogLoader.loadInfo(info.name);
                end
            end
        end

        local logId = buttonList:pressed(x, y, b);
        if logId then
            info = LogLoader.loadInfo(logId);
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
