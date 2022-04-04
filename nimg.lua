--------------------NIMG EDITOR------------------------
------------------IMAGE SPLASH EDITOR------------------
--------------------by 9551 DEV------------------------
---Copyright (c) 2021-2022 9551------------9551#0001---
---using this code in your project is fine!------------
---as long as you dont claim you made it---------------
---im cool with it, feel free to include---------------
---in your projects!   discord: 9551#0001--------------
---you dont have to but giving credits is nice :)------
-------------------------------------------------------
-------------------------------------------------------
---NIMG is a program for creating and loading images---
local keybinds = {
    delete = keys.x,
}
local openCreateFile = true
local chars = "0123456789abcdef"
local saveCols, loadCols = {}, {}
for i = 0, 15 do
  saveCols[2^i] = chars:sub(i + 1, i + 1)
  loadCols[chars:sub(i + 1, i + 1)] = 2^i
end
local decode = function(tbl)
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
                output[k][ko].t = loadCols[vo.t]
                output[k][ko].b = loadCols[vo.b]
                output[k][ko].s = vo.s 
            end
		end
	 end
  end
  return setmetatable(output,getmetatable(tbl))
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
local remover = function(c)
  return c:gsub(" ","")
end
local monitorP = function(...)
    local tArgs = { ... }
    local sName = tArgs[2]
    local sProgram = tArgs[1]
    local sPath = sProgram
	if sName == "find" then
		local m = peripheral.find("monitor")
		if m then sName = peripheral.getName(m)
		else sName = "noMonitorError" end
	end
    local monitor = peripheral.wrap(sName)
    if not monitor then error("not a valid monitor!",0) end
	tArgs[5] = tonumber(tArgs[5])
	monitor.setTextScale(math.max(math.min(tArgs[5] or 0.5,4),0.5))
    local previousTerm = term.redirect(monitor)
    print(sPath)
    local co = coroutine.create(function()
        (shell.execute or shell.run)(sProgram, tArgs[3], tArgs[4])
    end)
	local printError = function(param)
		error(param,0)
	end
    local function resume(...)
        local ok, param = coroutine.resume(co, ...)
        if not ok then
            printError(param)
        end
        return param
    end
    local timers = {}
    local ok, param = pcall(function()
        local sFilter = resume()
        while coroutine.status(co) ~= "dead" do
            local tEvent = table.pack(os.pullEventRaw())
            if sFilter == nil or tEvent[1] == sFilter or tEvent[1] == "terminate" then sFilter = resume(table.unpack(tEvent, 1, tEvent.n))
            end
            if coroutine.status(co) ~= "dead" and (sFilter == nil or sFilter == "mouse_click") then
                if tEvent[1] == "monitor_touch" and tEvent[2] == sName then timers[os.startTimer(0.1)] = { tEvent[3], tEvent[4] } sFilter = resume("mouse_click", 1, table.unpack(tEvent, 3, tEvent.n))
                end
            end
            if coroutine.status(co) ~= "dead" and (sFilter == nil or sFilter == "term_resize") then
                if tEvent[1] == "monitor_resize" and tEvent[2] == sName then sFilter = resume("term_resize")
                end
            end
            if coroutine.status(co) ~= "dead" and (sFilter == nil or sFilter == "mouse_up") then
                if tEvent[1] == "timer" and timers[tEvent[2]] then sFilter = resume("mouse_up", 1, table.unpack(timers[tEvent[2]], 1, 2)) timers[tEvent[2]] = nil
                end
            end
        end
    end)
    term.redirect(previousTerm)
    if not ok then
        printError(param)
    end
end
local useAccelerated
local expect = require("cc.expect").expect
local nimg = shell.getRunningProgram()
local args = {...}
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
if arg[3] and args[1] ~= "addFrame" then
	if args[1] ~= "addFrame" then
		monitorP(nimg,args[3],args[1],args[2],args[4])
	end
