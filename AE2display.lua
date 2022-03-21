if not fs.exists("log.lua") then
    shell.run("wget https://github.com/9551-Dev/apis/raw/main/log.lua")
end
local history = {}
local cache = {}
if not fs.exists("ae.cfg") then
    local file = fs.open("ae.cfg","w")
    file.write(textutils.serialise({
        update_time=0,
        log_frequency=1,
        use_display_names=true,
        keep_log_history=true
    }))
    file.close()
end

local file = fs.open("ae.cfg","r")
local cfg = textutils.unserialise(file.readAll())
file.close()

if fs.exists("ae.history") and cfg.keep_log_history then
    local file = fs.open("ae.history","r")
    local data = file.readAll()
    file.close()
    history = textutils.unserialise(data)
end
if fs.exists("ae_name.cache") then
    local file = fs.open("ae_name.cache","r")
    local data = file.readAll()
    file.close()
    cache = textutils.unserialise(data)
end
local wrap = peripheral.find("appliedenergistics2:interface")
if not wrap then error("failed ot find AE2 interface",0) end 
local function convert_to_name(list)
    local out = {}
    for k,v in pairs(list) do
        out[v.name.."*"..tostring(v.damage or 0)] = v
    end
    return out
end
local function separate_name_damage(str)
    local sout,n = str:match("(.-)%*(.+)")
    return sout,tonumber(n)
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
local function remove_time(str)
    return str:gsub("^%[%d-%:%d-% %a-]","")
end
local function remove_n(str)
    return str:gsub("%(%d-%)$","")
end
for k,v in pairs(history) do
    for k,_log in pairs(logs) do
        _log(":"..remove_time(remove_n(v.str)),v.type)
        table.remove(_log.history,#_log.history)
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
local function get_item_display_name(name,damage)
    local name_matches = wrap.findItems(name)
    local threads = {}
    local damage_match
    for k,v in pairs(name_matches) do
        table.insert(threads,function()
            local meta = v.getMetadata()
            if meta.damage == damage then
                damage_match = meta.displayName
            end
        end)
    end
    parallel.waitForAll(unpack(threads))
    return damage_match
end
for i=1,math.huge do
    local list = wrap.listAvailableItems()
    local list = convert_to_name(list)
    for k,v in pairs(old_list) do
        local name = k
        if cfg.use_display_names then
            name = cache[k]
            if not name then
                name = get_item_display_name(separate_name_damage(k))
                cache[k] = name
                local file = fs.open("ae_name.cache","w")
                file.write(textutils.serialise(cache))
                file.close()
                log("found unnamed item "..k.." adding into name cache....",lt.warn)
            end
        end
        if list[k] then
            if v.count < list[k].count then log(name.." increased by: "..tostring(list[k].count-v.count),lt.update) end
            if v.count > list[k].count then log(name.." dropped by: "..tostring(v.count-list[k].count),lt.error) end
        else
            log("Removed "..name.." from system",lt.fatal)
        end
    end
    for k,v in pairs(list) do
        local name = k
        if cfg.use_display_names then
            name = cache[k]
            if not name then
                name = get_item_display_name(separate_name_damage(k))
                cache[k] = name
                local file = fs.open("ae_name.cache","w")
                file.write(textutils.serialise(cache))
                file.close()
                log("found unnamed item "..k.." adding into name cache....",lt.warn)
            end
        end
        if not old_list[k] then log("Added "..name.." into system",lt.success) end
    end
    old_list = list
    if i%cfg.log_frequency == 0 then dump(math.ceil(i/cfg.log_frequency)) end
    sleep(cfg.update_time)
end
