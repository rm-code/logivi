local LogLoader = {};

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local LOG_FOLDER = 'logs';
local LOG_FILE = 'log.txt';
local INFO_FILE = 'info.lua';

local TAG_INFO = 'info: ';

-- ------------------------------------------------
-- Local variables
-- ------------------------------------------------

local list;

-- ------------------------------------------------
-- Local Functions
-- ------------------------------------------------

---
-- Removes the specified tag from the line.
-- @param line (string) The line to edit.
-- @param tag  (string) The tag to remove.
-- @return     (string) The edited line with the tag removed.
--
local function removeTag( line, tag )
    return line:gsub( tag, '' );
end

---
-- Splits the line at the specified delimiter.
-- @param line      (string) The line to edit.
-- @param delimiter (string) The delimiter which marks the the position at which
--                            to split the line.
-- @return          (table)  A sequence containing the split parts of the line.
--
local function splitLine( line, delimiter )
    local tmp = {}
    for part in line:gmatch( '[^' .. delimiter .. ']+' ) do
        tmp[#tmp + 1] = part;
    end
    return tmp;
end

---
-- Creates a list of all folders found in the LOG_FOLDER directory, which
-- contain a LOG_FILE.
-- @param dir (string) The path to the directory which contains the log files.
-- @return    (table)  The table containing the name and the path to each log file.
--
local function fetchProjectFolders( dir )
    local folders = {};
    for _, name in ipairs( love.filesystem.getDirectoryItems( dir )) do
        local subdir = dir .. '/' .. name;
        if love.filesystem.isDirectory( subdir ) and love.filesystem.isFile( subdir .. '/' .. LOG_FILE ) then
            folders[#folders + 1] = { name = name, path = subdir .. '/' .. LOG_FILE };
        end
    end
    return folders;
end

---
-- Reads a git log file and stores each line in a sequence.
-- @param path (string) The path pointing to a log file.
-- @return     (table)  A sequence containing each line of the git log.
--
local function parseLog( path )
    local file = {};
    for line in love.filesystem.lines( path ) do
        if line ~= '' then
            file[#file + 1] = line;
        end
    end
    return file;
end

---
-- Turns a unix timestamp into a human-readable date string.
-- @param timestamp (string) The unix timestamp read from the git log.
-- @return          (string) The newly created human-readable date string.
--
local function createDateFromUnixTimestamp( timestamp )
    local date = os.date( '*t', tonumber( timestamp ));
    return string.format( "%02d:%02d:%02d - %02d-%02d-%04d", date.hour, date.min, date.sec, date.day, date.month, date.year );
end

---
-- Splits a commit line into modifier, path, file and extension. This basically
-- extracts the essential information about which changes have been performed
-- on a certain file in a commit.
-- @param line (string) The line to split.
-- @return     (table)  A table containing the split parts.
--
local function buildCommitLine( line )
    local modifier  = line:sub( 1, 1 );
    local path      = line:gsub( '^(%a)%s*', '' );
    local file      = path:match( '/?([^/]+)$' );
    local extension = file:match( '(%.[^.]+)$' ) or '.?';

    path = path:gsub( '/?([^/]+)$', '' ); -- Remove the filename from the path.
    path = path ~= '' and '/' .. path or path;

    return { modifier = modifier, path = path, file = file, extension = extension };
end

---
-- Splits the log table into commits. Each commit is stored a new nested table.
-- The has part of the table contains the author, the author's email adress and
-- the date at which the changes have been commited. The array part of the table
-- contains the changes which have been made in the commit. This contains the
-- info about which modifier has been applied to a certain file in the
-- repository.
-- @param log (table) A sequence containing each line of the git log.
-- @return    (table) A sequence containing each commit of the git log.
--
local function splitCommits( log )
    local commits = {};
    local commitIndex = 0;
    for i = 1, #log do
        local line = log[i];

        if line:find( TAG_INFO ) then -- Look for the start of a new commit.
            local commit = {};

            local info = splitLine( removeTag( line, TAG_INFO ), '|' );
            commit.author = info[1];
            commit.email  = info[2];
            commit.date   = createDateFromUnixTimestamp( info[3] );

            commitIndex = commitIndex + 1;
            commits[commitIndex] = commit;
        elseif commits[commitIndex] then
            commits[commitIndex][#commits[commitIndex] + 1] = buildCommitLine( line );
        end
    end
    return commits;
end

---
-- Returns the index of a stored log if it can be found.
-- @param name (string) The name of the log to search.
-- @return     (number) The index at which the log was found.
--
local function searchLog( name )
    for i, log in ipairs( list ) do
        if log.name == name then
            return i;
        end
    end
end

-- ------------------------------------------------
-- Public Functions
-- ------------------------------------------------

---
-- Try to load a certain log stored in the list and create a table which can
-- be processed by LoGiVi.
-- @param log (string) The name of the log to load.
-- @return    (table)  A sequence containing each commit of the git log.
--
function LogLoader.load( log )
    local index = searchLog( log );
    local rawLog = parseLog( list[index].path );
    return splitCommits( rawLog );
end

---
-- Loads information about a git repository.
-- @param name (string) The name of the git log to load the info file for.
-- @return     (table)  A table containing information about the git log.
--
function LogLoader.loadInfo( name )
    if love.filesystem.isFile( LOG_FOLDER .. '/' .. name .. '/' .. INFO_FILE ) then
        local successful, info = pcall( love.filesystem.load, LOG_FOLDER .. '/' .. name .. '/' .. INFO_FILE );
        if successful then
            return info();
        end
    end
    return {
        name = name,
        totalCommits = 0,
        aliases = {},
        colors = {},
    };
end

---
-- Initialises the LogLoader. It will fetch a list of all folders containing a
-- log file.
-- @return (table) A sequence containing the names and paths of all stored git logs.
--
function LogLoader.init()
    list = fetchProjectFolders( LOG_FOLDER );
    return list;
end

return LogLoader;
