-- Zaphire v1.7
-- made by kai

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

-- Temas predefinidos
local Themes = {
    Normal   = { WindowBackground=Color3.fromRGB(30,30,30), TabBackground=Color3.fromRGB(45,45,45), SectionBackground=Color3.fromRGB(50,50,50), Accent=Color3.fromRGB(0,170,255), TextColor=Color3.new(1,1,1) },
    Light    = { WindowBackground=Color3.fromRGB(240,240,240), TabBackground=Color3.fromRGB(220,220,220), SectionBackground=Color3.fromRGB(200,200,200), Accent=Color3.fromRGB(0,120,215), TextColor=Color3.new(0,0,0) },
    Dark     = { WindowBackground=Color3.fromRGB(15,15,15), TabBackground=Color3.fromRGB(30,30,30), SectionBackground=Color3.fromRGB(45,45,45), Accent=Color3.fromRGB(255,85,0), TextColor=Color3.new(1,1,1) },
    Aqua     = { WindowBackground=Color3.fromRGB(0,50,100), TabBackground=Color3.fromRGB(0,60,120), SectionBackground=Color3.fromRGB(0,70,140), Accent=Color3.fromRGB(0,200,255), TextColor=Color3.new(1,1,1) },
    RedMoon  = { WindowBackground=Color3.fromRGB(30,0,0), TabBackground=Color3.fromRGB(60,0,0), SectionBackground=Color3.fromRGB(90,0,0), Accent=Color3.fromRGB(255,50,50), TextColor=Color3.new(1,1,1) },
    Esmerald = { WindowBackground=Color3.fromRGB(0,30,0), TabBackground=Color3.fromRGB(0,45,0), SectionBackground=Color3.fromRGB(0,60,0), Accent=Color3.fromRGB(50,255,100), TextColor=Color3.new(1,1,1) },
    Discord  = { WindowBackground=Color3.fromRGB(54,57,63), TabBackground=Color3.fromRGB(47,49,54), SectionBackground=Color3.fromRGB(59,63,68), Accent=Color3.fromRGB(114,137,218), TextColor=Color3.new(1,1,1) },
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
    assert(type(config)=="table" and config.Name, "CreateWindow -> Name missing")
    local theme = type(config.Theme)=="string" and Themes[config.Theme] or config.Theme or Themes.Normal
    assert(theme, "CreateWindow -> invalid Theme")

    -- ScreenGui
    local gui = Instance.new("ScreenGui")
    gui.Name = config.Name
    gui.ResetOnSpawn = false
    gui.Parent = game:GetService("CoreGui")

    -- Main window
    local win = Instance.new("Frame")
    win.Name = "MainWindow"
    win.Size = UDim2.new(0,500,0,350)
    win.Position = UDim2.new(0.5,-250,0.5,-175)
    win.BackgroundColor3 = theme.WindowBackground
    win.Parent = gui
    applyRoundCorners(win,12)

    -- TitleBar
    local titleBar = Instance.new("Frame")
    titleBar.Name = "TitleBar"
    titleBar.Size = UDim2.new(1,0,0,30)
    titleBar.BackgroundTransparency = 1
    titleBar.Parent = win

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

    -- Control buttons factory
    local function makeBtn(name,sym,xOff)
        local b = Instance.new("TextButton")
        b.Name = name
        b.Size = UDim2.new(0,30,0,30)
        b.Position = UDim2.new(1, xOff, 0, 0)
        b.BackgroundTransparency = 1
        b.Text = sym
        b.TextColor3 = theme.TextColor
        b.Font = Enum.Font.SourceSansBold
        b.TextSize = 18
        b.Parent = titleBar
        return b
    end
    local maxB = makeBtn("Maximize","▢",-90)
    local minB = makeBtn("Minimize","—",-60)
    local closeB = makeBtn("Close","✕",-30)

    -- Tabs container
    local tabs = Instance.new("Frame")
    tabs.Name = "Tabs"
    tabs.Size = UDim2.new(0,120,1,-30)
    tabs.Position = UDim2.new(0,0,0,30)
    tabs.BackgroundColor3 = theme.TabBackground
    tabs.Parent = win
    applyRoundCorners(tabs,8)
    local list = Instance.new("UIListLayout", tabs)
    list.FillDirection = Enum.FillDirection.Vertical

    -- Content area
    local content = Instance.new("Frame")
    content.Name = "Content"
    content.Size = UDim2.new(1,-120,1,-30)
    content.Position = UDim2.new(0,120,0,30)
    content.BackgroundTransparency = 1
    content.Parent = win

    -- Dragging logic
    do
        local dragging = false
        local startPos, winPos
        titleBar.InputBegan:Connect(function(i)
            if i.UserInputType==Enum.UserInputType.MouseButton1 then
                dragging=true
                startPos=i.Position
                winPos=win.Position
            end
        end)
        titleBar.InputChanged:Connect(function(i)
            if i.UserInputType==Enum.UserInputType.MouseMovement then
                titleBar.DragInput = i
            end
        end)
        UserInputService.InputEnded:Connect(function(i)
            if i.UserInputType==Enum.UserInputType.MouseButton1 then
                dragging=false
            end
        end)
        UserInputService.InputChanged:Connect(function(i)
            if dragging and i==titleBar.DragInput then
                local delta = i.Position - startPos
                win.Position = winPos + UDim2.new(0,delta.X,0,delta.Y)
            end
        end)
    end

    -- Minimize / Restore
    local restoreBtn
    minB.MouseButton1Click:Connect(function()
        win.Visible = false
        -- create a draggable restore button
        restoreBtn = Instance.new("TextButton")
        restoreBtn.Name = "Restore"
        restoreBtn.Size = UDim2.new(0,40,0,40)
        restoreBtn.Position = UDim2.new(0,10,0,10)
        restoreBtn.Text = "▢"
        restoreBtn.TextColor3 = theme.TextColor
        restoreBtn.Font = Enum.Font.SourceSansBold
        restoreBtn.TextSize = 18
        restoreBtn.BackgroundColor3 = theme.Accent
        applyRoundCorners(restoreBtn,8)
        restoreBtn.Parent = gui

        -- drag restore
        local rd, start, rpos
        restoreBtn.InputBegan:Connect(function(i)
            if i.UserInputType==Enum.UserInputType.MouseButton1 then
                rd=true; start=i.Position; rpos=restoreBtn.Position
            end
        end)
        restoreBtn.InputChanged:Connect(function(i)
            if i.UserInputType==Enum.UserInputType.MouseMovement then
                restoreBtn.DragInput=i
            end
        end)
        UserInputService.InputChanged:Connect(function(i)
            if rd and i==restoreBtn.DragInput then
                local d = i.Position - start
                restoreBtn.Position = rpos + UDim2.new(0,d.X,0,d.Y)
            end
        end)
        restoreBtn.InputEnded:Connect(function(i)
            if i.UserInputType==Enum.UserInputType.MouseButton1 then
                rd=false
            end
        end)

        restoreBtn.MouseButton1Click:Connect(function()
            win.Visible = true
            restoreBtn:Destroy()
        end)
    end)

    -- Maximize
    do
        local maximized = false
        local orig = {pos=win.Position, size=win.Size}
        maxB.MouseButton1Click:Connect(function()
            if not maximized then
                orig.pos = win.Position; orig.size = win.Size
                win.Position = UDim2.new(0.025,0,0.025,0)
                win.Size     = UDim2.new(0.95,0,0.95,0)
            else
                win.Position = orig.pos
                win.Size     = orig.size
            end
            maximized = not maximized
        end)
    end

    -- Close
    closeB.MouseButton1Click:Connect(function()
        gui:Destroy()
        if restoreBtn then restoreBtn:Destroy() end
    end)

    -- Return window object
    local selfWin = setmetatable({
        ScreenGui = gui,
        _Main     = win,
        Container = content,
        Tabs      = {},
        CurrentTab= nil,
        Theme     = theme,
    }, Zaphire)

    return selfWin
end

-- CreateTab
function Zaphire:CreateTab(params)
    assert(type(params)=="table" and params.Name, "CreateTab -> Name missing")
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

    local function selectTab()
        if self.CurrentTab then
            self.CurrentTab.Btn.TextColor3 = self.Theme.TextColor
            self.CurrentTab.Page.Visible = false
        end
        btn.TextColor3 = self.Theme.Accent
        page.Visible = true
        self.CurrentTab = {Btn = btn, Page = page}
    end
    btn.MouseButton1Click:Connect(selectTab)
    if #self.Tabs == 0 then selectTab() end
    table.insert(self.Tabs, {Btn=btn, Page=page})
    return {Button=btn, Content=page}
end

-- CreateSection
function Zaphire:CreateSection(tab, name)
    assert(type(tab)=="table" and tab.Content, "CreateSection -> invalid tab")
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
function Zaphire:CreateToggle(sec, name, default, cb)
    local f = Instance.new("Frame"); f.Size = UDim2.new(1,0,0,28); f.Parent = sec.Container; f.BackgroundTransparency=1
    local lbl = Instance.new("TextLabel", f); lbl.Text = name; lbl.Size = UDim2.new(0.8,0,1,0)
    lbl.BackgroundTransparency = 1; lbl.TextColor3 = self.Theme.TextColor; lbl.Font=Enum.Font.SourceSans; lbl.TextSize=16
    local togg = Instance.new("Frame", f); togg.Size = UDim2.new(0,40,0,20)
    togg.Position = UDim2.new(1,-45,0.5,-10); togg.BackgroundColor3=self.Theme.SectionBackground; applyRoundCorners(togg,10)
    local knob = Instance.new("Frame", togg); knob.Size=UDim2.new(0,18,0,18)
    knob.Position = UDim2.new(default and 1 or 0, default and -18 or 0, 0, 0)
    knob.BackgroundColor3 = self.Theme.Accent; applyRoundCorners(knob,9)
    local state = default
    togg.InputBegan:Connect(function(inp)
        if inp.UserInputType==Enum.UserInputType.MouseButton1 then
            state = not state
            tween(knob, {Position = UDim2.new(state and 1 or 0, state and -18 or 0,0,0)})
            cb(state)
        end
    end)
    table.insert(sec.Items, f); return f
end

-- CreateDropdown
function Zaphire:CreateDropdown(sec, name, options, cb)
    local f = Instance.new("Frame"); f.Size=UDim2.new(1,0,0,28); f.Parent = sec.Container; f.BackgroundTransparency=1
    local lbl = Instance.new("TextLabel", f); lbl.Text=name; lbl.Size=UDim2.new(0.5,0,1,0)
    lbl.BackgroundTransparency=1; lbl.TextColor3=self.Theme.TextColor; lbl.Font=Enum.Font.SourceSans; lbl.TextSize=16
    local btn = Instance.new("TextButton", f); btn.Text = options[1] or "Select"
    btn.Size = UDim2.new(0.5,-10,1,0); btn.Position = UDim2.new(0.5,10,0,0)
    btn.BackgroundColor3 = self.Theme.Accent; btn.TextColor3 = self.Theme.TextColor
    btn.Font=Enum.Font.SourceSansBold; btn.TextSize=16; applyRoundCorners(btn,4)
    local list = Instance.new("Frame", f)
    list.Size = UDim2.new(0, btn.AbsoluteSize.X, 0, #options*24)
    list.Position = UDim2.new(0.5,10,1,2)
    list.BackgroundColor3 = self.Theme.SectionBackground; applyRoundCorners(list,4)
    list.Visible = false
    local layout = Instance.new("UIListLayout", list)
    for _,opt in ipairs(options) do
        local oBtn = Instance.new("TextButton", list)
        oBtn.Size = UDim2.new(1,0,0,24); oBtn.BackgroundTransparency=1
        oBtn.Text = opt; oBtn.TextColor3 = self.Theme.TextColor
        oBtn.Font = Enum.Font.SourceSans; oBtn.TextSize=16
        oBtn.MouseButton1Click:Connect(function()
            btn.Text = opt; list.Visible = false; cb(opt)
        end)
    end
    btn.MouseButton1Click:Connect(function() list.Visible = not list.Visible end)
    table.insert(sec.Items, f); return f
end

-- CreateSlider
function Zaphire:CreateSlider(sec, name, min, max, default, cb)
    local f = Instance.new("Frame"); f.Size=UDim2.new(1,0,0,28); f.Parent=sec.Container; f.BackgroundTransparency=1
    local lbl = Instance.new("TextLabel", f); lbl.Text=name; lbl.Size=UDim2.new(0.4,0,1,0)
    lbl.BackgroundTransparency=1; lbl.TextColor3=self.Theme.TextColor; lbl.Font=Enum.Font.SourceSans; lbl.TextSize=16
    local bg = Instance.new("Frame", f); bg.Size=UDim2.new(0.5,0,0,6); bg.Position=UDim2.new(0.45,0,0.5,-3)
    bg.BackgroundColor3=self.Theme.SectionBackground; applyRoundCorners(bg,3)
    local fill = Instance.new("Frame", bg); fill.Size=UDim2.new((default-min)/(max-min),0,1,0)
    fill.BackgroundColor3=self.Theme.Accent; applyRoundCorners(fill,3)
    local dragging = false
    bg.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dragging=true end end)
    UserInputService.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dragging=false end end)
    UserInputService.InputChanged:Connect(function(i)
        if dragging and i.UserInputType==Enum.UserInputType.MouseMovement then
            local rel = math.clamp((i.Position.X - bg.AbsolutePosition.X) / bg.AbsoluteSize.X, 0, 1)
            fill.Size = UDim2.new(rel,0,1,0)
            cb(min + (max-min)*rel)
        end
    end)
    table.insert(sec.Items, f); return f
