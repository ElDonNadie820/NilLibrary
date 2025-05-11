-- TalentlessRemake: Modern Roblox UI Library with Minimize & Close Button
-- Author: ChatGPT
-- Version: 1.2.1

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local Talentless = {}
Talentless.__index = Talentless

-- Default theme
local DefaultTheme = {
    WindowBackground = Color3.fromRGB(30, 30, 30),
    TabBackground = Color3.fromRGB(45, 45, 45),
    SectionBackground = Color3.fromRGB(50, 50, 50),
    Accent = Color3.fromRGB(0, 170, 255),
    TextColor = Color3.new(1,1,1)
}

-- Utility: Apply rounded corners
local function applyRoundCorners(frame, radius)
    local uic = Instance.new("UICorner")
    uic.CornerRadius = UDim.new(0, radius or 6)
    uic.Parent = frame
end

-- Utility: Tween properties
local function tween(instance, properties, info)
    info = info or TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local tw = TweenService:Create(instance, info, properties)
    tw:Play()
    return tw
end

-- Create a new window
function Talentless:CreateWindow(config)
    assert(config and config.Name, "Window must have a Name")

    local theme = config.Theme or DefaultTheme
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = config.Name
    screenGui.ResetOnSpawn = false
    screenGui.Parent = game:GetService("CoreGui")

    local window = Instance.new("Frame")
    window.Name = "Window"
    window.Size = UDim2.new(0, 500, 0, 350)
    window.Position = UDim2.new(0.5, -250, 0.5, -175)
    window.BackgroundColor3 = theme.WindowBackground
    window.Parent = screenGui
    applyRoundCorners(window, 12)

    -- TitleBar
    local titleBar = Instance.new("Frame")
    titleBar.Name = "TitleBar"
    titleBar.Size = UDim2.new(1,0,0,30)
    titleBar.BackgroundTransparency = 1
    titleBar.Parent = window

    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1,-60,1,0)
    title.Position = UDim2.new(0,0,0,0)
    title.BackgroundTransparency = 1
    title.Text = config.Name
    title.TextColor3 = theme.TextColor
    title.Font = Enum.Font.SourceSansBold
    title.TextSize = 18
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = titleBar

    local minBtn = Instance.new("TextButton")
    minBtn.Name = "Minimize"
    minBtn.Size = UDim2.new(0,30,0,30)
    minBtn.Position = UDim2.new(1,-60,0,0)
    minBtn.BackgroundTransparency = 1
    minBtn.Text = "—"
    minBtn.TextColor3 = theme.TextColor
    minBtn.Font = Enum.Font.SourceSansBold
    minBtn.TextSize = 18
    minBtn.Parent = titleBar

    local closeBtn = Instance.new("TextButton")
    closeBtn.Name = "Close"
    closeBtn.Size = UDim2.new(0,30,0,30)
    closeBtn.Position = UDim2.new(1,-30,0,0)
    closeBtn.BackgroundTransparency = 1
    closeBtn.Text = "✕"
    closeBtn.TextColor3 = theme.TextColor
    closeBtn.Font = Enum.Font.SourceSansBold
    closeBtn.TextSize = 18
    closeBtn.Parent = titleBar

    -- Tabs container
    local tabsFrame = Instance.new("Frame")
    tabsFrame.Name = "Tabs"
    tabsFrame.Size = UDim2.new(0,120,1,-30)
    tabsFrame.Position = UDim2.new(0,0,0,30)
    tabsFrame.BackgroundColor3 = theme.TabBackground
    tabsFrame.Parent = window
    applyRoundCorners(tabsFrame,8)

    local tabList = Instance.new("UIListLayout")
    tabList.FillDirection = Enum.FillDirection.Vertical
    tabList.Parent = tabsFrame

    -- Content container
    local contentFrame = Instance.new("Frame")
    contentFrame.Name = "Content"
    contentFrame.Size = UDim2.new(1,-120,1,-30)
    contentFrame.Position = UDim2.new(0,120,0,30)
    contentFrame.BackgroundTransparency = 1
    contentFrame.Parent = window

    -- Draggable window
    local dragInfo = {Dragging=false}
    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType==Enum.UserInputType.MouseButton1 then
            dragInfo.Dragging=true
            dragInfo.StartPos=input.Position
            dragInfo.StartWindow=window.Position
        end
    end)
    titleBar.InputChanged:Connect(function(input)
        if input.UserInputType==Enum.UserInputType.MouseMovement then dragInfo.DragInput=input end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType==Enum.UserInputType.MouseButton1 then dragInfo.Dragging=false end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragInfo.Dragging and input==dragInfo.DragInput then
            local delta=input.Position-dragInfo.StartPos
            window.Position=dragInfo.StartWindow+UDim2.new(0,delta.X,0,delta.Y)
        end
    end)

    -- Minimize & restore
    local restoreIcon
    local function createRestoreIcon()
        restoreIcon = Instance.new("ImageButton")
        restoreIcon.Name="Restore"
        restoreIcon.Size=UDim2.new(0,40,0,40)
        restoreIcon.Position=UDim2.new(0,10,0,10)
        restoreIcon.BackgroundColor3=theme.Accent
        applyRoundCorners(restoreIcon,8)
        restoreIcon.Parent=screenGui
        -- draggable
        local d={Dragging=false}
        restoreIcon.InputBegan:Connect(function(i)
            if i.UserInputType==Enum.UserInputType.MouseButton1 then d.Dragging=true; d.Start=i.Position; d.Pos=restoreIcon.Position end
        end)
        restoreIcon.InputChanged:Connect(function(i)
            if i.UserInputType==Enum.UserInputType.MouseMovement then d.Input=i end
        end)
        UserInputService.InputChanged:Connect(function(i)
            if d.Dragging and i==d.Input then local delta=i.Position-d.Start; restoreIcon.Position=d.Pos+UDim2.new(0,delta.X,0,delta.Y) end
        end)
        restoreIcon.MouseButton1Click:Connect(function()
            window.Visible=true
            restoreIcon:Destroy()
        end)
    end
    minBtn.MouseButton1Click:Connect(function()
        window.Visible=false
        createRestoreIcon()
    end)

    -- Close
    closeBtn.MouseButton1Click:Connect(function()
        screenGui:Destroy()
        if restoreIcon then restoreIcon:Destroy() end
    end)

    local WindowObject=setmetatable({
        ScreenGui=screenGui,
        Container=contentFrame,
        Tabs={},
        CurrentTab=nil,
        Theme=theme
    },Talentless)
    return WindowObject
