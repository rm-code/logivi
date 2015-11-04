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
local MARGIN_LEFT = 10;
local MARGIN_RIGHT = 10;
local MARGIN_LABEL = 35;
local HEIGHT = 30;
local TOTAL_STEPS = 128;

local DEFAULT_STEP_SCALE = 0.4;
local HIGHLIGHT_STEP_SCALE = 0.7;
local CURRENT_STEP_SCALE = 0.6;

-- ------------------------------------------------
-- Constructor
-- ------------------------------------------------

function Timeline.new(visible, totalCommits, date)
    local self = {};

    local steps = totalCommits < TOTAL_STEPS and totalCommits or TOTAL_STEPS;
    local stepWidth = (love.graphics.getWidth() - MARGIN_LEFT - MARGIN_RIGHT) / steps;
    local currentStep = 0;
    local highlighted = -1;

    local stepSprite  = Resources.loadImage('step.png');
    local spritebatch = love.graphics.newSpriteBatch(stepSprite, TOTAL_STEPS, 'dynamic');
    spritebatch:setColor(100, 100, 100, 255);

    -- Create the timeline.
    for i = 1, steps do
        spritebatch:add(MARGIN_LEFT + (i - 1) * stepWidth, love.graphics.getHeight() - (stepSprite:getHeight() * DEFAULT_STEP_SCALE), 0, DEFAULT_STEP_SCALE, DEFAULT_STEP_SCALE);
    end

    ---
    -- Calculates which timestep the user has clicked on and returns the
    -- index of the commit which has been mapped to that location.
    -- @param x - The clicked x-position
    --
    local function calculateCommitIndex(x)
        return math.floor(totalCommits / (steps / math.floor((x / stepWidth))));
    end

    ---
    -- Maps a certain commit to a timestep.
    --
    local function calculateTimelineIndex(cindex)
        return math.floor((cindex / totalCommits) * (steps - 1) + 1);
    end

    function self:draw()
        if not visible then return end
        love.graphics.draw(spritebatch);

        local sw, sh = love.graphics.getDimensions();
        love.graphics.setColor(120, 120, 120, 255);
        love.graphics.draw(stepSprite, MARGIN_LEFT + (currentStep - 1) * stepWidth, sh - (stepSprite:getHeight() * CURRENT_STEP_SCALE), 0, CURRENT_STEP_SCALE, CURRENT_STEP_SCALE);

        love.graphics.setColor(255, 0, 0);
        love.graphics.draw(stepSprite, MARGIN_LEFT + (highlighted - 1) * stepWidth, sh - (stepSprite:getHeight() * HIGHLIGHT_STEP_SCALE), 0, HIGHLIGHT_STEP_SCALE, HIGHLIGHT_STEP_SCALE);

        love.graphics.setColor(100, 100, 100);
        love.graphics.setFont(TEXT_FONT);
        love.graphics.print(date, sw * 0.5 - TEXT_FONT:getWidth(date) * 0.5, sh - MARGIN_LABEL);
        love.graphics.setFont(DEFAULT_FONT)
        love.graphics.setColor(255, 255, 255);
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
        stepWidth = (nx - MARGIN_LEFT - MARGIN_RIGHT) / steps;

        -- Recreate the spritebatch when the window is resized.
        spritebatch:clear();
        for i = 1, steps do
            spritebatch:add(MARGIN_LEFT + (i - 1) * stepWidth, ny - (stepSprite:getHeight() * DEFAULT_STEP_SCALE), 0, DEFAULT_STEP_SCALE, DEFAULT_STEP_SCALE);
        end
    end

    return self;
end

return Timeline;
