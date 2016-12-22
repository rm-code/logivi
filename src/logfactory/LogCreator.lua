local LogCreator = {};

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local GIT_COMMAND = 'git -C "'
local LOG_COMMAND = '" log --reverse --numstat --pretty=format:"info: %an|%ae|%ct" --name-status --no-merges';
local STATUS_COMMAND = '" status';
local TOTAL_COMMITS_COMMAND = '" rev-list HEAD --count';
local LOG_FOLDER = 'logs/';
local LOG_FILE = '/log.txt';
local INFO_FILE = '/info.lua';
local COUNT_FILE = '/.commits';
local VERSION_COMMAND = 'git version';

-- ------------------------------------------------
-- Local Functions
-- ------------------------------------------------

---
-- Returns the total amount of commits in the specified repository.
-- @param path (string) The path pointing to a repository.
-- @Returns    (number) The total amount of commits in the repository.
--
local function getTotalCommits( path )
    local handle = io.popen( GIT_COMMAND .. path .. TOTAL_COMMITS_COMMAND );
    local totalCommits = handle:read( '*a' ):gsub( '[%s]+', '' );
    handle:close();
    return tonumber( totalCommits );
end

-- ------------------------------------------------
-- Public Functions
-- ------------------------------------------------

---
-- Creates a git log if git is available and no log has been
-- created in the target folder yet.
-- @param projectname (string) The name under which to store the git log.
-- @param path        (string) The path pointing to the repository.
--
function LogCreator.createGitLog( projectname, path )
    love.filesystem.createDirectory( LOG_FOLDER .. projectname );
    local handle = io.popen( GIT_COMMAND .. path .. LOG_COMMAND );
    love.filesystem.write( LOG_FOLDER .. projectname .. LOG_FILE, handle:read( '*all' ));
    handle:close();
end

---
-- Creates an info file for a certain project / repository. This file keeps
-- track of things like the total amount of commits in the repository, custom
-- author names, custom colors, etc.
-- @param projectname (string)  The name under which to store the info file.
-- @param path        (string)  The path pointing to the repository.
-- @param force       (boolean) Wether to force the creation of a new file.
--
function LogCreator.createInfoFile( projectname, path, force )
    if not force and love.filesystem.isFile( LOG_FOLDER .. projectname .. INFO_FILE ) then
        io.write( 'Info file for ' .. projectname .. ' already exists!\r\n' );
    else
        local fileContent = 'return {\r\n';

        fileContent = fileContent .. '    name = "' .. projectname .. '",\r\n';
        fileContent = fileContent .. '    aliases = {},\r\n';
        fileContent = fileContent .. '    colors = {},\r\n';

        fileContent = fileContent .. '}\r\n';

        love.filesystem.write( LOG_FOLDER .. projectname .. INFO_FILE, fileContent );

        fileContent = 'return {\r\n';
        fileContent = string.format( '%s    totalCommits = %s%s', fileContent, getTotalCommits( path ), '\r\n' );
        fileContent = fileContent .. '}\r\n';

        love.filesystem.write( LOG_FOLDER .. projectname .. COUNT_FILE, fileContent );
    end
end

---
-- Checks wether a repository needs to be updated. This is the case if the
-- total amount of commits has changed since the last time LoGiVi was started.
-- TODO: Fix https://github.com/rm-code/logivi/issues/68
-- @param path         (string)  A path pointing to a repository.
-- @param totalCommits (number)  The total amount of commits to check for.
-- @return             (boolean) Returns true if the total amount of commits has changed.
--
function LogCreator.needsUpdate( path, totalCommits )
    return getTotalCommits( path ) ~= totalCommits;
end

-- ------------------------------------------------
-- Getters
-- ------------------------------------------------

---
-- Checks if git is available on the system.
-- @return (boolean) Returns true if git was found on the user's system.
--
function LogCreator.isGitAvailable()
    local handle = io.popen( VERSION_COMMAND );
    local result = handle:read( '*a' );
    handle:close();
    return result:find( VERSION_COMMAND );
end

---
-- Checks if a path points to a valid git repository.
-- @param path (string)  The path to check.
-- @return     (boolean) Returns true if the the path points to a git repository.
--
function LogCreator.isGitRepository( path )
    local handle = io.popen( GIT_COMMAND .. path .. STATUS_COMMAND );
    local result = handle:read( '*a' );
    handle:close();
    return result ~= '';
end

return LogCreator;
