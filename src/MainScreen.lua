local Screen = require('lib/Screen');
local FileHandler = require('src/FileHandler');

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local MainScreen = {};

-- ------------------------------------------------
-- Constructor
-- ------------------------------------------------

function MainScreen.new()
    local self = Screen.new();

    local log;
    local commits;
    local curCommit = 0;
    local files = {};

    local function writeLog()
        -- Write the git log to love's save directory.
        os.execute([[
    cd love
    git log --reverse --date=short --pretty=format:'author: %an%ndate: %ad%n' --name-only > /Users/Robert//Library/Application\ Support/LOVE/rmcode_LoGiVi/tmpLog.txt
    ]]);
    end

    local function nextCommit()
        if curCommit == #commits then
            return;
        end

        curCommit = curCommit + 1;
        for i = 1, #commits[curCommit] do
            local line = commits[curCommit][i];

            if not line:find('author') and not line:find('date') then
                files[line] = files[line] or 1;
                files[line] = files[line] + 1;
            end
        end
    end

    function self:init()
        -- Create empty file to also set up the löve save folder.
        love.filesystem.newFile('tmplog.txt', 'w'):close();

        -- Write the git log to the tmp file.
        writeLog();

        log = FileHandler.loadFile('tmplog.txt');
        commits = FileHandler.splitCommits(log);
    end

    local posX, posY;
    function self:draw()
        posX, posY = 40, 40;
        for i, v in pairs(files) do
            posX, posY = posX + 40, posY + 40;
            love.graphics.circle('fill', posX, posY, v * 5);
            love.graphics.print(i, posX + 200, posY);
        end
    end

    local timer = 0;
    function self:update(dt)
        timer = timer + dt;
        if timer > 0.5 then
            nextCommit();
            timer = 0;
        end
    end

    return self;
end

-- ------------------------------------------------
-- Return Module
-- ------------------------------------------------

return MainScreen;

--==================================================================================================
-- Created 01.10.14 - 13:18                                                                        =
--==================================================================================================