-- Main.lua - ZaphireUI v1.8: Syntax fixes, removed invalid type annotations
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

-- Theme presets
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
    info = info or TweenInfo.new(0.25)
    local tw = TweenService:Create(inst, info, props)
    tw:Play()
    return tw
end

local Zaphire = {}
Zaphire.__index = Zaphire

-- Create the main window
function Zaphire:CreateWindow(config)
    assert(type(config)=="table" and config.Name, "CreateWindow requires a Name")
    local theme = Themes[config.Theme] or config.Theme or Themes.Normal
    assert(type(theme)=="table", "Invalid theme")

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

    -- Title bar
    local titleBar = Instance.new("Frame", window)
    titleBar.Name = "TitleBar"
    titleBar.Size = UDim2.new(1,0,0,30)
    titleBar.BackgroundTransparency = 1

    local title = Instance.new("TextLabel", titleBar)
    title.Name = "Title"
    title.Size = UDim2.new(1,-90,1,0)
    title.Position = UDim2.new(0,10,0,0)
    title.BackgroundTransparency = 1
    title.Text = config.Name
    title.TextColor3 = theme.TextColor
    title.Font = Enum.Font.SourceSansBold
    title.TextSize = 18
    title.TextXAlignment = Enum.TextXAlignment.Left

    -- Control buttons
    local function makeBtn(parent, name, sym, x)
        local btn = Instance.new("TextButton", parent)
        btn.Name = name
        btn.Size = UDim2.new(0,30,0,30)
        btn.Position = UDim2.new(1,x,0,0)
        btn.BackgroundTransparency = 1
        btn.Text = sym
        btn.TextColor3 = theme.TextColor
        btn.Font = Enum.Font.SourceSansBold
        btn.TextSize = 18
        return btn
    end
    local btnMax = makeBtn(titleBar, "Maximize","▢",-90)
    local btnMin = makeBtn(titleBar, "Minimize","—",-60)
    local btnClose = makeBtn(titleBar, "Close","✕",-30)

    -- Tabs container
    local tabsFrame = Instance.new("Frame", window)
    tabsFrame.Name = "Tabs"
    tabsFrame.Size = UDim2.new(0,120,1,-30)
    tabsFrame.Position = UDim2.new(0,0,0,30)
    tabsFrame.BackgroundColor3 = theme.TabBackground
    applyRoundCorners(tabsFrame,8)
    local listLayout = Instance.new("UIListLayout", tabsFrame)
    listLayout.FillDirection = Enum.FillDirection.Vertical

    -- Content area
    local contentFrame = Instance.new("Frame", window)
    contentFrame.Name = "Content"
    contentFrame.Size = UDim2.new(1,-120,1,-30)
    contentFrame.Position = UDim2.new(0,120,0,30)
    contentFrame.BackgroundTransparency = 1

    -- Dragging logic
    do
        local dragging, startPos, startWindow = false, nil, nil
        titleBar.InputBegan:Connect(function(inp)
            if inp.UserInputType==Enum.UserInputType.MouseButton1 then
                dragging = true
                startPos = inp.Position
                startWindow = window.Position
            end
        end)
        titleBar.InputChanged:Connect(function(inp)
            if inp.UserInputType==Enum.UserInputType.MouseMovement then
                titleBar.DragInput = inp
            end
        end)
        UserInputService.InputEnded:Connect(function(inp)
            if inp.UserInputType==Enum.UserInputType.MouseButton1 then
                dragging = false
            end
        end)
        UserInputService.InputChanged:Connect(function(inp)
            if dragging and inp == titleBar.DragInput then
                local delta = inp.Position - startPos
                window.Position = startWindow + UDim2.new(0, delta.X, 0, delta.Y)
            end
        end)
    end

    -- Minimize & Restore
    do
        local restoreBtn
        btnMin.MouseButton1Click:Connect(function()
            window.Visible = false
            restoreBtn = Instance.new("TextButton", screenGui)
            restoreBtn.Name = "Restore"
            restoreBtn.Size = UDim2.new(0,40,0,40)
            restoreBtn.Position = UDim2.new(0,10,0,10)
            restoreBtn.BackgroundColor3 = theme.Accent
            restoreBtn.Text = "▢"
            restoreBtn.TextColor3 = theme.TextColor
            applyRoundCorners(restoreBtn,8)

            -- Drag restoreBtn
            local draggingR, startR, posR = false, nil, nil
            restoreBtn.InputBegan:Connect(function(inp)
                if inp.UserInputType==Enum.UserInputType.MouseButton1 then
                    draggingR = true
                    startR = inp.Position
                    posR = restoreBtn.Position
                end
            end)
            restoreBtn.InputChanged:Connect(function(inp)
                if inp.UserInputType==Enum.UserInputType.MouseMovement then
                    restoreBtn.DragInput = inp
                end
            end)
            UserInputService.InputEnded:Connect(function(inp)
                if inp.UserInputType==Enum.UserInputType.MouseButton1 then
                    draggingR = false
                end
            end)
            UserInputService.InputChanged:Connect(function(inp)
                if draggingR and inp == restoreBtn.DragInput then
                    local delta = inp.Position - startR
                    restoreBtn.Position = posR + UDim2.new(0, delta.X, 0, delta.Y)
                end
            end)

            restoreBtn.MouseButton1Click:Connect(function()
                window.Visible = true
                restoreBtn:Destroy()
            end)
        end)
    end

    -- Maximize
    do
        local maximized = false
        local orig = {pos=window.Position, size=window.Size}
        btnMax.MouseButton1Click:Connect(function()
            if not maximized then
                orig.pos = window.Position; orig.size = window.Size
                window.Position = UDim2.new(0.025,0,0.025,0)
                window.Size     = UDim2.new(0.95,0,0.95,0)
            else
                window.Position = orig.pos
                window.Size     = orig.size
            end
            maximized = not maximized
        end)
    end

    -- Close
    btnClose.MouseButton1Click:Connect(function()
        screenGui:Destroy()
    end)

    -- Final object
    local obj = setmetatable({
        ScreenGui = screenGui,
        _Main = window,
        Container = contentFrame,
        Tabs = {},
        CurrentTab = nil,
        Theme = theme,
    }, Zaphire)
    return obj
