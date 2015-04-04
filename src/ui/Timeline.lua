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

local Timeline = {};

function Timeline.new(v, totalCommits, date)
    local self = {};

    local stepWidth = love.graphics.getWidth() / totalCommits;
    local currentStep = 0;
    local visible = v;

    function self:draw()
        if visible and currentStep ~= 0 then
            love.graphics.setColor(40, 40, 40);
            love.graphics.line(0, love.graphics.getHeight() - 1, love.graphics.getWidth(), love.graphics.getHeight() - 1);
            love.graphics.setColor(255, 255, 255, 200);
            love.graphics.line(0, love.graphics.getHeight() - 1, currentStep * stepWidth, love.graphics.getHeight() - 1);
            love.graphics.print(date, love.graphics.getWidth() * 0.5 - 70, love.graphics.getHeight() - 15);
        end
    end

    function self:setCurrentCommit(commit)
        currentStep = commit;
    end

    function self:setCurrentDate(ndate)
        date = ndate;
    end

    function self:toggle()
        visible = not visible;
    end

    return self;
end

return Timeline;
