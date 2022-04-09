if not fs.exists("GuiH") then
    shell.run("wget run https://github.com/9551-Dev/Gui-h/raw/main/installer.lua")
end
local g_win = window.create(term.current(),1,1,term.getSize())
local program,w,h = ...
local args = {...}
table.remove(args,1)
table.remove(args,1)
table.remove(args,1)
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
        object.window.restoreCursor()
        return true
    end,
    btn={true}
})
local shown = true
local win = frame.window
local ele = frame.child
local w,h = win.getSize()
local t_win = window.create(win,2,2,w-2,h-2)

win.setCursorPos(1,1)
win.blit((" "):rep(w),("f"):rep(w),("7"):rep(w))
for i=2,h-1 do
    win.setCursorPos(1,i)
    win.blit(("\149"):rep(w),"8"..("f"):rep(w-1),"f"..("8"):rep(w-1))
end
win.setCursorPos(1,h)
win.blit("\141"..("\140"):rep(w-2).."\142",("8"):rep(w),("f"):rep(w))


t_win.clear()
local old_term = term.redirect(t_win)
local shell_coro = coroutine.create(function()
    shell.run((program ~= "") and program or "sh",unpack(args))
end)
local function update_shell()
    sleep(0.05)
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
        if not (frame.dragged and ev_data[1] == "mouse_drag") and ev_data[1] ~= "key_up" then
            coroutine.resume(shell_coro,table.unpack(ev_data,1,ev_data.n))
        end
        local cx,cy = win.getCursorPos()
        local prg = shell.getRunningProgram():match("[^%/-]+$")
        win.setCursorPos(1,1)
        win.blit(" "..prg..(" "):rep(w-#prg-1),("0"):rep(w),("7"):rep(w))
        win.setCursorPos(cx,cy)
        win.redraw()
        g_win.setVisible(true)
    end
end
local err = gui.execute(update_shell)
term.redirect(old_term)
term.clear()
term.setCursorPos(1,1)
print("Ended window session. "..((err ~= nil) and err or ""))
term.setCursorPos(1,2)
