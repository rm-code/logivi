local ScreenManager = require( 'lib.screenmanager.ScreenManager' );

---
-- This function is called exactly once at the beginning of the game.
--
function love.load()
    print( "===================" );
    print( string.format( "Title: '%s'", getTitle() ));
    print( string.format( "Version: %.4d", getVersion() ));
    print( string.format( "LOVE Version: %d.%d.%d (%s)", love.getVersion() ));
    print( string.format( "Resolution: %dx%d", love.graphics.getDimensions() ));

    -- Check the user's hardware.
    print( "\n---- RENDERER  ---- " );
    local name, version, vendor, device = love.graphics.getRendererInfo();
    print( string.format( "Name: %s \nVersion: %s \nVendor: %s \nDevice: %s", name, version, vendor, device ));

    print( "\n----  SYSTEM   ---- " );
    print( love.system.getOS() );
    print( "===================" );
    print( os.date( '%c', os.time() ));
    print( "===================" );

    local screens = {
        loading = require( 'src.screens.LoadingScreen' ),
        selection = require( 'src.screens.SelectionScreen' ),
        main = require( 'src.screens.MainScreen' ),
        input = require( 'src.screens.InputPanel' )
    };

    ScreenManager.init( screens, 'loading' );
end

---
-- Callback function used to draw on the screen every frame.
--
function love.draw()
    ScreenManager.draw();
end

---
-- Callback function used to update the state of the game every frame.
-- @param dt (number) Time since the last update in seconds.
--
function love.update( dt )
    ScreenManager.update( dt );
end

---
-- Callback function triggered when the game is closed.
--
function love.quit()
    ScreenManager.quit();
end

---
-- Called when the window is resized, for example if the user resizes the window, or if
-- love.window.setMode is called with an unsupported width or height in fullscreen and
-- the window chooses the closest appropriate size.
-- @param x (number) The new width, in pixels.
-- @param y (number) The new height, in pixels.
--
function love.resize( x, y )
    ScreenManager.resize( x, y );
end

---
-- Callback function triggered when a key is pressed.
-- @param key      (KeyConstant) Character of the pressed key.
-- @param scancode (Scancode)    The scancode representing the pressed key.
-- @param isrepeat (boolean)     Whether this keypress event is a repeat. The delay between
--                                key repeats depends on the user's system settings.
--
function love.keypressed( key, scancode, isrepeat )
    -- Transform strings to numbers to fit the control values we read from the config file.
    if tonumber( key ) then
        key = tonumber( key );
    end

    ScreenManager.keypressed( key, scancode, isrepeat );
end

---
-- Callback function triggered when a mouse button is pressed.
-- @param x       (number)  Mouse x position, in pixels.
-- @param y       (number)  Mouse y position, in pixels.
-- @param button  (number)  The button index that was pressed. 1 is the primary mouse button,
--                           2 is the secondary mouse button and 3 is the middle button. Further
--                           buttons are mouse dependent.
-- @param istouch (boolean) True if the mouse button press originated from a touchscreen touch-press.
--
function love.mousepressed( x, y, button, istouch )
    ScreenManager.mousepressed( x, y, button, istouch );
end

---
-- Callback function triggered when a mouse button is released.
-- @param x       (number)  Mouse x position, in pixels.
-- @param y       (number)  Mouse y position, in pixels.
-- @param button  (number)  The button index that was pressed. 1 is the primary mouse button,
--                           2 is the secondary mouse button and 3 is the middle button. Further
--                           buttons are mouse dependent.
-- @param istouch (boolean) True if the mouse button press originated from a touchscreen touch-release.
--
function love.mousereleased( x, y, button, istouch )
    ScreenManager.mousereleased( x, y, button, istouch );
end

---
-- Callback function triggered when the mouse is moved.
-- @param x  (number) The mouse position on the x-axis.
-- @param y  (number) The mouse position on the y-axis.
-- @param dx (number) The amount moved along the x-axis since the last time love.mousemoved was called.
-- @param dy (number) The amount moved along the y-axis since the last time love.mousemoved was called.
--
function love.mousemoved( x, y, dx, dy )
    ScreenManager.mousemoved( x, y, dx, dy );
end

---
-- Callback function triggered when the mouse wheel is moved.
-- @param x (number) Amount of horizontal mouse wheel movement. Positive values indicate movement to the right.
-- @param y (number) Amount of vertical mouse wheel movement. Positive values indicate upward movement.
--
function love.wheelmoved( x, y )
    ScreenManager.wheelmoved( x, y );
end

---
-- Callback function triggered when a directory is dragged and dropped onto the window.
-- @param path (string) The full platform-dependent path to the directory. It can be used as an argument to
--                       love.filesystem.mount, in order to gain read access to the directory with love.filesystem.
--
function love.directorydropped( path )
    ScreenManager.directorydropped( path );
end

---
-- Called when text has been entered by the user. For example if shift-2 is pressed on an American keyboard
-- layout, the text "@" will be generated.
-- @param text (string) The UTF-8 encoded unicode text.
--
function love.textinput( text )
    ScreenManager.textinput( text );
end
