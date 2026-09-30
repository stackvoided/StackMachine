local Debugger = {}
Debugger.__index = Debugger

function Debugger.new(cpu)
    local instance = setmetatable({}, Debugger)
    instance.cpu = cpu
    instance.breakpoints = {}
    return instance
end

function Debugger:set_breakpoint(addr)
    self.breakpoints[addr] = true
end

function Debugger:remove_breakpoint(addr)
    self.breakpoints[addr] = nil
end

function Debugger:inspect_state()
    print("== STATE INSPECTION ==")
    print(string.format("IP: 0x%04X | Cycles: %d", self.cpu.ip, self.cpu.cycles))
    for i = 0, 7 do
        io.write(string.format("R%d: 0x%04X  ", i, self.cpu.registers:get(i)))
    end
    print("\n======================")
end

return Debugger
