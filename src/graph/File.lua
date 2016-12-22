local Utility = require( 'src.Utility' );

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

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

---
-- Creates a new File object.
-- @param parentX      (number) The position of the file's parent node along the x-axis.
-- @param parentY      (number) The position of the file's parent node along the y-axis.
-- @param defaultColor (table)  A table containing the RGB values for this file type.
-- @param extension    (string) The file's extension.
-- @return             (File)   A new file instance.
--
function File.new( parentX, parentY, defaultColor, extension )
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
    -- Lerps the file from its current offset position to the target offset.
    -- This adds a nice animation effect when files are rearranged around their
    -- parent nodes.
    -- @param dt   (number) The delta time between frames.
    -- @param tarX (number) The target offset on the x-axis.
    -- @param tarY (number) The target offset on the y-axis.
    --
    local function animate( dt, tarX, tarY )
        currentOffsetX = Utility.lerp( currentOffsetX, tarX, dt * ANIM_TIMER );
        currentOffsetY = Utility.lerp( currentOffsetY, tarY, dt * ANIM_TIMER );
    end

    -- ------------------------------------------------
    -- Public Functions
    -- ------------------------------------------------

    ---
    -- If the file is marked as modified the color will be lerped from the
    -- modified color to the default file color.
    -- @param dt (number) The delta time between frames.
    --
    function self:update( dt )
        animate( dt, targetOffsetX, targetOffsetY );

        -- Slowly change the color from the modified color back to the default.
        currentColor.r = Utility.lerp( currentColor.r, defaultColor.r, dt * MOD_TIMER );
        currentColor.g = Utility.lerp( currentColor.g, defaultColor.g, dt * MOD_TIMER );
        currentColor.b = Utility.lerp( currentColor.b, defaultColor.b, dt * MOD_TIMER );

        -- Slowly fade out the file when it has been marked for deletion.
        if state == 'del' then
            currentColor.a = Utility.clamp( 0, currentColor.a - FADE_TIMER, 255 );
            if currentColor.a == 0 then
                state = 'dead';
            end
        end
    end

    ---
    -- Sets the state of the file and changes the current color to a specific
    -- color based on the used modifier.
    -- @param mod (string) The modifier used on the file.
    --
    function self:setState( mod )
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
    -- @return (number) The position of the file along the x-axis.
    --
    function self:getX()
        return parentX + currentOffsetX;
    end

    ---
    -- Returns the real position of the node on the y-axis.
    -- This is the sum of the parent-node's position and the offset of the file.
    -- @return (number) The position of the file along the y-axis.
    --
    function self:getY()
        return parentY + currentOffsetY;
    end

    ---
    -- Returns the current color of the file. The table uses rgba keys to store
    -- the color.
    -- @return (table) A table containing the RGB values of the file.
    --
    function self:getColor()
        return currentColor;
    end

    ---
    -- Returns the extension of the file as a string.
    -- @return (string) The extension of the file.
    --
    function self:getExtension()
        return extension;
    end

    ---
    -- Returns true if the file is marked as dead.
    -- @return (boolean) True if the file is marked as dead.
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
    -- @param ox (number) The offset from the parent along the x-axis.
    -- @param oy (number) The offset from the parent along the y-axis.
    --
    function self:setOffset( ox, oy )
        targetOffsetX, targetOffsetY = ox, oy;
    end

    ---
    -- Sets the position of the parent node on which the file is located.
    -- @param nx (number) The position of the parent along the x-axis.
    -- @param ny (number) The position of the parent along the y-axis.
    --
    function self:setPosition( nx, ny )
        parentX, parentY = nx, ny;
    end

    return self;
end

-- ------------------------------------------------
-- Return Module
-- ------------------------------------------------

return File;
