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

function Author.new(name, avatar)
    local self = {};

    local name = name;
    local posX, posY = love.math.random(100, 1000), love.math.random(100, 600);
    local dX, dY = love.math.random(-50, 50), love.math.random(-50, 50);
    local links = {};
    local inactivity = 0;
    local alpha = DEFAULT_ALPHA;

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

    function self:draw()
        for i = 1, #links do
            love.graphics.setColor(255, 255, 255, 50);
            love.graphics.line(posX, posY, links[i]:getX(), links[i]:getY());
            love.graphics.setColor(255, 255, 255, 255);
        end
        love.graphics.setColor(255, 255, 255, alpha);
        love.graphics.draw(avatar, posX - AVATAR_SIZE * 0.5, posY - AVATAR_SIZE * 0.5, 0, AVATAR_SIZE / avatar:getWidth(), AVATAR_SIZE / avatar:getHeight());
        love.graphics.setColor(255, 255, 255, 255);
    end

    function self:update(dt)
        if posX < 200 or posX > love.graphics.getWidth() - 200 then
            dX = -dX;
        end
        if posY < 200 or posY > love.graphics.getHeight() - 200 then
            dY = -dY;
        end
        posX = posX + (dX * dt);
        posY = posY + (dY * dt);

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
