local Resources = require( 'src.Resources' );

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local LABEL_FONT   = Resources.loadFont( 'SourceCodePro-Medium.otf', 20 );
local DEFAULT_FONT = Resources.loadFont( 'default', 12 );

local AVATAR_SIZE = 48;
local INACTIVITY_TIMER = 2;
local MOVEMENT_TIMER = 0.5;
local FADE_FACTOR = 125;
local DEFAULT_AVATAR_ALPHA = 255;
local DEFAULT_LINK_ALPHA = 100;
local DAMPING_FACTOR = 0.90;
local FORCE_MAX = 2;
local FORCE_SPRING = -0.5;
local BEAM_WIDTH = 3;
local MOVEMENT_SPEED = 32;

local LINK_COLOR = {
    A = { r =   0, g = 255, b = 0 },
    D = { r = 255, g =   0, b = 0 },
    M = { r = 254, g = 140, b = 0 },
};

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local Author = {};

-- ------------------------------------------------
-- Constructor
-- ------------------------------------------------

function Author.new( name, avatar, spritebatch, cx, cy )
    local self = {};

    local active = true;

    local posX, posY = cx + love.math.random( 5, 200 ) * ( love.math.random( 0, 1 ) == 0 and -1 or 1 ), cy + love.math.random( 5, 200 ) * ( love.math.random( 0, 1 ) == 0 and -1 or 1 );
    local accX, accY = 0, 0;
    local velX, velY = 0, 0;

    local links = {};
    local inactivity = 0;
    local avatarAlpha = DEFAULT_AVATAR_ALPHA;
    local linkAlpha = DEFAULT_LINK_ALPHA;

    -- Avatar's width and height.
    local aw, ah = avatar:getWidth(), avatar:getHeight();

    -- ------------------------------------------------
    -- Private Functions
    -- ------------------------------------------------

    ---
    -- Clamps a value to a certain range.
    -- @param min (number) The minimum value to clamp to.
    -- @param val (number) The value to clamp.
    -- @param max (number) The maximum value to clamp to.
    -- @return    (number) The clamped value.
    --
    local function clamp( min, val, max )
        return math.max( min, math.min( val, max ));
    end

    ---
    -- Resets an author's state.
    --
    local function reactivate()
        inactivity = 0;
        active = true;
        avatarAlpha = DEFAULT_AVATAR_ALPHA;
        linkAlpha = DEFAULT_LINK_ALPHA;
    end

    ---
    -- Deactivates an author and hides resets his links.
    --
    local function deactivate()
        active = false;
        self:resetLinks();
    end

    ---
    -- Moves the author.
    -- @param dt (number) The delta time between frames.
    --
    local function move( dt )
        velX = ( velX + accX * dt * MOVEMENT_SPEED ) * DAMPING_FACTOR;
        velY = ( velY + accY * dt * MOVEMENT_SPEED ) * DAMPING_FACTOR;
        posX = posX + velX;
        posY = posY + velY;
    end

    ---
    -- Changes the acceleration of an author based on the force values.
    -- The actual moving is handled by the move function.
    -- @param fx (number) The force along the x-axis.
    -- @param fy (number) The force along the y-axis.
    --
    local function applyForce( fx, fy )
        accX = clamp( -FORCE_MAX, accX + fx, FORCE_MAX );
        accY = clamp( -FORCE_MAX, accY + fy, FORCE_MAX );
    end

    -- ------------------------------------------------
    -- Public Functions
    -- ------------------------------------------------

    ---
    -- Draws the author.
    -- @param rotation  (number)  The camera's rotation.
    -- @param scale     (number)  The camera's zoom factor.
    -- @param showLabel (boolean) Wether to show or hide the name label.
    --
    function self:draw( rotation, scale, showLabel )
        if active then
            love.graphics.setLineWidth( BEAM_WIDTH );
            for i = 1, #links do
                local link = links[i];
                local type = link.mod;
                love.graphics.setColor( LINK_COLOR[type].r, LINK_COLOR[type].g, LINK_COLOR[type].b, linkAlpha );
                love.graphics.line( posX, posY, link.file:getX(), link.file:getY() );
            end
            love.graphics.setLineWidth( 1 );
            love.graphics.setColor( 255, 255, 255, avatarAlpha );

            if showLabel then
                love.graphics.setFont( LABEL_FONT );
                love.graphics.print( name, posX, posY, -rotation, 1 / scale, 1 / scale, LABEL_FONT:getWidth(name) * 0.5, - AVATAR_SIZE * scale );
                love.graphics.setFont( DEFAULT_FONT );
            end

            love.graphics.setColor( 255, 255, 255, 255 );
        end
    end

    ---
    -- Updates the author.
    -- This function checks how much time has passed since the author last was
    -- active. If it was inactive too long it starts fading out and eventually
    -- is deactivated. It can be reactivated via reactivate().
    -- @param dt             (number) The delta time between frames.
    -- @param cameraRotation (number) The camera's rotation.
    --
    function self:update( dt, cameraRotation )
        if active then
            move( dt );

            -- Fade out the author after it has been inactive for too long.
            if inactivity > INACTIVITY_TIMER then
                avatarAlpha = clamp( 0, avatarAlpha - dt * FADE_FACTOR, 255 );
                linkAlpha   = clamp( 0, linkAlpha   - dt * FADE_FACTOR, 255 );
            end

            -- Stop the author's movement after a short inactivity.
            if inactivity > MOVEMENT_TIMER then
                accX, accY = 0, 0;
            end

            -- Deactivate the author when it becomes fully invisible.
            if avatarAlpha <= 0 then
                deactivate();
            end

            spritebatch:setColor( 255, 255, 255, avatarAlpha );
            spritebatch:add( posX, posY, -cameraRotation, AVATAR_SIZE / aw, AVATAR_SIZE / ah, aw * 0.5, ah * 0.5 );

            inactivity = inactivity + dt;
        end
    end

    ---
    -- Adds a link to the author.
    -- This represents a file the author has either added, modified or deleted.
    -- @param file     (table)  The file to link to.
    -- @param modifier (string) The kind of modifier used on the file.
    --
    function self:addLink( file, modifier )
        reactivate();
        links[#links + 1] = { file = file, mod = modifier };

        local dx, dy = posX - file:getX(), posY - file:getY();
        local distance = math.sqrt( dx * dx + dy * dy );
        dx = dx / distance;
        dy = dy / distance;

        local strength = FORCE_SPRING * distance;
        applyForce( dx * strength, dy * strength );
    end

    ---
    -- Removes an old set of links by allocating a new table.
    --
    function self:resetLinks()
        links = {};
    end

    return self;
end

-- ------------------------------------------------
-- Return Module
-- ------------------------------------------------

return Author;
