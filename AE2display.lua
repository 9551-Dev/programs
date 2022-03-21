-----------CONFIG-------------
local cfg = {
    update_time = 0,
    log_frequency = 1
}
------------------------------
 
if not fs.exists("log.lua") then
    shell.run("wget https://github.com/9551-Dev/apis/raw/main/log.lua")
end
local history = {}
if fs.exists("ae.history") then
    local file = fs.open("ae.history","r")
    local data = file.readAll()
    file.close()
    history = textutils.unserialise(data)
end
local wrap = peripheral.find("appliedenergistics2:interface")
if not wrap then error("failed ot find AE2 interface",0) end 
local function convert_to_name(list)
    local out = {}
    for k,v in pairs(list) do
        out[v.name.." dmg:"..tostring(v.damage or 0)] = v
    end
    return out
end
local old_list = convert_to_name(wrap.listAvailableItems())
local api = require("log")
local mons = {peripheral.find("monitor")}
local logs = {}
for k,v in pairs(mons) do
    v.clear()
    v.setTextScale(0.5)
    v.setCursorPos(1,1)
    v.setBackgroundColor(colors.orange)
    local _log = api.create_log(v,"item logger","\127")
    _log.history = history
    table.insert(logs,_log)
    v.setBackgroundColor(colors.black)
    v.setCursorPos(1,3)
end
for k,v in pairs(history) do
    for k,_log in pairs(logs) do
        _log(":"..v.str,v.type)
        table.remove(_log.history,#log.history)
    end
end
local lt = debug.getmetatable(api.create_log(term)).__index
local function log(str,type)
    for k,v in pairs(logs) do
        v(str,type)
    end
end
local function dump(i)
    local lg = logs[math.random(1,#logs)]
    lg:dump("ae")
    local file = fs.open("ae.history","w")
    file.write(textutils.serialise(lg.history))
    file.close()
end
for i=1,math.huge do
    local list = wrap.listAvailableItems()
    local list = convert_to_name(list)
    for k,v in pairs(old_list) do
        if list[k] then
            if v.count < list[k].count then log(k.." increased by: "..tostring(list[k].count-v.count),lt.update) end
            if v.count > list[k].count then log(k.." dropped by: "..tostring(v.count-list[k].count),lt.error) end
        else log("Removed "..k.." from system",lt.fatal) end
    end
    for k,v in pairs(list) do if not old_list[k] then log("Added "..k.." into system",lt.success) end end
    old_list = list
    if i%cfg.log_frequency == 0 then dump(math.ceil(i/cfg.log_frequency)) end
    sleep(cfg.update_time)
end
