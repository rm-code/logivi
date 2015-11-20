local File = {};

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local MOD_TIMER = 2;
local MOD_COLOR = {
    add = { r =   0, g = 255, b = 0 },
    del = { r = 255, g =   0, b = 0 },
    mod = { r = 254, g = 140, b = 0 },
};

-- ------------------------------------------------
-- Constructor
-- ------------------------------------------------

function File.new(name, color, extension, x, y)
    local self = {};

    local posX, posY = x, y;
    local offX, offY = 0, 0;
    local fileColor, extension = color, extension;
    local currentColor = { r = 0, g = 0, b = 0};
    local modified = false;
    local timer = MOD_TIMER;
    local dead = false;

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
        currentColor.r = fileColor.r;
        currentColor.g = fileColor.g;
        currentColor.b = fileColor.b;
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
                currentColor.r = lerp(currentColor.r, fileColor.r, dt * 1.5);
                currentColor.g = lerp(currentColor.g, fileColor.g, dt * 1.5);
                currentColor.b = lerp(currentColor.b, fileColor.b, dt * 1.5);
            else
                reset();
            end
        end
    end

    ---
    -- Marks the file as modified and changes the
    -- current color to the modified color.
    -- @param mod
    --
    function self:modify(mod)
        modified = true;
        currentColor.r = MOD_COLOR[mod].r;
        currentColor.g = MOD_COLOR[mod].g;
        currentColor.b = MOD_COLOR[mod].b;
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
