local InputHandler = require('src.InputHandler');
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
-- Local variables
-- ------------------------------------------------

local camera_zoomIn;
local camera_zoomOut;
local camera_rotateL;
local camera_rotateR;
local camera_n;
local camera_s;
local camera_e;
local camera_w;

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

    ---
    -- Assign the keybindings to local variables for faster access.
    -- @param config
    --
    function self:assignKeyBindings(config)
        camera_zoomIn = config.keyBindings.camera_zoomIn;
        camera_zoomOut = config.keyBindings.camera_zoomOut;
        camera_rotateL = config.keyBindings.camera_rotateL;
        camera_rotateR = config.keyBindings.camera_rotateR;
        camera_n = config.keyBindings.camera_n;
        camera_s = config.keyBindings.camera_s;
        camera_e = config.keyBindings.camera_e;
        camera_w = config.keyBindings.camera_w;
    end

    ---
    -- Processes camera related controls and updates the camera.
    -- @param dt
    --
    function self:move(dt)
        local tzoom = calculateAutoZoom(camera.rot);
        zoom = lerp(zoom, tzoom, dt * 2);

        -- Handle manual zoom. This will be added to the automatic zoom factor.
        if InputHandler.isDown(camera_zoomIn) then
            manualZoom = manualZoom + CAMERA_ZOOM_SPEED * dt;
        elseif InputHandler.isDown(camera_zoomOut) then
            manualZoom = manualZoom - CAMERA_ZOOM_SPEED * dt;
        end

        camera:zoomTo(math.max(CAMERA_MAX_ZOOM, math.min(zoom + manualZoom, CAMERA_MIN_ZOOM)));

        -- Rotation.
        if InputHandler.isDown(camera_rotateL) then
            camera:rotate(-CAMERA_ROTATION_SPEED * dt);
        elseif InputHandler.isDown(camera_rotateR) then
            camera:rotate(CAMERA_ROTATION_SPEED * dt);
        end

        -- Horizontal Movement.
        local dx = 0;
        if InputHandler.isDown(camera_w) then
            dx = dx - dt * CAMERA_TRANSLATION_SPEED;
        elseif InputHandler.isDown(camera_e) then
            dx = dx + dt * CAMERA_TRANSLATION_SPEED;
        end
        -- Vertical Movement.
        local dy = 0;
        if InputHandler.isDown(camera_n) then
            dy = dy - dt * CAMERA_TRANSLATION_SPEED;
        elseif InputHandler.isDown(camera_s) then
            dy = dy + dt * CAMERA_TRANSLATION_SPEED;
        end

        -- Take the camera rotation into account when calculating the new offset.
        ox = ox + (math.cos(-camera.rot) * dx - math.sin(-camera.rot) * dy);
        oy = oy + (math.sin(-camera.rot) * dx + math.cos(-camera.rot) * dy);

        -- Gradually move the camera to the target position.
        cx = cx - (cx - math.floor(gx + ox)) * dt * CAMERA_TRACKING_SPEED;
        cy = cy - (cy - math.floor(gy + oy)) * dt * CAMERA_TRACKING_SPEED;
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

    return self;
end

return CamWrapper;
