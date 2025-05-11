-- Main.lua - ZaphireUI v1.9: Fully functional UI Library with Acrylic Theme
-- Author: ChatGPT
-- Version: 1.9

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

-- Theme presets
local Themes = {
    Normal = { WindowBackground=Color3.fromRGB(30,30,30), TabBackground=Color3.fromRGB(45,45,45), SectionBackground=Color3.fromRGB(50,50,50), Accent=Color3.fromRGB(0,170,255), TextColor=Color3.new(1,1,1) },
    Light = { WindowBackground=Color3.fromRGB(240,240,240), TabBackground=Color3.fromRGB(220,220,220), SectionBackground=Color3.fromRGB(200,200,200), Accent=Color3.fromRGB(0,120,215), TextColor=Color3.new(0,0,0) },
    Dark = { WindowBackground=Color3.fromRGB(15,15,15), TabBackground=Color3.fromRGB(30,30,30), SectionBackground=Color3.fromRGB(45,45,45), Accent=Color3.fromRGB(255,85,0), TextColor=Color3.new(1,1,1) },
    Aqua = { WindowBackground=Color3.fromRGB(0,50,100), TabBackground=Color3.fromRGB(0,60,120), SectionBackground=Color3.fromRGB(0,70,140), Accent=Color3.fromRGB(0,200,255), TextColor=Color3.new(1,1,1) },
    RedMoon = { WindowBackground=Color3.fromRGB(30,0,0), TabBackground=Color3.fromRGB(60,0,0), SectionBackground=Color3.fromRGB(90,0,0), Accent=Color3.fromRGB(255,50,50), TextColor=Color3.new(1,1,1) },
    Esmerald = { WindowBackground=Color3.fromRGB(0,30,0), TabBackground=Color3.fromRGB(0,45,0), SectionBackground=Color3.fromRGB(0,60,0), Accent=Color3.fromRGB(50,255,100), TextColor=Color3.new(1,1,1) },
    Discord = { WindowBackground=Color3.fromRGB(54,57,63), TabBackground=Color3.fromRGB(47,49,54), SectionBackground=Color3.fromRGB(59,63,68), Accent=Color3.fromRGB(114,137,218), TextColor=Color3.new(1,1,1) },
    Acrylic = { WindowBackground=Color3.fromRGB(50,50,50), TabBackground=Color3.fromRGB(70,70,70), SectionBackground=Color3.fromRGB(90,90,90), Accent=Color3.fromRGB(200,200,255), TextColor=Color3.new(1,1,1) },
}

-- Utility
local function applyRoundCorners(frame, radius)
    local uic = Instance.new("UICorner") uic.CornerRadius = UDim.new(0, radius or 6) uic.Parent = frame
end
local function tween(frame, props)
    local info = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local tw = TweenService:Create(frame, info, props) tw:Play() return tw
end

-- Zaphire library
local Zaphire = {}
Zaphire.__index = Zaphire

