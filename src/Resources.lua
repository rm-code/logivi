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
