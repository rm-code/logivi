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
function AuthorManager.draw()
    local count = 0;
    for author, _ in pairs(authors) do
        count = count + 1;
        love.graphics.print(author, 20, 100 + count * 20);
    end
end

---
-- Adds a new author to the list. If a file for alternatives
-- was found, the function will use relapcements from that list.
-- This can be used to fix "faulty" authors in commits.
-- @param nauthor
--
function AuthorManager.add(nauthor)
    authors[aliases[nauthor] or nauthor] = true;
end

return AuthorManager;