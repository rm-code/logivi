local Camera = require('lib.camera.Camera');
local Messenger = require('src.messenger.Messenger');
local Utility = require( 'src.Utility' );

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local CamWrapper = {};

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local EVENT = require('src.messenger.Event');

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

    local camera = Camera.new();
    local currentX, currentY = 0, 0; -- The actual position of the camera.
    local targetX,  targetY  = 0, 0; -- The desired coordinates.
    local graphCenterX, graphCenterY = 0, 0;
    local graphWidth, graphHeight = 0, 0;
    local zoom = 1;
    local manualZoom = 0;

    local subscriptions = {};

    -- ------------------------------------------------
    -- Private Functions
    -- ------------------------------------------------

    ---
    -- Updates the position on which the camera offset builds.
    -- @param ngx (number) The graph's center along the x-axis.
    -- @param ngy (number) The graph's center along the y-axis.
    --
    local function updateCenter( ngx, ngy )
        graphCenterX, graphCenterY = ngx, ngy;
    end

    ---
    -- Updates the dimensions (width and height) of the graph.
    -- @param minX (number) The minimum coordinate of the graph along the x-axis.
    -- @param maxX (number) The maximum coordinate of the graph along the x-axis.
    -- @param minY (number) The minimum coordinate of the graph along the y-axis.
    -- @param maxY (number) The maximum coordinate of the graph along the y-axis.
    --
    local function updateGraphDimensions( minX, maxX, minY, maxY )
        graphWidth, graphHeight = maxX - minX, maxY - minY;
    end

    ---
    -- Calculates the automatic zoom factor needed to fit the whole graph on
    -- the user's screen.
    -- @param rot (number) The current rotation of the camera.
    -- @return    (number) Either the width or height to use for the zoom.
    local function calculateAutoZoom( rot )
        local w, h = GRAPH_PADDING + graphWidth, GRAPH_PADDING + graphHeight;
        local sw, sh = love.graphics.getDimensions();

        -- Take rotation of the graph into account.
        local rw = h * math.abs( math.sin( rot )) + w * math.abs( math.cos( rot ));
        local rh = h * math.abs( math.cos( rot )) + w * math.abs( math.sin( rot ));

        -- Calculate the zoom factors for both width and height and use the
        -- smaller one to zoom.
        local ratioW, ratioH =  sw / rw, sh / rh;

        return ratioW <= ratioH and ratioW or ratioH;
    end

    -- ------------------------------------------------
    -- Public Functions
    -- ------------------------------------------------

    ---
    -- Zooms the camera.
    -- @param dt (number) Time since the last update in seconds.
    -- @param dir (number) The direction in which the camera should be zoomed.
    --
    function self:zoom( dt, dir )
        manualZoom = manualZoom + ( dir * CAMERA_ZOOM_SPEED ) * dt;
    end

    ---
    -- Rotates the camera.
    -- @param dt  (number) Time since the last update in seconds.
    -- @param dir (number) The direction in which the camera should be rotated.
    --
    function self:rotate( dt, dir )
        camera:rotate( dir * CAMERA_ROTATION_SPEED * dt );
    end

    ---
    -- Moves the camera.
    -- @param dt (number) Time since the last update in seconds.
    -- @param dx (number) The distance to move along the x-axis.
    -- @param dy (number) The distance to move along the y-axis.
    --
    function self:move( dt, dx, dy )
        dx = dx * dt * CAMERA_TRANSLATION_SPEED;
        dy = dy * dt * CAMERA_TRANSLATION_SPEED;
        targetX = targetX + ( math.cos( -camera.rot ) * dx - math.sin( -camera.rot ) * dy );
        targetY = targetY + ( math.sin( -camera.rot ) * dx + math.cos( -camera.rot ) * dy );
    end

    ---
    -- Processes camera related controls and updates the camera.
    -- @param dt (number) Time since the last update in seconds.
    --
    function self:update( dt )
        local targetZoom = calculateAutoZoom( camera.rot );
        zoom = Utility.lerp( zoom, targetZoom, dt * 2 );

        camera:zoomTo( Utility.clamp( CAMERA_MAX_ZOOM, zoom + manualZoom, CAMERA_MIN_ZOOM ));

        -- Gradually move the camera to the target position.
        currentX = Utility.lerp( currentX, graphCenterX + targetX, dt * CAMERA_TRACKING_SPEED );
        currentY = Utility.lerp( currentY, graphCenterY + targetY, dt * CAMERA_TRACKING_SPEED );
        camera:lookAt( currentX, currentY );
    end

    ---
    -- Applies the camera transformation to the scene via a callback function.
    -- @param func (function) The function to apply the camera transformations to.
    --
    function self:draw( func )
        camera:draw( func );
    end

    ---
    -- Returns the camera's rotation.
    -- @return (number) The camera's rotation.
    --
    function self:getRotation()
        return camera.rot;
    end

    ---
    -- Returns the camera's zoom factor.
    -- @return (number) The camera's zoom factor.
    --
    function self:getScale()
        return camera.scale;
    end

    ---
    -- Transforms the camera and sets the position.
    -- @param nx (number) The new coordinate along the x-axis.
    -- @param ny (number) The new coordinate along the y-axis.
    --
    function self:setPosition( nx, ny )
        camera:lookAt( nx, ny );
        currentX, currentY = nx, ny;
    end

    ---
    -- Removes the camera's subsriptions from the Messenger.
    --
    function self:reset()
        for _, v in ipairs( subscriptions ) do
            Messenger.remove( v );
        end
    end

    -- ------------------------------------------------
    -- Observed Events
    -- ------------------------------------------------

    subscriptions[#subscriptions + 1] = Messenger.observe( EVENT.GRAPH_UPDATE_CENTER, function( ... )
        updateCenter( ... );
    end)

    subscriptions[#subscriptions + 1] = Messenger.observe( EVENT.GRAPH_UPDATE_DIMENSIONS, function( ... )
        updateGraphDimensions( ... );
    end)

    return self;
end

return CamWrapper;
