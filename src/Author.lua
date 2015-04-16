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
local DAMPING_FACTOR = 0.90;
local FORCE_MAX = 2;
local FORCE_SPRING = -0.5;
local BEAM_WIDTH = 3;

-- ------------------------------------------------
-- Constructor
-- ------------------------------------------------

function Author.new(name, avatar, cx, cy)
    local self = {};

    local posX, posY = cx + love.math.random(5, 200) * (love.math.random(0, 1) == 0 and -1 or 1), cy + love.math.random(5, 200) * (love.math.random(0, 1) == 0 and -1 or 1);
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

    local function clamp(min, val, max)
        return math.max(min, math.min(val, max));
    end

    local function reactivate()
        inactivity = 0;
        avatarAlpha = DEFAULT_AVATAR_ALPHA;
        linkAlpha = DEFAULT_LINK_ALPHA;
    end

    local function move(dt)
        velX = (velX + accX * dt * 32) * DAMPING_FACTOR;
        velY = (velY + accY * dt * 32) * DAMPING_FACTOR;
        posX = posX + velX;
        posY = posY + velY;
    end

    local function applyForce(fx, fy)
        accX = clamp(-FORCE_MAX, accX + fx, FORCE_MAX);
        accY = clamp(-FORCE_MAX, accY + fy, FORCE_MAX);
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
        if inactivity > 0.5 then
            accX, accY = 0, 0;
        end
    end

    function self:addLink(file)
        reactivate();
        links[#links + 1] = file;

        local dx, dy = posX - file:getX(), posY - file:getY();
        local distance = math.sqrt(dx * dx + dy * dy);
        dx = dx / distance;
        dy = dy / distance;

        local strength = FORCE_SPRING * distance;
        applyForce(dx * strength, dy * strength);
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
