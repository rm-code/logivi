local LoadLogCommand = {};

function LoadLogCommand.new(receiver)
    local self = {};

    function self:execute()
        receiver:refreshLog();
    end

    return self;
end

return LoadLogCommand;
