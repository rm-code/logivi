local Author = require('src/Author');
local http = require('socket.http');

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local AuthorManager = {};

-- ------------------------------------------------
-- Local Variables
-- ------------------------------------------------

local authors;
local avatars;
local aliases;

-- ------------------------------------------------
-- Public Functions
-- ------------------------------------------------

function AuthorManager.init()
    authors = {};
    local default = [[
return {
    -- ['NameToReplace'] = 'ReplaceWith',
};
]];

    if not love.filesystem.isFile('aliases.lua') then
        local file = love.filesystem.newFile('aliases.lua');
        file:open('w');
        file:write(default);
        file:close();
    end
    aliases = love.filesystem.load('aliases.lua')();

    avatars = {};
    -- Grab the default avatar online, write it to the save folder and load it as an image.
    local body = http.request('https://www.love2d.org/w/images/9/9b/Love-game-logo-256x256.png');
    love.filesystem.write('tmp_default.png', body);
    avatars['default'] = love.graphics.newImage('tmp_default.png');

    -- Read the avatars.lua file (if there is one) and use it to grab an avatar online, write it
    -- to the save folder and load it as an image to use in LoGiVi.
    local counter = 0;
    if not love.filesystem.isFile('avatars.lua') then
        local file = love.filesystem.newFile('avatars.lua');
        local default = [[
return {
    -- ['user'] = 'UrlToAvatar',
};
]];
        file:open('w');
        file:write(default);
        file:close();
    end
    local avatarFile = love.filesystem.load('avatars.lua')();
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

return AuthorManager;