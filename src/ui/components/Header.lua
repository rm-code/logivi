local BaseComponent = require('src.ui.components.BaseComponent');
local TextLabel = require('src.ui.decorators.TextLabel');
local Resources = require('src.Resources');

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local Header = {};

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local HEADER_FONT = Resources.loadFont('SourceCodePro-Bold.otf', 35);

-- ------------------------------------------------
-- Constructor
-- ------------------------------------------------

function Header.new(text, x, y, w, h)
    local shadowCol = { 0, 0, 0, 100 };
    local textCol = { 255, 100, 100, 255 };

    local self = TextLabel(text, textCol, HEADER_FONT, 0, 0);
    self:attach(TextLabel(text, shadowCol, HEADER_FONT, 5, 5));
    self:attach(BaseComponent(x, y, w, h));

    return self;
end

return Header;
