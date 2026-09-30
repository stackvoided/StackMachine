package.path = package.path .. ";./?.lua"

local System = require("src.init")

local function read_source(path)
    local file, err = io.open(path, "r")
    if not file then
        error("Source file read failure: " .. tostring(err))
    end
    local data = file:read("*a")
    file:close()
    return data
end

local function main()
    local target = arg[1] or "examples/math_demo.asm"
    local sys = System.new()
    local code = read_source(target)
    sys:load_and_run(code)
end

main()
