if not fs.exists("log.lua")then
shell.run("wget https://github.com/9551-Dev/apis/raw/main/log.lua")end local
e={}local t={}if not fs.exists("ae.cfg")then local
a=fs.open("ae.cfg","w")a.write(textutils.serialise({update_time=0,log_frequency=1,use_display_names=true,keep_log_history=true}))a.close()end
local o=fs.open("ae.cfg","r")local
i=textutils.unserialise(o.readAll())o.close()if fs.exists("ae.history")and
i.keep_log_history then local o=fs.open("ae.history","r")local
n=o.readAll()o.close()e=textutils.unserialise(n)end if
fs.exists("ae_name.cache")then local o=fs.open("ae_name.cache","r")local
s=o.readAll()o.close()t=textutils.unserialise(s)end local
h=peripheral.find("appliedenergistics2:interface")if not h then
error("failed ot find AE2 interface",0)end local function r(d)local l={}for u,c
in pairs(d)do l[c.name.."*"..tostring(c.damage or 0)]=c end return l end local
function m(f)local w,y=f:match("(.-)%*(.+)")return w,tonumber(y)end local
p=r(h.listAvailableItems())local v=require("log")local
b={peripheral.find("monitor")}local g={}for k,q in pairs(b)do
q.clear()q.setTextScale(0.5)q.setCursorPos(1,1)q.setBackgroundColor(colors.orange)local
j=v.create_log(q,"item logger","\127")j.history=e
table.insert(g,j)q.setBackgroundColor(colors.black)q.setCursorPos(1,3)end for
x,z in pairs(e)do for x,E in pairs(g)do
E(":"..z.str,z.type)table.remove(E.history,#E.history)end end local
T=debug.getmetatable(v.create_log(term)).__index local function A(O,I)for N,S
in pairs(g)do S(O,I)end end local function H(R)local
D=g[math.random(1,#g)]D:dump("ae")local
o=fs.open("ae.history","w")o.write(textutils.serialise(D.history))o.close()end
local function L(U,C)local M=h.findItems(U)local F={}local W for Y,P in
pairs(M)do table.insert(F,function()local V=P.getMetadata()if V.damage==C then
W=V.displayName end end)end parallel.waitForAll(unpack(F))return W end for
B=1,math.huge do local G=h.listAvailableItems()local G=r(G)for K,Q in
pairs(p)do local J=K if i.use_display_names then J=t[K]if not J then
J=L(m(K))t[K]=J local
o=fs.open("ae_name.cache","w")o.write(textutils.serialise(t))o.close()A("found unnamed item "..K.." adding into name cache....",T.warn)end
end if G[K]then if Q.count<G[K].count then
A(J.." increased by: "..tostring(G[K].count-Q.count),T.update)end if
Q.count>G[K].count then
A(J.." dropped by: "..tostring(Q.count-G[K].count),T.error)end else
A("Removed "..J.." from system",T.fatal)end end for X,Z in pairs(G)do local
et=X if i.use_display_names then et=t[X]if not et then et=L(m(X))t[X]=et local
o=fs.open("ae_name.cache","w")o.write(textutils.serialise(t))o.close()A("found unnamed item "..X.." adding into name cache....",T.warn)end
end if not p[X]then A("Added "..et.." into system",T.success)end end p=G if
B%i.log_frequency==0 then H(math.ceil(B/i.log_frequency))end
sleep(i.update_time)end
