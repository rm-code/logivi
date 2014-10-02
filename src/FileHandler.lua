-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local FileHandler = {};

---
-- Remove leading and trailing whitespace.
-- @param str
--
local function trim(str)
    return str:match("^%s*(.-)%s*$");
end

---
-- Loads the file and stores it line for line in a lua table.
-- @param name
--
function FileHandler.loadFile(name)
    local file = {};
    for line in love.filesystem.lines(name) do
        file[#file + 1] = line;
    end
    return file;
end

---
-- Split up the log table into commits. Each commit is a new
-- nested table.
-- @param log
--
function FileHandler.splitCommits(log)
    local commits = {};
    local index = 0;
    for i = 1, #log do
        local line = log[i];

        -- New commit.
        if line:find('commit') then
            index = index + 1;
            commits[index] = {};
        elseif line:find('author') then
            commits[index].author = line;
        elseif line:find('date') then
            commits[index].date = line;
        elseif line:len() ~= 0 then
            local modifier = line:sub(1, 1);
            local path = line:sub(2);
            path = trim(path);
            commits[index][#commits[index] + 1] = { mod = modifier, path = path };
        end
    end

    return commits;
end

-- ------------------------------------------------
-- Return Module
-- ------------------------------------------------

return FileHandler;

--==================================================================================================
-- Created 01.10.14 - 12:34                                                                        =
--==================================================================================================