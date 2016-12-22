local Messenger = require('src.messenger.Messenger');

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local LogReader = {};

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local EVENT = require('src.messenger.Event');
local MOD_ADD = 'A';
local MOD_DELETE = 'D';
local MOD_MODIFY = 'M';

local PLAYBACK_NORMAL = 'normal';
local PLAYBACK_FAST   = 'fast';

local PLAYMODE_NORMAL = 'default';
local PLAYMODE_REWIND = 'rewind';

-- ------------------------------------------------
-- Local Variables
-- ------------------------------------------------

local log;
local index;
local commitTimer;
local commitDelay;
local play;
local rewind;

-- ------------------------------------------------
-- Local Functions
-- ------------------------------------------------

---
-- This function will take a git modifier and return the direct opposite of it.
-- This means the add modifier will be reversed to delete, whereas the delete
-- modifier will be reversed to add.
-- @param modifier (string) The git modifier to reverse.
-- @return         (string) The reversed git modifier.
--
local function reverseGitStatus( modifier )
    if modifier == MOD_ADD then
        return MOD_DELETE;
    elseif modifier == MOD_DELETE then
        return MOD_ADD;
    end
    return modifier;
end

---
-- Loads the new commit and publishes the necessary events.
--
local function applyNextCommit()
    -- Stop if we reach the end of the log.
    if index == #log then
        return;
    end
    index = index + 1;

    -- Notify listeners of the new commit.
    Messenger.publish( EVENT.NEW_COMMIT, log[index].email, log[index].author );

    -- Notify listeners of file changes made in the new commit.
    for i = 1, #log[index] do
        local change = log[index][i];
        Messenger.publish( EVENT.LOGREADER_CHANGED_FILE, change.modifier, change.path, change.file, change.extension, PLAYBACK_NORMAL );
    end
end

---
-- Reverses the current commit. This basically means we read a commit and reverse
-- all the modifications made by it. Added files will be removed for example.
--
local function reverseCurCommit()
    -- Stop if we reach the beginning of the log.
    if index == 0 then
        return;
    end

    -- Notify listeners of the new commit.
    Messenger.publish( EVENT.NEW_COMMIT, log[index].email, log[index].author );

    -- Notify listeners of file changes made in the new commit.
    for i = 1, #log[index] do
        local change = log[index][i];
        Messenger.publish( EVENT.LOGREADER_CHANGED_FILE, reverseGitStatus( change.modifier ), change.path, change.file, change.extension, PLAYBACK_NORMAL );
    end

    index = index - 1;
end

---
-- Fast forwards the graph from the current position to the target position. We
-- ignore author assigments and modifications and only are interested in
-- additions and deletions.
-- @param to (number) The index of the commit to go to.
--
local function fastForward( to )
    -- We start at index + 1 because the current index has already
    -- been loaded (or it was 0 and therefore nonrelevant anyway).
    for i = index + 1, to do
        index = i; -- Update the index.
        local commit = log[index];
        for j = 1, #commit do
            local change = commit[j];
            -- Ignore modifications, we just need to know about additions and deletions.
            if change.modifier ~= MOD_MODIFY then
                Messenger.publish( EVENT.LOGREADER_CHANGED_FILE, change.modifier, change.path, change.file, change.extension, PLAYBACK_FAST );
            end
        end
    end
end

---
-- Quickly rewinds the graph from the current position to the target position.
-- We ignore author assigments and modifications and only are interested in
-- additions and deletions.
-- @param to (number) The index of the commit to go to.
--
local function fastBackward( to )
    -- We start at the current index, because it has already been loaded
    -- and we have to reverse it too.
    for i = index, to, -1 do
        index = i;

        -- When we have reached the target commit, we update the index, but
        -- don't reverse the changes it made.
        if index == to then
            break
        end

        local commit = log[index];
        for j = #commit, 1, -1 do
            local change = commit[j];
            -- Ignore modifications we just need to know about additions and deletions.
            if change.modifier ~= MOD_MODIFY then
                Messenger.publish( EVENT.LOGREADER_CHANGED_FILE, reverseGitStatus( change.modifier ), change.path, change.file, change.extension, PLAYBACK_FAST );
            end
        end
    end
end

-- ------------------------------------------------
-- Public Functions
-- ------------------------------------------------

---
-- Loads the file and stores it line for line in a lua table.
-- @param gitlog   (table)   A sequence containing each commit of the git log.
-- @param delay    (number)  The amount of time to wait before loading the next commit.
-- @param playmode (string)  The playmode (default or rewind).
-- @param autoplay (boolean) Wether to directly start playing the visualisation.
--
function LogReader.init( gitlog, delay, playmode, autoplay )
    log = gitlog;

    -- Set default values.
    index = 0;
    if playmode == PLAYMODE_NORMAL then
        rewind = false;
    elseif playmode == PLAYMODE_REWIND then
        fastForward( #log ); -- Jump to the end of the log.
        rewind = true;
    else
        error( "Unsupported playmode '" .. playmode .. "' - please use either 'default' or 'rewind'" );
    end
    commitTimer = 0;
    commitDelay = delay;
    play = autoplay;
end

---
-- Updates the LogReader.
-- @param dt (number) Time since the last update in seconds.
--
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

---
-- Toggle the playback.
--
function LogReader.toggleSimulation()
    play = not play;
end

---
-- Reverses the playback direction.
--
function LogReader.toggleRewind()
    rewind = not rewind;
end

---
-- Advances the log by a single step.
--
function LogReader.loadNextCommit()
    play = false;
    applyNextCommit();
end

---
-- Moves the log back a single step.
--
function LogReader.loadPrevCommit()
    play = false;
    reverseCurCommit();
end

---
-- Sets the reader to a new commit index. If the index is the same as the current
-- one, the input is ignored. If the target commit is smaller (aka older) as the
-- current one we fast-rewind the graph to that position. If the target commit is
-- bigger than the current one, we fast-forward instead.
-- @param ni (number) The new index to jump to.
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

---
-- Returns the total amount of commits in the git log.
-- @return (number) The total amount of commits.
--
function LogReader.getTotalCommits()
    return #log;
end

---
-- Returns the current index in the log.
-- @return (number) The current index.
function LogReader.getCurrentIndex()
    return index;
end

---
-- Returns the date of the current commit.
-- @return (string) The current date or an empty string.
--
function LogReader.getCurrentDate()
    return index ~= 0 and log[index].date or '';
end

-- ------------------------------------------------
-- Return Module
-- ------------------------------------------------

return LogReader;
