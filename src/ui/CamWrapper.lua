local Camera = require('lib.camera.Camera');

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local CamWrapper = {};

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local CAMERA_ROTATION_SPEED = 0.6;
local CAMERA_TRANSLATION_SPEED = 400;
local CAMERA_TRACKING_SPEED = 2;
local CAMERA_ZOOM_SPEED = 0.6;
local CAMERA_MAX_ZOOM = 0.05;
local CAMERA_MIN_ZOOM = 2;

local GRAPH_PADDING = 100;

-- ------------------------------------------------
-- Constructor
-- ------------------------------------------------

function CamWrapper.new()
    local self = {};

    local camera = Camera.new(); -- The actual camera object.
    local cx, cy = 0, 0;
    local ox, oy = 0, 0;
    local gx, gy = 0, 0;
    local gw, gh = 0, 0;
    local zoom = 1;
    local manualZoom = 0;

    -- ------------------------------------------------
    -- Private Functions
    -- ------------------------------------------------

    local function clamp(min, val, max)
        return math.max(min, math.min(val, max));
    end

    local function lerp(a, b, t)
        return a + (b - a) * t;
    end

    ---
    -- Updates the position on which the camera offset builds.
    -- @param ngx
    -- @param ngy
    --
    local function updateCenter(ngx, ngy)
        gx, gy = ngx, ngy;
    end

    ---
    -- Updates the dimensions of the graph and adds a padding value.
    -- @param minX
    -- @param maxX
    -- @param minY
    -- @param maxY
    --
    local function updateGraphDimensions(minX, maxX, minY, maxY)
        gw, gh = maxX - minX, maxY - minY;
    end

    ---
    -- Calculates the automatic zoom factor needed to fit the whole graph on
    -- the user's screen.
    --
    local function calculateAutoZoom(rot)
        local w, h = GRAPH_PADDING + gw, GRAPH_PADDING + gh;
        local sw, sh = love.graphics.getDimensions();

        local rw = h * math.abs(math.sin(rot)) + w * math.abs(math.cos(rot));
        local rh = h * math.abs(math.cos(rot)) + w * math.abs(math.sin(rot));

        -- Calculate the zoom factors for both width and height and use the
        -- smaller one to zoom.
        local ratioW, ratioH =  sw / rw, sh / rh;

        return ratioW <= ratioH and ratioW or ratioH;
    end

    -- ------------------------------------------------
    -- Public Functions
    -- ------------------------------------------------

    function self:zoom(dt, dir)
        manualZoom = manualZoom + (dir * CAMERA_ZOOM_SPEED) * dt;
    end

    function self:rotate(dt, dir)
        camera:rotate(dir * CAMERA_ROTATION_SPEED * dt);
    end

    function self:move(dt, dx, dy)
        dx = (dx * dt * CAMERA_TRANSLATION_SPEED);
        dy = (dy * dt * CAMERA_TRANSLATION_SPEED);
        ox = ox + (math.cos(-camera.rot) * dx - math.sin(-camera.rot) * dy);
        oy = oy + (math.sin(-camera.rot) * dx + math.cos(-camera.rot) * dy);
    end

    ---
    -- Processes camera related controls and updates the camera.
    -- @param dt
    --
    function self:update(dt)
        local tzoom = calculateAutoZoom(camera.rot);
        zoom = lerp(zoom, tzoom, dt * 2);

        camera:zoomTo(clamp(CAMERA_MAX_ZOOM, zoom + manualZoom, CAMERA_MIN_ZOOM));

        -- Gradually move the camera to the target position.
        cx = lerp(cx, gx + ox, dt * CAMERA_TRACKING_SPEED);
        cy = lerp(cy, gy + oy, dt * CAMERA_TRACKING_SPEED);
        camera:lookAt(cx, cy);
    end

    ---
    -- @param func
    --
    function self:draw(func)
        camera:draw(func);
    end

    ---
    -- Receives events from an observable.
    -- @param event
    -- @param ...
    --
    function self:receive(event, ...)
        if event == 'GRAPH_UPDATE_CENTER' then
            updateCenter(...);
        elseif event == 'GRAPH_UPDATE_DIMENSIONS' then
            updateGraphDimensions(...);
        end
    end

    ---
    -- Returns the camera's rotation.
    --
    function self:getRotation()
        return camera.rot;
    end

    function self:getScale()
        return camera.scale;
    end

    return self;
end

return CamWrapper;
