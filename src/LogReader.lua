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

local TAG_AUTHOR = 'author: ';
local TAG_DATE = 'date: ';
local ROOT_FOLDER = 'root';

local EVENT_NEW_COMMIT = 'NEW_COMMIT';
local EVENT_MODIFY_FILE = 'MODIFY_FILE';

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local LogReader = {};

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local WARNING_TITLE = 'No git log found.';
local WARNING_MESSAGE = [[
To use LoGiVi you will have to generate a git log first.

You can view the wiki (online) for more information on how to generate a proper log.

LoGiVi now will open the file directory in which to place the log.
]];

local MOD_ADD = 'A';
local MOD_DELETE = 'D';

-- ------------------------------------------------
-- Local Variables
-- ------------------------------------------------

local log;
local index;
local commitTimer;
local commitDelay;
local play;
local rewind;
local observers;

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
-- Notify observers about the event.
-- @param event
-- @param ...
--
local function notify(event, ...)
    for i = 1, #observers do
        observers[i]:receive(event, ...);
    end
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
            local file = path:match("/?([^/]+)$");  -- Get the the filename at the end.
            path = path:gsub("/?([^/]+)$", '');     -- Remove the filename from the path.
            if path ~= '' then
                path = '/' .. path;
            end
            commits[index][#commits[index] + 1] = { modifier = line:sub(1, 1), path = ROOT_FOLDER .. path, file = file };
        end
    end

    return commits;
end

---
-- This function will take a git modifier and return the direct
-- opposite of it.
-- @param modifier
--
local function reverseGitStatus(modifier)
    if modifier == MOD_ADD then
        return MOD_DELETE;
    elseif modifier == MOD_DELETE then
        return MOD_ADD;
    end
    return modifier;
end

---
-- Checks if there is a log file LoGiVi can work with. If the file
-- can't be found it will display a warning message and open the save
-- folder.
-- @param name
--
local function isLogFile(name)
    if not love.filesystem.isFile(name) then
        local buttons = { "Yes", "No", "Show Help (Online)", enterbutton = 1, escapebutton = 2 };

        local pressedbutton = love.window.showMessageBox(WARNING_TITLE, WARNING_MESSAGE, buttons, 'warning', false);
        if pressedbutton == 1 then
            love.system.openURL('file://' .. love.filesystem.getSaveDirectory());
        elseif pressedbutton == 3 then
            love.system.openURL('https://github.com/rm-code/logivi/wiki#instructions');
        end
        return false;
    end
    return true;
end

---
-- Reads the git log and returns it as a table.
-- @param path
--
local function readLogFile(path)
    local file = {};
    for line in love.filesystem.lines(path) do
        if line ~= '' then
            file[#file + 1] = line;
        end
    end
    return file;
end

local function applyNextCommit(graph)
    if index == #log then
        return;
    end
    index = index + 1;

    notify(EVENT_NEW_COMMIT, log[index].email, log[index].author);

    for i = 1, #log[index] do
        local change = log[index][i];

        -- Modify the graph based on the git file status we read from the log.
        local file = graph:applyGitStatus(change.modifier, change.path, change.file);

        notify(EVENT_MODIFY_FILE, file);
    end
end

local function reverseCurCommit(graph)
    if index == 0 then
        return;
    end

    notify(EVENT_NEW_COMMIT, log[index].email, log[index].author);

    for i = 1, #log[index] do
        local change = log[index][i];

        -- Modify the graph based on the git file status we read from the log.
        local file = graph:applyGitStatus(reverseGitStatus(change.modifier), change.path, change.file);

        notify(EVENT_MODIFY_FILE, file);
    end

    index = index - 1;
end

---
-- Fast forwards the graph from the current position to the
-- target position. We ignore author assigments and modifications
-- and only are interested in additions and deletions.
-- @param graph -- The graph on which to apply these changes.
-- @param to -- The index of the commit to go to.
--
local function fastForward(graph, to)
    -- We start at index + 1 because the current index has already
    -- been loaded (or it was 0 and therefore nonrelevant anyway).
    for i = index + 1, to do
        index = i; -- Update the index.
        local commit = log[index];
        for j = 1, #commit do
            local change = commit[j];
            -- Ignore modifications we just need to know about additions and deletions.
            if change.modifier ~= 'M' then
                graph:applyGitStatus(change.modifier, change.path, change.file);
            end
        end
    end
end

---
-- Quickly rewinds the graph from the current position to the
-- target position. We ignore author assigments and modifications
-- and only are interested in additions and deletions.
-- @param graph -- The graph on which to apply these changes.
-- @param to -- The index of the commit to go to.
--
local function fastBackward(graph, to)
    -- We start at the current index, because it has already been loaded
    -- and we have to reverse it too.
    for i = index, to, -1 do
        index = i;

        -- When we have reached the target commit, we update the index, but
        -- don't reverse the changes it made.
        if index == to then break end

        local commit = log[index];
        for j = #commit, 1, -1 do
            local change = commit[j];
            -- Ignore modifications we just need to know about additions and deletions.
            if change.modifier ~= 'M' then
                graph:applyGitStatus(reverseGitStatus(change.modifier), change.path, change.file);
            end
        end
    end
end

-- ------------------------------------------------
-- Public Functions
-- ------------------------------------------------

---
-- Loads the file and stores it line for line in a lua table.
-- @param logpath
--
function LogReader.init(logpath, delay, playmode, autoplay, graph)
    if not isLogFile(logpath) then
        return {};
    end

    local logFile = readLogFile(logpath);
    log = splitCommits(logFile);

    -- Set default values.
    index = 0;
    if playmode == 'default' then
        rewind = false;
    elseif playmode == 'rewind' then
        fastForward(graph, #log);
        rewind = true;
    else
        error("Unsupported playmode '" .. playmode .. "' - please use either 'default' or 'rewind'");
    end
    commitTimer = 0;
    commitDelay = delay;
    play = autoplay;

    observers = {};
end

function LogReader.update(dt, graph)
    if not play then return end

    commitTimer = commitTimer + dt;
    if commitTimer > commitDelay then
        if rewind then
            reverseCurCommit(graph);
        else
            applyNextCommit(graph);
        end
        commitTimer = 0;
    end
end

function LogReader.toggleSimulation()
    play = not play;
end

function LogReader.toggleRewind()
    rewind = not rewind;
end

function LogReader.loadNextCommit(graph)
    play = false;
    applyNextCommit(graph);
end

function LogReader.loadPrevCommit(graph)
    play = false;
    reverseCurCommit(graph);
end

---
-- Sets the reader to a new commit index. If the
-- index is the same as the current one, the input is
-- ignored. If the target commit is smaller (aka older)
-- as the current one we fast-rewind the graph to that
-- position. If the target commit is bigger than the 
-- current one, we fast-forward instead.
--
function LogReader.setCurrentIndex(graph, ni)
    if log[ni] then
        if index == ni then
            return;
        elseif index < ni then
            fastForward(graph, ni);
        elseif index > ni then
            fastBackward(graph, ni);
        end
    end
end

function LogReader.getTotalCommits()
    return #log;
end

function LogReader.getCurrentIndex()
    return index;
end

function LogReader.getCurrentDate()
    return index ~= 0 and log[index].date or '';
end

---
-- Register an observer.
-- @param observer
--
function LogReader.register(observer)
    observers[#observers + 1] = observer;
end

-- ------------------------------------------------
-- Return Module
-- ------------------------------------------------

return LogReader;
