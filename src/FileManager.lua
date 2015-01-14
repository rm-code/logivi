local FileManager = {};

-- ------------------------------------------------
-- Local Variables
-- ------------------------------------------------

local extensions = {};

-- ------------------------------------------------
-- Local Functions
-- ------------------------------------------------

---
-- Splits the extension from a file.
-- @param fileName
--
local function splitExtension(fileName)
    local pos = fileName:find('%.');
    if pos then
        return fileName:sub(pos);
    else
        -- Prevents issues with files sans extension.
        return '.?';
    end
end

-- ------------------------------------------------
-- Public Functions
-- ------------------------------------------------

---
-- Draws a list of all authors working on the project.
--
function FileManager.draw()
    local count = 0;
    for ext, tbl in pairs(extensions) do
        count = count + 1;
        love.graphics.setColor(tbl.color);
        love.graphics.print(ext, love.graphics.getWidth() - 80, 100 + count * 20);
        love.graphics.print(tbl.amount, love.graphics.getWidth() - 120, 100 + count * 20);
        love.graphics.setColor(255, 255, 255);
    end
end

---
-- Adds a new file extension to the list.
-- @param fileName
--
function FileManager.add(fileName)
    local ext = splitExtension(fileName);
    if not extensions[ext] then
        extensions[ext] = {};
        extensions[ext].amount = 0;
        extensions[ext].color = { love.math.random(0, 255), love.math.random(0, 255), love.math.random(0, 255) };
    end
    extensions[ext].amount = extensions[ext].amount + 1;

    return extensions[ext].color;
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
    if extensions[ext].amount == 0 then
        extensions[ext] = nil;
    end
end

function FileManager.getColor(ext)
    return extensions[ext].color;
end

return FileManager;