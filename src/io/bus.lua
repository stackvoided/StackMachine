local Bus = {}
Bus.__index = Bus

function Bus.new(limit)
    local instance = setmetatable({}, Bus)
    instance.limit = limit or 16
    instance.devices = {}
    return instance
end

function Bus:attach(device)
    if #self.devices >= self.limit then
        error("Exceeded maximum peripherals limit attached to expansion bus")
    end
    table.insert(self.devices, device)
end

function Bus:read_port(port)
    for _, dev in ipairs(self.devices) do
        if port >= dev.port_start and port <= dev.port_end then
            return dev:read(port)
        end
    end
    return 0
end

function Bus:write_port(port, val)
    for _, dev in ipairs(self.devices) do
        if port >= dev.port_start and port <= dev.port_end then
            dev:write(port, val)
            return
        end
    end
end

return Bus
