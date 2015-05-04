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

local BaseComponent = require('src.ui.components.BaseComponent');
local BaseDecorator = require('src.ui.decorators.BaseDecorator');
local BoxDecorator = require('src.ui.decorators.BoxDecorator');
local MouseOverDecorator = require('src.ui.decorators.MouseOverDecorator');
local Clickable = require('src.ui.decorators.Clickable');
local TextLabel = require('src.ui.decorators.TextLabel');

local Button = {};

function Button.new(command, text, x, y, w, h)
    local self = BaseDecorator(x, y, w, h);

    local bodyCol = { 60, 60, 60, 255 };
    local outlineCol = { 100, 100, 100, 255 };
    local hlCol = { 255, 255, 255, 100 };
    local textCol = { 200, 200, 200, 255 };

    local LABEL_FONT = love.graphics.newFont('res/fonts/SourceCodePro-Medium.otf', 20);

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
