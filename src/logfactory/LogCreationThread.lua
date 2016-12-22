require( 'love.system' );
require( 'love.timer'  );

local LogCreator = require( 'src.logfactory.LogCreator' );
local LogLoader  = require( 'src.logfactory.LogLoader'  );

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
    if LogCreator.isGitRepository( path ) then
        local count = LogLoader.loadCountFile( name );
        if LogCreator.needsUpdate( path, tonumber( count.totalCommits )) then
            print( "Writing log for " .. name );
            LogCreator.createGitLog( name, path );
            LogCreator.createInfoFile( name, path );
        end
        local channel = love.thread.getChannel( 'info' );
        channel:push( name );
    else
        local channel = love.thread.getChannel( 'error' );
        channel:push( { msg = 'no_repository', name = name, data = path } );
    end
end

local endTime = love.timer.getTime();
print( string.format( 'Loaded git logs in %.3f seconds!', endTime - startTime ));
