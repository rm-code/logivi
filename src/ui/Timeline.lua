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

local TEXT_FONT = love.graphics.newFont('res/fonts/SourceCodePro-Medium.otf', 15);
local DEFAULT_FONT = love.graphics.newFont(12);
local MARGIN_LEFT = 10;
local MARGIN_RIGHT = 10;
local HEIGHT = 30;
local TOTAL_STEPS = 128;

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local Timeline = {};

-- ------------------------------------------------
-- Constructor
-- ------------------------------------------------

function Timeline.new(v, totalCommits, date)
    local self = {};

    local stepWidth = (love.graphics.getWidth() - MARGIN_LEFT - MARGIN_RIGHT) / TOTAL_STEPS;
    local currentStep = 0;
    local highlighted = -1;
    local visible = v;
    local w, h = 2, -5;

    ---
    -- Calculates which timestep the user has clicked on and returns the 
    -- index of the commit which has been mapped to that location.
    -- @param x - The clicked x-position
    --
    local function calculateCommitIndex(x)
        return math.floor(totalCommits / (TOTAL_STEPS / math.floor((x / stepWidth))));
    end

    ---
    -- Maps a certain commit to a timestep.
    --
    local function calculateTimelineIndex(cindex)
        return math.floor((cindex / totalCommits) * (TOTAL_STEPS - 1) + 1);
    end

    function self:draw()
        if not visible then return end
        for i = 1, TOTAL_STEPS do
            if i == highlighted then
                love.graphics.setColor(200, 0, 0);
                love.graphics.rectangle('fill', MARGIN_LEFT + (i - 1) * stepWidth, love.graphics.getHeight(), w * 2, h * 2.1);
            elseif i == currentStep then
                love.graphics.setColor(80, 80, 80);
                love.graphics.rectangle('fill', MARGIN_LEFT + (i - 1) * stepWidth, love.graphics.getHeight(), w * 2, h * 2);
            else
                love.graphics.setColor(50, 50, 50);
                love.graphics.rectangle('fill', MARGIN_LEFT + (i - 1) * stepWidth, love.graphics.getHeight(), w, h);
            end

            love.graphics.setColor(100, 100, 100);
            love.graphics.setFont(TEXT_FONT);
            love.graphics.print(date, love.graphics.getWidth() * 0.5 - 70, love.graphics.getHeight() - 25);
            love.graphics.setFont(DEFAULT_FONT)
            love.graphics.setColor(255, 255, 255);
        end
    end

    function self:update(dt)
        if love.mouse.getY() > love.graphics.getHeight() - HEIGHT then
            highlighted = math.floor(love.mouse.getX() / stepWidth);
        else
            highlighted = -1;
        end
    end

    function self:setCurrentCommit(commit)
        currentStep = calculateTimelineIndex(commit);
    end

    function self:setCurrentDate(ndate)
        date = ndate;
    end

    function self:toggle()
        visible = not visible;
    end

    function self:getCommitAt(x, y)
        if y > love.graphics.getHeight() - HEIGHT then
            return calculateCommitIndex(x);
        end
    end

    function self:resize(nx, ny)
        stepWidth = (nx - MARGIN_LEFT - MARGIN_RIGHT) / TOTAL_STEPS;
    end

    return self;
end

return Timeline;
