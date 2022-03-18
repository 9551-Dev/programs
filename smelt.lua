------------------------------------------------------------------
-------------CONFIG-----------------------------------------------
local main_term_log_object = term

local chests = {
    input="?", --your smeltables input chest name
    output="?", --your output chest name
    fuel="?", --your fuel chest name
    wraps={}
}

local cycle_delay = 0 --delay betweeen fueling and filling cycles
------------------------------------------------------------------
------------------------------------------------------------------

local log
local function main(term)
    if not fs.exists("log_9") then
        shell.run("wget https://github.com/9551-Dev/apis/raw/main/log.lua log_9")
    end
    log = require("log_9").create_log(term.current())
    assert(chests.input ~= "?","please select input chest in the config",0)
    assert(chests.output ~= "?","please select output chest in the config",0)
    assert(chests.fuel ~= "?","please select fuel chest in the config",0)
    local furnaces = {peripheral.find("minecraft:furnace")}
    for k,v in pairs(furnaces) do
        log(peripheral.getName(v),log.update)
    end
    log("found "..#furnaces.." furnaces",log.success)
    log("")
    for k,v in pairs(chests) do
        if type(v) == "string" then
            local wrap = peripheral.wrap(v)
            if not wrap then
                error("invalid chest: "..k..">"..v,0)
            end
            chests.wraps[k] = wrap
        end
    end
    local function get_amount_per_furnace(list)
        local n = 0
        for k,v in pairs(list) do
            n = n + v.count
        end
        local ret = (n/#furnaces ~= math.huge) and n/#furnaces or 0
        return ret
    end
    local function process_input_part(type,furnace,size,f_am)
        local tcnt = 0
        for i=1,size do
            tcnt = tcnt + furnace.pullItems(chests[type],i,math.ceil((f_am-tcnt)+0.5),(type == "fuel") and 2 or 1)
            if tcnt >= f_am then return end
        end
    end
    local function post_process(a1,a2,a3)
        local ors = #a1
        local ors2 = #a2
        for k,v in ipairs(a2) do
            a1[k+ors] = v
        end
        for k,v in ipairs(a3) do
            a1[k+ors+ors2] = v
        end
        return unpack(a1)
    end
    while true do
        local f_cs = chests.wraps.fuel.size()
        local i_cs = chests.wraps.input.size()
        local f_am = get_amount_per_furnace(chests.wraps.fuel.list())
        local i_am = get_amount_per_furnace(chests.wraps.input.list())
        local t1,t2,t3 = {},{},{}
        for k,v in ipairs(furnaces) do
            table.insert(t1,function() process_input_part("fuel",v,f_cs,f_am) end)
            table.insert(t2,function() process_input_part("input",v,i_cs,i_am) end)
            table.insert(t3,function() v.pushItems(chests.output,3) end)
        end
        parallel.waitForAll(post_process(t1,t2,t3))
        log("Finished cycles ",log.success)
        sleep(cycle_delay)
    end
end
local function main_wrapped()
    main(main_term_log_object)
end
local function error_handle(err)

    log("an fatal error occured: "..err:match(":%d+: (.+)"),log.fatal)
    log("type Y to save log into smelt.log",log.update)
    log.term.scroll(1)
    local _,h = log.term.getSize()
    term.setCursorPos(1,h)
    local user_select = read():upper()
    if user_select:match("Y") then log:dump("smelt") end
end

xpcall(main_wrapped,error_handle)
