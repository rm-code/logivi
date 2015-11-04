local SelectLogCommand = {};

function SelectLogCommand.new(receiver, var)
    local self = {};

    function self:execute()
        receiver:selectLog(var);
    end

    return self;
end

return SelectLogCommand;
