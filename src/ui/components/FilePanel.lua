local BaseComponent = require('src.ui.components.BaseComponent');
local BoxDecorator = require('src.ui.decorators.BoxDecorator');
local Resizable = require('src.ui.decorators.Resizable');
local Draggable = require('src.ui.decorators.Draggable');
local Scrollable = require('src.ui.decorators.Scrollable');
local RenderArea = require('src.ui.decorators.RenderArea');
local Toggleable = require('src.ui.decorators.Toggleable');

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local FilePanel = {};

-- ------------------------------------------------
-- Constructor
-- ------------------------------------------------

function FilePanel.new(render, update, x, y, w, h)
    local bodyBaseCol = { 0, 0, 0, 0 };

    local self = Toggleable();
    self:attach(Scrollable(0, 0, 0, 0));
    self:attach(RenderArea(render, update, 2, 2, -2, -2));
    self:attach(BoxDecorator('fill', bodyBaseCol, 0, 0, 0, 0));
    self:attach(BaseComponent(x, y, w, h));

    return self;
end

return FilePanel;
