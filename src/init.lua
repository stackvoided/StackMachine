local Config = require("src.config")
local Memory = require("src.core.memory")
local Bus = require("src.io.bus")
local CPU = require("src.core.cpu")
local Lexer = require("src.asm.lexer")
local SymbolTable = require("src.asm.symbol_table")
local Parser = require("src.asm.parser")
local CodeGen = require("src.asm.codegen")
local Profiler = require("src.toolchain.profiler")
local Debugger = require("src.toolchain.debugger")

local System = {}
System.__index = System

function System.new()
    local instance = setmetatable({}, System)
    instance.config = Config
    instance.memory = Memory.new(Config.MEMORY_SIZE)
    instance.bus = Bus.new(Config.BUS_DEVICES_LIMIT)
    instance.cpu = CPU.new(instance.memory, instance.bus, Config)
    instance.profiler = Profiler.new(instance.cpu)
    instance.debugger = Debugger.new(instance.cpu)
    return instance
end

function System:compile(source)
    local lexer = Lexer.new(source)
    local tokens = lexer:tokenize()
    local symbols = SymbolTable.new()
    local parser = Parser.new(tokens)
    local ast = parser:parse(symbols)
    local codegen = CodeGen.new(ast, symbols)
    return codegen:emit()
end

function System:load_and_run(source)
    local bytecode = self:compile(source)
    self.memory:reset()
    self.memory:bulk_write(0, bytecode)
    self.cpu.ip = 0
    self.cpu.halted = false

    self.profiler:start()
    while true do
        local running, executed_op = self.cpu:step()
        if executed_op then
            self.profiler:record(executed_op)
        end
        if not running then break end
    end
    self.profiler:generate_report()
end

return System
