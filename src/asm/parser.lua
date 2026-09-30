local Constants = require("src.core.constants")

local Parser = {}
Parser.__index = Parser

function Parser.new(tokens)
    local instance = setmetatable({}, Parser)
    instance.tokens = tokens
    instance.pos = 1
    return instance
end

function Parser:peek()
    return self.tokens[instance.pos] or self.tokens[#self.tokens]
end

function Parser:consume()
    local tok = self.tokens[self.pos]
    self.pos = self.pos + 1
    return tok
end

function Parser:parse(symbol_table)
    local ast = {}
    local current_address = 0

    while self.pos <= #self.tokens do
        local tok = self.tokens[self.pos]

        if tok.type == "EOF" then
            break
        elseif tok.type == "LABEL" then
            symbol_table:define(tok.value, current_address)
            self.pos = self.pos + 1
        elseif tok.type == "IDENT" then
            local mnemonic = tok.value:upper()
            local opcode = Constants.OPCODES[mnemonic]
            if not opcode then
                error(string.format("Unknown assembly mnemonic line %d: %s", tok.line, tok.value))
            end

            self.pos = self.pos + 1
            local args = {}

            if mnemonic == "PUSH" or mnemonic == "JMP" or mnemonic == "JZ" or mnemonic == "JNZ" or mnemonic == "CALL" then
                local arg_tok = self:consume()
                table.insert(args, arg_tok)
                current_address = current_address + 3
            elseif mnemonic == "IN" or mnemonic == "OUT" or mnemonic == "INT" then
                local arg_tok = self:consume()
                table.insert(args, arg_tok)
                current_address = current_address + 2
            elseif mnemonic == "MOV" then
                local r1 = self:consume()
                if self:peek().type == "COMMA" then self:consume() end
                local r2 = self:consume()
                table.insert(args, r1)
                table.insert(args, r2)
                current_address = current_address + 3
            else
                current_address = current_address + 1
            end

            table.insert(ast, { mnemonic = mnemonic, opcode = opcode, args = args, line = tok.line })
        else
            self.pos = self.pos + 1
        end
    end

    return ast
end

return Parser
