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

local Node = require('src/nodes/Node');

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local FileNode = {};

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local MOD_TIMER = 2;
local MOD_COLOR = { 255, 0, 0 };

-- ------------------------------------------------
-- Local Variables
-- ------------------------------------------------

local img = love.graphics.newImage('res/fileNode.png');

-- ------------------------------------------------
-- Constructor
-- ------------------------------------------------

function FileNode.new(name, color)
    local self = Node.new('file', name);

    local fileColor = color;
    local currentColor = {};
    local modified = false;
    local timer = MOD_TIMER;

    -- ------------------------------------------------
    -- Private Function
    -- ------------------------------------------------

    local function lerp(a, b, t)
        return a + (b - a) * t;
    end

    -- ------------------------------------------------
    -- Public Function
    -- ------------------------------------------------

    ---
    -- Draw the node with the current color modifier.
    --
    function self:draw()
        love.graphics.setColor(currentColor);
        love.graphics.draw(img, self:getX() - 8, self:getY() - 8);
        love.graphics.setColor(255, 255, 255);
    end

    ---
    -- If the file is marked as modified the color will be lerped from
    -- the modified color to the default file color.
    -- @param dt
    --
    function self:update(dt)
        if timer > 0 and modified then
            timer = timer - dt;
            currentColor[1] = lerp(currentColor[1], fileColor[1], dt * 1.5);
            currentColor[2] = lerp(currentColor[2], fileColor[2], dt * 1.5);
            currentColor[3] = lerp(currentColor[3], fileColor[3], dt * 1.5);
        else
            -- Reset values.
            timer = MOD_TIMER;
            modified = false;
            currentColor[1] = fileColor[1]
            currentColor[2] = fileColor[2];
            currentColor[3] = fileColor[3];
        end
    end

    ---
    -- Marks the file as modified and changes the
    -- current color to the modified color.
    -- @param mod
    --
    function self:setModified(mod)
        modified = mod;
        currentColor[1] = MOD_COLOR[1];
        currentColor[2] = MOD_COLOR[2];
        currentColor[3] = MOD_COLOR[3];
    end

    return self;
end

-- ------------------------------------------------
-- Return Module
-- ------------------------------------------------

return FileNode;
