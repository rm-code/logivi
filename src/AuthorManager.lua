local Author = require('src/Author');

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local AuthorManager = {};

-- ------------------------------------------------
-- Local Variables
-- ------------------------------------------------

local authors;
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
        authors[nickname] = Author.new(nickname);
    end
    return authors[nickname];
end

return AuthorManager;