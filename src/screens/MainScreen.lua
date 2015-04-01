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
local LogReader = require('src.LogReader');
local Camera = require('lib.camera.Camera');
local ConfigReader = require('src.conf.ConfigReader');
local AuthorManager = require('src.AuthorManager');
local FileManager = require('src.FileManager');
local Graph = require('src.graph.Graph');
local Panel = require('src.ui.Panel');

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local LOG_FILE = 'log.txt';

local CAMERA_ROTATION_SPEED = 0.6;
local CAMERA_TRANSLATION_SPEED = 400;
local CAMERA_TRACKING_SPEED = 2;
local CAMERA_ZOOM_SPEED = 0.6;
local CAMERA_MAX_ZOOM = 0.05;
local CAMERA_MIN_ZOOM = 2;

-- ------------------------------------------------
-- Controls
-- ------------------------------------------------

local camera_zoomIn;
local camera_zoomOut;
local camera_rotateL;
local camera_rotateR;
local camera_n;
local camera_s;
local camera_e;
local camera_w;

local toggleAuthors;
local toggleFilePanel;

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local MainScreen = {};

-- ------------------------------------------------
-- Constructor
-- ------------------------------------------------

function MainScreen.new()
    local self = Screen.new();

    local commits;
    local index = 0;
    local date = '';
    local previousAuthor;
    local commitTimer = 0;
    local graph;

    local commitDelay;

    local camera;
    local cx, cy;
    local ox, oy;
    local zoom = 1;

    local filePanel;

    -- ------------------------------------------------
    -- Private Functions
    -- ------------------------------------------------

    local function nextCommit()
        if index == #commits then
            return;
        end
        index = index + 1;

        local commitAuthor = AuthorManager.add(commits[index].email, commits[index].author, graph:getCenter());
        previousAuthor = commitAuthor; -- Store author so we can reset him when the next commit is loaded.

        date = commits[index].date;
        for i = 1, #commits[index] do
            local change = commits[index][i];

            -- Modify the graph based on the git file status we read from the log.
            local file = graph:applyGitStatus(change.modifier, change.path, change.file);

            -- Add a link from the file to the author of the commit.
            commitAuthor:addLink(file);
        end
    end

    ---
    -- Processes camera related controls and updates the camera.
    -- @param cx - The current x-position the camera is looking at.
    -- @param cy - The current y-position the camera is looking at.
    -- @param ox - The current offset of the camera on the x-axis.
    -- @param oy - The current offset of the camera on the y-axis.
    -- @param dt
    --
    local function updateCamera(cx, cy, ox, oy, dt)
        -- Zoom.
        if love.keyboard.isDown(camera_zoomIn) then
            zoom = zoom + CAMERA_ZOOM_SPEED * dt;
        elseif love.keyboard.isDown(camera_zoomOut) then
            zoom = zoom - CAMERA_ZOOM_SPEED * dt;
        end
        zoom = math.max(CAMERA_MAX_ZOOM, math.min(zoom, CAMERA_MIN_ZOOM));
        camera:zoomTo(zoom);

        -- Rotation.
        if love.keyboard.isDown(camera_rotateL) then
            camera:rotate(CAMERA_ROTATION_SPEED * dt);
        elseif love.keyboard.isDown(camera_rotateR) then
            camera:rotate(-CAMERA_ROTATION_SPEED * dt);
        end

        -- Horizontal Movement.
        local dx = 0;
        if love.keyboard.isDown(camera_w) then
            dx = dx - dt * CAMERA_TRANSLATION_SPEED;
        elseif love.keyboard.isDown(camera_e) then
            dx = dx + dt * CAMERA_TRANSLATION_SPEED;
        end
        -- Vertical Movement.
        local dy = 0;
        if love.keyboard.isDown(camera_n) then
            dy = dy - dt * CAMERA_TRANSLATION_SPEED;
        elseif love.keyboard.isDown(camera_s) then
            dy = dy + dt * CAMERA_TRANSLATION_SPEED;
        end

        -- Take the camera rotation into account when calculating the new offset.
        ox = ox + (math.cos(-camera.rot) * dx - math.sin(-camera.rot) * dy);
        oy = oy + (math.sin(-camera.rot) * dx + math.cos(-camera.rot) * dy);

        -- Gradually move the camera to the target position.
        local gx, gy = graph:getCenter();
        cx = cx - (cx - math.floor(gx + ox)) * dt * CAMERA_TRACKING_SPEED;
        cy = cy - (cy - math.floor(gy + oy)) * dt * CAMERA_TRACKING_SPEED;
        camera:lookAt(cx, cy);

        return cx, cy, ox, oy;
    end

    local function setWindowMode(options)
        local w, h, flags = love.window.getMode();

        flags.fullscreen = options.fullscreen;
        flags.fullscreentype = options.fullscreenType;
        flags.vsync = options.vsync;
        flags.msaa = options.msaa;
        flags.display = options.display;
        flags.x = 0;
        flags.y = 0;

        love.window.setMode(options.screenWidth, options.screenHeight, flags);
    end

    -- ------------------------------------------------
    -- Public Functions
    -- ------------------------------------------------

    function self:init()
        local config = ConfigReader.init();

        commitDelay = config.options.commitDelay;

        -- Load key bindings.
        camera_zoomIn = config.keyBindings.camera_zoomIn;
        camera_zoomOut = config.keyBindings.camera_zoomOut;
        camera_rotateL = config.keyBindings.camera_rotateL;
        camera_rotateR = config.keyBindings.camera_rotateR;
        camera_n = config.keyBindings.camera_n;
        camera_s = config.keyBindings.camera_s;
        camera_e = config.keyBindings.camera_e;
        camera_w = config.keyBindings.camera_w;

        toggleAuthors = config.keyBindings.toggleAuthors;
        toggleFilePanel = config.keyBindings.toggleFileList;

        -- Set the background color based on the option in the config file.
        love.graphics.setBackgroundColor(config.options.backgroundColor);
        setWindowMode(config.options);

        AuthorManager.init(config.aliases, config.avatars, config.options.showAuthors);

        commits = LogReader.loadLog(LOG_FILE);

        graph = Graph.new(config.options.edgeWidth);

        -- Create the camera.
        camera = Camera.new();
        cx, cy = 0, 0;
        ox, oy = 0, 0;

        -- Create panel.
        filePanel = Panel.new(0, 0, 150, 400);
        filePanel:setVisible(config.options.showFileList);
    end

    function self:draw()
        camera:draw(function()
            graph:draw(camera.rot);
            AuthorManager.drawLabels(camera.rot);
        end);

        filePanel:draw(FileManager.draw);
    end

    function self:update(dt)
        commitTimer = commitTimer + dt;
        if commitTimer > commitDelay then
            -- Reset links of the previous author.
            if previousAuthor then
                previousAuthor:resetLinks();
            end
            nextCommit();
            commitTimer = 0;
        end

        graph:update(dt);

        AuthorManager.update(dt);
        filePanel:update(dt);

        cx, cy, ox, oy = updateCamera(cx, cy, ox, oy, dt);
    end

    function self:quit()
        if ConfigReader.getConfig('options').removeTmpFiles then
            ConfigReader.removeTmpFiles();
        end
    end

    function self:keypressed(key)
        if key == toggleAuthors then
            AuthorManager.setVisible(not AuthorManager.isVisible());
        elseif key == toggleFilePanel then
            filePanel:setVisible(not filePanel:isVisible());
        end
    end

    function self:mousepressed(x, y, b)
        filePanel:mousepressed(x, y, b);
    end

    function self:mousereleased(x, y, b)
        filePanel:mousereleased(x, y, b);
    end

    function self:mousemoved(x, y, dx, dy)
        filePanel:mousemoved(x, y, dx, dy);
    end

    return self;
end

-- ------------------------------------------------
-- Return Module
-- ------------------------------------------------

return MainScreen;
