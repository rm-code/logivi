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
local INACTIVITY_TIMER = 10;
local FADE_FACTOR = 2;
local DEFAULT_ALPHA = 255;

-- ------------------------------------------------
-- Constructor
-- ------------------------------------------------

function Author.new(name, avatar, cx, cy)
    local self = {};

    local radius = 200;
    local speed = love.math.random(1, 5) / 5;
    local angle = love.math.random(360);
    local x, y = cx + math.cos(angle) * radius, cy + math.sin(angle) * radius;

    local links = {};
    local inactivity = 0;
    local alpha = DEFAULT_ALPHA;

    -- Avatar's width and height.
    local aw, ah = avatar:getWidth(), avatar:getHeight();

    -- ------------------------------------------------
    -- Private Functions
    -- ------------------------------------------------

    local function reactivate()
        inactivity = 0;
        alpha = DEFAULT_ALPHA;
    end

    -- ------------------------------------------------
    -- Public Functions
    -- ------------------------------------------------

    function self:draw(rotation)
        for i = 1, #links do
            love.graphics.setColor(255, 255, 255, 50);
            love.graphics.line(x, y, links[i]:getX(), links[i]:getY());
            love.graphics.setColor(255, 255, 255, 255);
        end
        love.graphics.setColor(255, 255, 255, alpha);
        love.graphics.draw(avatar, x, y, -rotation, AVATAR_SIZE / aw, AVATAR_SIZE / ah, aw * 0.5, ah * 0.5);
        love.graphics.setColor(255, 255, 255, 255);
    end

    function self:update(dt)
        angle = angle + speed * dt;
        x, y = cx + math.cos(angle) * radius, cy + math.sin(angle) * radius;

        inactivity = inactivity + dt;
        if inactivity > INACTIVITY_TIMER then
            alpha = alpha - alpha * dt * FADE_FACTOR;
        end
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