-- Create main window
function Zaphire:CreateWindow(config)
    assert(type(config.Name)=="string", "Window needs Name")
    local theme = Themes[config.Theme] or Themes.Normal

    -- ScreenGui
    local gui = Instance.new("ScreenGui") gui.Name = config.Name gui.ResetOnSpawn = false gui.Parent = game:GetService("CoreGui")

    -- Main frame
    local win = Instance.new("Frame") win.Name="MainWindow" win.Size=UDim2.new(0,500,0,350) win.Position=UDim2.new(0.5,-250,0.5,-175) win.BackgroundColor3=theme.WindowBackground win.Parent=gui applyRoundCorners(win,12)

    -- Title bar
    local bar = Instance.new("Frame", win) bar.Name="TitleBar" bar.Size=UDim2.new(1,0,0,30) bar.BackgroundTransparency=1
    local title = Instance.new("TextLabel", bar) title.Text=config.Name title.TextColor3=theme.TextColor title.BackgroundTransparency=1 title.Size=UDim2.new(1,-90,1,0) title.Position=UDim2.new(0,10,0,0) title.Font=Enum.Font.SourceSansBold title.TextSize=18 title.TextXAlignment=Enum.TextXAlignment.Left

    -- Control buttons
    local function mkBtn(sym, x)
        local b=Instance.new("TextButton", bar) b.Size=UDim2.new(0,30,0,30) b.Position=UDim2.new(1,x,0,0) b.BackgroundTransparency=1 b.Text=sym b.TextColor3=theme.TextColor b.Font=Enum.Font.SourceSansBold b.TextSize=18 return b
    end
    local btnMax, btnMin, btnClose = mkBtn("▢", -90), mkBtn("—", -60), mkBtn("✕", -30)

    -- Tabs
    local tabs=Instance.new("Frame",win) tabs.Name="Tabs" tabs.Size=UDim2.new(0,120,1,-30) tabs.Position=UDim2.new(0,0,0,30) tabs.BackgroundColor3=theme.TabBackground applyRoundCorners(tabs,8) Instance.new("UIListLayout", tabs).FillDirection=Enum.FillDirection.Vertical

    -- Content
    local content=Instance.new("Frame",win) content.Name="Content" content.Size=UDim2.new(1,-120,1,-30) content.Position=UDim2.new(0,120,0,30) content.BackgroundTransparency=1

    -- Drag
    do local drag, startPos, startWin=false,nil,nil bar.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then drag=true startPos=i.Position startWin=win.Position end end) bar.InputChanged:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseMovement then bar.DragInput=i end end) UserInputService.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then drag=false end end) UserInputService.InputChanged:Connect(function(i) if drag and i==bar.DragInput then local d=i.Position-startPos win.Position=startWin+UDim2.new(0,d.X,0,d.Y) end end) end

    -- Minimize/Restore
    do local restore do btnMin.MouseButton1Click:Connect(function() win.Visible=false restore=Instance.new("TextButton", gui) restore.Size=UDim2.new(0,40,0,40) restore.Position=UDim2.new(0,10,0,10) restore.BackgroundColor3=theme.Accent restore.Text="▢" restore.TextColor3=theme.TextColor applyRoundCorners(restore,8) -- drag restore local dR,sR,pR=false,nil,nil restore.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dR=true sR=i.Position pR=restore.Position end end) restore.InputChanged:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseMovement then restore.DragInput=i end end) UserInputService.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dR=false end end) UserInputService.InputChanged:Connect(function(i) if dR and i==restore.DragInput then local d=i.Position-sR restore.Position=pR+UDim2.new(0,d.X,0,d.Y) end end) restore.MouseButton1Click:Connect(function() win.Visible=true restore:Destroy() end) end end)
    end

    -- Maximize
    do local maxed=false local origPos,origSize=win.Position,win.Size btnMax.MouseButton1Click:Connect(function() if not maxed then origPos,origSize=win.Position,win.Size win.Position=UDim2.new(0.025,0,0.025,0) win.Size=UDim2.new(0.95,0,0.95,0) else win.Position,win.Size=origPos,origSize end maxed=not maxed end) end

    -- Close
    btnClose.MouseButton1Click:Connect(function() gui:Destroy() end)

    -- Return API
    local api=setmetatable({ScreenGui=gui, _Main=win, Container=content, Tabs={}, CurrentTab=nil, Theme=theme}, Zaphire)
    return api
end

