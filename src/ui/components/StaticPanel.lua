local BaseComponent = require('src.ui.components.BaseComponent');
local BaseDecorator = require('src.ui.decorators.BaseDecorator');
local BoxDecorator = require('src.ui.decorators.BoxDecorator');

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local StaticPanel = {};

-- ------------------------------------------------
-- Constructor
-- ------------------------------------------------

function StaticPanel.new(x, y, w, h)
    local self = BaseDecorator(x, y, w, h);

    local bodyCol = { 40, 40, 40, 255 };
    local outlineCol = { 80, 80, 80, 255 };

    self:attach(BoxDecorator('line', outlineCol, 0, 0, 0, 0));
    self:attach(BoxDecorator('fill', bodyCol, 0, 0, 0, 0));
    self:attach(BaseComponent(x, y, w, h));

    return self;
end

return StaticPanel;
