local files = fs.list("./mods")
local proccesList = {}

print("getting invalid mods...")
sleep(1)
--gets all the mods with impropper name
for k,v in pairs(files) do
    if not v:match("_%d+%.%d+%.%d+") then
        proccesList[k] = v
        print("invalid version setting at "..v)
    else
        print("mod version fine at "..v)
    end
    sleep(0.05)
end

print()
print("getting versions of invalid mods...")
sleep(1)
local versionsList = {}
--json stage gets all the versions of the inpropper mods
for k,v in pairs(proccesList) do
    local dataPath = "./mods/"..v.."/info.json"
    local file = fs.open(dataPath,"r") 
    if file then
        local json = textutils.unserialiseJSON(file.readAll())
        file.close()
        versionsList[dataPath] = dataPath:gsub("/info.json","").. "_"..json.version
        print("got version of "..dataPath)
    else 
        print("coulnt get version of "..dataPath)
    end
    sleep(0.05)
end

print()
print("patching mods files...")
sleep(1)
--this stage applies all the final changes to the files
for k,v in pairs(versionsList) do
    local oldPath = k:gsub("/info.json","")
    print("patching mod "..oldPath.." changed to "..v)
    fs.move(oldPath,v)
    sleep(0.05)
end

print("\nfinished! press any key to continue")
os.pullEvent("key")


