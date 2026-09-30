local Device = {}
Device.__index = Device

function Device.new(id, port_start, port_end)
    local instance = setmetatable({}, Device)
    instance.id = id
    instance.port_start = port_start
    instance.port_end = port_end
    return instance
end

function Device:read(port)
    return 0
end

function Device:write(port, val)
end

return Device
