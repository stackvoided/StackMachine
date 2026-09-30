local Constants = require("src.core.constants")

local Profiler = {}
Profiler.__index = Profiler

function Profiler.new(cpu)
    local instance = setmetatable({}, Profiler)
    instance.cpu = cpu
    instance.opcode_counts = {}
    instance.start_time = 0

    instance.opcode_names = {}
    for name, code in pairs(Constants.OPCODES) do
        instance.opcode_names[code] = name
    end

    return instance
end

function Profiler:start()
    self.start_time = os.clock()
    self.opcode_counts = {}
end

function Profiler:record(op)
    self.opcode_counts[op] = (self.opcode_counts[op] or 0) + 1
end

function Profiler:generate_report()
    local duration = os.clock() - self.start_time
    print("----- PROFILER EXECUTION METRICS -----")
    print(string.format("Total Duration: %.6f seconds", duration))
    print(string.format("Total Clock Cycles: %d", self.cpu.cycles))
    for op, count in pairs(self.opcode_counts) do
        local name = self.opcode_names[op] or string.format("0x%02X", op)
        print(string.format("Opcode %-8s (0x%02X): %d executions", name, op, count))
    end
    print("--------------------------------------")
end

return Profiler
