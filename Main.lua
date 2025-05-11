-- ZaphireUI v1.6: Complete UI Library with Themes, Drag, Minimize, Maximize, Close
-- Author: maxlol2023k or eldonnadie820 on youtube
-- Version: 1.6

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

-- Theme presets
local Themes = {
    Normal = { WindowBackground=Color3.fromRGB(30,30,30), TabBackground=Color3.fromRGB(45,45,45), SectionBackground=Color3.fromRGB(50,50,50), Accent=Color3.fromRGB(0,170,255), TextColor=Color3.new(1,1,1) },
    Light  = { WindowBackground=Color3.fromRGB(240,240,240), TabBackground=Color3.fromRGB(220,220,220), SectionBackground=Color3.fromRGB(200,200,200), Accent=Color3.fromRGB(0,120,215), TextColor=Color3.new(0,0,0) },
    Dark   = { WindowBackground=Color3.fromRGB(15,15,15), TabBackground=Color3.fromRGB(30,30,30), SectionBackground=Color3.fromRGB(45,45,45), Accent=Color3.fromRGB(255,85,0), TextColor=Color3.new(1,1,1) },
    Aqua   = { WindowBackground=Color3.fromRGB(0,50,100), TabBackground=Color3.fromRGB(0,60,120), SectionBackground=Color3.fromRGB(0,70,140), Accent=Color3.fromRGB(0,200,255), TextColor=Color3.new(1,1,1) },
    RedMoon= { WindowBackground=Color3.fromRGB(30,0,0), TabBackground=Color3.fromRGB(60,0,0), SectionBackground=Color3.fromRGB(90,0,0), Accent=Color3.fromRGB(255,50,50), TextColor=Color3.new(1,1,1) },
    Esmerald={ WindowBackground=Color3.fromRGB(0,30,0), TabBackground=Color3.fromRGB(0,45,0), SectionBackground=Color3.fromRGB(0,60,0), Accent=Color3.fromRGB(50,255,100), TextColor=Color3.new(1,1,1) },
    Discord= { WindowBackground=Color3.fromRGB(54,57,63), TabBackground=Color3.fromRGB(47,49,54), SectionBackground=Color3.fromRGB(59,63,68), Accent=Color3.fromRGB(114,137,218), TextColor=Color3.new(1,1,1) },
}

local function applyRoundCorners(inst, radius)
    local uic = Instance.new("UICorner")
    uic.CornerRadius = UDim.new(0, radius or 6)
    uic.Parent = inst
end

local function tween(inst, props, info)
    info = info or TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local tw = TweenService:Create(inst, info, props)
    tw:Play()
    return tw
end

local Zaphire = {}
Zaphire.__index = Zaphire

