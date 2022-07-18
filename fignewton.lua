local GuiH = require "GuiH"
local mGui = GuiH.new(term.current())
mGui.background = colors.blue

local width,height = 30,9

local win = mGui.new.frame{
    x=math.floor(mGui.w/2-width/2+1),y=mGui.h/2-height/2+1,width=width+1,height=height,
    on_move=function(self,new)
        if mGui.api.general.is_within_field(new.x,new.y,1,1,mGui.w-self.positioning.width+1,mGui.h-self.positioning.height+1) then
            self.window.reposition(new.x,new.y)
        end
        return true
    end
}

local gui = win.child

local rect = gui.new.rectangle({
    x=1,y=1,width=gui.w,height=gui.h,
    symbols=mGui.preset.rect.framed_window(colors.gray,colors.lightGray),
    graphic_order=0
})

gui.new.text{
    text=gui.text{
        text="FIG-newton",
        centered=true,
        transparent=true,
        height=1
    },
    graphic_order=2
}

rect.symbols.top_left.sym = "\135"
rect.symbols.top_left.fg  = colors.blue

rect.symbols.top_right.sym = "\139"
rect.symbols.top_right.fg  = colors.blue

local GROUP_textfield = gui.new.group{
    x=4,y=3,width=25,height=4
}

local textfield = GROUP_textfield.gui

textfield.cls = true
textfield.background = colors.gray

local function wrap(str)
    return mGui.api.text.wrap(str,23)
end

local response = http.get("https://ideas.skystuff.games")
local txt = response and response.readAll() or "click the FUCKING button 4head"
if response then response.close() end

local field = textfield.new.text{
    text=textfield.text{
        centered=true,
        transparent=true,
        text=wrap(txt),
        offset_y=-0.5
    }
}

gui.new.button{
    x=4,y=8,width=6,height=1,
    background_color=colors.red,
    text=gui.text{
        text="Exit",
        transparent=true,
        centered=true
    },
    on_click=mGui.stop
}

local cry_button = gui.new.button{
    x=14,y=8,width=5,height=1,
    background_color=colors.black,
    text=gui.text{
        fg=colors.red,
        text="Cry",
        transparent=true,
        centered=true
    },
    on_click=function()
        field.text.text = "Sobs immensly..."
        field.text.fg = colors.red
        field.text.bg = colors.black
        field.text.transparent = false
        sleep(1)
        os.shutdown()
    end,
    visible=false,
    reactive=false
}

local poll

gui.new.button{
    x=23,y=8,width=6,height=1,
    background_color=colors.green,
    text=gui.text{
        text="Idea",
        transparent=true,
        centered=true
    },
    on_click=function()
        if not poll or not poll.alive() then
            poll = mGui.async(function()
                local response = http.get("https://ideas.skystuff.games")
                if not response then
                    field.text.text     = wrap("text.ERROR - Idea not found")
                    cry_button.visible  = true
                    cry_button.reactive = true
                else
                    field.text.text = wrap(response.readAll())
                end
            end)
        end
    end
}

mGui.run()

term.clear()
term.setCursorPos(1,1)
