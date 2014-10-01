--==================================================================================================
-- Copyright (C) 2014 by Robert Machmer                                                            =
--==================================================================================================

local Screen = {};

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

function Screen.new()
    local self = {};

    local active = true;

    -- ------------------------------------------------
    -- Public Methods
    -- ------------------------------------------------

    function self:init() end

    function self:close() end

    function self:update(dt) end

    function self:draw() end

    function self:focus(dfocus) end

    function self:resize(w, h) end

    function self:visible(dvisible) end

    function self:keypressed(key) end

    function self:keyreleased(key) end

    function self:textinput(input) end

    function self:mousereleased(x, y, button) end

    function self:mousepressed(x, y, button) end

    function self:mousefocus(focus) end

    function self:isActive()
        return active;
    end

    function self:setActive(dactiv)
        active = dactiv;
    end

    return self;
end

-- ------------------------------------------------
-- Return Module
-- ------------------------------------------------

return Screen;

--==================================================================================================
-- Created 02.06.14 - 20:25                                                                        =
--==================================================================================================