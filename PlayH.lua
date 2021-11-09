-------PlayH music player program by 9551 Dev-------
-----------configuration------------
local infoscreens = {
	--example: ["top"] = true,
	-----------["monitor_62"] = true,
}
local exclude_screens = {
	--do not touch this unless you know what does this do and how to use it
}
local autostartPlay = false
local defVol = 70
local chesttype = "minecraft:chest" --the type of chest used by the system. useful setting for modded chests (system can max handle 27 slots)
local updaterate = 1 --rate to update screen/click lower = smoother sytem but worse click detection high = good click detection but less smooth screen
local readspeed = 5 --speed to read contets of chest (min 5) if this is below 5 system and timers are go break
local breaktimerafterPlay = false --if this is true then playlist wont get updated while tape is inserted
------------------------------------

print("if you have multiple monitors dont forget to select info screens!")
local arg = ...
if not fs.exists("./musicdata") then
    fs.makeDir("./musicdata")
end
if arg then
    shell.run("rm ./musicdata/*")
    return
end
if not fs.exists("button") then
    shell.run("pastebin get LTDZZZEJ ./button") --API by 9551 Dev
end
if not fs.exists("bigfont") then
    shell.run("pastebin get 3LfWxRWh ./bigfont") --API by Wojbie
end
-----vars-----
local filter = function(name, wrap)
    return not infoscreens[name]
end
if readspeed < 5 then
    readspeed = 5
end
local shortspeed = 0.1
local b = require("./button").monitor
local bf = require("./bigfont")
local periphs = peripheral.getNames()
local m = peripheral.find("monitor", filter)
local s = peripheral.find("tape_drive")
local c = peripheral.find(chesttype)
local start = false
local maxname = "00000000000"
---periph check---
if not m then
    error("you are missing a monitor", 0)
end
if not s then
    error("you are missing a tape drive", 0)
end
if not c then
    error("you are missing a chest", 0)
end
local mname = peripheral.getName(m)
---periph check*---

-----vars*-----
m.setBackgroundColor(colors.black)
m.clear()
m.setTextColor(colors.white)
m.setTextScale(0.5)
b.frame(mname, 5, 17, 71, 10, "white", "blue")
m.setBackgroundColor(colors.blue)
bf.writeOn(m, 2, "PlayH", nil, 10)
m.setTextColor(colors.black)
bf.writeOn(m, 1, "Music player program", 10, 19)
bf.writeOn(m, 1, "by 9551 DEV", nil, 22)
bf.writeOn(m, 1, "loading", 1, 2)
----------base functions----------
local funcs = {}
local function setup()
    m.setCursorPos(1, 37)
    m.write(string.rep("\140", 100))
    m.setCursorPos(1, 38)
    m.write("\169" .. " PlayH | copyright 2021/2022   9551 DEV")
    b.frame(mname, 3, 19, 75, 17, "white", "black")
    b.frame(mname, 6, 20, 20, 15, "white", "blue")
    b.frame(mname, 30, 20, 45, 15, "white", "blue")
    m.setCursorPos(6, 6)
    m.blit("play list", "fffffffff", "000000000")
    m.setBackgroundColor(colors.blue)
    b.frame(mname, 32, 13, 41, 2, "black", "blue")
    m.setCursorPos(32, 11)
    m.blit("VOLUME", "000000", "ffffff")
    m.setBackgroundColor(colors.black)
