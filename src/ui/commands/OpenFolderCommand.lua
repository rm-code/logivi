local OpenFolderCommand = {};

function OpenFolderCommand.new()
    local self = {};

    function self:execute()
        love.system.openURL('file://' .. love.filesystem.getSaveDirectory());
    end

    return self;
end

return OpenFolderCommand;
