local Stack = {}
Stack.__index = Stack

function Stack.new(memory, base_addr, max_depth)
    local instance = setmetatable({}, Stack)
    instance.mem = memory
    instance.base = base_addr
    instance.sp = base_addr
    instance.limit = base_addr - (max_depth * 2)
    return instance
end

function Stack:push(val)
    if self.sp <= self.limit then
        error("Execution stack overflow exception triggered")
    end
    self.sp = self.sp - 2
    self.mem:write_u16(self.sp, val)
end

function Stack:pop()
    if self.sp >= self.base then
        error("Execution stack underflow exception triggered")
    end
    local val = self.mem:read_u16(self.sp)
    self.sp = self.sp + 2
    return val
end

function Stack:peek()
    if self.sp >= self.base then
        error("Stack peek fault on empty stack frame")
    end
    return self.mem:read_u16(self.sp)
end

function Stack:clear()
    self.sp = self.base
end

return Stack
