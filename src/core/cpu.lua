local Constants = require("src.core.constants")
local Registers = require("src.core.registers")
local Stack = require("src.core.stack")
local BitOps = require("src.utils.bit_ops")

local CPU = {}
CPU.__index = CPU

function CPU.new(memory, bus, config)
    local instance = setmetatable({}, CPU)
    instance.memory = memory
    instance.bus = bus
    instance.config = config
    instance.registers = Registers.new()
    instance.stack = Stack.new(memory, config.MEMORY_SIZE - 1, config.MAX_STACK_DEPTH)
    instance.ip = 0
    instance.fp = 0
    instance.halted = false
    instance.cycles = 0
    instance.call_stack = {}
    return instance
end

function CPU:fetch_u8()
    local val = self.memory:read_u8(self.ip)
    self.ip = self.ip + 1
    return val
end

function CPU:fetch_u16()
    local val = self.memory:read_u16(self.ip)
    self.ip = self.ip + 2
    return val
end

function CPU:step()
    if self.halted then return false, nil end

    local op = self:fetch_u8()
    self.cycles = self.cycles + 1

    local OP = Constants.OPCODES

    if op == OP.NOP then

    elseif op == OP.PUSH then
        local val = self:fetch_u16()
        self.stack:push(val)

    elseif op == OP.POP then
        self.stack:pop()

    elseif op == OP.ADD then
        local b = self.stack:pop()
        local a = self.stack:pop()
        local res = BitOps.to_u16(a + b)
        self.registers:set_flag(Constants.FLAGS.ZERO, res == 0)
        self.stack:push(res)

    elseif op == OP.SUB then
        local b = self.stack:pop()
        local a = self.stack:pop()
        local res = BitOps.to_u16(a - b)
        self.registers:set_flag(Constants.FLAGS.ZERO, res == 0)
        self.registers:set_flag(Constants.FLAGS.NEGATIVE, res > 32767)
        self.stack:push(res)

    elseif op == OP.MUL then
        local b = self.stack:pop()
        local a = self.stack:pop()
        local res = BitOps.to_u16(a * b)
        self.stack:push(res)

    elseif op == OP.DIV then
        local b = self.stack:pop()
        local a = self.stack:pop()
        if b == 0 then error("Arithmetic division fault by zero") end
        self.stack:push(math.floor(a / b))

    elseif op == OP.MOD then
        local b = self.stack:pop()
        local a = self.stack:pop()
        if b == 0 then error("Arithmetic modulo fault by zero") end
        self.stack:push(a % b)

    elseif op == OP.AND then
        local b = self.stack:pop()
        local a = self.stack:pop()
        self.stack:push(BitOps.band(a, b))

    elseif op == OP.OR then
        local b = self.stack:pop()
        local a = self.stack:pop()
        self.stack:push(BitOps.bor(a, b))

    elseif op == OP.XOR then
        local b = self.stack:pop()
        local a = self.stack:pop()
        self.stack:push(BitOps.bxor(a, b))

    elseif op == OP.NOT then
        local a = self.stack:pop()
        self.stack:push(BitOps.to_u16(65535 - a))

    elseif op == OP.SHL then
        local shift = self.stack:pop()
        local val = self.stack:pop()
        self.stack:push(BitOps.to_u16(BitOps.lshift(val, shift)))

    elseif op == OP.SHR then
        local shift = self.stack:pop()
        local val = self.stack:pop()
        self.stack:push(BitOps.rshift(val, shift))

    elseif op == OP.EQ then
        local b = self.stack:pop()
        local a = self.stack:pop()
        self.stack:push(a == b and 1 or 0)

    elseif op == OP.LT then
        local b = self.stack:pop()
        local a = self.stack:pop()
        self.stack:push(a < b and 1 or 0)

    elseif op == OP.GT then
        local b = self.stack:pop()
        local a = self.stack:pop()
        self.stack:push(a > b and 1 or 0)

    elseif op == OP.JMP then
        self.ip = self:fetch_u16()

    elseif op == OP.JZ then
        local target = self:fetch_u16()
        local cond = self.stack:pop()
        if cond == 0 then self.ip = target end

    elseif op == OP.JNZ then
        local target = self:fetch_u16()
        local cond = self.stack:pop()
        if cond ~= 0 then self.ip = target end

    elseif op == OP.CALL then
        local target = self:fetch_u16()
        table.insert(self.call_stack, self.ip)
        self.ip = target

    elseif op == OP.RET then
        if #self.call_stack == 0 then error("Subroutine return stack state invalid") end
        self.ip = table.remove(self.call_stack)

    elseif op == OP.LOAD then
        local addr = self.stack:pop()
        self.stack:push(self.memory:read_u16(addr))

    elseif op == OP.STORE then
        local addr = self.stack:pop()
        local val = self.stack:pop()
        self.memory:write_u16(addr, val)

    elseif op == OP.LOADB then
        local addr = self.stack:pop()
        self.stack:push(self.memory:read_u8(addr))

    elseif op == OP.STOREB then
        local addr = self.stack:pop()
        local val = self.stack:pop()
        self.memory:write_u8(addr, val)

    elseif op == OP.DUP then
        local val = self.stack:peek()
        self.stack:push(val)

    elseif op == OP.SWAP then
        local b = self.stack:pop()
        local a = self.stack:pop()
        self.stack:push(b)
        self.stack:push(a)

    elseif op == OP.OVER then
        local b = self.stack:pop()
        local a = self.stack:pop()
        self.stack:push(a)
        self.stack:push(b)
        self.stack:push(a)

    elseif op == OP.IN then
        local port = self:fetch_u8()
        local val = self.bus:read_port(port)
        self.stack:push(val)

    elseif op == OP.OUT then
        local port = self:fetch_u8()
        local val = self.stack:pop()
        self.bus:write_port(port, val)

    elseif op == OP.MOV then
        local dst_reg = self:fetch_u8()
        local src_reg = self:fetch_u8()
        self.registers:set(dst_reg, self.registers:get(src_reg))

    elseif op == OP.INT then
        local vec = self:fetch_u8()
        table.insert(self.call_stack, self.ip)
        self.ip = self.memory:read_u16(self.config.INTERRUPT_VECTOR_OFFSET + (vec * 2))

    elseif op == OP.HALT then
        self.halted = true
        return false, op

    else
        error(string.format("Fatal opcode decode error 0x%02X at 0x%04X", op, self.ip - 1))
    end

    return true, op
end

function CPU:run()
    while self:step() do end
end

return CPU
