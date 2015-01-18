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

local ScreenManager = require('lib/screenmanager/ScreenManager');

-- ------------------------------------------------
-- Local Functions
-- ------------------------------------------------

---
-- Check if the hardware supports certain features.
--
local function checkSupport()
    print("\n---- SUPPORTED ---- ");
    print("Canvas:         " .. tostring(love.graphics.isSupported('canvas')));
    print("PO2:            " .. tostring(love.graphics.isSupported('npot')));
    print("Subtractive BM: " .. tostring(love.graphics.isSupported('subtractive')));
    print("Shaders:        " .. tostring(love.graphics.isSupported('shader')));
    print("HDR Canvas:     " .. tostring(love.graphics.isSupported('hdrcanvas')));
    print("Multicanvas:    " .. tostring(love.graphics.isSupported('multicanvas')));
    print("Mipmaps:        " .. tostring(love.graphics.isSupported('mipmap')));
    print("DXT:            " .. tostring(love.graphics.isSupported('dxt')));
    print("BC5:            " .. tostring(love.graphics.isSupported('bc5')));
    print("SRGB:           " .. tostring(love.graphics.isSupported('srgb')));

    print("\n---- RENDERER  ---- ");
    local name, version, vendor, device = love.graphics.getRendererInfo()
    print(string.format("Name: %s \nVersion: %s \nVendor: %s \nDevice: %s", name, version, vendor, device));
end

-- ------------------------------------------------
-- Callbacks
-- ------------------------------------------------

function love.load()
    print("===================")
    print(string.format("Title: '%s'", getTitle()));
    print(string.format("Version: %.4d", getVersion()));
    print(string.format("LOVE Version: %d.%d.%d (%s)", love.getVersion()));
    print(string.format("Resolution: %dx%d", love.window.getDimensions()));

    -- Check the user's hardware.
    checkSupport();
    print("===================")
    print(os.date('%c', os.time()));
    print("===================")

    local screens = {
        main = require('src/screens/MainScreen');
    };

    ScreenManager.init(screens, 'main');
end

function love.draw()
    ScreenManager.draw();

    love.graphics.print(string.format("FT: %.3f ms", 1000 * love.timer.getAverageDelta()), 10, love.window.getHeight() - 60);
    love.graphics.print(string.format("FPS: %.3f fps", love.timer.getFPS()), 10, love.window.getHeight() - 40);
    love.graphics.print(string.format("MEM: %.3f kb", collectgarbage("count")), 10, love.window.getHeight() - 20);
end

function love.update(dt)
    ScreenManager.update(dt);
end

function love.quit(q)
    ScreenManager.quit(q);
end