end

-- CreateTab
function Zaphire:CreateTab(params)
    assert(type(params)=="table" and params.Name, "CreateTab requires Name")
    local btn = Instance.new("TextButton", self._Main:FindFirstChild("Tabs"))
    btn.Name = params.Name.."TabBtn"
    btn.Size = UDim2.new(1,0,0,30)
    btn.BackgroundTransparency = 1
    btn.Text = params.Name
    btn.TextColor3 = self.Theme.TextColor
    btn.Font = Enum.Font.SourceSans
    btn.TextSize = 16

    local page = Instance.new("Frame", self.Container)
    page.Name = params.Name.."Page"
    page.Size = UDim2.new(1,0,1,0)
    page.BackgroundColor3 = self.Theme.SectionBackground
    page.Visible = false
    applyRoundCorners(page,6)
    Instance.new("UIListLayout", page).Padding = UDim.new(0,6)

    local tabObj = {Button=btn, Content=page}
    setmetatable(tabObj, {__index = Zaphire})

    btn.MouseButton1Click:Connect(function()
        if self.CurrentTab then
            self.CurrentTab.Button.TextColor3 = self.Theme.TextColor
            self.CurrentTab.Content.Visible = false
        end
        btn.TextColor3 = self.Theme.Accent
        page.Visible = true
        self.CurrentTab = tabObj
    end)
    if #self.Tabs == 0 then btn:CaptureFocus(); btn.MouseButton1Click:Fire() end
    table.insert(self.Tabs, tabObj)
    return tabObj
end

-- CreateSection
function Zaphire:CreateSection(tab, name)
    assert(type(tab)=="table" and tab.Content, "CreateSection invalid tab")
    local sec = Instance.new("Frame", tab.Content)
    sec.Name = name.."Section"
    sec.Size = UDim2.new(1,-20,0,28)
    sec.BackgroundColor3 = tab.Theme.SectionBackground
    applyRoundCorners(sec,4)

    local obj = {Container=sec, Items={}}
    setmetatable(obj, {__index = Zaphire})
    return obj
end

-- CreateButton
function Zaphire:CreateButton(sec, name, cb)
    local b = Instance.new("TextButton", sec.Container)
    b.Size = UDim2.new(1,0,0,28)
    b.BackgroundColor3 = self.Theme.Accent
    b.Text = name; b.TextColor3 = self.Theme.TextColor
    b.Font = Enum.Font.SourceSansBold; b.TextSize = 16
    applyRoundCorners(b,4)
    b.MouseButton1Click:Connect(cb)
    table.insert(sec.Items, b)
    return b
end

-- CreateToggle
function Zaphire:CreateToggle(sec, name, default, cb)
    -- implement similar to above
    return nil
end

-- Other component definitions here...

return Zaphire
