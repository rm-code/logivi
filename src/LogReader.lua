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
-- Checks if there is a log file LoGiVi can work with. If the file
-- can't be found it will display a warning message and open the save
-- folder.
-- @param name
--
local function isLogFile(name)
    if not love.filesystem.isFile(name) then
        local msg = [[
To use LoGiVi you will have to generate a git log first. See the readme for instructions on how to generate a proper log.

LoGiVi now will open the file directory in which to place the log.
]];
        love.window.showMessageBox('No git log found.', msg, 'warning', false);
        love.system.openURL('file://' .. love.filesystem.getSaveDirectory());
        return false;
    end
    return true;
end

---
-- Loads the file and stores it line for line in a lua table.
-- @param name
--
function LogReader.loadLog(name)
    if not isLogFile(name) then
        return {};
    end

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
