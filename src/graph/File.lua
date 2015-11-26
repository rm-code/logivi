local File = {};

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local ANIM_TIMER = 3.5;
local FADE_TIMER = 3.0;
local MOD_TIMER  = 1.5;

local MOD_COLOR = {
    add = { r =   0, g = 255, b = 0, a = 255 },
    del = { r = 255, g =   0, b = 0, a = 255 },
    mod = { r = 254, g = 140, b = 0, a = 255 },
};

-- ------------------------------------------------
-- Constructor
-- ------------------------------------------------

function File.new(posX, posY, defaultColor, extension)
    local self = {};

    local state;

    -- The target and the current offset from the parent node's position.
    -- This is used to arrange the files around a node.
    local targetOffsetX,  targetOffsetY  = 0, 0;
    local currentOffsetX, currentOffsetY = 0, 0;

    -- The actual color currently displayed on screen.
    local currentColor = {};

    -- ------------------------------------------------
    -- Private Functions
    -- ------------------------------------------------

    ---
    -- Linear interpolation between a and b.
    --
    local function lerp(a, b, t)
        return a + (b - a) * t;
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
        currentOffsetX = lerp(currentOffsetX, tarX, dt * ANIM_TIMER);
        currentOffsetY = lerp(currentOffsetY, tarY, dt * ANIM_TIMER);
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

        -- Slowly change the color from the modified color back to the default.
        currentColor.r = lerp(currentColor.r, defaultColor.r, dt * MOD_TIMER);
        currentColor.g = lerp(currentColor.g, defaultColor.g, dt * MOD_TIMER);
        currentColor.b = lerp(currentColor.b, defaultColor.b, dt * MOD_TIMER);

        -- Slowly fade out the file when it has been marked for deletion.
        if state == 'del' then
            currentColor.a = math.max(0, math.min(currentColor.a - FADE_TIMER, 255));
            if currentColor.a == 0 then
                state = 'dead';
            end
        end
    end

    ---
    -- Sets the state of the file and changes the current color to a specific
    -- color based on the used modifier.
    -- @param mod - The modifier used on the file.
    --
    function self:setState(mod)
        state = mod;

        currentColor.r = MOD_COLOR[mod].r;
        currentColor.g = MOD_COLOR[mod].g;
        currentColor.b = MOD_COLOR[mod].b;
        currentColor.a = MOD_COLOR[mod].a;
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
        return state == 'dead';
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
