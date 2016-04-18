local Messenger = {};

local subscriptions = {};
local index = 0;

function Messenger.publish( message, ... )
    for _, subscription in pairs( subscriptions ) do
        if subscription.message == message then
            subscription.callback( ... );
        end
    end
end

function Messenger.observe( message, callback )
    index = index + 1;
    subscriptions[index] = { message = message, callback = callback };
    return index;
end

function Messenger.remove( nindex )
    subscriptions[nindex] = nil;
end

return Messenger;
