local function create_memory()
    local proxy = {}
    local mem = setmetatable({},{
        __index=function(self,key)
            if not rawget(proxy,key) then
                rawset(proxy,key,0)
                return 0
            else
                return rawget(proxy,key)
            end
        end,
        __newindex=function(self,key,value)
            if value > 255 then value = 0 end
            if value < 0 then value = 255 end
            rawset(proxy,key,value)
            rawset(self,key,nil)
        end
    })
    return mem
end

local function precise_sleep(t)
    local ftime = os.epoch("utc")+t*1000
    while os.epoch("utc") < ftime do
        os.queueEvent("waiting")
        os.pullEvent()
    end
end

local function interpret(program,interpret_speed)
    local memory = create_memory()
    local stack = {}
    local active_loop = false
    local loops = 0
    local cursor = 0
    local bf_ops = program:gsub("[^%!%>%<%+%-%.%,%[%]]","")
    local i=1
    local pted = false
    local ign_newline = false
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
                if (memory[cursor] == 0x0A) and (not ign_newline) then print()
                else
                    term.write(string.char(math.max(0,math.min(255,memory[cursor]))))
                    if ign_newline and memory[cursor] == 0x0A then ign_newline = false end
                end
                pted = true
            elseif op == "," then
                local inp = select(2,os.pullEvent("char")):sub(1,1) or ""
                term.write(inp)
                local byte = inp:byte()
                if byte then memory[cursor] = byte end
            elseif op == "[" then
                if memory[cursor] == 0 then active_loop = true
                else table.insert(stack,i) end
            elseif op == "]" then
                if memory[cursor] > 0 then i = stack[#stack]
                else table.remove(stack,#stack)
                end
            elseif op == "!" then
                ign_newline = true
            end
        end
        if not interpret_speed or interpret_speed < 0.00001 then
            os.queueEvent("wait")
            os.pullEvent()
        else precise_sleep(interpret_speed) end
        i = i + 1
    end
    return memory,pted
end

local function main(...)
    local args = {...}
    local path = shell.resolve(args[1] or "")
    if not args[1] or args[1] == "" then
        local history = {}
        local program = ""
        term.setTextColor(colors.yellow)
        print("Enter 'run' when you are finished with your program or 'exit' to exit.")
        term.setTextColor(colors.white)
        while true do
            term.blit("> ","E0","FF")
            local inp = read(nil,history)
            table.insert(history,inp)
            if inp == "run" then break
            elseif inp == "exit" then return
            else program = program .. inp end
        end
        local mem,pted = interpret(program,tonumber(args[2] or ""))
        if pted then print() end
    elseif args[1] == "-i" then
        local program = args[2] or ""
        local mem,pted = interpret(program,tonumber(args[3] or ""))
        if pted then print() end
    elseif args[1] == "-sh" then
        local history = {}
        term.setTextColor(colors.yellow)
        print("Brainfuck prompt.")
        print("Run 'exit' to exit.")
        term.setTextColor(colors.white)
        while true do
            term.blit("BF> ","00E0","FFFF")
            local inp = read(nil,history)
            table.insert(history,inp)
            if inp == "exit" then break end
            local mem,pted = interpret(inp,tonumber(args[2] or ""))
            if pted then print() end
        end
    else
        if fs.exists(path) and path:match("%.bf$") then
            local file = fs.open(path,"r")
            local data = file.readAll()
            file.close()
            interpret(data,tonumber(args[2] or ""))
        else
            error("Path doesnt exist or doesnt have the .bf extension: "..path,0)
        end
    end
end

main(...)