end

-- CreateTab
function Talentless:CreateTab(params)
    assert(params and params.Name, "Tab must have a Name")
    local parent=self
    local btn=Instance.new("TextButton")
    btn.Name=params.Name.."Tab"
    btn.Size=UDim2.new(1,0,0,30)
    btn.BackgroundTransparency=1
    btn.Text=params.Name
    btn.TextColor3=parent.Theme.TextColor
    btn.Font=Enum.Font.SourceSans
    btn.TextSize=16
    btn.Parent=parent.ScreenGui.Window.Tabs

    local frame=Instance.new("Frame")
    frame.Name=params.Name.."Content"
    frame.Size=UDim2.new(1,0,1,0)
    frame.BackgroundColor3=parent.Theme.SectionBackground
    frame.Visible=false
    frame.Parent=parent.Container
    applyRoundCorners(frame,8)
    local layout=Instance.new("UIListLayout",frame)
    layout.Padding=UDim.new(0,6)

    btn.MouseButton1Click:Connect(function()
        if parent.CurrentTab then parent.CurrentTab.Button.TextColor3=parent.Theme.TextColor; parent.CurrentTab.Content.Visible=false end
        btn.TextColor3=parent.Theme.Accent
        frame.Visible=true
        parent.CurrentTab={Button=btn,Content=frame}
    end)
    if not parent.CurrentTab then btn.MouseButton1Click:Fire() end
    table.insert(parent.Tabs,{Button=btn,Content=frame})
    return {Button=btn,Content=frame}
