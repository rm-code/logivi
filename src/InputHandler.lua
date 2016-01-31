local InputHandler = {};

---
-- Determines if a key constant or if any in a table of key constants are down.
-- @param constant (string) The key constant or table of constants.
--
function InputHandler.isDown( constant )
    if type( constant ) == 'table' then
        for _, keyToCheck in ipairs( constant ) do
            if love.keyboard.isDown( keyToCheck ) then
                return true;
            end
        end
        return false;
    else
        return love.keyboard.isDown( constant );
    end
end

---
-- Determines if a key constant or if any in a table of key constants was pressed.
-- @param key      (string) The key to check.
-- @param constant (string) The key constant or table of constants to check for.
--
function InputHandler.isPressed( key, constant )
    if type( constant ) == 'table' then
        for _, keyToCheck in ipairs( constant ) do
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
