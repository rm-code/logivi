local Screen = require('lib/Screen');
local FileHandler = require('src/FileHandler');
local FileObject = require('src/FileObject');

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
    local curDate = '';
    local ww, wh = love.window.getDimensions();

    local function writeLog()
        -- Write the git log to love's save directory.
        os.execute([[
            cd /Users/Robert//Library/Application\ Support/LOVE/rmcode_LoGiVi/
            git log --reverse --date=iso --pretty=format:'author: %an%ndate: %ad%n' --name-only > /Users/Robert//Library/Application\ Support/LOVE/rmcode_LoGiVi/tmpLog.txt
        ]]);
    end

    local spawnX = 20;
    local spawnY = 40;
    local function nextCommit()
        if curCommit == #commits then
            return;
        end

        curCommit = curCommit + 1;
        for i = 1, #commits[curCommit] do
            local line = commits[curCommit][i];

            if line:find('date') then
                curDate = line;
            end
            if not line:find('author') and not line:find('date') and not files[line] then
                spawnY = spawnY + 15;
                if spawnY > wh - 30 then
                    spawnY = 55;
                    spawnX = spawnX + 400;
                end
                files[line] = FileObject.new(line, spawnX, spawnY);
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

    function self:draw()
        love.graphics.print(curDate, 20, 20);
        for _, file in pairs(files) do
            file:draw()
        end
    end

    local timer = 0;
    function self:update(dt)
        timer = timer + dt;
        if timer > 0.5 then
            nextCommit();
            timer = 0;
        end

        for _, file in pairs(files) do
            file:update(dt)
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