if not fs.exists("GuiH") then shell.run("wget https://github.com/9551-Dev/apis/raw/main/GuiH.lua") term.clear() end
local GuiH = require("GuiH")

local m = peripheral.find("monitor")
m.setTextScale(0.5)
local gui = GuiH.new(m)

local interface = peripheral.find("appliedenergistics2:interface")
local drives = {peripheral.find("appliedenergistics2:drive")}

local mb = 1024
local storage_cell_capacity = {}
local storage_cell_block_size = {}
local n = 1
for i=1,4 do
    storage_cell_capacity["appliedenergistics2:storage_cell_"..n.."k"] = mb*n
    storage_cell_block_size["appliedenergistics2:storage_cell_"..n.."k"] = n*8
    n=n*4
end

local pbc = setmetatable({
    [0]  = colors.black,
    [1]  = colors.lightGray,
    [2]  = colors.white,
    [2]  = colors.lightBlue,
    [3]  = colors.lightBlue,
    [3]  = colors.blue,
    [4]  = colors.blue,
    [5]  = colors.orange,
    [6]  = colors.orange,
    [7]  = colors.brown,
    [8]  = colors.brown,
    [9]  = colors.red,
    [10] = colors.red,
},{__index=function() return colors.gray end})

local function get_item_data(avg_mult)
    local types = {}
    local count = 0
    local type_count = 0
    local items = interface.listAvailableItems()
    for k,v in pairs(items) do
        local comparator = v.name .. v.damage
        if not types[comparator] then
            count = count + avg_mult
            type_count = type_count + 1
            types[comparator] = true
        end
        count = v.count/8 + count
    end
    return count,type_count
end

local function get_storage_capacity()
    local type_storage = 0
    local amount_storage = 0
    local added_types = 0
    local cells = 0
    for k,drive in pairs(drives) do
        for k,v in pairs(drive.list()) do
            type_storage = type_storage + 63
            cells = cells + 1
            local disk_storage = storage_cell_capacity[v.name]
            local block_size = storage_cell_block_size[v.name]
            added_types = added_types + block_size
            amount_storage = amount_storage + disk_storage
        end
    end
    return amount_storage,type_storage,added_types/cells
end

local items = gui.new.progressbar{
    direction = "left-right",
    x=4,y=5,width=gui.w-6,height=4,
    bg = colors.gray,fg=colors.lightBlue,
}

local itemsborder = gui.new.rectangle{
    x=3,y=4,width=gui.w-4,height=6,
    symbols=gui.preset.rect.border(colors.lightGray,colors.black),
    graphic_order=0,
}

itemsborder.symbols.side_bottom.bg = colors.gray

local typesborder = itemsborder.replicate()
local types = items.replicate()
typesborder.positioning.y = 14
types.positioning.y = 15

local itemstext = gui.new.text{
    text=gui.text{
        x=4,y=10,
        text=(" "):rep(gui.w-6),
        bg=colors.gray,
        fg=colors.white
    }
}

local typestext = itemstext.replicate()
typestext.text.y = 20

local itemstitle = gui.new.text{
    text=gui.text{
        x=4,y=4,
        text="items",
        transparent=true
    },
    graphic_order=2
}

local typestitle = itemstitle.replicate()
typestitle.text.y = 14
typestitle.text.text = "types"

gui.async(function()
    while true do
        local item_cap,type_cap,mult = get_storage_capacity()
        local used_item,used_type = get_item_data(mult)
        items.value = (used_item/item_cap)*100
        types.value = (used_type/type_cap)*100
        itemstext.text.text = gui.api.text.ensure_size(("%d%% %d/%d bytes used"):format(used_item/item_cap*100,used_item,item_cap),gui.w-6)
        typestext.text.text = gui.api.text.ensure_size(("%d%% %d/%d types used"):format(used_type/type_cap*100,used_type,type_cap),gui.w-6)
        sleep(0.05)
    end
end)

gui.async(function()
    while true do
        local peritems = math.min(10,math.ceil(items.value/10))
        local pertypes = math.min(10,math.ceil(types.value/10))
        items.fg = pbc[peritems]
        types.fg = pbc[pertypes]
        sleep(0.5)
    end
end)

gui.run()
