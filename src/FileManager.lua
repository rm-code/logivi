local FileManager = {};

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
-- Takes the extensions list and creates a list
-- which is sorted by the amount of files per extension.
-- @param extensions
--
local function createSortedList()
    for k in pairs( sortedList ) do
        sortedList[k] = nil;
    end

    for _, tbl in pairs( extensions ) do
        sortedList[#sortedList + 1] = tbl;
    end

    table.sort( sortedList, function( a, b )
        return a.amount > b.amount;
    end);
end

-- ------------------------------------------------
-- Public Functions
-- ------------------------------------------------

---
-- Adds a new file extension to the list.
-- @param ext
--
function FileManager.add( ext )
    if not extensions[ext] then
        extensions[ext] = {};
        extensions[ext].extension = ext;
        extensions[ext].amount = 0;
        extensions[ext].color = colors[ext] or {
            r = love.math.random( 0, 255 ),
            g = love.math.random( 0, 255 ),
            b = love.math.random( 0, 255 )
        };
    end
    extensions[ext].amount = extensions[ext].amount + 1;
    totalFiles = totalFiles + 1;

    createSortedList( extensions );

    return extensions[ext].color, ext;
end

---
-- Reduce the amount of counted files of the
-- same extension. If there are no more files
-- of that extension, it will remove it from
-- the list.
-- @param ext
--
function FileManager.remove( ext )
    if not extensions[ext] then
        error( 'Tried to remove the non existing file extension "' .. ext .. '".' );
    end

    extensions[ext].amount = extensions[ext].amount - 1;
    totalFiles = totalFiles - 1;
    if extensions[ext].amount == 0 then
        extensions[ext] = nil;
    end

    createSortedList( extensions );
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
function FileManager.getColor( ext )
    return extensions[ext].color;
end

function FileManager.getSortedList()
    return sortedList;
end

function FileManager.getTotalFiles()
    return totalFiles;
end

-- ------------------------------------------------
-- Setters
-- ------------------------------------------------

---
-- @param ncol
--
function FileManager.setColorTable( ncol )
    colors = ncol;
end

-- ------------------------------------------------
-- Return Module
-- ------------------------------------------------

return FileManager;