end
local function basemain()
    m.clear()
    setup()
    if click then
        if b.switch(mname, 1, click, 7, 4, "red", "green", "white", "loop song") then
            if s.isEnd() then
                s.seek(-s.getSize())
            end
        end
        if b.switch(mname, 2, click, 17, 4, "red", "green", "white", "shuffle") then
            if s.isEnd() then
                s.seek(-s.getSize())
                moveOut()
                moveIn(1)
                s.seek(-s.getSize())
				b.sliderHor("setdb",2,32)
                sortchest(c)
            end
            moveIn(1)
        end
        b.switch(mname, 3, click, 68, 8, "red", "green", "white", "PLAY")
        if b.switch("db", 3) then
            b.switch("setdb", 3, s.play())
        else
            s.stop()
        end
        if b.switch("db", 1) and b.switch("db", 2) then
            b.switch("setdb", 2, false)
        end
        b.frame(mname, 6, 20, 20, 15, "white", "blue")
        m.setCursorPos(6, 6)
        m.blit("play list", "fffffffff", "000000000")
        m.setBackgroundColor(colors.green)
        m.setTextColor(colors.black)
        for k, v in pairs(objects) do
            if b.button(mname, click, 7, 7 + k, v) then
                actions(v, k)
            end
        end
        m.setTextColor(colors.white)
        m.setBackgroundColor(colors.orange)
        if b.button(mname, click, 63, 7, "EJECT TAPE") then
            s.seek(-s.getSize())
            moveOut()
            short = os.startTimer(shortspeed)
            long = os.startTimer(readspeed)
        end
        m.setBackgroundColor(colors.black)
        if b.button(mname, click, 67, 38, "reset timers") then
            short = os.startTimer(shortspeed)
            long = os.startTimer(readspeed)
        end
        b.sliderHor(mname, click, 1, 33, 13, 38, "blue", "white")
    end
    m.setCursorPos(50, 38)
    m.write("clocks:" .. timers1 .. "|" .. timers2)
    local label = s.getLabel()
    m.setCursorPos(33, 8)
    m.setBackgroundColor(colors.blue)
    m.setTextColor(colors.black)
    if label ~= nil then
        if label ~= "" then
            bf.writeOn(m, 1, label, 30, 7)
        else
            bf.writeOn(m, 1, "UnTitled", 30, 7)
        end
        local maxpos = s.getSize()
        local curpos = s.getPosition()
        local timemax = math.floor(maxpos / 6000)
        local curtime = math.floor(curpos / 6000)
        b.bar(mname, 32, 27, 41, 6, curtime + 1, timemax, "gray", "cyan", "black", false, false, "", false, true, false)
        local curfstr = ("%02d:%02d"):format(curtime / 60, curtime % 60)
        local maxfstr = ("%02d:%02d"):format(timemax / 60, timemax % 60)
        m.setCursorPos(32, 22)
        m.blit(
            curfstr .. " / " .. maxfstr,
            string.rep("0", #curfstr + #maxfstr + 3),
            string.rep("f", #curfstr + #maxfstr + 3)
        )
        local oc = m.getBackgroundColor()
        m.setBackgroundColor(colors.blue)
        b.frame(mname, 32, 18, 41, 2, "black", "blue")
        m.setCursorPos(32, 16)
        m.blit("TIMELINE", "00000000", "ffffffff")
        if click then
            b.sliderHor(mname, click, 2, 33, 18, 38, "blue", "white")
            b.switch(mname, 4, click, 68, 17, "red", "green", "white", "SAVE")
        end
        local TIMELINE = b.sliderHor("db", 2)
        if not b.switch("db", 4) then
            b.sliderHor("setdb", 2, math.floor(curtime / timemax * 38) + 32)
            short = os.startTimer(shortspeed)
            long = os.startTimer(readspeed)
        else
            s.seek(-s.getSize())
            local time = (b.sliderHor("db", 2) - 32) / 38 * timemax
            s.seek(time * 6000)
            short = os.startTimer(shortspeed)
            long = os.startTimer(readspeed)
        end
        m.setBackgroundColor(oc)
    else
        m.setCursorPos(33, 8)
        m.write("waiting for tape....")
    end
    m.setTextColor(colors.white)
    m.setCursorPos(30, 10)
    m.write(string.rep("\131", 44))
    m.setBackgroundColor(colors.black)
    local vol = b.sliderHor("db", 1)
    if vol == nil then
        vol = 0
    end
    if vol > 0 then
        vol = vol - 32
    end
    s.setVolume(0.0263157894736842 * vol)
    for mname, bool in pairs(infoscreens) do
        if not exclude_screens[mname] then
            local m = peripheral.wrap(mname)
            m.setBackgroundColor(colors.blue)
            m.clear()
            m.setTextScale(0.5)
            m.setCursorPos(1, 2)
            m.write(string.rep("\131", 15), m.getSize())
            m.setCursorPos(1, 1)
            m.setBackgroundColor(colors.blue)
            local label = s.getLabel()
            if label == "" then
                label = "UnTitled"
            end
            m.write(label or "no tape....")
            m.setCursorPos(1, 3)
            m.write("state: " .. s.getState())
            m.setCursorPos(1, 4)
            m.write("volume: " .. math.floor((vol / 38) * 100) .. "%")
            local maxpos = s.getSize()
            local curpos = s.getPosition()
            local timemax = math.floor(maxpos / 6000)
            local curtime = math.floor(curpos / 6000)
            local curfstr = ("%01d:%02d"):format(curtime / 60, curtime % 60)
            local maxfstr = ("%01d:%02d"):format(timemax / 60, timemax % 60)
            if label then
                b.bar(
                    mname,
                    3,
                    8,
                    12,
                    2.5,
                    curtime + 1,
                    timemax,
                    "gray",
                    "cyan",
                    "black",
                    false,
                    false,
                    "",
                    false,
                    true,
                    true
                )
                m.setCursorPos(3, 5)
                m.blit(
                    curfstr .. "/" .. maxfstr,
                    string.rep("0", #curfstr + #maxfstr + 1),
                    string.rep("f", #curfstr + #maxfstr + 1)
                )
            end
        end
    end
end
local function loadbar(ins, max)
    m.setBackgroundColor(colors.blue)
    b.frame(mname, 3, 19, 75, 17, "white", "blue")
    b.bar(mname, 5, 22, 71, 13, ins, max, "gray", "cyan", "white", false, false, "", false, true, false)
end
function actions(disk, position)
    m.setBackgroundColor(colors.black)
    m.setTextColor(colors.white)
    b.frame(mname, 3, 19, 75, 17, "white", "blue")
    m.setCursorPos(20, 10)
    m.setBackgroundColor(colors.green)
    m.write("what action do you want to perform with")
    m.setBackgroundColor(colors.lightBlue)
    bf.writeOn(m, 1, disk, nil, 12)
    while true do
        local click = b.timetouch(1, mname)
        m.setBackgroundColor(colors.red)
        if b.button(mname, click, 26, 18, "EXIT") then
            setup()
            break
        end
        m.setBackgroundColor(colors.orange)
        if b.button(mname, click, 34, 17, "WIPE TAPE") then
            cleartape(disk, position)
            setup()
            break
        end
        m.setBackgroundColor(colors.orange)
        if b.button(mname, click, 32, 18, "DOWNLOAD SONG") then
            downloadtape(disk, position)
            setup()
            short = os.startTimer(shortspeed)
            long = os.startTimer(readspeed)
            break
        end
        m.setBackgroundColor(colors.green)
        if b.button(mname, click, 49, 17, "PLAY") then
            playtape(disk, position)
            setup()
            break
        end
        m.setBackgroundColor(colors.green)
        if b.button(mname, click, 47, 18, "NAME TAPE") then
            setTape(disk, position)
            setup()
            break
        end
        m.setBackgroundColor(colors.orange)
        if b.button(mname, click, 34, 19, "LOAD FILE") then
            loadtape(disk, position)
            setup()
            break
        end
    end
    short = os.startTimer(shortspeed)
    long = os.startTimer(readspeed)
end
actionlist = {}
function moveIn(num)
    s.pullItems(peripheral.getName(c), num, 64, 1)
end
function moveOut()
    s.pushItems(peripheral.getName(c), 1, 64)
end
function cleartape(disk, position)
	moveOut()
    moveIn(position)
    local tsize = s.getSize()
    local counter1 = 0
    local counter2 = 0
    s.stop()
    s.seek(-tsize)
    s.stop()
    s.seek(-90000)
    local str = string.rep("\xAA", 8192)
    for i = 1, tsize + 8191, 8192 do
        s.write(str)
        counter1 = counter1 + 1
        counter2 = counter2 + 1
        if counter1 > 10 then
            counter1 = 0
            b.frame(mname, 1000, 1000, 100, 20, "white", "blue") --*this is here to slow it down so monitor doesnt glitch
        end
        if counter2 > 300 then
            counter2 = 0
            loadbar(i, tsize)
        end
        local per = tsize / 100
        local percent = math.floor(i / per)
        bf.writeOn(
            m,
            1,
            math.floor(i / 1024) .. "Kb/" .. math.floor(tsize / 1024) .. "Kb" .. " " .. percent .. "%",
            5,
            6
        )
    end
    s.seek(-tsize)
    s.seek(-90000)
    moveOut()
end

function downloadtape(disk, position)
    moveOut()
    b.frame(mname, 3, 19, 75, 17, "white", "blue")
    bf.writeOn(m, 1, "continue in terminal")
    term.clear()
    term.setCursorPos(1, 1)
    print("please enter direct download link to your dfpwm file.")
    local ins = read()
    print("please enter how you wanna name the file")
    local name = read()
    local rand = math.random(1, 999)
    b.frame(mname, 3, 19, 75, 17, "white", "blue")
    bf.writeOn(m, 1, "downloading from web")
    local web, err = http.get(ins, nil, true)
    b.frame(mname, 3, 19, 75, 17, "white", "blue")
    bf.writeOn(m, 1, "DONE")
    if not err then
        local webdata = web.readAll()
        local path = "./musicdata/" .. name .. "_" .. tostring(rand) .. ".dfpwm"
        local file = fs.open(path, "wb")
        moveIn(position)
        --------------------------
        local tsize = s.getSize()
        local counter1 = 0
        local counter2 = 0
        s.stop()
        s.seek(-tsize)
        s.stop()
        s.seek(-90000)
        local str = string.rep("\xAA", 8192)
        for i = 1, tsize + 8191, 8192 do
            s.write(str)
            counter1 = counter1 + 1
            counter2 = counter2 + 1
            if counter1 > 10 then
                counter1 = 0
                b.frame(mname, 1000, 1000, 100, 20, "white", "blue") --*this is here to slow it down so monitor doesnt glitch
            end
            if counter2 > 300 then
                counter2 = 0
                loadbar(i, tsize)
            end
            local per = tsize / 100
            local percent = math.floor(i / per)
            bf.writeOn(
                m,
                1,
                math.floor(i / 1024) .. "Kb/" .. math.floor(tsize / 1024) .. "Kb" .. " " .. percent .. "%",
                5,
                6
            )
        end
        s.seek(-tsize)
        s.seek(-90000)
        --------------------------
        file.write(webdata)
        file.flush()
        file.close()
        file = fs.open(path, "rb")
        local block = 8192
        s.stop()
        s.seek(-s.getSize())
        s.stop()
        local bytery = 0
        local filesize = fs.getSize(path)
        if filesize > s.getSize() then
            filesize = s.getSize()
        end
        repeat
            local bytes = {}
            for i = 1, block do
                local byte = file.read()
                if not byte then
                    break
                end
                bytes[#bytes + 1] = byte
            end
            if #bytes > 0 then
                bytery = bytery + #bytes
                loadbar(math.min(bytery, filesize), filesize)
                bf.writeOn(
                    m,
                    1,
                    math.floor(math.min(bytery, filesize) / 1024) .. "Kb/" .. math.floor(filesize / 1024) .. "Kb",
                    5,
                    6
                )
                for i = 1, #bytes do
                    s.write(bytes[i])
                end
                sleep(0)
            end
        until not bytes or #bytes <= 0 or bytery > filesize
        file.close()
        s.stop()
        s.seek(-s.getSize())
        s.stop()
        if disk == "UnTitled" then
            s.setLabel(name)
        end
        moveOut()
    else
        print("not able to get file. reason:\n" .. err)
    end
end

function playtape(disk, position)
    b.frame(mname, 3, 19, 75, 17, "white", "blue")
    if s.isReady() then
        s.seek(-s.getSize())
    end
    moveOut()
    moveIn(position)
    sortchest(c)
end

function setTape(disk, position)
    b.frame(mname, 3, 19, 75, 17, "white", "blue")
    bf.writeOn(m, 1, "continue in terminal")
    moveOut()
    moveIn(position)
    term.clear()
    term.setCursorPos(1, 1)
    local ins = "placeHolderInHereIsPlaceholder!"
    print("Enter name to asign to tape: " .. disk)
    while #ins > #maxname do
        ins = read()
        if #ins > #maxname then
            print("too long (max " .. #maxname .. " chars)")
            sleep(2)
            term.clear()
            term.setCursorPos(1, 1)
        end
    end
    s.setLabel(ins)
    moveOut()
    term.clear()
    term.setCursorPos(1, 1)
end

function loadtape(disk, position)
    moveOut()
    b.frame(mname, 3, 19, 75, 17, "white", "blue")
    bf.writeOn(m, 1, "continue in terminal")
    term.clear()
    term.setCursorPos(1, 1)
    shell.run("dir ./musicdata/")
    print("\nplease enter what file you want to flash onto the tape")
    local ins = read()
    if fs.exists("./musicdata/" .. ins) then
        print("please enter how you wanna name the tape (if unnamed)")
        local name = read()
        local rand = math.random(1, 1000)

        --
        moveIn(position)
        --------------------------
        local tsize = s.getSize()
        local counter1 = 0
        local counter2 = 0
        s.stop()
        s.seek(-tsize)
        s.stop()
        s.seek(-90000)
        local str = string.rep("\xAA", 8192)
        for i = 1, tsize + 8191, 8192 do
            s.write(str)
            counter1 = counter1 + 1
            counter2 = counter2 + 1
            if counter1 > 10 then
                counter1 = 0
                b.frame(mname, 1000, 1000, 100, 20, "white", "blue") --*this is here to slow it down so monitor doesnt glitch
            end
            if counter2 > 300 then
                counter2 = 0
                loadbar(i, tsize)
            end
            local per = tsize / 100
            local percent = math.floor(i / per)
            bf.writeOn(
                m,
                1,
                math.floor(i / 1024) .. "Kb/" .. math.floor(tsize / 1024) .. "Kb" .. " " .. percent .. "%",
                5,
                6
            )
        end
        s.seek(-tsize)
        s.seek(-90000)
        --------------------------
        local file = fs.open("./musicdata/" .. ins, "rb")
        file = fs.open("./musicdata/" .. ins, "rb")
        local block = 8192
        s.stop()
        s.seek(-s.getSize())
        s.stop()
        local bytery = 0
        local filesize = fs.getSize("./musicdata/" .. ins)
        if filesize > s.getSize() then
            filesize = s.getSize()
        end
        repeat
            local bytes = {}
            for i = 1, block do
                local byte = file.read()
                if not byte then
                    break
                end
                bytes[#bytes + 1] = byte
            end
            if #bytes > 0 then
                bytery = bytery + #bytes
                loadbar(math.min(bytery, filesize), filesize)
                bf.writeOn(
                    m,
                    1,
                    math.floor(math.min(bytery, filesize) / 1024) .. "Kb/" .. math.floor(filesize / 1024) .. "Kb",
                    5,
                    6
                )
                for i = 1, #bytes do
                    s.write(bytes[i])
                end
                sleep(0)
            end
        until not bytes or #bytes <= 0 or bytery > filesize
        file.close()
        s.stop()
        s.seek(-s.getSize())
        s.stop()
        if disk == "UnTitled" then
            s.setLabel(name)
        end
    else
        print("no such file")
    end
    moveOut()
end

local function updateplaylist()
    funcs = {}
    objects = {}
    local list = c.list()
    for i = 1, c.size() do
        if list[i] then
            funcs[i] = function()
                local meta = c.getItemMeta(i)
                if meta then
                    objects[i] = meta.media.label
                    if objects[i] == "" then
                        objects[i] = "UnTitled"
                    end
                end
            end
        else
            break
        end
    end
    if #funcs > 0 then
        parallel.waitForAll(table.unpack(funcs))
    end
end
local function empty_end_slots(c)
    local list = c.list()
    local csize = c.size()
    local count = 0
    for i = 0, csize - 1 do
        local num = csize - i
        if not list[num] then
            count = count + 1
        end
    end
    return count
end
function sortchest(c)
    sorting_stage = 0
    local list = c.list()
    if next(list) then
        for i = 1, c.size() - empty_end_slots(c) do
            sorting_stage = sorting_stage + 1
            while not list[i] do
                for j = i + 1, 27 do
                    c.pullItems(peripheral.getName(c), j, 64, j - 1)
                end
                list = c.list()
            end
            bf.writeOn(m, 1, "sorting: " .. i .. "/" .. c.size() - empty_end_slots(c), 5, 6)
            loadbar(i, c.size() - empty_end_slots(c))
        end
    end
end
local firsst = true
local function getClick()
    click = b.timetouch(updaterate, mname)
    if firsst then
		firsst = false
		b.switch(mname, 3, click, 68, 8, "red", "green", "white", "PLAY")
		b.switch(mname, 2, click, 17, 4, "red", "green", "white", "shuffle")
		b.sliderHor(mname, click, 1, 33, 13, 38, "blue", "white")
		if autostartPlay then b.switch("setdb",3,true) end
		if autostartPlay then b.switch("setdb",2,true) end
		if autostartPlay then b.sliderHor("setdb",1,defVol) end
	end
end

local function checkforevent()
    _, event = os.pullEvent("timer")
end
timers1 = 0
timers2 = 0
counts = 0
local function timers()
    if event == long then
        updateplaylist()
        timers1 = timers1 + 1
        if not start then
            start = not start
            m.setTextColor(colors.white)
            m.setBackgroundColor(colors.black)
            m.clear()
            setup()
        end
        long = os.startTimer(readspeed)
        short = os.startTimer(shortspeed)
    elseif event == short then
        if not breaktimerafterPlay then
            counts = counts + 1
            if counts > readspeed then
                counts = 0
                updateplaylist()
            end
        end
        parallel.waitForAll(basemain, getClick)
        timers2 = timers2 + 1
        short = os.startTimer(shortspeed)
    end
end
----------base functions*----------
local function main()
    short = os.startTimer(.1)
    long = os.startTimer(2)
    updateplaylist()
    while true do
        parallel.waitForAll(checkforevent, timers)
    end
end

local ok, err = pcall(main)
if not ok then
    local names = peripheral.getNames()
    for i = 1, #names do
        if peripheral.getType(names[i]) == "monitor" then
            if not exclude_screens[peripheral.getType(names[i])] then
                peripheral.call(names[i], "setBackgroundColor", colors.black)
                peripheral.call(names[i], "setTextColor", colors.white)
                peripheral.call(names[i], "clear")
            end
        end
    end
    moveOut()
    print("playH crashed reason:\n" .. err)
end
