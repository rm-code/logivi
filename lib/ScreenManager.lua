--==================================================================================================
-- Copyright (C) 2014 by Robert Machmer                                                            =
--==================================================================================================

local ScreenManager = {};

local stack = {};

-- ------------------------------------------------
-- Module Functions
-- ------------------------------------------------

---
-- Initialise the ScreenManager and
-- @param screen
--
function ScreenManager.init(screen)
    stack = {};
    ScreenManager.push(screen);
end

---
-- Clears the ScreenManager, creates a new screen and switches
-- to it. Use this if you don't want to stack onto other screens.
--
-- @param nscreen
--
function ScreenManager.switch(screen)
    ScreenManager.clear();
    ScreenManager.push(screen);
end

---
-- Creates a new screen and pushes it on the screen stack, where
-- it will overlay all the other screens.
-- Screens below the this new screen will be set inactive.
--
-- @param nscreen
--
function ScreenManager.push(nscreen)
    -- Deactivate the previous screen if there is one.
    if ScreenManager.peek() then
        ScreenManager.peek():setActive(false);
    end

    -- Push the new screen onto the stack.
    stack[#stack + 1] = nscreen;

    -- Create the new screen and initialise it.
    nscreen:init();
end

---
-- Returns the screen on top of the screen stack without removing it.
--
function ScreenManager.peek()
    return stack[#stack];
end

---
-- Removes the topmost screen of the stack
--
function ScreenManager.pop()
    if #stack > 1 then
        -- Close the currently active screen.
        local tmp = ScreenManager.peek();

        -- Remove the now inactive screen from the stack.
        stack[#stack] = nil;

        -- Close the previous screen.
        tmp:close();

        -- Activate next screen on the stack.
        ScreenManager.peek():setActive(true);
    else
        error("Can't close the last screen. Use switch() to clear the screen manager and add a new screen");
    end
end

---
-- Close and remove all screens from the stack.
--
function ScreenManager.clear()
    for i = 1, #stack do
        stack[i]:close();
        stack[i] = nil;
    end
end

---
-- Draw all screens on the stack. Screens that are higher on the stack
-- will overlay screens that are on the bottom.
--
function ScreenManager.draw()
    for i = 1, #stack do
        stack[i]:draw();
    end
end

---
-- Update all screens on the stack.
--
function ScreenManager.update(dt)
    for i = 1, #stack do
        stack[i]:update(dt);
    end
end

---
-- Resize all screens on the stack.
-- @param w
-- @param h
--
function ScreenManager.resize(w, h)
    for i = 1, #stack do
        stack[i]:resize(w, h);
    end
end

---
-- Update all screens on the stack whenever the game window gains or
-- loses focus.
-- @param dfocus
--
function ScreenManager.focus(dfocus)
    for i = 1, #stack do
        stack[i]:focus(dfocus);
    end
end

---
-- Update all screens on the stack whenever the game window is minimized.
-- @param dvisible
--
function ScreenManager.visible(dvisible)
    for i = 1, #stack do
        stack[i]:visible(dvisible);
    end
end

---
-- Reroutes the keypressed callback to the currently active screen.
-- @param key
--
function ScreenManager.keypressed(key)
    ScreenManager.peek():keypressed(key);
end

---
-- Reroutes the keyreleased callback to the currently active screen.
-- @param key
--
function ScreenManager.keyreleased(key)
    ScreenManager.peek():keyreleased(key);
end

---
-- Reroute the textinput callback to the currently active screen.
-- @param input
--
function ScreenManager.textinput(input)
    ScreenManager.peek():textinput(input);
end

---
-- Reroute the mousepressed callback to the currently active screen.
-- @param x
-- @param y
-- @param button
--
function ScreenManager.mousepressed(x, y, button)
    ScreenManager.peek():mousepressed(x, y, button);
end

---
-- Reroute the mousereleased callback to the currently active screen.
-- @param x
-- @param y
-- @param button
--
function ScreenManager.mousereleased(x, y, button)
    ScreenManager.peek():mousereleased(x, y, button);
end

---
-- Reroute the mousefocus callback to the currently active screen.
-- @param x
-- @param y
-- @param button
--
function ScreenManager.mousefocus(focus)
    ScreenManager.peek():mousefocus(focus);
end

-- ------------------------------------------------
-- Return Module
-- ------------------------------------------------

return ScreenManager;

--==================================================================================================
-- Created 02.06.14 - 17:30                                                                        =
--==================================================================================================