local Author = {};

function Author.new(name)
    local self = {};

    local name = name;
    local posX, posY = love.math.random(100, 1000), love.math.random(100, 600);
    local dX, dY = love.math.random(-50, 50), love.math.random(-50, 50);
    local links = {};

    function self:draw()
        for i = 1, #links do
            love.graphics.setColor(255, 255, 255, 50);
            love.graphics.line(posX, posY, links[i]:getX(), links[i]:getY());
            love.graphics.setColor(255, 255, 255, 255);
        end
        love.graphics.circle('fill', posX, posY, 20, 20);
        love.graphics.print(name, posX + 10, posY + 10);
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
    end

    function self:addLink(file)
        links[#links + 1] = file;
    end

    function self:resetLinks()
        links = {};
    end

    return self;
end

return Author;