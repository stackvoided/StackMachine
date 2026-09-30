local Lexer = {}
Lexer.__index = Lexer

function Lexer.new(source)
    local instance = setmetatable({}, Lexer)
    instance.source = source
    instance.pos = 1
    instance.line = 1
    return instance
end

function Lexer:next_token()
    while self.pos <= #self.source do
        local char = self.source:sub(self.pos, self.pos)

        if char == "\n" then
            self.line = self.line + 1
            self.pos = self.pos + 1
        elseif char:match("%s") then
            self.pos = self.pos + 1
        elseif char == ";" then
            while self.pos <= #self.source and self.source:sub(self.pos, self.pos) ~= "\n" do
                self.pos = self.pos + 1
            end
        elseif char:match("[%a_]") then
            local start = self.pos
            while self.pos <= #self.source and self.source:sub(self.pos, self.pos):match("[%w_]") do
                self.pos = self.pos + 1
            end
            local val = self.source:sub(start, self.pos - 1)
            if self.source:sub(self.pos, self.pos) == ":" then
                self.pos = self.pos + 1
                return { type = "LABEL", value = val, line = self.line }
            end
            return { type = "IDENT", value = val, line = self.line }
        elseif char:match("[%d]") then
            local start = self.pos
            while self.pos <= #self.source and self.source:sub(self.pos, self.pos):match("[%d%xX]") do
                self.pos = self.pos + 1
            end
            local raw = self.source:sub(start, self.pos - 1)
            local num = tonumber(raw)
            return { type = "NUMBER", value = num, line = self.line }
        elseif char == "," then
            self.pos = self.pos + 1
            return { type = "COMMA", value = ",", line = self.line }
        else
            error(string.format("Lexical syntax fault at line %d: '%s'", self.line, char))
        end
    end
    return { type = "EOF", value = nil, line = self.line }
end

function Lexer:tokenize()
    local tokens = {}
    while true do
        local tok = self:next_token()
        table.insert(tokens, tok)
        if tok.type == "EOF" then break end
    end
    return tokens
end

return Lexer