function Zaphire:CreateWindow(config)
    assert(config and config.Name, "Window must have a Name")
    local theme = type(config.Theme)=="string" and Themes[config.Theme] or config.Theme or Themes.Normal
    assert(theme, "Invalid theme provided")

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = config.Name
    screenGui.ResetOnSpawn = false
    screenGui.Parent = game:GetService("CoreGui")

    local window = Instance.new("Frame")
    window.Name = "MainWindow"
    window.Size = UDim2.new(0,500,0,350)
    window.Position = UDim2.new(0.5,-250,0.5,-175)
    window.BackgroundColor3 = theme.WindowBackground
    window.Parent = screenGui
    applyRoundCorners(window,12)

    local titleBar = Instance.new("Frame")
    titleBar.Name = "TitleBar"
    titleBar.Size = UDim2.new(1,0,0,30)
    titleBar.BackgroundTransparency = 1
    titleBar.Parent = window

    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1,-90,1,0)
    title.Position = UDim2.new(0,10,0,0)
    title.BackgroundTransparency = 1
    title.Text = config.Name
    title.TextColor3 = theme.TextColor
    title.Font = Enum.Font.SourceSansBold
    title.TextSize = 18
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = titleBar

    local function makeBtn(name, sym, x)
        local b = Instance.new("TextButton")
        b.Name = name; b.Size = UDim2.new(0,30,0,30)
        b.Position = UDim2.new(1,x,0,0)
        b.BackgroundTransparency = 1; b.Text = sym
        b.TextColor3 = theme.TextColor; b.Font = Enum.Font.SourceSansBold; b.TextSize = 18
        b.Parent = titleBar; return b
    end
    local maxBtn = makeBtn("Maximize","▢",-90)
    local minBtn = makeBtn("Minimize","—",-60)
    local closeBtn = makeBtn("Close","✕",-30)

    local tabsFrame = Instance.new("Frame")
    tabsFrame.Name = "Tabs"
    tabsFrame.Size = UDim2.new(0,120,1,-30)
    tabsFrame.Position = UDim2.new(0,0,0,30)
    tabsFrame.BackgroundColor3 = theme.TabBackground
    tabsFrame.Parent = window
    applyRoundCorners(tabsFrame,8)
    local tabLayout = Instance.new("UIListLayout", tabsFrame)
    tabLayout.FillDirection = Enum.FillDirection.Vertical

    local contentFrame = Instance.new("Frame")
    contentFrame.Name = "Content"
    contentFrame.Size = UDim2.new(1,-120,1,-30)
    contentFrame.Position = UDim2.new(0,120,0,30)
    contentFrame.BackgroundTransparency = 1
    contentFrame.Parent = window

    -- Drag
    local drag = {active=false}
    titleBar.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 then
            drag.active=true; drag.start=i.Position; drag.pos=window.Position
        end
    end)
    titleBar.InputChanged:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseMovement then drag.input=i end end)
    UserInputService.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then drag.active=false end end)
    UserInputService.InputChanged:Connect(function(i)
        if drag.active and i==drag.input then
            local d = i.Position - drag.start
            window.Position = drag.pos + UDim2.new(0,d.X,0,d.Y)
        end
    end)

    -- Minimize / Restore
    local restoreBtn
    local function createRestore()
        restoreBtn = Instance.new("TextButton")
        restoreBtn.Name = "Restore"; restoreBtn.Size = UDim2.new(0,40,0,40)
        restoreBtn.Position = UDim2.new(0,10,0,10); restoreBtn.Text="▢"
        restoreBtn.TextColor3 = theme.TextColor; restoreBtn.Font = Enum.Font.SourceSansBold; restoreBtn.TextSize = 18
        restoreBtn.BackgroundColor3 = theme.Accent
        applyRoundCorners(restoreBtn,8); restoreBtn.Parent = screenGui
        -- drag restore
        local rd={active=false}
        restoreBtn.InputBegan:Connect(function(i)
            if i.UserInputType==Enum.UserInputType.MouseButton1 then rd.active=true; rd.start=i.Position; rd.pos=restoreBtn.Position end
        end)
        restoreBtn.InputChanged:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseMovement then rd.input=i end end)
        UserInputService.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then rd.active=false end end)
        UserInputService.InputChanged:Connect(function(i)
            if rd.active and i==rd.input then local d=i.Position-rd.start; restoreBtn.Position = rd.pos + UDim2.new(0,d.X,0,d.Y) end
        end)
        restoreBtn.MouseButton1Click:Connect(function() window.Visible=true; restoreBtn:Destroy() end)
    end
    minBtn.MouseButton1Click:Connect(function() window.Visible=false; createRestore() end)

    -- Maximize
    local maxim=false; local orig={pos=window.Position, size=window.Size}
    maxBtn.MouseButton1Click:Connect(function()
        if not maxim then orig.pos=window.Position; orig.size=window.Size; window.Position=UDim2.new(0.025,0,0.025,0); window.Size=UDim2.new(0.95,0,0.95,0)
        else window.Position=orig.pos; window.Size=orig.size end; maxim=not maxim
    end)

    -- Close
    closeBtn.MouseButton1Click:Connect(function() screenGui:Destroy(); if restoreBtn then restoreBtn:Destroy() end end)

    local win = setmetatable({
        ScreenGui=screenGui,
        Container=contentFrame,
        _Main=window,
        Tabs={},
        CurrentTab=nil,
        Theme=theme
    }, Zaphire)
    return win
end

