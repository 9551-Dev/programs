-----------CONFIG-------------
local e = {
    update_time = 0,
    log_frequency = 1
}
------------------------------
if not fs.exists("log.lua")then
shell.run("wget https://github.com/9551-Dev/apis/raw/main/log.lua")end local
t=peripheral.find("appliedenergistics2:interface")if not t then
error("failed ot find AE2 interface",0)end local function a(o)local i={}for n,s
in pairs(o)do i[s.name]=s end return i end local
h=a(t.listAvailableItems())local r=require("log")local
d={peripheral.find("monitor")}local l={}for u,c in pairs(d)do
c.clear()c.setTextScale(0.5)c.setCursorPos(1,1)c.setBackgroundColor(colors.red)table.insert(l,r.create_log(c,"item logger","\127"))c.setBackgroundColor(colors.black)end
local m=debug.getmetatable(r.create_log(term)).__index local function f(w,y)for
p,v in pairs(l)do v(w,y)end end local function b(g)local
k=l[math.random(1,#l)]k:dump("AE_latest")end for q=1,math.huge do local
j=t.listAvailableItems()local j=a(j)for x,z in pairs(h)do if j[x]then if
z.count<j[x].count then
f(x.." increased by: "..tostring(j[x].count-z.count),m.update)end if
z.count>j[x].count then
f(x.." dropped by: "..tostring(z.count-j[x].count),m.error)end else
f("Removed "..x.." from system",m.fatal)end end for E,T in pairs(j)do if not
h[E]then f("Added "..E.." into system",m.success)end end h=j if
q%e.log_frequency==0 then b(math.ceil(q/e.log_frequency))end
sleep(e.update_time)end
