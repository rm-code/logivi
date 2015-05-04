--==================================================================================================
-- Copyright (C) 2015 by Robert Machmer                                                            =
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
local BoxDecorator = require('src.ui.decorators.BoxDecorator');
local Resizable = require('src.ui.decorators.Resizable');
local Draggable = require('src.ui.decorators.Draggable');
local Scrollable = require('src.ui.decorators.Scrollable');
local RenderArea = require('src.ui.decorators.RenderArea');
local Toggleable = require('src.ui.decorators.Toggleable');

local FilePanel = {};

function FilePanel.new(render, update, x, y, w, h)
    local bodyBaseCol = { 80, 80, 80, 150 };

    local self = Toggleable();
    self:attach(Resizable(w - 16, h - 16, -w + 16, -h + 16, true, true, true, true));
    self:attach(BoxDecorator('fill', bodyBaseCol, w - 16, h - 16, -w + 16, -h + 16, true, true, true, true));
    self:attach(Draggable (0, 0, 0, 0));
    self:attach(Scrollable(0, 0, 0, 0));
    self:attach(RenderArea(render, update, 2, 2, -2, -2));
    self:attach(BoxDecorator('fill', bodyBaseCol, 0, 0, 0, 0));
    self:attach(BaseComponent(x, y, w, h));

    return self;
end

return FilePanel;
