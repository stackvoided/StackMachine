local Constants = require("src.core.constants")

local CodeGen = {}
CodeGen.__index = CodeGen

function CodeGen.new(ast, symbol_table)
    local instance = setmetatable({}, CodeGen)
    instance.ast = ast
    instance.symbols = symbol_table
    return instance
end

function CodeGen:emit()
    local stream = {}

    for _, node in ipairs(self.ast) do
        table.insert(stream, node.opcode)

        for _, arg in ipairs(node.args) do
            if arg.type == "NUMBER" then
                local val = arg.value
                if node.opcode == Constants.OPCODES.IN or node.opcode == Constants.OPCODES.OUT or node.opcode == Constants.OPCODES.INT then
                    table.insert(stream, val % 256)
                else
                    table.insert(stream, math.floor(val / 256) % 256)
                    table.insert(stream, val % 256)
                end
            elseif arg.type == "IDENT" then
                if Constants.REGISTERS[arg.value:upper()] then
                    table.insert(stream, Constants.REGISTERS[arg.value:upper()])
                else
                    local target_addr = self.symbols:resolve(arg.value)
                    if not target_addr then
                        error(string.format("Symbol resolution failed for target: %s at line %d", arg.value, arg.line))
                    end
                    table.insert(stream, math.floor(target_addr / 256) % 256)
                    table.insert(stream, target_addr % 256)
                end
            end
        end
    end

    return stream
end

return CodeGen
