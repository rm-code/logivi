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

local PATH_AVATARS = 'tmp/avatars/';

-- ------------------------------------------------
-- Local Variables
-- ------------------------------------------------

local authors;
local avatars;
local aliases;
local addresses;

-- ------------------------------------------------
-- Local Functions
-- ------------------------------------------------

---
-- Tries to load user avatars from the local filesystem or the internet.
-- @param urlList
--
local function grabAvatars(urlList)
    local counter = 0;
    local avatars = {};
    for author, url in pairs(urlList) do
        -- If the file exists locally we load it as usual.
        -- If it doesn't we see if the url returns something useful.
        if love.filesystem.isFile(url) then
            avatars[author] = love.graphics.newImage(url);
        else
            local body = http.request(url);
            if body then
                -- Set up the temporary folder if we don't have one yet.
                if not love.filesystem.isDirectory(PATH_AVATARS) then
                    love.filesystem.createDirectory(PATH_AVATARS);
                end

                -- Write file to a temporary folder.
                love.filesystem.write(string.format(PATH_AVATARS .. "tmp_%03d.png", counter), body);

                local ok, image = pcall(love.graphics.newImage, string.format(PATH_AVATARS .. "tmp_%03d.png", counter));
                if ok then
                    avatars[author] = image;
                    counter = counter + 1;
                else
                    print("Couldn't load avatar from " .. url .. " - A default avatar will be used instead.");
                end
                counter = counter + 1;
            end
        end
    end

    -- Load the default user avatar.
    avatars['default'] = love.graphics.newImage('res/user.png');

    return avatars;
end

-- ------------------------------------------------
-- Public Functions
-- ------------------------------------------------

function AuthorManager.init(naliases, avatarUrls)
    -- Set up the table to store all authors.
    authors = {};

    addresses = {};
    aliases = naliases;

    -- Load avatars from the local filesystem or an online location.
    avatars = grabAvatars(avatarUrls);
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
-- Adds a new author to the list using his name as a key. Before storing the
-- author the function checks the config file to see if an alias is associated
-- with the specific email address. If it is, it will use the alias and ignore
-- the name found in the log file.
-- If there isn't an alias, it will check if there already is another nickname
-- stored for that email address. If there isn't, it will use the nickname
-- found in the log.
-- @param nemail
-- @param nauthor
-- @param cx
-- @param cy
--
function AuthorManager.add(nemail, nauthor, cx, cy)
    local nickname = aliases[nemail] or addresses[nemail] or nauthor;

    if not authors[nickname] then
        addresses[nemail] = nauthor; -- Store this name as the default for this email address.
        authors[nickname] = Author.new(nickname, avatars[nickname] or avatars['default'], cx, cy);
    end

    return authors[nickname];
end

-- ------------------------------------------------
-- Return Module
-- ------------------------------------------------

return AuthorManager;
