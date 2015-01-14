-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local TAG_SEPARATOR = 'logivi_commit';
local TAG_AUTHOR = 'author: ';
local TAG_DATE = 'date';

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local LogReader = {};

---
-- Remove leading and trailing whitespace.
-- @param str
--
local function trim(str)
    return str:match("^%s*(.-)%s*$");
end

---
-- Remove the specified tag from the line.
-- @param line
-- @param tag
--
local function removeTag(line, tag)
    return line:gsub(tag, '');
end

---
-- Split up the log table into commits. Each commit is a new
-- nested table.
-- @param log
--
local function splitCommits(log)
    local commits = {};
    local index = 0;
    for i = 1, #log do
        local line = log[i];

        if line:find(TAG_SEPARATOR) then -- Commit separator.
            index = index + 1;
            commits[index] = {};
        elseif line:find(TAG_AUTHOR) then
            commits[index].author = removeTag(line, TAG_AUTHOR);
        elseif line:find(TAG_DATE) then
            commits[index].date = line;
        elseif line:len() ~= 0 then
            -- Split the file information into the modifier, which determines
            -- what has happened to the file since the last commit and the actual
            -- filepath / name.
            local modifier = line:sub(1, 1);
            local path = line:sub(2);
            path = trim(path);
            commits[index][#commits[index] + 1] = { modifier = modifier, path = path };
        end
    end

    return commits;
end

---
-- Loads the file and stores it line for line in a lua table.
-- @param name
--
function LogReader.loadLog(name)
    local log = {};
    for line in love.filesystem.lines(name) do
        log[#log + 1] = line;
    end
    return splitCommits(log);
end

-- ------------------------------------------------
-- Return Module
-- ------------------------------------------------

return LogReader;

--==================================================================================================
-- Created 01.10.14 - 12:34                                                                        =
--==================================================================================================