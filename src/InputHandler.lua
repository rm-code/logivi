--==================================================================================================
-- Copyright (C) 2014 - 2015 by Robert Machmer                                                     =
--                                                                                                 =
-- Permission is hereby granted, free of charge, to any person obtaining a copy                    =
-- of this software and associated documentation files (the "Software"), to deal                   =
-- in the Software without restriction, including without limitation the rights                    =
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell                       =
-- copies of the Software, and to permit persons to whom the Software is                           =
-- furnished to do so, subject to the following conditions:                                        =
--                                                                                                 =
-- The above copyright notice and this permission notice shall be included in                      =
-- all copies or substantial portions of the Software.                                             =
--                                                                                                 =
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR                      =
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,                        =
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE                     =
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER                          =
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,                   =
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN                       =
-- THE SOFTWARE.                                                                                   =
--==================================================================================================

local InputHandler = {};

---
-- Determines if a key constant or if any in a table of key constants are down.
-- @param constant - The key constant or table of constants.
--
function InputHandler.isDown(constant)
    if type(constant) == 'table' then
        for _, keyToCheck in ipairs(constant) do
            if love.keyboard.isDown(keyToCheck) then
                return true;
            end
        end
        return false;
    else
        return love.keyboard.isDown(constant);
    end
end

---
-- Determines if a key constant or if any in a table of key constants was pressed.
-- @param key - The key to check for.
-- @param constant - The key constant or table of constants.
--
function InputHandler.isPressed(key, constant)
    if type(constant) == 'table' then
        for _, keyToCheck in ipairs(constant) do
            if key == keyToCheck then
                return true;
            end
        end
        return false;
    else
        return key == constant;
    end
end

return InputHandler;
