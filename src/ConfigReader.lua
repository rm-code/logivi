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

local ConfigReader = {};

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local FILE_NAME = 'config.lua';
local FILE_TEMPLATE = [[
-- ------------------------------- --
-- LoGiVi - Configuration File.    --
-- ------------------------------- --

return {
    -- Replaces the name of the specified authors.
    aliases = {
        -- ['nameToReplace'] = 'replaceWith',
    },
    -- Assigns an avatar to an author.
    avatars = {
        -- ['author'] = 'urlToAvatar',
    },
    options = {
        backgroundColor = { 0, 0, 0 },
        removeTmpFiles = false,
        screenWidth = 800,
        screenHeight = 600,
    },
};
]]

-- ------------------------------------------------
-- Local Variables
-- ------------------------------------------------

local config;

-- ------------------------------------------------
-- Local Functions
-- ------------------------------------------------

local function loadFile(name, default)
    if not love.filesystem.isFile(name) then
        local file = love.filesystem.newFile(name);
        file:open('w');
        file:write(default);
        file:close();
    end
    return love.filesystem.load(name)();
end

-- ------------------------------------------------
-- Public Functions
-- ------------------------------------------------

function ConfigReader.init()
    config = loadFile(FILE_NAME, FILE_TEMPLATE);
end

function ConfigReader.removeTmpFiles()
    print('Removing temporary files...');
    local function recursivelyDelete(item, depth)
        local ws = '';
        for _ = 1, depth do
            ws = ws .. '    ';
        end
        print(ws .. item);
        if love.filesystem.isDirectory(item) then
            for _, child in pairs(love.filesystem.getDirectoryItems(item)) do
                recursivelyDelete(item .. '/' .. child, depth + 1);
                love.filesystem.remove(item .. '/' .. child);
            end
        elseif love.filesystem.isFile(item) then
            love.filesystem.remove(item);
        end
        love.filesystem.remove(item);
    end

    recursivelyDelete('tmp', 0);
    print('... Done!');
end

-- ------------------------------------------------
-- Getters
-- ------------------------------------------------

function ConfigReader.getConfig(section)
    return config[section];
end

-- ------------------------------------------------
-- Return Module
-- ------------------------------------------------

return ConfigReader;