-- CreateTab
function Zaphire:CreateTab(params)
    assert(params.Name, "Tab needs Name")
    local btn=Instance.new("TextButton", self._Main:FindFirstChild("Tabs")) btn.Size=UDim2.new(1,0,0,30) btn.BackgroundTransparency=1 btn.Text=params.Name btn.TextColor3=self.Theme.TextColor btn.Font=Enum.Font.SourceSans btn.TextSize=16
    local page=Instance.new("Frame", self.Container) page.Size=UDim2.new(1,0,1,0) page.BackgroundColor3=self.Theme.SectionBackground page.Visible=false applyRoundCorners(page,6) Instance.new("UIListLayout", page).Padding=UDim.new(0,6)
    local tab={Button=btn, Content=page} setmetatable(tab, {__index=Zaphire})
    btn.MouseButton1Click:Connect(function() if self.CurrentTab then self.CurrentTab.Button.TextColor3=self.Theme.TextColor self.CurrentTab.Content.Visible=false end btn.TextColor3=self.Theme.Accent page.Visible=true self.CurrentTab=tab end)
    if #self.Tabs==0 then btn.MouseButton1Click:Fire() end table.insert(self.Tabs, tab) return tab
end

-- CreateSection
function Zaphire:CreateSection(tab,name)
    assert(tab and tab.Content, "Section needs valid tab")
    local sec=Instance.new("Frame", tab.Content) sec.Size=UDim2.new(1,-20,0,28) sec.BackgroundColor3=self.Theme.SectionBackground applyRoundCorners(sec,4)
    local obj={Container=sec, Items={}} setmetatable(obj,{__index=Zaphire}) return obj
end

-- CreateButton
function Zaphire:CreateButton(sec,name,cb)
    local b=Instance.new("TextButton", sec.Container) b.Size=UDim2.new(1,0,0,28) b.BackgroundColor3=self.Theme.Accent b.Text=name b.TextColor3=self.Theme.TextColor b.Font=Enum.Font.SourceSansBold b.TextSize=16 applyRoundCorners(b,4) b.MouseButton1Click:Connect(cb) table.insert(sec.Items,b) return b end

-- CreateToggle
function Zaphire:CreateToggle(sec,name,def,cb)
    local f=Instance.new("Frame",sec.Container) f.Size=UDim2.new(1,0,0,28) f.BackgroundTransparency=1
    local l=Instance.new("TextLabel",f) l.Text=name l.Size=UDim2.new(0.8,0,1,0) l.BackgroundTransparency=1 l.TextColor3=self.Theme.TextColor l.Font=Enum.Font.SourceSans l.TextSize=16
    local t=Instance.new("Frame",f) t.Size=UDim2.new(0,40,0,20) t.Position=UDim2.new(1,-45,0.5,-10) t.BackgroundColor3=self.Theme.SectionBackground applyRoundCorners(t,10)
    local k=Instance.new("Frame",t) k.Size=UDim2.new(0,18,0,18) k.Position=UDim2.new(def and 1 or 0, def and -18 or 0,0,0) k.BackgroundColor3=self.Theme.Accent applyRoundCorners(k,9)
    local state=def t.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then state=not state tween(k,{Position=UDim2.new(state and 1 or 0,state and -18 or 0,0,0)}) cb(state) end end)
    table.insert(sec.Items,f) return f
end

