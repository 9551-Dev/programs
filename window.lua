if not fs.exists("GuiH") then
    shell.run("wget run https://github.com/9551-Dev/Gui-h/raw/main/installer.lua")
end
local program,w,h = ...
local args = {...}
table.remove(args,1)
table.remove(args,1)
table.remove(args,1)
_G.args = args
w,h = (w ~= "") and w or "20",(h ~= "") and h or "10"
local api = require("GuiH.main")
local gui = api.create_gui(term.current())

local frame = gui.create.frame({
    x=2,2,width=tonumber(w),height=tonumber(h),
    dragger={
        x=1,y=1,width=tonumber(w),height=1
    }
})
local shown = true
local win = frame.window
local ele = frame.child
local w,h = win.getSize()
local t_win = window.create(win,2,2,w-2,h-2)
win.setCursorPos(1,1)
win.setBackgroundColor(colors.gray)
win.clear()
win.setBackgroundColor(colors.lightGray)
win.setCursorPos(1,1)
win.write((" "):rep(w))
win.setBackgroundColor(colors.black)
t_win.clear()
term.redirect(t_win)
local function update_thread()
    gui.update(0)
    while true do
        gui.update()
    end
end
local function update_shell()
    shell.run((program ~= "") and program or "sh",unpack(args))
end
parallel.waitForAll(
    update_thread,
    update_shell
)
