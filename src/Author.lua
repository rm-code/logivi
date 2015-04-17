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

local Author = {};

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local AVATAR_SIZE = 48;
local AUTHOR_INACTIVITY_TIMER = 2;
local LINK_INACTIVITY_TIMER = 2;
local FADE_FACTOR = 2;
local DEFAULT_AVATAR_ALPHA = 255;
local DEFAULT_LINK_ALPHA = 50;
local DEFAULT_DAMPING_VALUE = 0.5;
local MIN_DISTANCE = 400;
local BEAM_WIDTH = 3;

-- ------------------------------------------------
-- Constructor
-- ------------------------------------------------

function Author.new(name, avatar, cx, cy)
    local self = {};

    local posX, posY = cx + love.math.random(5, 40) * (love.math.random(0, 1) == 0 and -1 or 1), cy + love.math.random(5, 40) * (love.math.random(0, 1) == 0 and -1 or 1);
    local accX, accY = 0, 0;
    local velX, velY = 0, 0;

    local links = {};
    local inactivity = 0;
    local avatarAlpha = DEFAULT_AVATAR_ALPHA;
    local linkAlpha = DEFAULT_LINK_ALPHA;

    -- Avatar's width and height.
    local aw, ah = avatar:getWidth(), avatar:getHeight();

    local dampingFactor = DEFAULT_DAMPING_VALUE;

    -- ------------------------------------------------
    -- Private Functions
    -- ------------------------------------------------

    local function reactivate()
        inactivity = 0;
        dampingFactor = DEFAULT_DAMPING_VALUE;
        avatarAlpha = DEFAULT_AVATAR_ALPHA;
        linkAlpha = DEFAULT_LINK_ALPHA;
    end

    local function move(dt)
        local dx, dy;
        local distance

        for i = 1, #links do
            local file = links[i];

            -- Attract
            dx, dy = posX - file:getX(), posY - file:getY();
            distance = math.sqrt(dx * dx + dy * dy);

            -- Normalise vector.
            dx = dx / distance;
            dy = dy / distance;

            -- Attraction.
            if distance > MIN_DISTANCE then
                accX = dx * -distance * 5;
                accY = dy * -distance * 5;
            end

            -- Repulsion.
            accX = accX + (dx * distance);
            accY = accY + (dy * distance);
        end

        -- Repel from the graph's center.
        dx, dy = posX - cx, posY - cy;
        distance = math.sqrt(dx * dx + dy * dy);
        dx = dx / distance;
        dy = dy / distance;
        accX = accX + (dx * distance);
        accY = accY + (dy * distance);

        accX = math.max(-4, math.min(accX, 4));
        accY = math.max(-4, math.min(accY, 4));

        velX = velX + accX * dt * 16;
        velY = velY + accY * dt * 16;

        posX = posX + velX;
        posY = posY + velY;

        velX = velX * dampingFactor;
        velY = velY * dampingFactor;
    end

    -- ------------------------------------------------
    -- Public Functions
    -- ------------------------------------------------

    function self:draw(rotation)
        for i = 1, #links do
            love.graphics.setColor(255, 255, 255, linkAlpha);
            love.graphics.setLineWidth(BEAM_WIDTH);
            love.graphics.line(posX, posY, links[i]:getX(), links[i]:getY());
            love.graphics.setLineWidth(1);
            love.graphics.setColor(255, 255, 255, 255);
        end
        love.graphics.setColor(255, 255, 255, avatarAlpha);
        love.graphics.draw(avatar, posX, posY, -rotation, AVATAR_SIZE / aw, AVATAR_SIZE / ah, aw * 0.5, ah * 0.5);
        love.graphics.setColor(255, 255, 255, 255);
    end

    function self:update(dt)
        move(dt);

        inactivity = inactivity + dt;
        if inactivity > AUTHOR_INACTIVITY_TIMER then
            avatarAlpha = avatarAlpha - avatarAlpha * dt * FADE_FACTOR;
        end
        if inactivity > LINK_INACTIVITY_TIMER then
            linkAlpha = linkAlpha - linkAlpha * dt * FADE_FACTOR;
        end
        dampingFactor = math.max(0.01, dampingFactor - dt);
    end

    function self:addLink(file)
        reactivate();
        links[#links + 1] = file;
    end

    function self:resetLinks()
        links = {};
    end

    return self;
end

-- ------------------------------------------------
-- Return Module
-- ------------------------------------------------

return Author;
