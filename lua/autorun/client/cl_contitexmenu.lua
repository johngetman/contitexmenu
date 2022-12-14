--[[

    ContitexMenu - Very awesome Context Menu, based on DMenu VGUI Element.
    vers 1.1

]]--

local Yes, No = true, false -- don't ask

ContitexMenu = {}
ContitexMenu.Config = {}
ContitexMenu.Objects = {}

--[[
    Config
]]--

local cfg = ContitexMenu.Config

cfg.BackgroundColor = Color(45, 45, 45) -- Color of background
cfg.TextColor = Color(255, 255, 255) -- Color of text
cfg.SpacerColor = Color(70, 70, 70) -- Color of spacer

cfg.Font = "Montserrat" -- Font
cfg.FontSize = 16 -- Size of font

--[[
    Font
]]--

surface.CreateFont("ContitexMenuFont", {
    font = cfg.Font,
    size = cfg.FontSize,
    extended = true
})

--[[
    Meta-Table part
]]--

local object = {}
object.__index = object

function ContitexMenu:New()
    local obj = {
        IsButton = Yes,
        IsSubMenu = No,
        IsSpacer = No,
        Icon = "icon16/page.png",
        Name = "Please, set name to me!",
        SubMenuTable = {},
        IsVisible = function() return Yes end,
        DoClick = function(text) end
    }

    setmetatable(obj, object)

    self.Objects[#self.Objects+1] = obj

    return obj
end

function object:SetSubMenuTable(tab)
    self.SubMenuTable = tab
    return self
end

function object:SetButton(bool)
    self.IsButton = bool
    if bool then
        self.IsSpacer = false
        self.IsSubMenu = false
    end
    
    return self
end

function object:SetSpacer(bool)
    self.IsSpacer = bool
    if bool then
        self.IsButton = false
        self.IsSubMenu = false
    end
    
    return self
end

function object:SetSubMenu(bool)
    self.IsSubMenu = bool
    if bool then
        self.IsButton = false
        self.IsSpacer = false
    end
    
    return self
end

function object:SetName(str)
    self.Name = str
    return self
end

function object:SetVisible(func)
    self.IsVisible = func
    return self
end

function object:SetOnClick(func)
    self.DoClick = func
    return self
end

function object:SetIcon(str)
    self.Icon = str
    return self
end

--[[
    Buttons creation zone.

    Build the context menu of your dreams right here!
]]--

ContitexMenu:New()
    :SetSubMenu(true)
    :SetName("Button1")
    :SetIcon("icon16/tux.png")
    :SetSubMenuTable({
        ["icon16/sound.png"] = "Text1" -- Key = path to icon, value = text
    })
    :SetOnClick(function(text)
        print "Click!"
    end)
    :SetVisible(function()
        return Yes
    end)

ContitexMenu:New()
    :SetSpacer(true)

ContitexMenu:New()
    :SetName("Button2")
    :SetIcon("icon16/tux.png")
    :SetOnClick(function()
        print "Click!"
    end)
    :SetVisible(function()
        return Yes
    end)

/*
    Main Menu
*/

function ContitexMenu:Open()
    timer.Simple(0, function() -- todo: remove this
        self.Menu = DermaMenu()
        self.Menu:SetMaxHeight(ScrW()*0.8)
        self.Menu.Paint = function(self, w, h)
            surface.SetDrawColor(cfg.BackgroundColor)
            surface.DrawRect(0, 0, w, h)
        end

        for _, v in ipairs(ContitexMenu.Objects) do
            local Visible = v.IsVisible and v.IsVisible() 
            if not Visible then continue end
            if v.IsSpacer then
                local spacer = self.Menu:AddSpacer()
                spacer.Paint = function(self, w, h)
                    surface.SetDrawColor(cfg.SpacerColor)
                    surface.DrawLine(0, 0, w, 0)
                end; continue
            elseif v.IsSubMenu then
                local submenu, par = self.Menu:AddSubMenu(v.Name)
                par:SetTextColor(cfg.TextColor)
                par:SetFont("ContitexMenuFont")
                if v.Icon then
                    par:SetIcon(v.Icon)
                end

                local method = v.SubMenuTable[1] and ipairs or pairs
                for key, val in method(v.SubMenuTable) do
                    local button = submenu:AddOption(v.Name, function()
                        v.DoClick(val)
                    end)
                    button:SetTextColor(cfg.TextColor)
                    button:SetFont("ContitexMenuFont")
                    button.Paint = self.Menu.Paint

                    if isstring(key) then
                        button:SetIcon(key)
                    end
                end; continue
            end

            local button = self.Menu:AddOption(v.Name, v.DoClick)
            button:SetTextColor(cfg.TextColor)
            button:SetFont("ContitexMenuFont")

            if v.Icon then
                button:SetIcon(v.Icon)
            end
        end
    
        self.Menu:Open()
        self.Menu:SetX(5)
        self.Menu:CenterVertical()
        self.Menu:MakePopup()
    end)
end

function ContitexMenu:Close()
    if IsValid(self.Menu) then
        self.Menu:Remove()
    end
end

hook.Add("OnContextMenuOpen", "ContitexMenu", function()
    ContitexMenu:Open()
end)

hook.Add("OnContextMenuClose", "ContitexMenu", function()
    ContitexMenu:Close()
end)
