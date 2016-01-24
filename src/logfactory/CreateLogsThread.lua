require("love.system");
require("love.timer");
require("love.window");

local LogCreator = require('src.logfactory.LogCreator');

local BUTTON_OK = 'Ok';
local BUTTON_HELP = 'Help (online)';

local URL_INSTRUCTIONS = 'https://github.com/rm-code/logivi#generating-git-logs-automatically';

local WARNING_TITLE_NO_GIT   = 'Git is not available';
local WARNING_MESSAGE_NO_GIT = 'LoGiVi can\'t find git in your PATH. This means LoGiVi won\'t be able to create git logs automatically, but can still be used to view pre-generated logs.';

local WARNING_TITLE_NO_REPO   = 'Not a valid git repository';
local WARNING_MESSAGE_NO_REPO = 'The path "%s" does not point to a valid git repository. Make sure you have specified the full path in the settings file.';

local repositories = unpack( { ... } );

local startTime = love.timer.getTime();

-- Exit early if git isn't available.
if not LogCreator.isGitAvailable() then
    -- Show a warning to the user.
    local pressedbutton = love.window.showMessageBox(WARNING_TITLE_NO_GIT, WARNING_MESSAGE_NO_GIT, { BUTTON_OK, BUTTON_HELP, enterbutton = 1, escapebutton = 1 }, 'warning', false);
    if pressedbutton == 2 then
        love.system.openURL(URL_INSTRUCTIONS);
    end
    return;
end

for name, path in pairs( repositories ) do
    -- Check if the path points to a valid git repository before attempting
    -- to create a git log and the info file for it.
    if LogCreator.isGitRepository(path) then
        LogCreator.createGitLog(name, path);
        LogCreator.createInfoFile(name, path);
        local channel = love.thread.getChannel( 'info' );
        channel:push( name );
    else
        love.window.showMessageBox(WARNING_TITLE_NO_REPO, string.format(WARNING_MESSAGE_NO_REPO, path), 'warning', false);
    end
end

local endTime = love.timer.getTime();
print( string.format("Loaded git logs in %.3f seconds!", endTime - startTime ));
