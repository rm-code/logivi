local FilePanel = {};

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local MAX_VELOCITY = 8;
local SCROLL_SPEED = 2;
local DAMPING = 8;

local FIRST_ROW_X  = 10;
local SECOND_ROW_X = 50;
local VERTICAL_OFFSET = 10;
local LINE_HEIGHT = 20;

-- ------------------------------------------------
-- Constructor
-- ------------------------------------------------

---
-- Creates a new Timeline object.
-- @param visible (boolean)   Wether to show the timeline.
-- @param x       (number)    The position of the filepanel along the x-axis.
-- @param y       (number)    The position of the filepanel along the y-axis.
-- @param w       (number)    The width of the filepanel.
-- @param h       (number)    The height of the filepanel.
-- @return        (FilePanel) A new FilePanel object.
--
function FilePanel.new( visible, x, y, w, h )
    local self = {};

    local scrollVelocity = 0;
    local contentOffset = 0;

    local minY, maxY;

    local totalFiles;
    local sortedList;

    -- ------------------------------------------------
    -- Private Functions
    -- ------------------------------------------------

    ---
    -- Draws the panel's contents.
    -- @param cx (number) The position of the filepanel's content along the x-axis.
    -- @param cy (number) The position of the filepanel's content along the y-axis.
    --
    local function drawPanel( cx, cy )
        love.graphics.print( totalFiles, cx + FIRST_ROW_X,  cy + VERTICAL_OFFSET );
        love.graphics.print( 'Files',    cx + SECOND_ROW_X, cy + VERTICAL_OFFSET );

        for i, tbl in ipairs( sortedList ) do
            love.graphics.setColor( tbl.color.r, tbl.color.g, tbl.color.b );
            love.graphics.print( tbl.amount,    cx + FIRST_ROW_X,  cy + VERTICAL_OFFSET + i * LINE_HEIGHT );
            love.graphics.print( tbl.extension, cx + SECOND_ROW_X, cy + VERTICAL_OFFSET + i * LINE_HEIGHT );
            love.graphics.setColor( 255, 255, 255 );
        end
    end

    ---
    -- Calculates the panel's height.
    -- @return (number) The panels height in pixels.
    --
    local function calculatePanelHeight()
        return VERTICAL_OFFSET + ( #sortedList + 1 ) * LINE_HEIGHT;
    end

    -- ------------------------------------------------
    -- Public Functions
    -- ------------------------------------------------

    ---
    -- Draws the panel.
    --
    function self:draw()
        if not visible then
            return;
        end

        love.graphics.setScissor( x, y, w, h );
        if totalFiles and sortedList then
            drawPanel( x, y + contentOffset );
        end
        love.graphics.setScissor();
    end

    ---
    -- Updates the file panel.
    -- @param dt (number) Time since the last update in seconds.
    --
    function self:update( dt )
        if not visible then
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

        minY, maxY = 0, calculatePanelHeight();

        if maxY < h then
            contentOffset = minY;
        elseif y + contentOffset + maxY < y + h then
            contentOffset = ( y + h ) - ( y + maxY );
        elseif contentOffset > minY then
            contentOffset = minY;
        end
    end

    ---
    -- Scrolls the contents of the file panel.
    -- @param _  (number) The scroll speed in x-direction (unused).
    -- @param dy (number) The scroll speed in y-direction.
    --
    function self:scroll( _, dy )
        if dy < 0 then
            scrollVelocity = scrollVelocity > 0 and 0 or scrollVelocity;
            scrollVelocity = scrollVelocity - SCROLL_SPEED;
        elseif dy > 0 then
            scrollVelocity = scrollVelocity < 0 and 0 or scrollVelocity;
            scrollVelocity = scrollVelocity + SCROLL_SPEED;
        end
    end

    ---
    -- Checks if the coordinates intersect with the file panel's area.
    -- @param cx (number)  The position to check for along the x-axis.
    -- @param cy (number)  The position to check for along the y-axis.
    -- @return   (boolean) True if the specified coordinates intersect
    --                      the panel's area.
    --
    function self:intersects( cx, cy )
        return x < cx and x + w > cx and y < cy and y + h > cy;
    end

    ---
    -- Toggles the file panel.
    --
    function self:toggle()
        visible = not visible;
    end

    ---
    -- Sets the sorted file list to use for drawing.
    -- @param nsortedList (table) The sorted list of files in the graph.
    --
    function self:setSortedList( nsortedList )
        sortedList = nsortedList;
    end

    ---
    -- Sets the total amount of files in the graph.
    -- @param ntotalFiles (number) The total amount of files in the graph.
    --
    function self:setTotalFiles( ntotalFiles )
        totalFiles = ntotalFiles;
    end

    return self;
end

return FilePanel;