end

-- CreateSection
function Talentless:CreateSection(tab,name)
    assert(tab and tab.Content)
    local sec=Instance.new("Frame") sec.Name=name.."Sec" sec.Size=UDim2.new(1,-20,0,100)
    sec.BackgroundColor3=self.Theme.SectionBackground sec.Parent=tab.Content; applyRoundCorners(sec,6)
    local ttl=Instance.new("TextLabel") ttl.Name="Title" ttl.Size=UDim2.new(1,0,0,24)
    ttl.BackgroundTransparency=1 ttl.Text=name ttl.TextColor3=self.Theme.TextColor ttl.Font=Enum.Font.SourceSansBold ttl.TextSize=14 ttl.Parent=sec
    local cont=Instance.new("Frame") cont.Name="Items" cont.Size=UDim2.new(1,0,1,-24) cont.Position=UDim2.new(0,0,0,24) cont.BackgroundTransparency=1 cont.Parent=sec
    local lay=Instance.new("UIListLayout",cont); lay.Padding=UDim.new(0,4)
    return {Container=cont,Items={}}
end

-- CreateButton
function Talentless:CreateButton(sec,name,cb)
    local b=Instance.new("TextButton") b.Size=UDim2.new(1,0,0,28) b.BackgroundColor3=self.Theme.Accent
    b.Text=name b.TextColor3=Color3.new(1,1,1) b.Font=Enum.Font.SourceSansBold b.TextSize=16 b.Parent=sec.Container; applyRoundCorners(b,4)
    b.MouseButton1Click:Connect(cb) table.insert(sec.Items,b) return b
end

-- CreateToggle
function Talentless:CreateToggle(sec,name,def,cb)
    local f=Instance.new("Frame") f.Size=UDim2.new(1,0,0,28) f.BackgroundTransparency=1 f.Parent=sec.Container
    local l=Instance.new("TextLabel",f) l.Text=name; l.Size=UDim2.new(0.8,0,1,0); l.BackgroundTransparency=1; l.TextColor3=self.Theme.TextColor; l.Font=Enum.Font.SourceSans; l.TextSize=16
    local t=Instance.new("Frame",f) t.Size=UDim2.new(0,40,0,20); t.Position=UDim2.new(1,-45,0.5,-10); t.BackgroundColor3=Color3.fromRGB(100,100,100); applyRoundCorners(t,10)
    local k=Instance.new("Frame",t) k.Size=UDim2.new(0,18,0,18); k.Position=UDim2.new(def and 1 or 0,def and -18 or 0,0,0); k.BackgroundColor3=self.Theme.WindowBackground; applyRoundCorners(k,9)
    local s=def
    t.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then s=not s; tween(k,{Position=UDim2.new(s and 1 or 0,s and -18 or 0,0,0)}); cb(s) end end)
    table.insert(sec.Items,f) return f
end

