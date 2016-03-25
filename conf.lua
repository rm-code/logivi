local PROJECT_TITLE = "LoGiVi";

local PROJECT_VERSION = "0432";

local PROJECT_IDENTITY = "rmcode_LoGiVi";

local LOVE_VERSION = "0.10.1";

---
-- Initialise LÖVE's config file.
-- @param t (table) The table containing LÖVE's default values.
--
function love.conf( t )
    t.identity = PROJECT_IDENTITY;
    t.version = LOVE_VERSION;
    t.console = true;

    t.accelerometerjoystick = true;
    t.externalstorage = false;
    t.gammacorrect = false;

    t.window.title = PROJECT_TITLE;
    t.window.icon = 'res/img/icon.png';
    t.window.width = 800;
    t.window.height = 600;
    t.window.borderless = false;
    t.window.resizable = true;
    t.window.minwidth = 800;
    t.window.minheight = 600;
    t.window.fullscreen = false;
    t.window.fullscreentype = "exclusive";
    t.window.vsync = true;
    t.window.msaa = 0;
    t.window.display = 1;
    t.window.highdpi = false;
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
    t.modules.touch = true;
    t.modules.video = true;
    t.modules.window = true;
    t.modules.thread = true;
end

---
-- Returns the project's version.
-- @return (string) The project's version.
--
function getVersion()
    if PROJECT_VERSION then
        return PROJECT_VERSION;
    end
end

---
-- Returns the project's title.
-- @return (string) The project's title.
--
function getTitle()
    if PROJECT_TITLE then
        return PROJECT_TITLE;
    end
end
