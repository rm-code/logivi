--===============================================================================--
--                                                                               --
-- Copyright (c) 2014 Robert Machmer                                             --
--                                                                               --
-- This software is provided 'as-is', without any express or implied             --
-- warranty. In no event will the authors be held liable for any damages         --
-- arising from the use of this software.                                        --
--                                                                               --
-- Permission is granted to anyone to use this software for any purpose,         --
-- including commercial applications, and to alter it and redistribute it        --
-- freely, subject to the following restrictions:                                --
--                                                                               --
--  1. The origin of this software must not be misrepresented; you must not      --
--      claim that you wrote the original software. If you use this software     --
--      in a product, an acknowledgment in the product documentation would be    --
--      appreciated but is not required.                                         --
--  2. Altered source versions must be plainly marked as such, and must not be   --
--      misrepresented as being the original software.                           --
--  3. This notice may not be removed or altered from any source distribution.   --
--                                                                               --
--===============================================================================--

local Camera = {};

function Camera.new()
    local self = {};

    -- ------------------------------------------------
    -- Private Variables
    -- ------------------------------------------------

    local x, y = 0, 0;
    local sx, sy = 1, 1;
    local graphMinX, graphMaxX, graphMinY, graphMaxY;
    
    -- ------------------------------------------------
    -- Private Methods
    -- ------------------------------------------------
    
    local function debugDraw()
        love.graphics.setColor(180, 180, 180, 50);
        love.graphics.rectangle('fill', graphMinX, graphMinY, graphMaxX - graphMinX, graphMaxY - graphMinY);
        love.graphics.setColor(255, 0, 0, 100);
        love.graphics.circle('fill', graphMinX + (graphMaxX - graphMinX) * 0.5, graphMinY + (graphMaxY - graphMinY) * 0.5, 2);
        love.graphics.setColor(255,255,255, 255);
    end
    
    -- ------------------------------------------------
    -- Public Methods
    -- ------------------------------------------------
    
    function self:update(dt)
        self:track(graphMinX + (graphMaxX - graphMinX) * 0.5, graphMinY + (graphMaxY - graphMinY) * 0.5, 3, dt);
    end

    function self:set()
        love.graphics.push();
        love.graphics.scale(sx, sy);
        love.graphics.translate(-x, -y);
        love.graphics.translate(love.graphics.getWidth() / (2 * sx), love.graphics.getHeight() / (2 * sy));
    end

    function self:unset()
        love.graphics.pop();
    end

    function self:track(tarX, tarY, speed, dt)
        x = x - (x - math.floor(tarX)) * dt * speed;
        y = y - (y - math.floor(tarY)) * dt * speed;
    end

    function self:checkEdges(tree)
        local rootX = tree:getX();
        local rootY = tree:getY();
        graphMinX, graphMaxX, graphMinY, graphMaxY = rootX, rootX, rootY, rootY;

        local function traverseNodes(node, depth)
            if node:getType() == 'folder' then

                -- Find the edges.
                local x, y = node:getPosition();
                if x < graphMinX then
                    graphMinX = x;
                elseif x > graphMaxX then
                    graphMaxX = x;
                end

                if y < graphMinY then
                    graphMinY = y;
                elseif y > graphMaxY then
                    graphMaxY = y;
                end

                for key, child in pairs(node:getChildren()) do
                    traverseNodes(child, depth + 1);
                end
            end
        end
        traverseNodes(tree, 0);
    end

    return self;
end

-- ------------------------------------------------
-- Return Module
-- ------------------------------------------------

return Camera;

--==================================================================================================
-- Created 08.09.14 - 13:34                                                                        =
--==================================================================================================
