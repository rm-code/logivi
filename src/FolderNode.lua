-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local FolderNode = {};

-- ------------------------------------------------
-- Constructor
-- ------------------------------------------------

function FolderNode.new()
    local self = {};

    local children = {};

    function self:draw()
        for _, node in pairs(children) do
            node:draw();
        end
    end

    function self:update(dt)
        for _, node in pairs(children) do
            node:update(dt);
        end
    end

    function self:getNode(name)
        return children[name];
    end

    function self:append(name, node)
        if not children[name] then
            children[name] = node;
        end
    end

    return self;
end

-- ------------------------------------------------
-- Return Module
-- ------------------------------------------------

return FolderNode;

--==================================================================================================
-- Created 02.10.14 - 16:49                                                                        =
--==================================================================================================