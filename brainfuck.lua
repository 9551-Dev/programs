local function create_memory(n)
    local mem = {}
    for i=0,n do
        mem[i] = 0
    end
    return mem
end

local function precise_sleep(t)
    local ftime = os.epoch("utc")+t*1000
    while os.epoch("utc") < ftime do
        os.queueEvent("waiting")
        os.pullEvent()
    end
end

local function interpret(program,memory,interpret_speed)
    if memory and memory < 1 then memory = 1 end
    local memory = create_memory(memory or 30000)
    local stack = {}
    local active_loop = false
    local loops = 0
    local cursor = 0
    local bf_ops = program:gsub("[^%>%<%+%-%.%,%[%]]","")
    local i=1
    while i<=#bf_ops do
        local op = bf_ops:sub(i,i)
        local process_arg = true
        if active_loop then
            if op == "[" then loops = loops + 1 end
            if op == "]" then
                if loops == 0 then active_loop = false
                else loops = loops - 1 end
            end
            process_arg = false
        end
        if process_arg then
            if op == "+" then
                memory[cursor] = memory[cursor] + 1
            elseif op == "-" then
                memory[cursor] = memory[cursor] - 1
            elseif op == ">" then
                if memory[cursor+1] then cursor = cursor + 1 end
            elseif op == "<" then
                if memory[cursor-1] then cursor = cursor - 1 end
            elseif op == "." then
                if memory[cursor] == 0x0A then print()
                else term.write(string.char(math.max(0,math.min(255,memory[cursor])))) end
            elseif op == "," then
                local inp = read():sub(1,1):byte()
                if inp then memory[cursor] = inp end
            elseif op == "[" then
                if memory[cursor] == 0 then active_loop = true
                else table.insert(stack,i) end
            elseif op == "]" then
                if memory[cursor] > 0 then i = stack[#stack]
                else table.remove(stack,#stack)
                end
            end
        end
        if not interpret_speed or interpret_speed < 0.00001 then
            os.queueEvent("wait")
            os.pullEvent()
        else precise_sleep(interpret_speed) end
        i = i + 1
    end
    return memory
end

local function main(...)
    local args = {...}
    local path = shell.resolve(args[1] or "")
    if fs.exists(path) and path:match("%.bf$") then
        local file = fs.open(path,"r")
        local data = file.readAll()
        file.close()
        interpret(data,tonumber(args[3] or ""),tonumber(args[2] or ""))
    else
        error("Path doesnt exist or doesnt have the .bf extension: "..path,0)
    end
end

main(...)
