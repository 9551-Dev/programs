if not fs.exists("GuiH") then
    shell.run("wget run https://github.com/9551-Dev/Gui-h/raw/main/installer.lua")
end
local g_win = window.create(term.current(),1,1,term.getSize())
local program,w,h = ...
local args = {...}
table.remove(args,1)
table.remove(args,1)
table.remove(args,1)
_G.args = args
w,h = (w ~= "") and w or "20",(h ~= "") and h or "10"
local api = require("GuiH.main")
local gui = api.create_gui(g_win)
local frame = gui.create.frame({
    x=2,2,width=tonumber(w),height=tonumber(h),
    dragger={
        x=1,y=1,width=tonumber(w),height=1
    },
    on_move=function(object,pos)
        local term = object.canvas.term_object
        local w,h = term.getSize()
        object.window.reposition(
            math.max(
                math.min(
                    pos.x+object.positioning.width,
                    w+1
                )-object.positioning.width,1
            ),
            math.max(
                math.min(
                    pos.y+object.positioning.height,
                    h+1
                )-object.positioning.height,1
            )
        )
        return true
    end
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
        g_win.setVisible(false)
        g_win.clear()
        gui.update()
        g_win.setVisible(true)
    end
end
local shell_coro = coroutine.create(function()
    shell.run((program ~= "") and program or "sh",unpack(args))
end)

local function update_shell()
    coroutine.resume(shell_coro)
    while coroutine.status(shell_coro) ~= "dead" do
        g_win.setVisible(false)
        g_win.clear()
        local ev_data = table.pack(os.pullEvent())
        local ev = api.convert_event(table.unpack(ev_data,1,ev_data.n))
        if api.valid_events[ev.name] then
            local x,y = win.getPosition()
            ev_data[3] = ev.x-x
            ev_data[4] = ev.y-y
        end
        coroutine.resume(shell_coro,table.unpack(ev_data,1,ev_data.n))
        win.redraw()
        g_win.setVisible(true)
    end
end
pcall(function()
    parallel.waitForAny(
        update_thread,
        update_shell
    )
end)
term.clear()
term.setCursorPos(1,1)
print("Ended window session") 
