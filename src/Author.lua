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

    local function reactivate()
        inactivity = 0;
        alpha = DEFAULT_ALPHA;
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

return Author;