end

-- CreateColorPicker
function Zaphire:CreateColorPicker(sec, name, defaultColor, cb)
    local f = Instance.new("Frame"); f.Size=UDim2.new(1,0,0,28); f.Parent=sec.Container; f.BackgroundTransparency=1
    local lbl = Instance.new("TextLabel", f); lbl.Text=name; lbl.Size=UDim2.new(0.4,0,1,0)
    lbl.BackgroundTransparency=1; lbl.TextColor3=self.Theme.TextColor; lbl.Font=Enum.Font.SourceSans; lbl.TextSize=16
    local chooser = Instance.new("TextButton", f); chooser.Size=UDim2.new(0,28,0,28)
    chooser.Position=UDim2.new(0.45,0,0,0); chooser.BackgroundColor3=defaultColor or self.Theme.Accent
    applyRoundCorners(chooser,4); chooser.Text=""
    local picker = Instance.new("Frame", f); picker.Size=UDim2.new(0,150,0,150)
    picker.Position=UDim2.new(0.45,32,1,4); picker.BackgroundColor3=self.Theme.SectionBackground
    applyRoundCorners(picker,6); picker.Visible=false
    -- Simple Apply button inside picker
    local applyBtn = Instance.new("TextButton", picker)
    applyBtn.Size=UDim2.new(1,0,0,24); applyBtn.Position=UDim2.new(0,0,1,-24)
    applyBtn.BackgroundColor3=self.Theme.Accent; applyBtn.Text="Apply"; applyBtn.TextColor3=self.Theme.TextColor
    applyBtn.Font=Enum.Font.SourceSansBold; applyBtn.TextSize=16
    applyBtn.MouseButton1Click:Connect(function()
        local col = Color3.new(math.random(),math.random(),math.random())
        chooser.BackgroundColor3 = col; picker.Visible = false; cb(col)
    end)
    chooser.MouseButton1Click:Connect(function()
        picker.Visible = not picker.Visible
    end)
    table.insert(sec.Items, f); return f
end

return Zaphire
