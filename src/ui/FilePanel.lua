local MAX_VELOCITY = 8;
local SCROLL_SPEED = 2;
local DAMPING = 8;

local FIRST_ROW_X  = 10;
local SECOND_ROW_X = 50;
local VERTICAL_OFFSET = 10;
local LINE_HEIGHT = 20;

local FilePanel = {};

function FilePanel.new( active, x, y, w, h )
    local self = {};

    local scrollVelocity = 0;
    local contentOffset = 0;

    local minY, maxY;

    local totalFiles;
    local sortedList;

    local function drawPanel( cx, cy )
        love.graphics.print( totalFiles, cx + FIRST_ROW_X, cy + VERTICAL_OFFSET );
        love.graphics.print( 'Files', cx + SECOND_ROW_X, cy + VERTICAL_OFFSET );
        for i, tbl in ipairs( sortedList ) do
            love.graphics.setColor( tbl.color.r, tbl.color.g, tbl.color.b );
            love.graphics.print( tbl.amount, cx + FIRST_ROW_X, cy + VERTICAL_OFFSET + i * LINE_HEIGHT );
            love.graphics.print( tbl.extension, cx + SECOND_ROW_X, cy + VERTICAL_OFFSET + i * LINE_HEIGHT );
            love.graphics.setColor( 255, 255, 255 );
        end
    end

    local function calculatePanelHeight()
        return 0, VERTICAL_OFFSET + ( #sortedList + 1 ) * LINE_HEIGHT;
    end

    function self:draw()
        if not active then
            return;
        end

        love.graphics.setScissor( x, y, w, h );
        if totalFiles and sortedList then
            drawPanel( x, y + contentOffset );
        end
        love.graphics.setScissor();
    end

    function self:update( dt )
        if not active then
            return;
        end

        -- Reduce the scrolling velocity over time.
        if scrollVelocity < -0.5 then
            scrollVelocity = scrollVelocity + dt * DAMPING;
        elseif scrollVelocity > 0.5 then
            scrollVelocity = scrollVelocity - dt * DAMPING;
        else
            scrollVelocity = 0;
        end

        -- Clamp velocity to prevent too fast scrolling.
        scrollVelocity = math.max( -MAX_VELOCITY, math.min( scrollVelocity, MAX_VELOCITY ));

        -- Update the position of the scrolled content.
        contentOffset = contentOffset + scrollVelocity;

        minY, maxY = calculatePanelHeight();

        if maxY < h then
            contentOffset = minY;
        elseif y + contentOffset + maxY < y + h then
            contentOffset = ( y + h ) - ( y + maxY );
        elseif contentOffset > minY then
            contentOffset = minY;
        end
    end

    function self:scroll( _, dy )
        if dy < 0 then
            scrollVelocity = scrollVelocity > 0 and 0 or scrollVelocity;
            scrollVelocity = scrollVelocity - SCROLL_SPEED;
        elseif dy > 0 then
            scrollVelocity = scrollVelocity < 0 and 0 or scrollVelocity;
            scrollVelocity = scrollVelocity + SCROLL_SPEED;
        end
    end

    function self:intersects( cx, cy )
        return x < cx and x + w > cx and y < cy and y + h > cy;
    end

    function self:toggle()
        active = not active;
    end

    function self:setSortedList( nsortedList )
        sortedList = nsortedList;
    end

    function self:setTotalFiles( ntotalFiles )
        totalFiles = ntotalFiles;
    end

    return self;
end

return FilePanel;