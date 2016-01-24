local LogReader = {};

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local EVENT_NEW_COMMIT = 'NEW_COMMIT';
local EVENT_CHANGED_FILE = 'LOGREADER_CHANGED_FILE';
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
-- Notify observers about the event.
-- @param event
-- @param ...
--
local function notify( event, ... )
    for i = 1, #observers do
        observers[i]:receive( event, ... );
    end
end

---
-- This function will take a git modifier and return the direct
-- opposite of it.
-- @param modifier
--
local function reverseGitStatus( modifier )
    if modifier == MOD_ADD then
        return MOD_DELETE;
    elseif modifier == MOD_DELETE then
        return MOD_ADD;
    end
    return modifier;
end

local function applyNextCommit()
    if index == #log then
        return;
    end
    index = index + 1;

    notify( EVENT_NEW_COMMIT, log[index].email, log[index].author );

    for i = 1, #log[index] do
        local change = log[index][i];
        notify( EVENT_CHANGED_FILE, change.modifier, change.path, change.file, change.extension, 'normal' );
    end
end

local function reverseCurCommit()
    if index == 0 then
        return;
    end

    notify( EVENT_NEW_COMMIT, log[index].email, log[index].author );

    for i = 1, #log[index] do
        local change = log[index][i];
        notify( EVENT_CHANGED_FILE, reverseGitStatus(change.modifier), change.path, change.file, change.extension, 'normal' );
    end

    index = index - 1;
end

---
-- Fast forwards the graph from the current position to the
-- target position. We ignore author assigments and modifications
-- and only are interested in additions and deletions.
-- @param to -- The index of the commit to go to.
--
local function fastForward( to )
    -- We start at index + 1 because the current index has already
    -- been loaded (or it was 0 and therefore nonrelevant anyway).
    for i = index + 1, to do
        index = i; -- Update the index.
        local commit = log[index];
        for j = 1, #commit do
            local change = commit[j];
            -- Ignore modifications we just need to know about additions and deletions.
            if change.modifier ~= 'M' then
                notify( EVENT_CHANGED_FILE, change.modifier, change.path, change.file, change.extension, 'fast' );
            end
        end
    end
end

---
-- Quickly rewinds the graph from the current position to the
-- target position. We ignore author assigments and modifications
-- and only are interested in additions and deletions.
-- @param to -- The index of the commit to go to.
--
local function fastBackward( to )
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
                notify( EVENT_CHANGED_FILE, reverseGitStatus(change.modifier), change.path, change.file, change.extension, 'fast' );
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
function LogReader.init( gitlog, delay, playmode, autoplay )
    log = gitlog;

    -- Set default values.
    index = 0;
    if playmode == 'default' then
        rewind = false;
    elseif playmode == 'rewind' then
        fastForward( #log );
        rewind = true;
    else
        error( "Unsupported playmode '" .. playmode .. "' - please use either 'default' or 'rewind'" );
    end
    commitTimer = 0;
    commitDelay = delay;
    play = autoplay;

    observers = {};
end

function LogReader.update( dt )
    if not play then return end

    commitTimer = commitTimer + dt;
    if commitTimer > commitDelay then
        if rewind then
            reverseCurCommit();
        else
            applyNextCommit();
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

function LogReader.loadNextCommit()
    play = false;
    applyNextCommit();
end

function LogReader.loadPrevCommit()
    play = false;
    reverseCurCommit();
end

---
-- Sets the reader to a new commit index. If the
-- index is the same as the current one, the input is
-- ignored. If the target commit is smaller (aka older)
-- as the current one we fast-rewind the graph to that
-- position. If the target commit is bigger than the
-- current one, we fast-forward instead.
--
function LogReader.setCurrentIndex( ni )
    if log[ni] then
        if index == ni then
            return;
        elseif index < ni then
            fastForward( ni );
        elseif index > ni then
            fastBackward( ni );
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
function LogReader.register( observer )
    observers[#observers + 1] = observer;
end

-- ------------------------------------------------
-- Return Module
-- ------------------------------------------------

return LogReader;
