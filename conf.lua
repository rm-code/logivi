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

local GAME_TITLE = "LoGiVi";

local LOVE_VERSION = "0.9.2";

local GAME_VERSION = "0142";

-- ------------------------------------------------
-- Local variables
-- ------------------------------------------------

local config;

-- ------------------------------------------------
-- Global Functions
-- ------------------------------------------------

---
-- Initialise löve's config file.
-- @param _conf
--
function love.conf(t)
    t.identity = 'rmcode_LoGiVi';
    t.version = LOVE_VERSION;
    t.console = true;

    t.window.title = GAME_TITLE;
    t.window.icon = nil;
    t.window.width = 800;
    t.window.height = 600;
    t.window.borderless = false;
    t.window.resizable = true;
    t.window.minwidth = 800;
    t.window.minheight = 600;
    t.window.fullscreen = false;
    t.window.fullscreentype = "normal";
    t.window.vsync = true;
    t.window.fsaa = 0;
    t.window.display = 1;
    t.window.highdpi = false;
    t.window.srgb = false;
    t.window.x = nil;
    t.window.y = nil;

    t.modules.audio = true;
    t.modules.event = true;
    t.modules.graphics = true;
    t.modules.image = true;
    t.modules.joystick = true;
    t.modules.keyboard = true;
    t.modules.math = true;
    t.modules.mouse = true;
    t.modules.physics = true;
    t.modules.sound = true;
    t.modules.system = true;
    t.modules.timer = true;
    t.modules.window = true;

    config = t;
end

---
-- Returns the config file.
--
function getConfig()
    if config then
        return config;
    end
end

---
-- Returns the game's version.
--
function getVersion()
    if GAME_VERSION then
        return GAME_VERSION;
    end
end

---
-- Returns the title.
--
function getTitle()
    if GAME_TITLE then
        return GAME_TITLE;
    end
end
