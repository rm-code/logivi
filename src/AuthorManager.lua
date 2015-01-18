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

local Author = require('src/Author');
local http = require('socket.http');

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local AuthorManager = {};

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local DEFAULT_ALIASES_FILE_CONTENT = [[
return {
    -- ['NameToReplace'] = 'ReplaceWith',
};
]];

local DEFAULT_AVATARS_FILE_CONTENT = [[
return {
    -- ['user'] = 'UrlToAvatar',
};
]];

local ALIASES_FILE_NAME = 'aliases.lua';
local AVATARS_FILE_NAME = 'avatars.lua';

-- ------------------------------------------------
-- Local Variables
-- ------------------------------------------------

local authors;
local avatars;
local aliases;

-- ------------------------------------------------
-- Private Functions
-- ------------------------------------------------

---
-- Checks if the file already exists. If it does it is
-- loaded, executed and returned. If the file doesn't
-- exist yet a default file will be written instead.
-- This default file is then read and returned.
-- @param name
-- @param default
--
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

function AuthorManager.init()
    -- Set up the table to store all authors.
    authors = {};

    -- Create an aliases default file or load an existing one.
    aliases = loadFile(ALIASES_FILE_NAME, DEFAULT_ALIASES_FILE_CONTENT);

    avatars = {};
    -- Grab the default avatar online, write it to the save folder and load it as an image.
    local body = http.request('https://www.love2d.org/w/images/9/9b/Love-game-logo-256x256.png');
    love.filesystem.write('tmp_default.png', body);
    avatars['default'] = love.graphics.newImage('tmp_default.png');

    -- Read the avatars.lua file (if there is one) and use it to grab an avatar online, write it
    -- to the save folder and load it as an image to use in LoGiVi.
    local counter = 0;
    local avatarFile = loadFile(AVATARS_FILE_NAME, DEFAULT_AVATARS_FILE_CONTENT);
    for author, url in pairs(avatarFile) do
        local body = http.request(url);
        love.filesystem.write(string.format("tmp_%03d.png", counter), body);
        avatars[author] = love.graphics.newImage(string.format("tmp_%03d.png", counter));
        counter = counter + 1;
    end
end

---
-- Draws a list of all authors working on the project.
--
function AuthorManager.drawLabels()
    for _, author in pairs(authors) do
        author:draw();
    end
end

function AuthorManager.drawList()
    local count = 0;
    for name, _ in pairs(authors) do
        count = count + 1;
        love.graphics.print(name, 20, 100 + count * 20);
    end
end

---
-- Updates all authors.
-- @param dt
--
function AuthorManager.update(dt)
    for name, author in pairs(authors) do
        author:update(dt);
    end
end

---
-- Adds a new author to the list. If a file for alternatives
-- was found, the function will use relapcements from that list.
-- This can be used to fix "faulty" authors in commits.
-- @param nauthor
--
function AuthorManager.add(nauthor)
    local nickname = aliases[nauthor] or nauthor;

    if not authors[nickname] then
        authors[nickname] = Author.new(nickname, avatars[nickname] or avatars['default']);
    end
    return authors[nickname];
end

-- ------------------------------------------------
-- Return Module
-- ------------------------------------------------

return AuthorManager;
