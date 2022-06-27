if not fs.exists("GuiH") then
    shell.run("wget run https://github.com/9551-Dev/Gui-h/raw/main/installer.lua")
end
if not fs.exists("yaropa") then
    shell.run("wget https://github.com/9551-Dev/yaropa/raw/main/main.lua yaropa")
end
local GuiH = require("GuiH")
local path = require("yaropa")
local w,h = term.getSize()
local grid = path.create_field(w,h,1)
local gui = GuiH.new(term.current())
local frame,frame2
local res_path = {}
local passages = {}
local last_task
local function process_path()
    if not last_task or not last_task.alive() then
        last_task = gui.async(function()
            local x1,y1 = frame.window.getPosition()
            local x2,y2 = frame2.window.getPosition()
            local node_a = path.node(x1,y1,1)
            local node_b = path.node(x2,y2,1)
            res_path = path.pathfind(grid,node_a,node_b)
        end)
    end
end
local switch = gui.create.switch({
    name="auto_update_switch",
    x=math.ceil(w/3),y=1,width=math.ceil(w/3+0.5),height=1,
    background_color=colors.red,
    background_color_on=colors.green,
    text=gui.text{
        text="auto: off",
        transparent=true,
        h=1,centered=true
    },
    text_on=gui.text{
        text="auto: on",
        transparent=true,
        offset_x=-1,
        h=1,centered=true
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
    x=1,y=1,width=math.ceil(w/3),height=1,
    background_color=colors.red,
    symbol="\127",
    text=gui.text{
        text="clear walls",
        transparent=true,
        h=1,centered=true
    },
    on_click=function()
        grid = path.create_field(w,h,1)
        passages = {}
    end
})
gui.create.button({
    name="find_path_button",
    x=math.ceil(w/3*2+1),y=1,width=math.ceil(w/3),height=1,
    background_color=colors.lime,
    text=gui.text{
        text="find path",
        transparent=true,
        h=1,centered=true
    },
    on_click=function() gui.schedule(process_path) end
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
            process_path()
        end
    end
})
local button
error(gui.execute(nil,function(term,event)
    local w1,w2 = frame.window,frame2.window
    w1.setBackgroundColor(colors.green)
    w1.clear()
    w2.setBackgroundColor(colors.red)
    w2.clear()
    if event.name == "mouse_click" or event.name == "mouse_drag" then
        local node_index = grid.grid.NODE_LOOKUP[event.x][event.y][1]
        local node = grid.grid.points[node_index]
        local ax,ay = frame.window.getPosition()
        local bx,by = frame.window.getPosition()
        if node and not (event.x == ax and event.y == ay) and not (event.x == bx and event.y == by) and not frame.dragged and not frame2.dragged then
            if event.button == 1 then
                node.passable = false
                if not passages[event.x] then passages[event.x] = {} end
                passages[event.x][event.y] = true
            elseif event.button == 2 then
                if node.passable == false then
                    node.passable = true
                    passages[event.x][event.y] = nil
                end
            end
            if switch.value then process_path() end
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
