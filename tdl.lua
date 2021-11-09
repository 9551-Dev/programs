if not fs.exists("button") then
    shell.run("pastebin get LTDZZZEJ button")
end
if not fs.exists("dsa") then
    shell.run("pastebin get J9mhuXuf dsa")
end
local arg = ...
if arg == "update" then
	shell.run("rename tdl tdl.old")
	shell.run("pastebin get yU5gzMZ1 tdl")
	shell.run("rm tdl.old")
	shell.run("tdl")
end
local b = require("button").terminal
local data = require("dsa")
local items = {}
local startsize = {term.getSize()}
local maxitems = startsize[2] - 3
local updaterate = 0.1
if not fs.exists("tdl.data") then
    fs.open("tdl.data", "w").close()
end
for i = 1, maxitems do
    items[i] = data.getLine("tdl.data", i)
    if items[i] == "" then
        items[i] = nil
        break
    end
end
local function centerWrite(text, customY)
    local width = term.getSize()
    term.setCursorPos(math.ceil((width / 2) - (text:len() / 2)), customY)
    term.write(text)
end
term.setCursorPos(1, 1)
local function tdl()
	term.setTextColor(colors.white)
    centerWrite("To do list", 1)
	term.setTextColor(colors.gray)
    centerWrite(string.rep("-",startsize[1]+1), 2)
	term.setTextColor(colors.cyan)
end
while true do
    local click = b.timetouch(updaterate)
	term.setBackgroundColor(colors.black)
    term.clear()
    tdl()
    do
        local width = term.getSize()
        local text = ">create items<"
        if b.button(1, click, math.ceil((width / 2) - (text:len() / 2)), 3, text) then
            centerWrite("make new item", 4)
            centerWrite("please enter name", 5)
            local count = 1
            for i = 1, #items do
                count = count + 1
            end
			term.setCursorPos(1,6)
            items[count] = read()
            data.writeLine("tdl.data", count, items[count])
        end
        term.setTextColor(colors.white)
    end
    for k, v in ipairs(items) do
        local width = term.getSize()
        local inf = data.getLine("tdl.data",k)
		if inf:gsub(string.sub(inf,2),"") == "!" then
			text = inf:gsub("!","") 
            term.setTextColor(colors.orange)
        else
            text = inf
        end
        term.setCursorPos(1,1)
        print(k.." "..v.." "..data.getLine("tdl.data",k))
        if b.button(1, click, math.ceil((width / 2) - (text:len() / 2)), k + 4, text) then
            items[k] = nil
            items = data.ser(items)
            fs.open("tdl.data", "w").close()
            for i = 1, #items do
                data.writeLine("tdl.data", i, items[i])
            end
        end
        term.setTextColor(colors.white)
    end
	for k, v in ipairs(items) do
		local text = v
		local width = term.getSize()
		if b.button(2, click, math.ceil((width / 2) - (text:len() / 2)), k + 4, "") then
			local info = data.getLine("tdl.data",k)
			if info:gsub(string.sub(info,2),"") ~= "!" then
				data.writeLine("tdl.data",k,"!"..info)
			else
				data.writeLine("tdl.data",k,info:gsub("!",""))
			end
		end
	end
	local scale = {term.getSize()} 
	term.setTextColor(colors.red)
	if b.button(1,click,1,scale[2],">exit<") then
		term.clear()
		term.setCursorPos(1,1)
		break
	end
	term.setTextColor(colors.yellow)
	if b.button(1,click,scale[1]-11,scale[2],">update tdl<") then
		shell.run("rename tdl tdl.old")
		shell.run("pastebin get yU5gzMZ1 tdl")
		shell.run("rm tdl.old")
		shell.run("tdl")
		break
	end
end
