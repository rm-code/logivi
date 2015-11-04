local WatchCommand = {};

function WatchCommand.new(receiver)
    local self = {};

    function self:execute()
        receiver:watchLog();
    end

    return self;
end

return WatchCommand;
