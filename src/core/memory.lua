local BitOps = require("src.utils.bit_ops")

local Memory = {}
Memory.__index = Memory

function Memory.new(capacity)
    local instance = setmetatable({}, Memory)
    instance.capacity = capacity
    instance.storage = {}
    for i = 0, capacity - 1 do
        instance.storage[i] = 0
    end
    return instance
end

function Memory:assert_address(addr)
    if type(addr) ~= "number" or addr < 0 or addr >= self.capacity then
        error(string.format("Out of bounds memory index: 0x%04X", tostring(addr)))
    end
end

function Memory:read_u8(addr)
    self:assert_address(addr)
    return self.storage[addr]
end

function Memory:write_u8(addr, val)
    self:assert_address(addr)
    self.storage[addr] = BitOps.to_u8(val)
end

function Memory:read_u16(addr)
    local hi = self:read_u8(addr)
    local lo = self:read_u8(addr + 1)
    return hi * 256 + lo
end

function Memory:write_u16(addr, val)
    val = BitOps.to_u16(val)
    self:write_u8(addr, math.floor(val / 256))
    self:write_u8(addr + 1, val % 256)
end

function Memory:bulk_write(start_addr, table_data)
    for i = 1, #table_data do
        self:write_u8(start_addr + i - 1, table_data[i])
    end
end

function Memory:reset()
    for i = 0, self.capacity - 1 do
        self.storage[i] = 0
    end
end

return Memory
