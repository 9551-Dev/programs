if not fs.exists("GuiH") then
    shell.run("wget run https://github.com/9551-Dev/Gui-h/raw/main/installer.lua")
end
local GuiH = require("GuiH")
local path = GuiH.apis.pathfind
local CoroH = GuiH.apis.coro
local coro = CoroH.create()
local w,h = term.getSize()
local grid = path.createField(w,h,1,1,1,1,w,h,1)
local gui = GuiH.create_gui(term.current())
local frame,frame2
local res_path = {}
local passages = {}
local function process_path()
    coro.create(function()
        local x1,y1 = frame.window.getPosition()
        local x2,y2 = frame2.window.getPosition()
        local node_a = path.createNode(false,x1,y1,1)
        local node_b = path.createNode(false,x2,y2,1)
        res_path = path.pathfind(grid,node_a,node_b)
    end)
    coro.run()
end
local switch = gui.create.switch({
    name="auto_update_switch",
    x=math.ceil(w/4),y=1,width=math.ceil(w/4+0.5),height=1,
    background_color=colors.red,
    background_color_on=colors.green,
    text=gui.text{
        text="auto: off",
        blit={"0000000000","eeeeeeeeee"},
    },
    text_on=gui.text{
        text="auto: on",
        blit={"000000000","ddddddddd"},
        offset_x=-1
    },
    on_change_state=function(object)
        if not object.value then
            res_path={}
        else
            gui.schedule(process_path)
        end
    end
})
gui.create.button({
    name="wall_clear_button",
    x=1,y=1,width=math.ceil(w/4),height=1,
    background_color=colors.red,
    symbol="\127",
    text=gui.text{
        text="clear walls",
        blit={"00000000000","eeeeeeeeeee"},
    },
    on_click=function() passages = {} end
})
gui.create.button({
    name="find_path_button",
    x=math.ceil(w/4*2+1),y=1,width=math.ceil(w/4),height=1,
    background_color=colors.lime,
    text=gui.text{
        text="find path",
        blit={"000000000","555555555"},
    },
    on_click=function() gui.schedule(process_path) end
})
gui.create.button({
    name="emergency_stop_button",
    x=math.ceil(w/4*3+1),y=1,width=w/4,height=1,
    background_color=colors.red,
    text=gui.text{
        text="emergency",
        blit={"0","e"},
    },
    on_click=function() coro.kill_all() res_path = {} end
})
frame = gui.create.frame({
    x=2,y=3,width=1,height=1,
    on_move=function()
        if switch.value then
            gui.schedule(process_path)
        end
    end
})
frame2 = gui.create.frame({
    x=w-1,y=h-1,width=1,height=1,
    on_move=function()
        if switch.value then
            gui.schedule(process_path)
        end
    end
})
local button
error(gui.execute(function()
end,function(term,event)
    local w1,w2 = frame.window,frame2.window
    w1.setBackgroundColor(colors.green)
    w1.clear()
    w2.setBackgroundColor(colors.red)
    w2.clear()
    if event.name == "mouse_click" or event.name == "mouse_drag" then
        local node = path.findInGrid(grid.grid,vector.new(event.x,event.y,1))
        local ax,ay = frame.window.getPosition()
        local bx,by = frame.window.getPosition()
        if node and not (event.x == ax and event.y == ay) and not (event.x == bx and event.y == by) and not frame.dragged and not frame2.dragged then
            if event.button == 1 then
                node.isPassable = false
                if not passages[event.x] then passages[event.x] = {} end
                passages[event.x][event.y] = true
            elseif event.button == 2 then
                if node.isPassable == false then
                    node.isPassable = true
                    passages[event.x][event.y] = nil
                end
            end
        end
    end
end,function(term)
    term.setBackgroundColor(colors.gray)
    for k,v in pairs(res_path) do
        term.setCursorPos(v.x,v.y)
        term.write(" ")
    end
    term.setBackgroundColor(colors.lightGray)
    term.setTextColor(colors.gray)
    for x,y_list in pairs(passages) do
        for y,data in pairs(y_list) do
            term.setCursorPos(x,y)
            term.write("\127")
        end
    end
end),0) 
