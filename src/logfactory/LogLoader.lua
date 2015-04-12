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

local LogLoader = {};

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local LOG_FOLDER = 'logs';
local LOG_FILE = 'log.txt';

local TAG_AUTHOR = 'author: ';
local TAG_DATE = 'date: ';
local ROOT_FOLDER = 'root';

local WARNING_TITLE = 'No git log found.';
local WARNING_MESSAGE = [[
To use LoGiVi you will have to generate a git log first.

You can view the wiki (online) for more information on how to generate a proper log.

LoGiVi now will open the file directory in which to place the log.
]];

-- ------------------------------------------------
-- Local variables
-- ------------------------------------------------

local list;
local activeLog;

-- ------------------------------------------------
-- Local Functions
-- ------------------------------------------------

---
-- Remove the specified tag from the line.
-- @param line
-- @param tag
--
local function removeTag(line, tag)
    return line:gsub(tag, '');
end

---
-- @param author
--
local function splitLine(line, delimiter)
    local pos = line:find(delimiter);
    if pos then
        return line:sub(1, pos - 1), line:sub(pos + 1);
    else
        return line;
    end
end

---
-- Creates a list of all folders found in the LOG_FOLDER directory, which
-- contain a LOG_FILE. Returns a sequence which contains the names of the folders
-- and the path to the log files in those folders.
-- @param dir
--
local function fetchProjectFolders(dir)
    local folders = {};

    for _, name in ipairs(love.filesystem.getDirectoryItems(dir)) do
        local subdir = dir .. '/' .. name;
        if love.filesystem.isDirectory(subdir) and love.filesystem.isFile(subdir .. '/' .. LOG_FILE) then
            folders[#folders + 1] = { name = name, path = subdir .. '/' .. LOG_FILE };
        end
    end

    return folders;
end

---
-- Reads the whole log file and stores each line in a sequence.
-- @param path
--
local function parseLog(path)
    local file = {};
    for line in love.filesystem.lines(path) do
        if line ~= '' then
            file[#file + 1] = line;
        end
    end
    return file;
end

---
-- Splits the log table into commits. Each commit is a new nested table.
-- @param log
--
local function splitCommits(log)
    local commits = {};
    local index = 0;
    for i = 1, #log do
        local line = log[i];

        if line:find(TAG_AUTHOR) then
            index = index + 1;
            commits[index] = {};
            commits[index].author, commits[index].email = splitLine(removeTag(line, TAG_AUTHOR), '|');
        elseif line:find(TAG_DATE) then
            -- Transform unix timestamp to a table containing a human-readable date.
            local timestamp = removeTag(line, TAG_DATE);
            local date = os.date('*t', tonumber(timestamp));
            commits[index].date = string.format("%02d:%02d:%02d - %02d-%02d-%04d",
                date.hour, date.min, date.sec,
                date.day, date.month, date.year);
        elseif commits[index] then
            -- Split the whole change line into modifier, file name and file path fields.
            local path = line:gsub("^(%a)%s*", ''); -- Remove modifier and whitespace.
            local file = path:match("/?([^/]+)$"); -- Get the the filename at the end.
            path = path:gsub("/?([^/]+)$", ''); -- Remove the filename from the path.
            if path ~= '' then
                path = '/' .. path;
            end
            commits[index][#commits[index] + 1] = { modifier = line:sub(1, 1), path = ROOT_FOLDER .. path, file = file };
        end
    end

    return commits;
end

---
-- Returns the index of a stored log if it can be found.
-- @param name
--
local function searchLog(name)
    for i, log in ipairs(list) do
        if log.name == name then
            return i;
        end
    end
end

-- ------------------------------------------------
-- Public Functions
-- ------------------------------------------------

---
-- Try to load a certain log stored in the list.
--
function LogLoader.loadActiveLog()
    local index = searchLog(activeLog);
    local rawLog = parseLog(list[index].path);
    return splitCommits(rawLog);
end

---
-- Initialises the LogLoader. It will fetch a list of all folders
-- containing a log file. If the list is empty it will display a
-- warning to the user.
--
function LogLoader.init()
    list = fetchProjectFolders(LOG_FOLDER);

    for i, log in ipairs(list) do
        print(i, log.name, log.path);
    end

    if #list == 0 then
        local buttons = { "Yes", "No", "Show Help (Online)", enterbutton = 1, escapebutton = 2 };

        local pressedbutton = love.window.showMessageBox(WARNING_TITLE, WARNING_MESSAGE, buttons, 'warning', false);
        if pressedbutton == 1 then
            love.system.openURL('file://' .. love.filesystem.getSaveDirectory());
        elseif pressedbutton == 3 then
            love.system.openURL('https://github.com/rm-code/logivi/wiki#instructions');
        end
        return {};
    end
    return list;
end

---
-- Selects a log to be loaded later on.
-- @param name
--
function LogLoader.setActiveLog(name)
    activeLog = name;
end

return LogLoader;