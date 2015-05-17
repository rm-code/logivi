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
