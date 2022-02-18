local args = {...}
if args[1] == nil or args[2] == nil then error("usage: program <input-file> <output-file>",0) end
if not fs.exists(args[1]) then error("file "..args[1].." doesnt exist.") end 
local file = fs.open(args[1],"r")
local fout = fs.open(args[2],"w")
local lines = {}
local bitlens = {}
local count = 0
local oldSleep = sleep 
local sleep = function(amount)
    if args[3] ~= "no-debug" then
        oldSleep(amount)
    end
end
for v in file.readAll():gmatch("(.-)\n") do
    count = count + 1
    table.insert(lines,v)
    table.insert(bitlens,#v)
    print("reading bit map: "..v,count,#v)
    sleep(0.1)
end
local added = 0
for k,v in pairs(bitlens) do
    added = added + v
    print("adding bitmap lenghts: "..k/count)
    sleep(0.1)
end
local build = {}
for i=1,added/count do
    print("building line: "..tostring(i).."/"..added/count)
    for k,v in pairs(lines) do
        if not build[i] then build[i] = "" end 
        build[i] = build[i]..v:sub(i,i)
        print("building layer: "..tostring(i).." status: "..build[i])
        sleep(0.05)
    end
    print()
    sleep(0.1)
end
for k,v in pairs(build) do
    local data = tostring(tonumber(v:reverse(),2))
    if data == "nil" then data = tostring(v) or v end
    fout.write(data.."\n")
    print("writing data into file: "..v:reverse().." > " ..data)
    sleep(0.1)
end
print("\nfinished")
fout.close() 
file.close()

