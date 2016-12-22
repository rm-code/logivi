local GitHandler = {};

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local GIT_VERSION_COMMAND = 'git version';
local GIT_STATUS_COMMAND  = 'git -C "%s" status';
local GIT_LOG_COMMAND     = 'git -C "%s" log --reverse --numstat --pretty=format:"info: %%an|%%ae|%%ct" --name-status --no-merges';
local GIT_COUNT_COMMAND   = 'git -C "%s" rev-list HEAD --count';

local LOG_FOLDER = 'logs/';
local LOG_FILE = '/.log';

-- ------------------------------------------------
-- Public Functions
-- ------------------------------------------------

---
-- Creates a git log if git is available and no log has been
-- created in the target folder yet.
-- @param projectname (string) The name under which to store the git log.
-- @param path        (string) The path pointing to the repository.
--
function GitHandler.createGitLog( projectname, path )
    love.filesystem.createDirectory( LOG_FOLDER .. projectname );
    local handle = io.popen( string.format( GIT_LOG_COMMAND, path ));
    love.filesystem.write( LOG_FOLDER .. projectname .. LOG_FILE, handle:read( '*all' ));
    handle:close();
end

---
-- Checks if git is available on the system.
-- @return (boolean) Returns true if git was found on the user's system.
--
function GitHandler.isGitAvailable()
    local handle = io.popen( GIT_VERSION_COMMAND );
    local result = handle:read( '*a' );
    handle:close();
    return result:find( GIT_VERSION_COMMAND );
end

---
-- Checks if a path points to a valid git repository.
-- @param path (string)  The path to check.
-- @return     (boolean) Returns true if the the path points to a git repository.
--
function GitHandler.isGitRepository( path )
    local handle = io.popen( string.format( GIT_STATUS_COMMAND, path ));
    local result = handle:read( '*a' );
    handle:close();
    return result ~= '';
end

---
-- Checks wether a repository needs to be updated. This is the case if the
-- total amount of commits has changed since the last time LoGiVi was started.
-- @param path         (string)  A path pointing to a repository.
-- @param totalCommits (number)  The total amount of commits to check for.
-- @return             (boolean) Returns true if the total amount of commits has changed.
--
function GitHandler.isRepositoryUpToDate( path, totalCommits )
    return GitHandler.getTotalCommits( path ) == tonumber( totalCommits );
end

---
-- Returns the total amount of commits in the specified repository.
-- @param path (string) The path pointing to a repository.
-- @Returns    (number) The total amount of commits in the repository.
--
function GitHandler.getTotalCommits( path )
    local handle = io.popen( string.format( GIT_COUNT_COMMAND, path ));
    local totalCommits = handle:read( '*a' ):gsub( '[%s]+', '' );
    handle:close();
    return tonumber( totalCommits );
end

return GitHandler;
