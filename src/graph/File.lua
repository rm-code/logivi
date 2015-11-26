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
    local targetOffsetX,  targetOffsetY  = 0, 0;
    local currentOffsetX, currentOffsetY = 0, 0;
    local fileColor, extension = color, extension;
    local currentColor = { r = 0, g = 0, b = 0, a = 255 };
    local modified = false;
    local timer = MOD_TIMER;
    local fade = false;
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
        fade = false;
        dead = false;
        currentColor.r = fileColor.r;
        currentColor.g = fileColor.g;
        currentColor.b = fileColor.b;
        currentColor.a = 255;
    end

    ---
    -- Lerps the file from its current offset position to the target offset.
    -- This adds a nice animation effect when files are rearranged around their
    -- parent nodes.
    -- @param dt - The delta time between frames.
    -- @param tarX - The target offset on the x-axis.
    -- @param tarY - The target offset on the y-axis.
    --
    local function animate(dt, tarX, tarY)
        currentOffsetX = lerp(currentOffsetX, tarX, dt * 3.5);
        currentOffsetY = lerp(currentOffsetY, tarY, dt * 3.5);
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
        animate(dt, targetOffsetX, targetOffsetY);

        if fade then
            currentColor.a = math.min(255, math.max(currentColor.a - 3, 0));
            if currentColor.a <= 0 then
                dead = true;
            end
            return;
        end

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
        reset();

        modified = true;
        currentColor.r = MOD_COLOR[mod].r;
        currentColor.g = MOD_COLOR[mod].g;
        currentColor.b = MOD_COLOR[mod].b;

        if mod == 'del' then
            fade = true;
        end
    end

    -- ------------------------------------------------
    -- Getters
    -- ------------------------------------------------

    ---
    -- Returns the real position of the node on the x-axis.
    -- This is the sum of the parent-node's position and the offset of the file.
    --
    function self:getX()
        return posX + currentOffsetX;
    end

    ---
    -- Returns the real position of the node on the y-axis.
    -- This is the sum of the parent-node's position and the offset of the file.
    --
    function self:getY()
        return posY + currentOffsetY;
    end

    ---
    -- Returns the current color of the file.
    -- The table uses rgba keys to store the color.
    --
    function self:getColor()
        return currentColor;
    end

    ---
    -- Returns the extension of the file as a string.
    --
    function self:getExtension()
        return extension;
    end

    ---
    -- Returns true if the file is marked as dead.
    --
    function self:isDead()
        return dead;
    end

    -- ------------------------------------------------
    -- Setters
    -- ------------------------------------------------

    ---
    -- Sets the target offset of the file from its parent node.
    -- This distance is used to plot all the files in a circle around the node.
    -- @param ox - The offset on the x-axis.
    -- @param oy - The offset on the y-axis.
    --
    function self:setOffset(ox, oy)
        targetOffsetX, targetOffsetY = ox, oy;
    end

    ---
    -- Sets the position of the parent node on which the file is located.
    -- @param nx - The new position on the x-axis.
    -- @param ny - The new position on the y-axis.
    --
    function self:setPosition(nx, ny)
        posX, posY = nx, ny;
    end

    return self;
end

-- ------------------------------------------------
-- Return Module
-- ------------------------------------------------

return File;