-- CreateTab
function Zaphire:CreateTab(params)
    assert(params and params.Name)
    local btn = Instance.new("TextButton")
    btn.Name = params.Name.."TabBtn"
    btn.Size = UDim2.new(1,0,0,30)
    btn.BackgroundTransparency = 1
    btn.Text = params.Name
    btn.TextColor3 = self.Theme.TextColor
    btn.Font = Enum.Font.SourceSans
    btn.TextSize = 16
    btn.Parent = self._Main:FindFirstChild("Tabs")

    local page = Instance.new("Frame")
    page.Name = params.Name.."Page"
    page.Size = UDim2.new(1,0,1,0)
    page.BackgroundColor3 = self.Theme.SectionBackground
    page.Visible = false
    page.Parent = self.Container
    applyRoundCorners(page,6)
    local layout = Instance.new("UIListLayout", page)
    layout.Padding = UDim.new(0,6)

    local function select()
        if self.CurrentTab then
            self.CurrentTab.Btn.TextColor3 = self.Theme.TextColor
            self.CurrentTab.Page.Visible = false
        end
        btn.TextColor3 = self.Theme.Accent
        page.Visible = true
        self.CurrentTab = {Btn=btn, Page=page}
    end
    btn.MouseButton1Click:Connect(select)
    if #self.Tabs == 0 then select() end
    table.insert(self.Tabs, {Btn=btn, Page=page})
    return {Button=btn, Content=page}
end

-- CreateSection
function Zaphire:CreateSection(tab, name)
    assert(tab and tab.Content)
    local sec = Instance.new("Frame")
    sec.Name = name.."Section"
    sec.Size = UDim2.new(1,-20,0,28)
    sec.BackgroundColor3 = self.Theme.SectionBackground
    sec.Parent = tab.Content
    applyRoundCorners(sec,4)
    return {Container=sec, Items={}}
end

-- CreateButton
function Zaphire:CreateButton(sec, name, cb)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1,0,0,28)
    b.BackgroundColor3 = self.Theme.Accent
    b.Text = name; b.TextColor3 = self.Theme.TextColor
    b.Font = Enum.Font.SourceSansBold; b.TextSize = 16
    b.Parent = sec.Container; applyRoundCorners(b,4)
    b.MouseButton1Click:Connect(cb)
    table.insert(sec.Items, b)
    return b
end

-- CreateToggle
function Zaphire:CreateToggle(sec, name, def, cb)
    local f = Instance.new("Frame"); f.Size = UDim2.new(1,0,0,28); f.Parent = sec.Container; f.BackgroundTransparency=1
    local l = Instance.new("TextLabel", f); l.Text = name; l.Size=UDim2.new(0.8,0,1,0); l.BackgroundTransparency=1; l.TextColor3=self.Theme.TextColor; l.Font=Enum.Font.SourceSans; l.TextSize=16
    local t = Instance.new("Frame", f); t.Size=UDim2.new(0,40,0,20); t.Position=UDim2.new(1,-45,0.5,-10); t.BackgroundColor3=self.Theme.SectionBackground; applyRoundCorners(t,10)
    local k = Instance.new("Frame", t); k.Size=UDim2.new(0,18,0,18); k.Position=UDim2.new(def and 1 or 0, def and -18 or 0,0,0); k.BackgroundColor3=self.Theme.Accent; applyRoundCorners(k,9)
    local s = def
    t.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 then
            s = not s
            tween(k, {Position= UDim2.new(s and 1 or 0, s and -18 or 0,0,0)})
            cb(s)
        end
    end)
    table.insert(sec.Items, f)
    return f
end

