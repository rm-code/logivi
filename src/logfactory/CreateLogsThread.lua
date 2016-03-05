require("love.system");
require("love.timer");

local LogCreator = require('src.logfactory.LogCreator');

local repositories = unpack( { ... } );

local startTime = love.timer.getTime();

-- Exit early if git isn't available.
if not LogCreator.isGitAvailable() then
    local channel = love.thread.getChannel( 'error' );
    channel:push( { msg = 'git_not_found' } );
    return;
end

for name, path in pairs( repositories ) do
    -- Check if the path points to a valid git repository before attempting
    -- to create a git log and the info file for it.
    if LogCreator.isGitRepository(path) then
        LogCreator.createGitLog(name, path);
        LogCreator.createInfoFile( name );
        local channel = love.thread.getChannel( 'info' );
        channel:push( name );
    else
        local channel = love.thread.getChannel( 'error' );
        channel:push( { msg = 'no_repository', data = path } );
    end
end

local endTime = love.timer.getTime();
print( string.format("Loaded git logs in %.3f seconds!", endTime - startTime ));