-- CreateDropdown
function Talentless:CreateDropdown(sec,name,opts,cb)
    local f=Instance.new("Frame") f.Size=UDim2.new(1,0,0,28); f.BackgroundTransparency=1; f.Parent=sec.Container
    local l=Instance.new("TextLabel",f) l.Text=name; l.Size=UDim2.new(0.5,0,1,0); l.BackgroundTransparency=1; l.TextColor3=self.Theme.TextColor; l.Font=Enum.Font.SourceSans; l.TextSize=16
    local b=Instance.new("TextButton",f) b.Text=opts[1] or "Select"; b.Size=UDim2.new(0.5,-10,1,0); b.Position=UDim2.new(0.5,10,0,0); b.BackgroundColor3=self.Theme.Accent; b.TextColor3=Color3.new(1,1,1); b.Font=Enum.Font.SourceSansBold; b.TextSize=16; applyRoundCorners(b,4)
    local lf=Instance.new("Frame",f) lf.Size=UDim2.new(0,b.AbsoluteSize.X,0,#opts*24); lf.Position=UDim2.new(0.5,10,1,2); lf.BackgroundColor3=self.Theme.SectionBackground; applyRoundCorners(lf,4); lf.Visible=false
    local lay=Instance.new("UIListLayout",lf)
    for _,o in ipairs(opts) do local ob=Instance.new("TextButton",lf); ob.Size=UDim2.new(1,0,0,24); ob.BackgroundTransparency=1; ob.Text=o; ob.TextColor3=self.Theme.TextColor; ob.Font=Enum.Font.SourceSans; ob.TextSize=16; ob.MouseButton1Click:Connect(function() b.Text=o; lf.Visible=false; cb(o) end) end
    b.MouseButton1Click:Connect(function() lf.Visible=not lf.Visible end)
    table.insert(sec.Items,f) return f
end

-- CreateSlider
function Talentless:CreateSlider(sec,name,min,max,def,cb)
    local f=Instance.new("Frame") f.Size=UDim2.new(1,0,0,28); f.BackgroundTransparency=1; f.Parent=sec.Container
    local l=Instance.new("TextLabel",f) l.Text=name; l.Size=UDim2.new(0.4,0,1,0); l.BackgroundTransparency=1; l.TextColor3=self.Theme.TextColor; l.Font=Enum.Font.SourceSans; l.TextSize=16
    local bg=Instance.new("Frame",f) bg.Size=UDim2.new(0.5,0,0,6); bg.Position=UDim2.new(0.45,0,0.5,-3); bg.BackgroundColor3=Color3.fromRGB(100,100,100); applyRoundCorners(bg,3)
    local fill=Instance.new("Frame",bg) fill.Size=UDim2.new((def-min)/(max-min),0,1,0); fill.BackgroundColor3=self.Theme.Accent; applyRoundCorners(fill,3)
    local dr=false
    bg.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dr=true end end)
    UserInputService.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dr=false end end)
    UserInputService.InputChanged:Connect(function(i)
        if dr and i.UserInputType==Enum.UserInputType.MouseMovement then
            local r=math.clamp((i.Position.X-bg.AbsolutePosition.X)/bg.AbsoluteSize.X,0,1)
            fill.Size=UDim2.new(r,0,1,0)
            cb(min+(max-min)*r)
        end
    end)
    table.insert(sec.Items,f) return f
end

-- CreateColorPicker
function Talentless:CreateColorPicker(sec,name,def,cb)
    local f=Instance.new("Frame") f.Size=UDim2.new(1,0,0,28); f.BackgroundTransparency=1; f.Parent=sec.Container
    local l=Instance.new("TextLabel",f) l.Text=name; l.Size=UDim2.new(0.4,0,1,0); l.BackgroundTransparency=1; l.TextColor3=self.Theme.TextColor; l.Font=Enum.Font.SourceSans; l.TextSize=16
    local chooser=Instance.new("Frame",f) chooser.Size=UDim2.new(0,28,0,28); chooser.Position=UDim2.new(0.45,0,0,0); chooser.BackgroundColor3=def or self.Theme.Accent; applyRoundCorners(chooser,4)
    local picker=Instance.new("Frame",f) picker.Size=UDim2.new(0,150,0,150); picker.Position=UDim2.new(0.45,32,1,4); picker.BackgroundColor3=self.Theme.SectionBackground; applyRoundCorners(picker,6); picker.Visible=false
    chooser.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then picker.Visible=not picker.Visible; if not picker.Visible then local c=Color3.new(math.random(),math.random(),math.random()); chooser.BackgroundColor3=c; cb(c) end end end)
    table.insert(sec.Items,f) return f
end

return Talentless
