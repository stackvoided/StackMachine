local StringBuffer = {}
StringBuffer.__index = StringBuffer

function StringBuffer.new()
    return setmetatable({ chunks = {} }, StringBuffer)
end

function StringBuffer:append(str)
    table.insert(self.chunks, tostring(str))
end

function StringBuffer:append_byte(b)
    table.insert(self.chunks, string.char(b % 256))
end

function StringBuffer:build(sep)
    return table.concat(self.chunks, sep or "")
end

function StringBuffer:clear()
    self.chunks = {}
end

return StringBuffer
