local FileManager = require('src.FileManager');

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local File = {};

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local MOD_TIMER = 2;
local MOD_COLOR = {
    add = { 0, 255, 0 },
    del = { 255, 0, 0 },
    mod = { 254, 140, 0 },
};

-- ------------------------------------------------
-- Constructor
-- ------------------------------------------------

function File.new(name, x, y)
    local self = {};

    local posX, posY = x, y;
    local offX, offY = 0, 0;
    local fileColor, extension = FileManager.add(name);
    local currentColor = {};
    local modified = false;
    local timer = MOD_TIMER;

    -- ------------------------------------------------
    -- Private Functions
    -- ------------------------------------------------

    local function lerp(a, b, t)
        return a + (b - a) * t;
    end

    ---
    -- Resets the color values and the timer, and sets
    -- the modified flag to false.
    --
    local function reset()
        timer = MOD_TIMER;
        modified = false;
        currentColor[1] = fileColor[1];
        currentColor[2] = fileColor[2];
        currentColor[3] = fileColor[3];
    end

    -- ------------------------------------------------
    -- Public Functions
    -- ------------------------------------------------

    ---
    -- If the file is marked as modified the color will be lerped from
    -- the modified color to the default file color.
    -- @param dt
    --
    function self:update(dt)
        if modified then
            if timer > 0 then
                timer = timer - dt;
                currentColor[1] = lerp(currentColor[1], fileColor[1], dt * 1.5);
                currentColor[2] = lerp(currentColor[2], fileColor[2], dt * 1.5);
                currentColor[3] = lerp(currentColor[3], fileColor[3], dt * 1.5);
            else
                reset();
            end
        end
    end

    function self:remove()
        FileManager.remove(name);
    end

    ---
    -- Marks the file as modified and changes the
    -- current color to the modified color.
    -- @param mod
    --
    function self:modify(mod)
        modified = true;
        currentColor[1] = MOD_COLOR[mod][1];
        currentColor[2] = MOD_COLOR[mod][2];
        currentColor[3] = MOD_COLOR[mod][3];
    end

    -- ------------------------------------------------
    -- Getters
    -- ------------------------------------------------

    function self:getX()
        return posX + offX;
    end

    function self:getY()
        return posY + offY;
    end

    function self:getColor()
        return currentColor;
    end

    function self:getExtension()
        return extension;
    end

    -- ------------------------------------------------
    -- Setters
    -- ------------------------------------------------

    function self:setOffset(ox, oy)
        offX, offY = ox, oy;
    end

    function self:setPosition(nx, ny)
        posX, posY = nx, ny;
    end

    return self;
end

-- ------------------------------------------------
-- Return Module
-- ------------------------------------------------

return File;
