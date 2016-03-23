local Resources = require('src.Resources');

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local Timeline = {};

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local TEXT_FONT    = Resources.loadFont('SourceCodePro-Medium.otf', 15);
local DEFAULT_FONT = Resources.loadFont('default', 12);

local MARGIN = 5;
local HEIGHT = 10;
local MOUSE_HOVERING_BOUNDS = 30;

local FADED_ALPHA = 0;
local VISIBLE_ALPHA = 150;

local HAND_CURSOR = love.mouse.getSystemCursor( 'hand' );

-- ------------------------------------------------
-- Constructor
-- ------------------------------------------------

---
-- Creates a new Timeline object.
-- @param visible      (boolean)  Wether to show the timeline.
-- @param totalCommits (number)   The total number of commits to display.
-- @param date         (string)   The starting date.
-- @return             (Timeline) A new timeline object.
--
function Timeline.new( visible, totalCommits, date )
    local self = {};

    local sw, sh = love.graphics.getDimensions();
    local currentCommit = 0;

    local alpha = FADED_ALPHA;
    local datePosition = sh - HEIGHT - MARGIN - MARGIN;

    -- ------------------------------------------------
    -- Private Functions
    -- ------------------------------------------------

    ---
    -- Linear interpolation between a and b.
    --
    local function lerp( a, b, t )
        return a + ( b - a ) * t;
    end

    ---
    -- Takes a pixel coordinate and tries to map it to a commit at this position
    -- on the timeline or close by.
    -- @param x (number) The position in pixels.
    -- @return  (number) The commit at this position on the timeline.
    --
    local function transformPixelsToCommits( x )
        return math.floor(( x - MARGIN ) / (( sw - MARGIN - MARGIN ) / totalCommits ));
    end

    ---
    -- Checks wether the mouse is hovering over the timeline.
    -- @return (boolean) True if the mouse is hovering, false otherwise.
    --
    local function mouseOver()
        return love.mouse.getY() > sh - MOUSE_HOVERING_BOUNDS;
    end

    ---
    -- Changes the mouse cursor to a hand symbol if the mouse is hovering over
    -- the timeline and changes it back if it isn't.
    --
    local function updateMouseCursor()
        if mouseOver() then
            love.mouse.setCursor( HAND_CURSOR );
        else
            love.mouse.setCursor();
        end
    end

    -- ------------------------------------------------
    -- Public Functions
    -- ------------------------------------------------

    ---
    -- Draws the timeline.
    --
    function self:draw()
        if not visible then
            return;
        end

        -- Draw the date label.
        local labelX =  sw * 0.5 - TEXT_FONT:getWidth( date ) * 0.5;
        love.graphics.setColor( 0, 0, 0, 210 );
        love.graphics.rectangle( 'fill', labelX - 2, datePosition - 2, TEXT_FONT:getWidth( date ) + 4, TEXT_FONT:getHeight( date ) + 4 );
        love.graphics.setColor( 215, 215, 215, 255 );
        love.graphics.setFont( TEXT_FONT );
        love.graphics.print( date, labelX, datePosition );
        love.graphics.setFont( DEFAULT_FONT )
        love.graphics.setColor( 255, 255, 255, 255 );

        -- Draw the timeline.
        love.graphics.setColor( 215, 215, 215, alpha );
        love.graphics.rectangle( 'line', MARGIN, sh - HEIGHT - MARGIN, sw - ( 2 * MARGIN ), HEIGHT );
        love.graphics.setColor( 200, 200, 200, alpha );
        love.graphics.rectangle( 'fill', MARGIN, sh - HEIGHT - MARGIN, ( sw - ( 2 * MARGIN )) * ( currentCommit / totalCommits ), HEIGHT );
        love.graphics.setColor( 255, 255, 255, 255 );
    end

    ---
    -- Updates the timeline.
    -- @param dt (number) Time since the last update in seconds.
    --
    function self:update( dt )
        if not visible then
            return;
        end

        -- Update the alpha channel of the timeline and the position of the
        -- date label based on wether the mouse is hovering over the timeline
        -- or not.
        local hover = mouseOver();
        alpha = lerp( alpha, hover and VISIBLE_ALPHA or FADED_ALPHA, dt * 4 );
        datePosition = lerp( datePosition, hover and ( sh - TEXT_FONT:getHeight( date ) - HEIGHT - MARGIN - MARGIN ) or ( sh - HEIGHT - MARGIN - MARGIN ), dt * 4 );

        updateMouseCursor();
    end

    ---
    -- Toggles the timeline.
    --
    function self:toggle()
        visible = not visible;
    end

    ---
    -- Updates the screen's dimensions when it has been resized.
    -- @param nx (number) The new screen width in pixels.
    -- @param ny (number) The new screen width in pixels.
    --
    function self:resize( nx, ny )
        sw, sh = nx, ny;
    end

    -- ------------------------------------------------
    -- Setters
    -- ------------------------------------------------

    ---
    -- Updates the current commit counter.
    -- @param commit (number) The index of the currently displayed commit.
    --
    function self:setCurrentCommit( commit )
        currentCommit = commit;
    end

    ---
    -- Updates the current date.
    -- @param ndate (string) The date of the currently displayed commit.
    --
    function self:setCurrentDate( ndate )
        date = ndate;
    end

    -- ------------------------------------------------
    -- Getters
    -- ------------------------------------------------

    ---
    -- Returns a commit at a certain position on the timeline or close by.
    -- @param x (number) The horizontal screen position in pixels.
    -- @return  (number) The commit at this position on the timeline.
    --
    function self:getCommitAt( x )
        if mouseOver() then
            return transformPixelsToCommits( x );
        end
    end

    return self;
end

return Timeline;
