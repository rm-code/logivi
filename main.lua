local ScreenManager = require('lib.screenmanager.ScreenManager');

-- ------------------------------------------------
-- Local Functions
-- ------------------------------------------------

---
-- Check if the hardware supports certain features.
--
local function checkSupport()
    print("\n---- RENDERER  ---- ");
    local name, version, vendor, device = love.graphics.getRendererInfo();
    print(string.format("Name: %s \nVersion: %s \nVendor: %s \nDevice: %s", name, version, vendor, device));

    print("\n----  SYSTEM   ---- ");
    print(love.system.getOS());
end

-- ------------------------------------------------
-- Callbacks
-- ------------------------------------------------

function love.load()
    print("===================")
    print(string.format("Title: '%s'", getTitle()));
    print(string.format("Version: %.4d", getVersion()));
    print(string.format("LOVE Version: %d.%d.%d (%s)", love.getVersion()));
    print(string.format("Resolution: %dx%d", love.graphics.getDimensions()));

    -- Check the user's hardware.
    checkSupport();
    print("===================")
    print(os.date('%c', os.time()));
    print("===================")

    local screens = {
        loading = require('src.screens.LoadingScreen');
        selection = require('src.screens.SelectionScreen');
        main = require('src.screens.MainScreen');
    };

    ScreenManager.init(screens, 'loading');
end

function love.draw()
    ScreenManager.draw();
end

function love.update(dt)
    ScreenManager.update(dt);
end

function love.quit(q)
    ScreenManager.quit(q);
end

function love.resize(x, y)
    ScreenManager.resize(x, y);
end

function love.keypressed(key)
    -- Transform strings to numbers to fit the control values we read from the config file.
    if tonumber(key) then
        key = tonumber(key);
    end

    ScreenManager.keypressed(key);
end

function love.mousepressed(x, y, b)
    ScreenManager.mousepressed(x, y, b);
end

function love.mousereleased(x, y, b)
    ScreenManager.mousereleased(x, y, b);
end

function love.mousemoved(x, y, dx, dy)
    ScreenManager.mousemoved(x, y, dx, dy);
end

function love.wheelmoved(x, y)
    ScreenManager.wheelmoved(x, y);
end

function love.directorydropped(path)
    ScreenManager.directorydropped(path);
end
