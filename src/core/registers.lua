local BitOps = require("src.utils.bit_ops")

local Registers = {}
Registers.__index = Registers

function Registers.new()
    local instance = setmetatable({}, Registers)
    instance.gpr = {0, 0, 0, 0, 0, 0, 0, 0}
    instance.flags = 0
    return instance
end

function Registers:get(idx)
    if idx < 0 or idx > 7 then
        error("Invalid GPR selector index: " .. tostring(idx))
    end
    return self.gpr[idx + 1]
end

function Registers:set(idx, val)
    if idx < 0 or idx > 7 then
        error("Invalid GPR selector index: " .. tostring(idx))
    end
    self.gpr[idx + 1] = BitOps.to_u16(val)
end

function Registers:set_flag(flag_mask, condition)
    if condition then
        self.flags = BitOps.bor(self.flags, flag_mask)
    else
        self.flags = BitOps.band(self.flags, 0xFFFF - flag_mask)
    end
end

function Registers:get_flag(flag_mask)
    return BitOps.band(self.flags, flag_mask) ~= 0
end

function Registers:reset()
    for i = 1, 8 do
        self.gpr[i] = 0
    end
    self.flags = 0
end

return Registers
