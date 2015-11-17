local Resources = {};

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local IMG_PATH  = 'res/img/';
local FONT_PATH = 'res/fonts/';

-- ------------------------------------------------
-- Local Variables
-- ------------------------------------------------

local images = {};
local fonts  = {
    default = {
        [12] = love.graphics.newFont(12)
    }
};

-- ------------------------------------------------
-- Public Functions
-- ------------------------------------------------

---
-- Loads an image or returns an already loaded image.
-- @param name - The name of the file to load.
--
function Resources.loadImage(name)
    if not images[name] then
        images[name] = love.graphics.newImage(IMG_PATH .. name);
    end
    return images[name]
end

---
-- Loads a font or returns an already loaded font.
-- @param name - The name of the font to load.
-- @param size - The size of the font to load.
--
function Resources.loadFont(name, size)
    if not fonts[name] then
        fonts[name] = {};
        fonts[name][size] = love.graphics.newFont(FONT_PATH .. name, size);
    elseif not fonts[name][size] then
        fonts[name][size] = love.graphics.newFont(FONT_PATH .. name, size);
    end
    return fonts[name][size];
end

return Resources;
