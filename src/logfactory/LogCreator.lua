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

-- ------------------------------------------------
-- Public Functions
-- ------------------------------------------------

local function getTotalCommits( path )
    local handle = io.popen( GIT_COMMAND .. path .. TOTAL_COMMITS_COMMAND );
    local totalCommits = handle:read('*a'):gsub('[%s]+', '');
    handle:close();
    return tonumber( totalCommits );
end

---
-- Creates a git log if git is available and no log has been
-- created in the target folder yet.
-- @param projectname
-- @param path
--
function LogCreator.createGitLog( projectname, path )
    love.filesystem.createDirectory(LOG_FOLDER .. projectname);

    local cmd = GIT_COMMAND .. path .. LOG_COMMAND;
    local handle = io.popen(cmd);
    love.filesystem.write(LOG_FOLDER .. projectname .. LOG_FILE, handle:read('*all'));
    handle:close();
end

function LogCreator.createInfoFile( projectname, path, force )
    if not force and love.filesystem.isFile( LOG_FOLDER .. projectname .. INFO_FILE ) then
        io.write( 'Info file for ' .. projectname .. ' already exists!\r\n' );
    else
        -- Number of commits.
        local totalCommits = getTotalCommits( path );

        local fileContent = 'return {\r\n';

        fileContent = fileContent .. '    name = "' .. projectname .. '",\r\n';
        fileContent = fileContent .. '    aliases = {},\r\n';
        fileContent = fileContent .. '    colors = {},\r\n';
        fileContent = fileContent .. '    totalCommits = ' .. totalCommits .. ',\r\n';

        fileContent = fileContent .. '}\r\n';

        love.filesystem.write( LOG_FOLDER .. projectname .. INFO_FILE, fileContent );
    end
end

function LogCreator.needsUpdate( path, totalCommits )
    return getTotalCommits( path ) ~= totalCommits;
end

-- ------------------------------------------------
-- Getters
-- ------------------------------------------------

---
-- Checks if git is available on the system.
--
function LogCreator.isGitAvailable()
    local handle = io.popen('git version');
    local result = handle:read('*a');
    handle:close();
    return result:find('git version');
end

---
-- Checks if a path points to a valid git repository.
-- @param path - The path to check.
--
function LogCreator.isGitRepository(path)
    local handle = io.popen(GIT_COMMAND .. path .. STATUS_COMMAND);
    local result = handle:read('*a');
    handle:close();
    return result ~= '';
end

return LogCreator;