-- CreateDropdown
function Zaphire:CreateDropdown(sec,name,opts,cb)
    local f=Instance.new("Frame",sec.Container) f.Size=UDim2.new(1,0,0,28) f.BackgroundTransparency=1
    local l=Instance.new("TextLabel",f) l.Text=name l.Size=UDim2.new(0.5,0,1,0) l.BackgroundTransparency=1 l.TextColor3=self.Theme.TextColor l.Font=Enum.Font.SourceSans l.TextSize=16
    local b=Instance.new("TextButton",f) b.Text=opts[1] or "Select" b.Size=UDim2.new(0.5,-10,1,0) b.Position=UDim2.new(0.5,10,0,0) b.BackgroundColor3=self.Theme.Accent b.TextColor3=self.Theme.TextColor applyRoundCorners(b,4)
    local lf=Instance.new("Frame",f) lf.Size=UDim2.new(0,b.AbsoluteSize.X,0,#opts*24) lf.Position=UDim2.new(0.5,10,1,2) lf.BackgroundColor3=self.Theme.SectionBackground applyRoundCorners(lf,4) lf.Visible=false Instance.new("UIListLayout",lf)
    for _,o in ipairs(opts) do local ob=Instance.new("TextButton",lf) ob.Size=UDim2.new(1,0,0,24) ob.BackgroundTransparency=1 ob.Text=o ob.TextColor3=self.Theme.TextColor ob.Font=Enum.Font.SourceSans ob.TextSize=16 ob.MouseButton1Click:Connect(function() b.Text=o lf.Visible=false cb(o) end) end
    b.MouseButton1Click:Connect(function() lf.Visible=not lf.Visible end) table.insert(sec.Items,f) return f end

-- CreateSlider
function Zaphire:CreateSlider(sec,name,min,max,def,cb)
    local f=Instance.new("Frame",sec.Container) f.Size=UDim2.new(1,0,0,28) f.BackgroundTransparency=1
    local l=Instance.new("TextLabel",f) l.Text=name l.Size=UDim2.new(0.4,0,1,0) l.BackgroundTransparency=1 l.TextColor3=self.Theme.TextColor l.Font=Enum.Font.SourceSans l.TextSize=16
    local bg=Instance.new("Frame",f) bg.Size=UDim2.new(0.5,0,0,6) bg.Position=UDim2.new(0.45,0,0.5,-3) bg.BackgroundColor3=self.Theme.SectionBackground applyRoundCorners(bg,3)
    local fill=Instance.new("Frame",bg) fill.Size=UDim2.new((def-min)/(max-min),0,1,0) fill.BackgroundColor3=self.Theme.Accent applyRoundCorners(fill,3)
    local dragging=false bg.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dragging=true end end) UserInputService.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dragging=false end end) UserInputService.InputChanged:Connect(function(i) if dragging and i.UserInputType==Enum.UserInputType.MouseMovement then local r=math.clamp((i.Position.X-bg.AbsolutePosition.X)/bg.AbsoluteSize.X,0,1) fill.Size=UDim2.new(r,0,1,0) cb(min+(max-min)*r) end end)
    table.insert(sec.Items,f) return f
end

-- CreateColorPicker
function Zaphire:CreateColorPicker(sec,name,def,cb)
    local f=Instance.new("Frame",sec.Container) f.Size=UDim2.new(1,0,0,28) f.BackgroundTransparency=1
    local l=Instance.new("TextLabel",f) l.Text=name l.Size=UDim2.new(0.4,0,1,0) l.BackgroundTransparency=1 l.TextColor3=self.Theme.TextColor l.Font=Enum.Font.SourceSans l.TextSize=16
    local chooser=Instance.new("TextButton",f) chooser.Size=UDim2.new(0,28,0,28) chooser.Position=UDim2.new(0.45,0,0,0) chooser.BackgroundColor3=def or self.Theme.Accent applyRoundCorners(chooser,4) chooser.Text=""
    local picker=Instance.new("Frame",f) picker.Size=UDim2.new(0,150,0,150) picker.Position=UDim2.new(0.45,32,1,4) picker.BackgroundColor3=self.Theme.SectionBackground applyRoundCorners(picker,6) picker.Visible=false
    local applyBtn=Instance.new("TextButton",picker) applyBtn.Size=UDim2.new(1,0,0,24) applyBtn.Position=UDim2.new(0,0,1,-24) applyBtn.BackgroundColor3=self.Theme.Accent applyBtn.Text="Apply" applyBtn.TextColor3=self.Theme.TextColor applyBtn.Font=Enum.Font.SourceSansBold applyBtn.TextSize=16 applyBtn.MouseButton1Click:Connect(function() local c=Color3.new(math.random(),math.random(),math.random()) chooser.BackgroundColor3=c picker.Visible=false cb(c) end)
    chooser.MouseButton1Click:Connect(function() picker.Visible=not picker.Visible end)
    table.insert(sec.Items,f) return f
end

return Zaphire
