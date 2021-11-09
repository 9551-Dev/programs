local arg = ...
local self = shell.getRunningProgram()
if not arg or arg == "" then error("use: "..self.." <filename>",0) end
if not fs.exists(arg..".nimg") then error("file doesnt exist. try using filename wihnout .nimg",0) end
local chars = "0123456789abcdef"
local saveCols = {}
for i = 0, 15 do
  saveCols[2^i] = chars:sub(i + 1, i + 1)
end
local encode = function(tbl)
  local output = setmetatable({},{
      __index=function(t,k)
      local new = {}
      t[k]=new
      return new
    end
  })
  output["offset"] = tbl["offset"]
  for k,v in pairs(tbl) do
    for ko,vo in pairs(v) do
        if type(vo) == "table" then
            output[k][ko] = {}
            if vo then
                output[k][ko].t = saveCols[vo.t]
                output[k][ko].b = saveCols[vo.b]
                output[k][ko].s = vo.s 
            end
        end
     end
  end
  return setmetatable(output,getmetatable(tbl))
end
---------------------------- 
--https://github.com/cc-tweaked/CC-Tweaked/blob/544bcaa599b296aaf9affe55c68ee1810c6a38c6/src/main/resources/data/computercraft/lua/rom/apis/textutils.lua#L710
--serialising function
local e={["and"]=true,["break"]=true,["do"]=true,["else"]=true,["elseif"]=true,["end"]=true,["false"]=true,["for"]=true,["function"]=true,["if"]=true,["in"]=true,["local"]=true,["nil"]=true,["not"]=true,["or"]=true,["repeat"]=true,["return"]=true,["then"]=true,["true"]=true,["until"]=true,["while"]=true,}local
t=math.huge local a=dofile("rom/modules/main/cc/expect.lua")local
o,i=a.expect,a.field local function a(n,s,h,r)local d=type(n)if d=="table"then
if s[n]~=nil then if s[n]==false then
error("Cannot serialize table with repeated entries",0)else
error("Cannot serialize table with recursive entries",0)end end s[n]=true local
l if next(n)==nil then l="{}"else local
u,c,m,f,w,y="{\n",h.."  ","[ "," ] = "," = ",",\n"if r.compact then
u,c,m,f,w,y="{","","[","]=","=",","end l=u local p={}for v,b in ipairs(n)do
p[v]=true l=l..c..a(b,s,c,r)..y end for g,k in pairs(n)do if not p[g]then local
q if type(g)=="string"and not e[g]and string.match(g,"^[%a_][%a%d_]*$")then
q=g..w..a(k,s,c,r)..y else q=m..a(g,s,c,r)..f..a(k,s,c,r)..y end l=l..c..q end
end l=l..h.."}"end if r.allow_repetitions then s[n]=nil else s[n]=false end
return l elseif d=="string"then return string.format("%q",n)elseif
d=="number"then if n~=n then return"0/0"elseif n==t then return"1/0"elseif
n==-t then return"-1/0"else return tostring(n)end elseif d=="boolean"or
d=="nil"then return tostring(n)else error("Cannot serialize type "..d,0)end end
function serialize(j,x)local z={}o(2,x,"table","nil")if x then
i(x,"compact","boolean","nil")i(x,"allow_repetitions","boolean","nil")else
x={}end return
a(j,z,"",x)end
textutils.serialise = serialize
textutils.serialize = serialize
------------------------
local remover = function(c)
  return c:gsub(" ","")
end
local file = fs.open(arg..".nimg","r")
local data = file.readAll()
file.close()
local noTcol = data:gsub("tcol","t")
local noBcol = noTcol:gsub("bcol","b")
local noSym = noBcol:gsub("sym","s")
local toEncode = textutils.unserialise(noSym)
local encoded = encode(toEncode)
local writeFile = fs.open(arg..".nimg","w")
local ser = textutils.serialize(encoded,{compact = true})
writeFile.write(ser)
writeFile.close()