else
	local arg = args[2]
    local xs, ys = term.getSize()
    local win
    local oldTerm
	local m
	if args[2] and args[1] == "edit" then
    	win = window.create(term.current(), 1, 1, xs, ys)
    	oldTerm = term.redirect(win)
	end
	if not fs.exists("ButtonH") then shell.run("pastebin get LTDZZZEJ ButtonH") end
	local b = require("ButtonH").terminal
    local pocketpc = {26,20}
    local standart = {51,19}
    local monitor = {7,5}
    local neural = {39,13}
    local turtle = neural
    local presets = {}
    if pocketpc[1] < xs-8  and pocketpc[2] < ys-3 then presets[1] = {pocket,"pocket"} end
    if standart[1] < xs-8  and standart[2] < ys-3 then presets[2] = {standart,"standart"} end
    if monitor[1] < xs-8  and monitor[2] < ys-3 then presets[3] = {monitor,"monitor"} end
    if neural[1] < xs-8  and neural[2] < ys-3 then presets[4] = {neural,"neural"} end
    if turtle[1] < xs-8  and turtle[2] < ys-3 then presets[5] = {turtle,"turtle"} end
    local pixelmap
    local drawmap
    local openmap
    local openpixelmap
    local cCol = colors.black
    local cBac = colors.white
    local cSym = " "
    local ft = ""
    local dfs = {3,7,11,4}
	local defs = {3,9,11,4}
    local block = {0,0,0,0}
    local windowOpen = ""
    local symbolTab = "basic"
    local miscTab = "settings"
    local exitMode = false
    local windowbug = 1
    local wincount = 0
    local updateSkip = 20
    local updateCur = 0
    local yy = 2
    local isSaved = true
    local charset = {}
    local alphabet = {}
    local upAlphabet = {}
    local numbers = {}
    local drawChars = {}
    local other = {}
    local symMCol = {}
    local misMCol = {}
    local autoSave = false
    local doSaveAll = false
    local asCol = colors.red
    local fileSize
    local changeBg = false
    local bg = {tc="gray",bg="black"}
    for i=1,255 do
        charset[i] = string.char(i)
    end
    for i=65,90 do
        table.insert(alphabet,(string.char(i)):lower())
        table.insert(upAlphabet,string.char(i))
    end
    for i=128, 159 do
        table.insert(drawChars,i-128,string.char(i))
    end
    for i=0,9 do
        table.insert(numbers,tostring(i))
    end
    for i=1,47 do table.insert(other,string.char(i)) end
    for i=58,64 do table.insert(other,string.char(i)) end
    for i=91,96 do table.insert(other,string.char(i)) end
    for i=123,127 do table.insert(other,string.char(i)) end
    for i=160,255 do table.insert(other,string.char(i)) end
    local mainCode = function()
        local getSize = function(tbl)
            local xindex = {}
            local yindex = {}
            for k,v in pairs(tbl) do
                if type(k) == "number" then
                    table.insert(xindex,k-tbl.offset[1]+1)
                    for k2 in pairs(v) do
                        table.insert(yindex,k2-(tbl.offset[2]))
                    end
                end
            end
            return {
                math.min(table.unpack(xindex) or 0),
                math.min(table.unpack(yindex) or 0),
                math.max(table.unpack(xindex) or 0),
                math.max(table.unpack(yindex) or 0)
            }
        end
        local count = function(tbl)
            local count = 0
            for k,v in pairs(tbl) do
                if type(k) == "number" then
                    for k,v in pairs(v) do
                        count = count + 1
                    end
                end
            end
            return count
        end
        local sTime = os.time()
        local frames = 0
        local FPS = 0
        local cTime = os.time()
        local calcFPS = function()
            local cTime = os.time()
            local tDif = (cTime-sTime)/0.02
            FPS = frames/tDif
        end
        local getColors = function()
            local cols = {}
            for k,v in pairs(colors) do
                if type(v) == "number" then
                    table.insert(cols,v)
                end
            end
            return cols
        end
        local function divideTable(tableToDivide, timesToDivide)
            local retTable = {}
            for i = 1, timesToDivide do
                retTable[i] = {}
            end
            local elementsPerTable = math.ceil(#tableToDivide/ timesToDivide)
            local curTable = 1
            for i = 1, #tableToDivide do
                table.insert(retTable[curTable], tableToDivide[i])
                if #retTable[curTable] >= elementsPerTable then
                    curTable = curTable + 1
                end
            end
            return retTable
        end
        local function length(tbl)
            local biggest = 0
            for k in pairs(tbl) do
                if type(k) == "number" then
                    biggest = math.max(biggest, k)
                end
            end
            return biggest
        end
        if args[1] ~= "edit" and args[1] ~= "create" and args[1] ~= "createImageSet" and args[1] ~= "addFrame" and args[1] ~= "view" and args[1] ~= "update" and args[1] ~= "getAPI" and not args[2] then error("use the help command: nimg help <images,image_sets>\nor use another command: nimg <update/getAPI/view file> ",0) end
        if args[2] and args[1] == "edit" then
			if pocket then error("pocket pc not supported!",0) end
            if not drawmap then
                if arg then
                    if fs.exists(arg..".nimg") then
                        local file =  fs.open(arg..".nimg","r")
                        drawmap = textutils.unserialize(file.readAll())
						if drawmap then
							drawmap = decode(drawmap)
						end
                        file.close()
                    else
                        error("not found. try using file name wihnout .nimg note that all files need to have .nimg extension to work",0)
                    end
                end
            end
            local sclick = {"tout",1,-1,-1}
            local dclick = {"tout",1,-1,-1}
            if not pixelmap then pixelmap = {} end
            if not drawmap then drawmap = {} end
            if not openmap then openmap = {} end
            if not openpixelmap then openpixelmap = {} end
            local sizeUpdate = function()
                win.reposition(1,1,term.getSize())
                xs, ys = win.getSize()
                term.setBackgroundColor(colors.black)
                term.setTextColor(colors.white)
                return xs, ys
            end
            sizeUpdate()
            local cfilter = {
                [2]=true,
                [3]=true,
                [4]=true,
                [5]=true
            }
            local c2filter = {
                [1]=true,
                [3]=true
            }
            local eventQueue = {}
            local menuClick = function()
                while true do
                    sclick = b.timetouch(1,cfilter,false)
                end
            end
            local drawClick = function()
                while true do
                    dclick = b.timetouch(.5,cfilter,true)
                end
            end
            local keyDown = function()
                while true do
                    _,keyDownEv = os.pullEvent("key")
                    if not eventQueue[keyDownEv] then
                        eventQueue[keyDownEv] = true
                    end
                end
            end
            local keyUp = function()
                while true do
                    _,keyUpEv = os.pullEvent("key_up")
                    eventQueue[keyUpEv] = false
                end
            end
            local bgswitch = function()
                while true do
                    sleep(1)
                    if changeBg  then
                        if bg.tc == "black" then
                            bg.tc = "gray"
                            bg.bg = "black"
                        else
                            bg.tc = "black"
                            bg.bg = "gray"
                        end
                    end
                end
            end
            local saving = function(bypass)
                if autoSave or bypass then
                    if doSaveAll then
                        isSaved = true
                        drawmap["offset"] = defs
                        local file = fs.open(args[2]..".nimg","w")
						local tosave = encode(drawmap)
						local ser = textutils.serialize(tosave,{compact = true})
                        file.write(ser)
                        file.close()
                    else
                        isSaved = true
                        openpixelmap["offset"] = defs
                        local file = fs.open(args[2]..".nimg","w")
						local tosave = encode(openpixelmap)
						local ser = textutils.serialize(tosave,{compact = true})
                        file.write(ser)
                        file.close()
                    end
                end
            end
            local draw = function()
                local drawBox = function(xs,ys)
                    sizeUpdate()
                    win.setVisible(false)
                    if wincount >= windowbug then
                        win.clear()
                        wincount = 0
                    end
                    wincount = wincount + 1
                    if dfs[3] < xs-12  then
                        if windowOpen == "" or dfs[3] < xs/2-20 then
                            term.setTextColor(colors.green)
                            if b.boxButton(1,dclick,dfs[1]+dfs[3]+3,dfs[2]-2,"green","black","+",2,1) then
                                dfs[3] = dfs[3] + 1
                                if not doSaveAll then
                                    saving()
                                end
                            end
                        end
                    end
                    if dfs[3] > 2 then
                        if windowOpen == "" or dfs[3] < xs/2-19 then
                            term.setTextColor(colors.red)
                            if b.boxButton(1,dclick,dfs[1]+dfs[3]+3,dfs[2]+2,"red","black","-",2,1) then
                                dfs[3] = dfs[3] - 1
                                if not doSaveAll then
                                    saving()
                                end
                            end
                        end
                    end
                    if dfs[4]+dfs[2] < ys-6 then
                        if b.boxButton(1,dclick,dfs[1]+(dfs[3]/2)-3,dfs[4]*2+5,"green","black","+",2,1) then
                            dfs[4] = dfs[4] + 0.5
                            dfs[2] = dfs[2] + 0.5
                            yy = yy + 1
                            if not doSaveAll then
                                saving()
                            end
                        end
                    end
                    if dfs[4] > 1 then
                        if b.boxButton(1,dclick,dfs[1]+(dfs[3]/2)+3,dfs[4]*2+5,"red","black","-",2,1) then
                            dfs[4] = dfs[4] - 0.5
                            dfs[2] = dfs[2] - 0.5
                            yy = yy - 1
                            if not doSaveAll then
                                saving()
                            end
                        end
                    end
                    term.setBackgroundColor(colors.black)
                    term.setTextColor(colors[bg.tc])
                    b.fill(nil,nil,nil,nil,"\127")
                    b.frame(dfs[1],dfs[2],dfs[3],dfs[4],"lightGray",bg.bg,false)
                    for x=dfs[1], dfs[1]+dfs[3]-2 do
                        for y=dfs[2]-dfs[4]+2, dfs[2]+dfs[4] do
                            if b.API(dclick,x,y-1,1,1) then
                                if not b.API(dclick,block[1],block[2],block[3],block[4]) then
                                    isSaved = false
                                    saving()
                                    if not pixelmap[x-dfs[1]+1] then pixelmap[x-dfs[1]+1] = {} end
                                    if not pixelmap[x-dfs[1]+1][y-dfs[2]+yy+1] then pixelmap[x-dfs[1]+1][y-dfs[2]+yy+1] = {} end
                                    if not drawmap[x] then drawmap[x] = {} end
                                    if not drawmap[x][y] then drawmap[x][y] = {} end
                                    if b.switch("db",1) or eventQueue[keybinds.delete] then
                                        pixelmap[x-dfs[1]+1][y-dfs[2]+yy+1] = nil
                                        drawmap[x][y] = nil
                                        dclick = {"tout",1,-1,-1}
                                    else
                                        pixelmap[x-dfs[1]+1][y-dfs[2]+yy+1] = {
                                            t = cCol,
                                            b = cBac,
                                            s = cSym
                                        }
                                        drawmap[x][y] = {}
                                        drawmap[x][y] = {
                                            t = cCol,
                                            b = cBac,
                                            s = cSym
                                        }
                                    end
                                    dclick = {"tout",1,-1,-1}
                                end
                            end
                        end
                    end
                    openmap = {}
                    openpixelmap = {}
                    for k,v in pairs(drawmap) do
                        if type(k) == "number" then
                            for k2,v2 in pairs(v) do
                                if k < dfs[1]+dfs[3]-1 and k >= dfs[1] then
                                    if k2 < dfs[2]+dfs[4]+1 and k2 > 4 then
                                        term.setCursorPos(k,k2-1)
                                        term.setBackgroundColor(v2.b)
                                        term.setTextColor(v2.t)
                                        term.write(v2.s)
                                        if not openmap[k-dfs[1]+1] then openmap[k-dfs[1]+1] = {} end
                                        if not openmap[k-dfs[1]+1][k2-dfs[2]+yy+1] then openmap[k-dfs[1]+1][k2-dfs[2]+yy+1] = {} end
                                        if not openpixelmap[k] then openpixelmap[k] = {} end
                                        if not openpixelmap[k][k2] then openpixelmap[k][k2] = {} end
                                        openmap[k-dfs[1]+1][k2-dfs[2]+yy+1] = {
                                            t = v2.t,
                                            b = v2.b,
                                            s = v2.s
                                        }
                                        openpixelmap[k][k2] = {
                                            t = v2.t,
                                            b = v2.b,
                                            s = v2.s
                                        }
                                    end
                                end
                            end
                        end
                    end
                end
                local offsetDrawmap = function(x,y)
                    local offsetmap = drawmap
                    drawmap = {}
                    for k,v in pairs(offsetmap) do
                        if type(k) == "number" then
                            for k2,v2 in pairs(v) do
                                if not drawmap[k+x] then drawmap[k+x] = {} end
                                if not drawmap[k+x][k2+y] then drawmap[k+x][k2+y] = {} end
                                drawmap[k+x][k2+y] = v2
                            end
                        end
                    end
                end
                local menu = function(xs, ys)
                    term.setCursorPos(1,1)
                    term.setBackgroundColor(colors.gray)
                    term.write((" "):rep(xs))
                    term.setCursorPos(1,2)
                    term.write((" "):rep(xs))
                    term.setBackgroundColor(colors.black)
                    if not isSaved then
                        term.setBackgroundColor(colors.red)
                        term.setTextColor(colors.white)
                    else
                        term.setBackgroundColor(colors.green)
                        term.setTextColor(colors.black)
                    end
                    if b.button(1,sclick,1,1,"SAVE") then
                        saving(true)
                    end
                    if b.boxButton(1,sclick,4,dfs[4]*2+8,"lightGray","black","\27",1) then
                        offsetDrawmap(-1,0)
						isSaved = false
                    end
                    if b.boxButton(1,sclick,7,dfs[4]*2+8,"lightGray","black","\26",1) then
                        offsetDrawmap(1,0)
						isSaved = false
                    end
                    if b.boxButton(1,sclick,11,dfs[4]*2+8,"gray","black","\25",1) then
                        offsetDrawmap(0,1)
						isSaved = false
                    end
                    if b.boxButton(1,sclick,14,dfs[4]*2+8,"gray","black","\24",1) then
                        offsetDrawmap(0,-1)
						isSaved = false
                    end
                    changeBg = b.switch(1,3,sclick,19,dfs[4]*2+8,"red","green","white","\182",2)
					useAccelerated = b.switch(1,2,sclick,xs-1,dfs[4]*2+8,"gray","yellow","white",("\187"):rep(2),1)
                    term.setTextColor(colors.white)
                    term.setBackgroundColor(colors.gray)
                    b.switch(1,1,sclick,xs-4,1,"red","green","white","\8",5,1)
                    if updateCur >= updateSkip then
                        term.setCursorPos(1,2)
                        fileSize = fs.getSize(args[2]..".nimg")/1024
                        local fsd = "fs: "..("%.1fKb"):format(fileSize)
                        term.write(fsd)
                        term.setCursorPos(6,1)
                        if doSaveAll then
                            ft = tostring(count(drawmap))
                        else
                            ft = tostring(count(openpixelmap))
                        end
                        term.write("chars:"..ft)
                        term.setCursorPos(dfs[3]+2,dfs[2]+dfs[4])
                        term.setBackgroundColor(colors.gray)
                        term.write(("x%d y%d"):format(dfs[3]-1,dfs[2]+dfs[4]-4))
                        term.setCursorPos(dfs[3]+2,dfs[2]+dfs[4]+1)
                        term.setTextColor(colors.white)
                        term.write("t col:")
                        term.setCursorPos(dfs[3]+8,dfs[2]+dfs[4]+1)
                        term.setTextColor(cCol)
                        term.setBackgroundColor(colors.lightGray)
                        term.write("\127")
                        term.setBackgroundColor(colors.gray)
                        term.setCursorPos(dfs[3]+2,dfs[2]+dfs[4]+2)
                        term.setTextColor(colors.white)
                        term.write("b col:")
                        term.setBackgroundColor(colors.lightGray)
                        term.setCursorPos(dfs[3]+8,dfs[2]+dfs[4]+2)
                        term.setTextColor(cBac)
                        term.write("\127")
                        term.setCursorPos(dfs[3]+2,dfs[2]+dfs[4]+3)
                        term.setBackgroundColor(colors.gray)
                        term.setTextColor(colors.white)
                        term.write("sym:")
                        term.setTextColor(cCol)
                        term.setBackgroundColor(cBac)
                        term.write(cSym)
                    end
                    term.setTextColor(colors.white)
                    term.setBackgroundColor(colors.gray)
                    local ft = "   "
                    local mval = #ft+xs-50
                    if xs > 51 then mval = #ft+((xs)-51)/2 end
                    if windowOpen == "backgroundColorMenu" then term.setBackgroundColor(colors.green) end
                    if b.button(1,sclick,14+mval,1,"background") then
                        windowOpen = "backgroundColorMenu"
                        symbolTab = "basic"
                        miscTab = "tools"
                    end
                    term.setBackgroundColor(colors.gray)
                    if windowOpen == "textColorMenu" then term.setBackgroundColor(colors.green) end
                    if b.button(1,sclick,25+mval,1,"text-color") then
                        windowOpen = "textColorMenu"
                        symbolTab = "basic"
                        miscTab = "tools"
                    end
                    term.setBackgroundColor(colors.gray)
                    if windowOpen == "symbolMenu" then term.setBackgroundColor(colors.green) end
                    if b.button(1,sclick,14+mval,2,"symbols") then
                        windowOpen = "symbolMenu"
                        symbolTab = "basic"
                        miscTab = "tools"
                    end
                    term.setBackgroundColor(colors.gray)
                    if windowOpen == "miscMenu" then term.setBackgroundColor(colors.green) end
                    if b.button(1,sclick,25+mval,2,"misc") then
                        windowOpen = "miscMenu"
                        symbolTab = "basic"
                        miscTab = "tools"
                    end
                    if windowOpen == "" then
                        block = {0,0,0,0}
                    end
                    if windowOpen == "backgroundColorMenu" then
                        block = {13+mval,4,20,4}
                        b.fill(nil,nil,nil,nil,"\127")
                        term.setBackgroundColor(colors.gray)
                        term.setTextColor(cBac)
                        b.frame(14+mval,5,19,2,"lightGray","gray")
                        term.setTextColor(colors.black)
                        term.setBackgroundColor(colors.red)
                        if b.button(1,sclick,31+mval,4,"\xD7") then
                            windowOpen = ""
                            dclick = {"tout",1,-1,-1}
                        end
                        for k,v in pairs(getColors()) do
                            term.setCursorPos(16+k,5)
                            term.setBackgroundColor(v)
                            if b.button(1,sclick,14+k+mval,5," ") then
                                cBac = v
                            end
                        end
                    end
                    if windowOpen == "textColorMenu" then
                        block = {13+mval,4,20,4}
                        b.fill(nil,nil,nil,nil,"\127")
                        term.setBackgroundColor(colors.gray)
                        term.setTextColor(cCol)
                        b.frame(14+mval,5,19,2,"lightGray","gray")
                        term.setTextColor(colors.black)
                        term.setBackgroundColor(colors.red)
                        if b.button(1,sclick,31+mval,4,"\xD7") then
                            windowOpen = ""
                            dclick = {"tout",1,-1,-1}
                        end
                        for k,v in pairs(getColors()) do
                            term.setCursorPos(16+k,5)
                            term.setBackgroundColor(v)
                            if b.button(1,sclick,14+k+mval,5," ") then
                                cCol = v
                            end
                        end
                    end
                    if windowOpen == "symbolMenu" then
                        block = {13+mval,4,31,14}
                        term.setTextColor(colors.black)
                        b.fill(nil,nil,nil,nil,"\127")
                        b.frame(14+mval,10,30,7,"lightGray","gray")
                        term.setBackgroundColor(colors.gray)
                        term.setTextColor(colors.black)
                        term.setCursorPos(18-#ft+mval-1,7)
                        term.write(("\131"):rep(29))
                        term.setTextColor(colors.black)
                        term.setBackgroundColor(colors.red)
                        if b.button(1,sclick,42+mval,8,"\xD7") then
                            windowOpen = ""
                            symbolTab = "basic"
							dclick = {"tout",1,-1,-1}
                        end
                        if symbolTab == "basic" then symMCol[1] = "green"
                        else symMCol[1] = "red" end
                        if symbolTab == "draw-chars" then symMCol[2] = "green"
                        else symMCol[2] = "red" end
                        if symbolTab == "other" then symMCol[3] = "green"
                        else symMCol[3] = "red" end
                        if b.boxButton(1,sclick,20-#ft+mval,5,symMCol[1],"black","basic",1.5,1) then
                            symbolTab = "basic"
                        end
                        if b.boxButton(1,sclick,30-#ft+mval-2,5,symMCol[2],"black","draw-chars",1.5,1) then
                            symbolTab = "draw-chars"
                        end
                        if b.boxButton(1,sclick,42-#ft+mval-1,5,symMCol[3],"black","other",1.5,1) then
                            symbolTab = "other"
                        end
                        term.setBackgroundColor(colors.black)
                        term.setTextColor(colors.white)
                        if symbolTab == "basic" then
                            for k,v in pairs(alphabet) do
                                if v == cSym then term.setBackgroundColor(colors.green)
                                else term.setBackgroundColor(colors.gray)
                                end
                                if b.button(1,dclick,17-#ft+mval+k,9,v) then cSym = v
                                end
                            end
                            for k,v in pairs(upAlphabet) do
                                if v == cSym then term.setBackgroundColor(colors.green)
                                else term.setBackgroundColor(colors.gray)
                                end
                                if b.button(1,dclick,17-#ft+mval+k,12,v) then
                                    cSym = v
                                end
                            end
                            for k,v in pairs(numbers) do
                                if v == cSym then term.setBackgroundColor(colors.green)
                                else term.setBackgroundColor(colors.gray)
                                end
                                if b.button(1,dclick,17-#ft+mval+k,15,v) then cSym = v
                                end
                            end
                            if cSym == " " then term.setBackgroundColor(colors.green)
                            else term.setBackgroundColor(colors.gray) end
                            if b.button(1,dclick,29-#ft+mval,15,"PIXEL") then
                                cSym = " "
                            end
                        end
                        if symbolTab == "draw-chars" then
                            local function addSym(draw,x,y)
                                for i=1,#draw do
                                    local v = draw[i]
                                    if v == cSym then term.setBackgroundColor(colors.green)
                                    else term.setBackgroundColor(colors.gray)
                                    end
                                    if b.button(1,dclick,17-#ft+mval+(i*2)+x,12+(y*2),v) then
                                        cSym = v
                                    end
                                end
                            end
                            local out = divideTable(drawChars,4)
                            addSym(out[1],5,-1.5)
                            addSym(out[2],5,-0.5)
                            addSym(out[3],5,0.5)
                            addSym(out[4],5,1.5)
                        end
                    end
                    if symbolTab == "other" then
                        local function addSym(draw,x,y)
                            for i=1,#draw do
                                local v = draw[i]
                                if v == cSym then term.setBackgroundColor(colors.green)
                                else term.setBackgroundColor(colors.gray)
                                end
                                if b.button(1,dclick,17-#ft+mval+(i)+x,12+(y),v) then
                                    cSym = v
                                end
                            end
                        end
                        local out = divideTable(other,6)
                        local count = 1
                        for k,v in pairs(out) do
                            addSym(out[count],0,count-3)
                            count = count + 1
                        end
                    end
                    if windowOpen == "miscMenu" then
                        term.setBackgroundColor(colors.gray)
                        block = {13+mval,4,30,14}
                        term.setTextColor(colors.black)
                        b.fill(nil,nil,nil,nil,"\127")
                        b.frame(14+mval,10,29,7,"lightGray","gray")
                        term.setBackgroundColor(colors.gray)
                        term.setTextColor(colors.black)
                        term.setCursorPos(18-#ft+mval-1,7)
                        term.write(("\131"):rep(28))
                        term.setTextColor(colors.black)
                        term.setBackgroundColor(colors.red)
                        if b.button(1,sclick,41+mval,8,"\xD7") then
                            windowOpen = ""
							dclick = {"tout",1,-1,-1}
                        end
                        term.setBackgroundColor(colors.lightGray)
                        term.setTextColor(colors.white)
                        if b.button(1,sclick,14+mval,8,"UPDATE") then
                            saving(true)
                            term.setBackgroundColor(colors.gray)
                            term.setTextColor(colors.white)
                            term.clear()
                            term.setCursorPos(xs/2-6/2,ys/2)
                            term.write("UPDATING")
                            win.setVisible(true)
                            fs.delete(nimg)
                            local web = http.get("https://pastebin.com/raw/2nbDhRXC")
                            local webdata = web.readAll()
                            local file = fs.open(nimg,"w")
                            file.write(webdata)
                            web.close()
                            file.close()
                            win.setVisible(false)
                            error("updated",0)
                        end
                        if miscTab == "FILE" then misMCol[1] = "green"
                        else misMCol[1] = "red" end
                        if miscTab == "tools" then misMCol[2] = "green"
                        else misMCol[2] = "red" end
                        if b.boxButton(1,sclick,20-#ft+mval,5,misMCol[1],"black","  FILE    ",2,1) then
                            miscTab = "FILE"
                        end
                        if b.boxButton(1,sclick,36-#ft+mval-2,5,misMCol[2],"black"," tools    ",2,1) then
                            miscTab = "tools"
                        end
                        if miscTab == "FILE" then
                            if autoSave then term.setBackgroundColor(colors.green)
                            else term.setBackgroundColor(colors.red) end
                            if b.button(1,sclick,31-#ft+mval-5,9,"auto-save") then
                                autoSave = not autoSave
                                saving()
                            end
                            if doSaveAll then term.setBackgroundColor(colors.green)
                            else term.setBackgroundColor(colors.red) end
                            if b.button(1,sclick,28-#ft+mval-5,11,"save all (mode)") then
                                doSaveAll = not doSaveAll
                            end
                            term.setTextColor(colors.white)
                            term.setBackgroundColor(colors.gray)
                            term.setCursorPos(28-#ft+mval-5,13)
                            term.write("filesize: "..("%.1fKb"):format(fileSize))
                            term.setCursorPos(29-#ft+mval-5,15)
                            if doSaveAll then
                                term.write("characters: "..tostring(count(drawmap)))
                            else
                                term.write("characters: "..tostring(count(openpixelmap)))
                            end
                        end
                        if miscTab == "tools" then
                            term.setTextColor(colors.white)
                            term.setBackgroundColor(colors.gray)
                            if b.button(1,sclick,33-#ft+mval-5,9,"clear") then
                                pixelmap = {}
                                drawmap = {}
                                openpixelmap = {}
                                openmap = {}
                                isSaved = false
                            end
                            if b.button(1,sclick,29-#ft+mval-5,13,"fill all open") then
                                for x=dfs[1], dfs[1]+dfs[3]-2 do
                                    for y=dfs[2]-dfs[4]+2, dfs[2]+dfs[4] do
                                        if not drawmap[x] then drawmap[x] = {} end
                                        if not drawmap[x][y] then drawmap[x][y] = {} end
                                        drawmap[x][y] = {
                                            t = cCol,
                                            b = cBac,
                                            s = cSym
                                        }
                                    end
                                end
                                isSaved = false
                            end
                            if b.button(1,sclick,28-#ft+mval-5,15,"fill background") then
                                local mergemap = {}
                                for x=dfs[1], dfs[1]+dfs[3]-2 do
                                    for y=dfs[2]-dfs[4]+2, dfs[2]+dfs[4] do
                                        if not mergemap[x] then mergemap[x] = {} end
                                        if not mergemap[x][y] then mergemap[x][y] = {} end
                                        mergemap[x][y] = {
                                            t = cCol,
                                            b = cBac,
                                            s = cSym
                                        }
                                    end
                                end
                                for k,v in pairs(mergemap) do
                                    if type(k) ~= "string" then
                                        for k2,v2 in pairs(v) do
                                            if not drawmap[k] then drawmap[k] = {} end
                                            if not drawmap[k][k2] then drawmap[k][k2] = {}  end
                                            if not next(drawmap[k][k2]) then
                                                drawmap[k][k2] = {
                                                    t = cCol,
                                                    b = cBac,
                                                    s = cSym
                                                }
                                            end
                                        end
                                    end
                                end
                                isSaved = false
                            end
                            if b.button(1,sclick,31-#ft+mval-5,11,"load file") then
                                term.clear()
                                term.setCursorPos(xs/2-19/2,ys/2)
                                term.write("what file to load ?")
                                term.setCursorPos(xs/2-18/2,ys/2+1)
                                win.setVisible(true)
                                local input = read()
                                win.setVisible(false)
                                local loadmap
                                if fs.exists(input..".nimg") then
                                    local file =  fs.open(input..".nimg","r")
                                    loadmap = textutils.unserialize(file.readAll())
									loadmap = decode(loadmap)
                                    file.close()
                                else
                                    error("Terminated",0)
                                end
                                for k,v in pairs(loadmap) do
                                    for k2,v2 in pairs(v) do
                                        if not drawmap[k] then drawmap[k] = {} end
                                        if not drawmap[k][k2] then drawmap[k][k2] = {} end
                                        drawmap[k][k2] = v2
                                    end
                                end
                                isSaved = false
                            end
                        end
                    end
                    --
                    term.setBackgroundColor(colors.red)
                    term.setTextColor(colors.white)
                    if b.button(1,sclick,xs-3,4,"EXIT") then
                        if isSaved == true then
                            error("nimg closed",0)
                        else
                            windowOpen = ""
                            exitMode = true
                        end
                    end
                    if exitMode then
                        block = {1,1,xs,ys}
                        miscTab = ""
                        windowOpen = "FILE"
                        symbolTab = "basic"
                        term.setBackgroundColor(colors.gray)
                        b.frame(14+mval,5,27,2,"lightGray","gray")
                        term.setTextColor(colors.red)
                        term.setCursorPos(14+mval,4)
                        term.write("you have unsaved progress.")
                        term.setCursorPos(14+mval,5)
                        term.write("do you want to continue ?")
                        term.setTextColor(colors.black)
                        term.setBackgroundColor(colors.green)
                        if b.button(1,sclick,20+mval,6,"YES") then
                            error("nimg closed",0)
                        end
                        term.setBackgroundColor(colors.red)
                        if b.button(1,sclick,29+mval,6,"NO!") then
                            exitMode = false
                            block = {0,0,0,0}
                            windowOpen = ""
                        end
                    end
                    updateCur = updateCur + 1
                    calcFPS()
                    win.setVisible(true)
                    sclick = {"tout",1,-1,-1}
                    frames = frames + 1
                    if useAccelerated then
                        os.queueEvent("fake")
                        os.pullEvent("fake")
					else
						sleep()
					end
                end
                while true do
                    local xs, ys = sizeUpdate()
                    drawBox(xs, ys)
                    menu(xs, ys)
                end
            end
            parallel.waitForAll(bgswitch,menuClick,drawClick,draw,keyDown,keyUp)
        elseif args[2] and args[1] == "create" then
            if fs.exists(args[2]..".nimg") then error("file exists!",0) end
            local file = fs.open(args[2]..".nimg","w")
            file.write("{}")
            file.close()
			if openCreateFile then
				shell.run(nimg,"edit",args[2],args[3] or "",args[4] or "")
			end
            error()
        elseif args[2] and args[1] == "view" then
            if fs.exists(args[2]..".nimg") then
                b.fill(nil,nil,nil,nil,"\127")
                term.setBackgroundColor(colors.black)
                term.setTextColor(colors.black)
                local index = {}
                function index:draw(x, y)
                    if not x then x = 0 end
                    if not y then y = 0 end
                    for k,v in pairs(self) do
                        if type(k) == "number" then
                            for k2,v2 in pairs(v) do
                                term.setCursorPos(k-self.offset[1]+x,k2-(self.offset[2]+1)+y)
                                term.setBackgroundColor(v2.b)
                                term.setTextColor(v2.t)
                                term.write(v2.s)
                            end
                        end
                    end
                end
                function index:size()
                    return getSize(self)
                end
                local function loadImage(name)
                    if not name then name = "" end
                    if not fs.exists(name..".nimg") then error("not found. try using file name wihnout .nimg note that all files need to have .nimg extension to work",2) end
                    local file = fs.open(name..".nimg","r")
                    local image = textutils.unserialize(file.readAll())
					local image = decode(image)
                    file.close()
                    return setmetatable(image, {__index = index})
                end
                term.setBackgroundColor(colors.black)
                term.clear()
                local img = loadImage(args[2])
                b.frame(3,ys/2+1,xs-2,ys/2-1,"lightGray","gray")
                img:draw(3,(ys/2))
                local txt = "press any char to continue..."
                term.setCursorPos(xs/2-#txt/2+1,ys)
                term.setBackgroundColor(colors.gray)
                term.write(txt)
                os.pullEvent("char")
                term.setTextColor(colors.white)
                term.setBackgroundColor(colors.black)
                term.clear()
                term.setCursorPos(1,1)
                error()
            else
                error("not found. try using file name wihnout .nimg note that all files need to have .nimg extension to work",0)
            end
        elseif args[1] == "update" then
            term.setBackgroundColor(colors.gray)
            term.setTextColor(colors.white)
            term.clear()
            term.setCursorPos(xs/2-6/2,ys/2)
            term.write("UPDATING")
            if win then win.setVisible(true) end
            fs.delete(nimg)
            local web = http.get("https://pastebin.com/raw/2nbDhRXC")
            local webdata = web.readAll()
            local file = fs.open(nimg,"w")
            file.write(webdata)
            web.close()
            file.close()
            if win then win.setVisible(false) end
            term.setTextColor(colors.white)
            term.setBackgroundColor(colors.black)
            term.clear()
            term.setCursorPos(1,1)
            error("updated",0)
        elseif args[1] == "createImageSet" and args[2] then
			if not fs.exists(args[2]..".animg") then
				fs.makeDir(args[2]..".animg")
			else
				error("file exists!",0)
			end
			error()
		elseif args[1] == "addFrame" and args[2] then
			if not fs.exists(args[2]..".animg") then
				error("image set doesnt exist!",0)
			else
				if not args[3] then error("you need to provide frame name!",0) end
                local count = 1
				for k,v in pairs(fs.list(args[2]..".animg")) do
                    if (v):match("^(%d+)") then
						count = count + 1
					end
				end
				local file = fs.open(args[2]..".animg/"..tostring(count).."_"..args[3]..".nimg","w")
				file.write("{}")
				file.close()
				error()
			end
		elseif args[1] == "getAPI" then
			shell.run("pastebin get zLnBmssj nimgAPI")
			error("NIMG API installed!",0)
		elseif args[1] == "help" and args[2] == "images" then
			error("edit: allows  you to edit a file using the nimg editor. usage:\nnimg edit <filename>\n\ncreate: allows you to create a new nimg file. using:\nnimg create <filename>\n",0)
		elseif args[1] == "help" and args[2] == "image_sets" then
			error("createImageSet: allows you to make image set. image sets allow you to store multiple images in a folder and then iterate/animate/draw them. usage:\nnimg createImageSet <name>\n\naddFrame: allows you  to add new images into image sets, image sets images need  to have pretty specific names and addFrame handles it for you\nnimg addFrame <imageSet> <frameName>",0)
		else
            local index = {}
			local indexAnimate = {}
            local indexBuffer = {}
            local function strech(tbl,x,y)
				if type(x) == "number" and type(y) == "number" then
                    local strechmap = {}
                    local strechmapy = {}
                    local final
                    local mulx = 1  
                    local muly = 1 
                    strechmap["offset"] = tbl.offset 
                    strechmapy["offset"] = tbl.offset
                    for k,v in pairs(tbl) do
                        if type(k) == "number" then
                            for k2,v2 in pairs(v) do
                                for i=1,x do
                                    if x > 1 then mulx = x end
                                    if not strechmap[k*mulx+i] then strechmap[k*mulx+i] = {} end
                                    if not strechmap[k*mulx+i][k2] then strechmap[k*mulx+i][k2] = {} end
                                    strechmap[k*mulx+i][k2] = tbl[k][k2]
                                end
                            end
                        end
                    end
                    if y > 1 then
                        for k,v in pairs(strechmap) do
                            if type(k) == "number" then
                                for k2,v2 in pairs(v) do
                                    for i=1,y do 
                                        if y > 1 then muly = y  end
                                        if not strechmapy[k] then strechmapy[k] = {} end
                                        if not strechmapy[k][k2*muly+i] then strechmapy[k][k2*muly+i] = {} end
                                        strechmapy[k][k2*muly+i] = strechmap[k][k2]
                                    end
                                end
                            end
                        end
                    end
                    if not next(strechmap) then strechmap = tbl end
                    if y > 1 then final = strechmapy
                    else final = strechmap end
					return setmetatable(final,getmetatable(tbl)) 
				else
                	return tbl
				end
            end
			function index:strech(x,y)
                local tbl = self
				if not self then error("try using : instead of .",0) end
				if type(x) == "number" and type(y) == "number" then
                    local strechmap = {}
                    local strechmapy = {}
                    local final
                    local mulx = 1  
                    local muly = 1 
                    strechmap["offset"] = tbl.offset 
                    strechmapy["offset"] = tbl.offset
                    for k,v in pairs(tbl) do
                        if type(k) == "number" then
                            for k2,v2 in pairs(v) do
                                for i=1,x do
                                    if x > 1 then mulx = x end
                                    if not strechmap[k*mulx+i] then strechmap[k*mulx+i] = {} end
                                    if not strechmap[k*mulx+i][k2] then strechmap[k*mulx+i][k2] = {} end
                                    strechmap[k*mulx+i][k2] = tbl[k][k2]
                                end
                            end
                        end
                    end
                    if y > 1 then
                        for k,v in pairs(strechmap) do
                            if type(k) == "number" then
                                for k2,v2 in pairs(v) do
                                    for i=1,y do 
                                        if y > 1 then muly = y  end
                                        if not strechmapy[k] then strechmapy[k] = {} end
                                        if not strechmapy[k][k2*muly+i] then strechmapy[k][k2*muly+i] = {} end
                                        strechmapy[k][k2*muly+i] = strechmap[k][k2]
                                    end
                                end
                            end
                        end
                    end
                    if not next(strechmap) then strechmap = tbl end
                    if y > 1 then final = strechmapy
                    else final = strechmap end
					return setmetatable(final,getmetatable(tbl)) 
				else
                	return tbl
				end
            end
            function index:draw(termobj, x, y, ix, iy)
                expect(1,termobj,"table","nil")
                expect(2,x,"number","nil")
                expect(3,y,"number","nil")
				local self = strech(self,ix,iy)
                local terms = termobj or term
                local x = x or 0
                local y = y or 0
                local obc = terms.getBackgroundColor()
                local otc = terms.getTextColor()
                for k,v in pairs(self) do
                    if type(k) == "number" then
                        for k2,v2 in pairs(v) do
                            terms.setCursorPos(k-(self.offset[1])+x,k2-(self.offset[2]/2)+y)
                            terms.setBackgroundColor(v2.b)
                            terms.setTextColor(v2.t)
                            terms.write(v2.s)
                        end
                    end
                end
                terms.setBackgroundColor(obc)
                terms.setTextColor(otc)
            end
            function indexAnimate:drawImage(termobj,frame,x,y,ix,iy)
                expect(1,termobj,"table","nil")
                expect(2,frame,"number")
                expect(3,x,"number","nil")
                expect(4,y,"number","nil")
                if not self then return false end
                local frame = frame or 1
                local frameToLoad = self[1][math.min(frame,#self[1])]
				local frameToLoad = strech(frameToLoad,ix,iy)
                if frameToLoad then
                    local terms = termobj or term
                    if not x then x = 0 end
                    if not y then y = 0 end
                    local obc = terms.getBackgroundColor()
                    local otc = terms.getTextColor()
                    for k,v in pairs(frameToLoad) do
                        if type(k) == "number" then
                            for k2,v2 in pairs(v) do
                                terms.setCursorPos(k-(frameToLoad.offset[1])+x,k2-(frameToLoad.offset[2]/2)+y)
                                terms.setBackgroundColor(v2.b)
                                terms.setTextColor(v2.t)
                                terms.write(v2.s)
                            end
                        end
                    end
                    terms.setBackgroundColor(obc)
                    terms.setTextColor(otc)
                end
            end
			function indexAnimate:animate(termobj,x,y,speed,buffer,clears,ix,iy)
                expect(1,termobj,"table")
                expect(2,x,"number")
                expect(3,y,"number")
                expect(4,speed,"number")
                expect(5,buffer,"boolean")
                expect(6,clears,"boolean")
                local terms = termobj or term.current()
                local tx, ty = terms.getSize()
                if buffer then terms = window.create(terms,1,1,tx,ty)  end
                local x = x or 0
                local y = y or 0
                if not speed then speed = 1 end
				if clears == nil then clears = false end
				if buffer == nil then buffer = false end
				local obc = terms.getBackgroundColor()
                local otc = terms.getTextColor()
				for k1,v1 in ipairs(self[1]) do
					local v1 = strech(v1,ix,iy)
					if buffer then terms.setVisible(false) end
					terms.setBackgroundColor(obc)
                	terms.setTextColor(otc)
					if clears then terms.clear() end
					local count = 0
					local curcount = 0
					for k,v in pairs(v1) do
						count = count + 1
					end
                    for k,v in pairs(v1) do
                        if type(k) == "number" then
                            for k2,v2 in pairs(v) do
                                terms.setCursorPos(k-(v1.offset[1])+x,k2-(v1.offset[2]/2)+y)
                                terms.setBackgroundColor(v2.b)
                                terms.setTextColor(v2.t)
                                terms.write(v2.s)
                            end
                        end
                    end
                    if buffer then terms.setVisible(true) end
					curcount = curcount + 1
					if curcount < #self[1] then sleep(speed) end
				end
                terms.setBackgroundColor(obc)
                terms.setTextColor(otc)
			end
            function indexAnimate:slide(termobj,x,y,ix,iy)
                expect(1,termobj,"table")
                expect(2,x,"number")
                expect(3,y,"number")
                local animation = self[1]
                local loadFrame =  self[2] + 1
                if not animation[loadFrame] then
                    return setmetatable({animation,0,false}, {__index = indexAnimate})
                end
                local terms = termobj or term
                local x = x or 0
                local y = y or 0
                local obc = terms.getBackgroundColor()
                local otc = terms.getTextColor()
				animation[loadFrame] = strech(animation[loadFrame],ix,iy)
                for k,v in pairs(animation[loadFrame]) do
                    if type(k) == "number" then
                        for k2,v2 in pairs(v) do
                            terms.setCursorPos(k-(animation[loadFrame].offset[1])+x,k2-(animation[loadFrame].offset[2]/2)+y)
                            terms.setBackgroundColor(v2.b)
                            terms.setTextColor(v2.t)
                            terms.write(v2.s)
                        end
                    end
                end
                terms.setBackgroundColor(obc)
                terms.setTextColor(otc)
                return setmetatable({animation,loadFrame,true}, {__index = indexAnimate})
            end
			function indexAnimate:iterate()
           		local currentImage = 0
            	local allFramesRaw = self[1]
                return function()
                	currentImage = currentImage + 1
					if allFramesRaw[currentImage] then
               			return setmetatable(allFramesRaw[currentImage], {__index = index}), allFramesRaw, currentImage
					end
  				end
			end
            local function loadImage(name)
                expect(1,name,"string")
                local name = name or ""
                if not fs.exists(name..".nimg") then error("not found. try using file name wihnout .nimg note that all files need to have .nimg extension to work",2) end
                local file = fs.open(name..".nimg","r")
                local image = textutils.unserialize(file.readAll())
				local image = decode(image)
                file.close()
                return setmetatable(image, {__index = index})
            end
			local function loadImageSet(name)
				local frames = {}
                expect(1,name,"string")
				local name = name or ""
                if not fs.isDir(name..".animg") then error("not found. try using file name wihnout .animg note that all image sets need to have .animg extension to work",2) end
				for k,v in pairs(fs.list(name..".animg")) do
					local fn, ext = v:match("^(%d+).+(%..-)$")
					if ext == ".nimg" then
						local file = fs.open(name..".animg/"..v,"r")
						frames[tonumber(fn)] = textutils.unserialise(file.readAll())
						frames[tonumber(fn)] = decode(frames[tonumber(fn)])
						file.close()
					end
				end
				return setmetatable({frames,0}, {__index = indexAnimate})
			end
            function indexBuffer:startBuffer(noclear)
                expect(1,noclear,"boolean","nil")
				self.setVisible(false)
				if not noclear then buffer.clear() end
			end
			function indexBuffer:endBuffer()
				self.setVisible(true)
			end
			local function createBuffer(termObj)
                expect(1,termObj,"table")
				local terms = termObj or term.current()
				local xs, ys = terms.getSize()
				return setmetatable(window.create(terms,1,1,xs,ys),{__index=indexBuffer})
			end
            local function getButtonH()
                return require("ButtonH")
            end
			local function downloadPastekage(pasteCode)
				--pasteges are packages for pastes:
				--they allow downloading a set of images by putting into an paste
				--pastekage format:
				--l1: **PASTEKAGE**
				--l2: [NAME]:PASTEBINCODE 
				--l3: [NAME]:PASTEBINCODE 
				--l4: etc...
				local pastecage, err = http.get("https://pastebin.com/raw/"..pasteCode)
				if err then error(err,0) end
				local rand = tostring(math.random(1,1000000))
				local temp = fs.open("9551_NIMG_MAIN_API_TEMP_PASTKAGE_"..rand,"w")
				temp.write(pastecage.readAll())
				temp.close()
				pastecage.close()
				local lc = 0
				for l in io.lines("9551_NIMG_MAIN_API_TEMP_PASTKAGE_"..rand) do
					lc = lc + 1
					if lc == 1 then if l ~= "**PASTEKAGE**" then error("not an pastekage!",0) end end
					if lc > 1 then
                        local name, code = l:match("^%[(.+)%]:(.+)")
                        local web, err = http.get("https://pastebin.com/raw/"..code)
                        if err then error(err,0) end
                        local file = fs.open(name,"w")
                        file.write(web.readAll())
                        file.close()
                        web.close()
					end
				end
				fs.delete("9551_NIMG_MAIN_API_TEMP_PASTKAGE_"..rand)
			end
            return {
                loadImage = loadImage,
				loadImageSet = loadImageSet,
                getButtonH = getButtonH,
				createBuffer = createBuffer,
				stretch2DMap = strech,
				downloadPastekage = downloadPastekage,
                encode = encode,
				decode = decode
            }
        end
    end
    local ok, err = true
    while ok do
        ok, err = pcall(mainCode)
        if not ok and err == "Terminated" then ok = true end
        if type(err) == "table" then ok = false return err end
        sleep()
    end
    if args[2] and args[1] == "edit" then
		if arg[3] ~= "monitorLaunch" then
        	term.redirect(oldTerm)
		end
        term.setTextColor(colors.white)
        term.setBackgroundColor(colors.black)
        term.clear()
        term.setCursorPos(1,1)
    end
    if not ok then
        error(err,2)
    end
end
