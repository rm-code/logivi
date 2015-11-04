local BaseComponent = require('src.ui.components.BaseComponent');
local BaseDecorator = require('src.ui.decorators.BaseDecorator');
local BoxDecorator = require('src.ui.decorators.BoxDecorator');
local MouseOverDecorator = require('src.ui.decorators.MouseOverDecorator');
local Clickable = require('src.ui.decorators.Clickable');
local TextLabel = require('src.ui.decorators.TextLabel');
local Resources = require('src.Resources');

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local Button = {};

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local LABEL_FONT = Resources.loadFont('SourceCodePro-Medium.otf', 20);

-- ------------------------------------------------
-- Constructor
-- ------------------------------------------------

function Button.new(command, text, x, y, w, h)
    local self = BaseDecorator(x, y, w, h);

    local bodyCol = { 60, 60, 60, 255 };
    local outlineCol = { 100, 100, 100, 255 };
    local hlCol = { 255, 255, 255, 100 };
    local textCol = { 200, 200, 200, 255 };

    local textX = w * 0.5 - LABEL_FONT:getWidth(text) * 0.5;
    local textY = h * 0.5 - LABEL_FONT:getHeight() * 0.5;

    self:attach(Clickable(command, 0, 0, 0, 0));
    self:attach(MouseOverDecorator(hlCol, 0, 0, 0, 0));
    self:attach(TextLabel(text, textCol, LABEL_FONT, textX, textY));
    self:attach(BoxDecorator('line', outlineCol, 0, 0, 0, 0));
    self:attach(BoxDecorator('fill', bodyCol, 0, 0, 0, 0));
    self:attach(BaseComponent(x, y, w, h));

    return self;
end

return Button;
