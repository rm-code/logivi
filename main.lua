local ScreenManager = require('lib.screenmanager.ScreenManager');

-- ------------------------------------------------
-- Local Variables
-- ------------------------------------------------

local showDebug = false;

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

local function drawStats()
    local h = love.graphics.getHeight();
    love.graphics.setColor(100, 100, 100, 255);
    love.graphics.rectangle('fill', 5, h - 185, 200, 200);
    love.graphics.setColor(255, 255, 255, 255);
    love.graphics.print(string.format("FT: %.3f ms", 1000 * love.timer.getAverageDelta()), 10, h - 180);
    love.graphics.print(string.format("FPS: %.3f fps", love.timer.getFPS()), 10, h - 160);
    love.graphics.print(string.format("MEM: %.3f kb", collectgarbage("count")), 10, h - 140);

    local stats = love.graphics.getStats();
    love.graphics.print(string.format("Drawcalls: %d", stats.drawcalls), 10, h - 120);
    love.graphics.print(string.format("Canvas Switches: %d", stats.canvasswitches), 10, h - 100);
    love.graphics.print(string.format("TextureMemory: %.2f kb", stats.texturememory / 1024), 10, h - 80);
    love.graphics.print(string.format("Images: %d", stats.images), 10, h - 60);
    love.graphics.print(string.format("Canvases: %d", stats.canvases), 10, h - 40);
    love.graphics.print(string.format("Fonts: %d", stats.fonts), 10, h - 20);
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
        selection = require('src.screens.SelectionScreen');
        main = require('src.screens.MainScreen');
    };

    ScreenManager.init(screens, 'selection');
end

function love.draw()
    ScreenManager.draw();

    if showDebug then
        drawStats();
    end
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
    if key == ' ' then
        key = 'space';
    elseif tonumber(key) then
        key = tonumber(key);
    end

    if key == 'f1' then
        showDebug = not showDebug;
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
