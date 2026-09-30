local SymbolTable = {}
SymbolTable.__index = SymbolTable

function SymbolTable.new()
    local instance = setmetatable({}, SymbolTable)
    instance.symbols = {}
    return instance
end

function SymbolTable:define(name, address)
    if self.symbols[name] then
        error("Duplicate symbol definition error: " .. tostring(name))
    end
    self.symbols[name] = address
end

function SymbolTable:resolve(name)
    return self.symbols[name]
end

function SymbolTable:clear()
    self.symbols = {}
end

return SymbolTable