-- CreateDropdown
function Zaphire:CreateDropdown(sec, name, opts, cb)
    local f = Instance.new("Frame"); f.Size=UDim2.new(1,0,0,28); f.Parent=sec.Container; f.BackgroundTransparency=1
    local l = Instance.new("TextLabel", f); l.Text=name; l.Size=UDim2.new(0.5,0,1,0); l.BackgroundTransparency=1; l.TextColor3=self.Theme.TextColor; l.Font=Enum.Font.SourceSans; l.TextSize=16
    local b = Instance.new("TextButton", f); b.Text=opts[1] or "Select"; b.Size=UDim2.new(0.5,-10,1,0); b.Position=UDim2.new(0.5,10,0,0); b.BackgroundColor3=self.Theme.Accent; b.TextColor3=self.Theme.TextColor; b.Font=Enum.Font.SourceSansBold; b.TextSize=16; applyRoundCorners(b,4)
    local lf = Instance.new("Frame", f); lf.Size=UDim2.new(0,b.AbsoluteSize.X,0,#opts*24); lf.Position=UDim2.new(0.5,10,1,2); lf.BackgroundColor3=self.Theme.SectionBackground; applyRoundCorners(lf,4); lf.Visible=false
    local lay = Instance.new("UIListLayout", lf)
    for _,o in ipairs(opts) do
        local ob = Instance.new("TextButton", lf)
        ob.Size = UDim2.new(1,0,0,24)
        ob.BackgroundTransparency=1; ob.Text=o; ob.TextColor3=self.Theme.TextColor; ob.Font=Enum.Font.SourceSans; ob.TextSize=16
        ob.MouseButton1Click:Connect(function()
            b.Text=o; lf.Visible=false; cb(o)
        end)
    end
    b.MouseButton1Click:Connect(function() lf.Visible=not lf.Visible end)
    table.insert(sec.Items, f)
    return f
end

-- CreateSlider
function Zaphire:CreateSlider(sec, name, min, max, def, cb)
    local f = Instance.new("Frame"); f.Size=UDim2.new(1,0,0,28); f.Parent=sec\Container; f.BackgroundTransparency=1
    local l = Instance.new("TextLabel", f); l.Text=name; l.Size=UDim2.new(0.4,0,1,0); l.BackgroundTransparency=1; l.TextColor3=self.Theme.TextColor; l.Font=Enum.Font.SourceSans; l.TextSize=16
    local bg = Instance.new("Frame",f); bg.Size=UDim2.new(0.5,0,0,6); bg.Position=UDim2.new(0.45,0,0.5,-3); bg.BackgroundColor3=self.Theme.SectionBackground; applyRoundCorners(bg,3)
    local fill = Instance.new("Frame", bg); fill.Size=UDim2.new((def-min)/(max-min),0,1,0); fill.BackgroundColor3=self.Theme.Accent; applyRoundCorners(fill,3)
    local dr = false
    bg.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dr=true end end)
    UserInputService.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dr=false end end)
    UserInputService.InputChanged:Connect(function(i)
        if dr and i.UserInputType==Enum.UserInputType.MouseMovement then
            local r = math.clamp((i.Position.X-bg.AbsolutePosition.X)/bg.AbsoluteSize.X,0,1)
            fill.Size = UDim2.new(r,0,1,0)
            cb(min + (max-min)*r)
        end
    end)
    table.insert(sec.Items, f)
    return f
end

-- CreateColorPicker
function Zaphire:CreateColorPicker(sec, name, def, cb)
    local f = Instance.new("Frame"); f.Size=UDim2.new(1,0,0,28); f.Parent=sec\Container; f.BackgroundTransparency=1
    local l = Instance.new("TextLabel", f); l.Text=name; l.Size=UDim2.new(0.4,0,1,0); l.BackgroundTransparency=1; l.TextColor3=self.Theme.TextColor; l.Font=Enum.Font.SourceSans; l.TextSize=16
    local chooser = Instance.new("TextButton", f); chooser.Size=UDim2.new(0,28,0,28); chooser.Position=UDim2.new(0.45,0,0,0); chooser.BackgroundColor3=def or self.Theme.Accent; applyRoundCorners(chooser,4); chooser.Text=""
    local picker = Instance.new("Frame", f); picker.Size=UDim2.new(0,150,0,150); picker.Position=UDim2.new(0.45,32,1,4); picker.BackgroundColor3=self.Theme.SectionBackground; applyRoundCorners(picker,6); picker.Visible=false
    -- Placeholder apply button
    local applyBtn = Instance.new("TextButton", picker)
    applyBtn.Size = UDim2.new(1,0,0,24); applyBtn.Position=UDim2.new(0,0,1,-24)
    applyBtn.BackgroundColor3=self.Theme.Accent; applyBtn.Text="Apply"; applyBtn.TextColor3=self.Theme.TextColor
    applyBtn.Font=Enum.Font.SourceSansBold; applyBtn.TextSize=16
    applyBtn.MouseButton1Click:Connect(function()
        local col = Color3.new(math.random(),math.random(),math.random())
        chooser.BackgroundColor3=col; picker.Visible=false; cb(col)
    end)
    chooser.MouseButton1Click:Connect(function() picker.Visible=true end)
    table.insert(sec.Items, f)
    return f
end

return Zaphire
