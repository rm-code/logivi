local FileManager = {};

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local FRST_OFFSET = 10;
local SCND_OFFSET = 50;

-- ------------------------------------------------
-- Local Variables
-- ------------------------------------------------

local extensions = {};
local sortedList = {};
local totalFiles = 0;
local colors;

-- ------------------------------------------------
-- Local Functions
-- ------------------------------------------------

---
-- Returns the extension of a file (or '.?' if it doesn't have one).
-- @param fileName
--
local function splitExtension(fileName)
    return fileName:match("(%.[^.]+)$") or '.?';
end

---
-- Takes the extensions list and creates a list
-- which is sorted by the amount of files per extension.
-- @param extensions
--
local function createSortedList(extensions)
    for k in pairs(sortedList) do
        sortedList[k] = nil;
    end

    for ext, tbl in pairs(extensions) do
        sortedList[#sortedList + 1] = tbl;
    end

    table.sort(sortedList, function(a, b)
        return a.amount > b.amount;
    end);
end

-- ------------------------------------------------
-- Public Functions
-- ------------------------------------------------

---
-- Draws a counter of all files in the project and
-- a separate counter for each used file extension.
--
function FileManager.draw(x, y)
    love.graphics.print(totalFiles, x + FRST_OFFSET, y + 10);
    love.graphics.print('Files', x + SCND_OFFSET, y + 10);
    for i, tbl in ipairs(sortedList) do
        love.graphics.setColor(tbl.color.r, tbl.color.g, tbl.color.b);
        love.graphics.print(tbl.amount, x + FRST_OFFSET, y + 10 + i * 20);
        love.graphics.print(tbl.extension, x + SCND_OFFSET, y + 10 + i * 20);
        love.graphics.setColor(255, 255, 255);
    end
end

function FileManager.update(dt)
    return 0, 0, 0, 10 + (#sortedList + 1) * 20;
end

---
-- Adds a new file extension to the list.
-- @param fileName
--
function FileManager.add(fileName)
    local ext = splitExtension(fileName);
    if not extensions[ext] then
        extensions[ext] = {};
        extensions[ext].extension = ext;
        extensions[ext].amount = 0;
        extensions[ext].color = colors[ext] or {
            r = love.math.random(0, 255),
            g = love.math.random(0, 255),
            b = love.math.random(0, 255)
        };
    end
    extensions[ext].amount = extensions[ext].amount + 1;
    totalFiles = totalFiles + 1;

    createSortedList(extensions);

    return extensions[ext].color, ext;
end

---
-- Reduce the amount of counted files of the
-- same extension. If there are no more files
-- of that extension, it will remove it from
-- the list.
--
function FileManager.remove(fileName)
    local ext = splitExtension(fileName);
    if not extensions[ext] then
        error('Tried to remove the non existing file extension "' .. ext .. '".');
    end

    extensions[ext].amount = extensions[ext].amount - 1;
    totalFiles = totalFiles - 1;
    if extensions[ext].amount == 0 then
        extensions[ext] = nil;
    end

    createSortedList(extensions);
end

function FileManager.reset()
    extensions = {};
    sortedList = {};
    totalFiles = 0;
    colors = nil;
end

-- ------------------------------------------------
-- Getters
-- ------------------------------------------------

---
-- @param ext
--
function FileManager.getColor(ext)
    return extensions[ext].color;
end

-- ------------------------------------------------
-- Setters
-- ------------------------------------------------

---
-- @param ncol
--
function FileManager.setColorTable(ncol)
    colors = ncol;
end

-- ------------------------------------------------
-- Return Module
-- ------------------------------------------------

return FileManager;
