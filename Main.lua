-- TalentlessRemake: Modern Roblox UI Library (Remake of hellohellohell012321/TALENTLESS)
-- Author: ChatGPT
-- Version: 1.1

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

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = config.Name or "TalentlessGUI"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = game:GetService("CoreGui")

    local window = Instance.new("Frame")
    window.Name = "Window"
    window.Size = UDim2.new(0, 500, 0, 350)
    window.Position = UDim2.new(0.5, -250, 0.5, -175)
    window.BackgroundColor3 = (config.Theme or DefaultTheme).WindowBackground
    window.Parent = screenGui
    applyRoundCorners(window, 12)

    local titleBar = Instance.new("Frame")
    titleBar.Name = "TitleBar"
    titleBar.Size = UDim2.new(1, 0, 0, 30)
    titleBar.BackgroundTransparency = 1
    titleBar.Parent = window

    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, 0, 1, 0)
    title.BackgroundTransparency = 1
    title.Text = config.Name
    title.TextColor3 = (config.Theme or DefaultTheme).TextColor
    title.Font = Enum.Font.SourceSansBold
    title.TextSize = 18
    title.Parent = titleBar

    local tabsFrame = Instance.new("Frame")
    tabsFrame.Name = "Tabs"
    tabsFrame.Size = UDim2.new(0, 120, 1, -30)
    tabsFrame.Position = UDim2.new(0, 0, 0, 30)
    tabsFrame.BackgroundColor3 = (config.Theme or DefaultTheme).TabBackground
    tabsFrame.Parent = window
    applyRoundCorners(tabsFrame, 8)

    local UIListLayout = Instance.new("UIListLayout")
    UIListLayout.FillDirection = Enum.FillDirection.Vertical
    UIListLayout.Parent = tabsFrame

    local contentFrame = Instance.new("Frame")
    contentFrame.Name = "Content"
    contentFrame.Size = UDim2.new(1, -120, 1, -30)
    contentFrame.Position = UDim2.new(0, 120, 0, 30)
    contentFrame.BackgroundTransparency = 1
    contentFrame.Parent = window

    -- Dragging logic
    local dragInfo = {Dragging = false}
    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragInfo.Dragging = true
            dragInfo.StartPos = input.Position
            dragInfo.StartWindow = window.Position
        end
    end)
    titleBar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInfo.DragInput = input
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragInfo.Dragging = false
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInfo.DragInput and dragInfo.Dragging then
            local delta = input.Position - dragInfo.StartPos
            window.Position = dragInfo.StartWindow + UDim2.new(0, delta.X, 0, delta.Y)
        end
    end)

    local WindowObject = setmetatable({
        ScreenGui = screenGui,
        Container = contentFrame,
        Tabs = {},
        CurrentTab = nil,
        Theme = config.Theme or DefaultTheme
    }, Talentless)

    return WindowObject
end

-- Create a new tab
function Talentless:CreateTab(params)
    assert(params and params.Name, "Tab must have a Name")
    local parent = self

    local button = Instance.new("TextButton")
    button.Name = params.Name.."TabButton"
    button.Size = UDim2.new(1, 0, 0, 30)
    button.BackgroundTransparency = 1
    button.Text = params.Name
    button.TextColor3 = parent.Theme.TextColor
    button.Font = Enum.Font.SourceSans
    button.TextSize = 16
    button.Parent = parent.ScreenGui.Window.Tabs

    local frame = Instance.new("Frame")
    frame.Name = params.Name.."Content"
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.BackgroundColor3 = parent.Theme.SectionBackground
    frame.Visible = false
    frame.Parent = parent.Container
    applyRoundCorners(frame, 8)

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 6)
    layout.Parent = frame

    button.MouseButton1Click:Connect(function()
        if parent.CurrentTab then
            parent.CurrentTab.Button.TextColor3 = parent.Theme.TextColor
            parent.CurrentTab.Content.Visible = false
        end
        button.TextColor3 = parent.Theme.Accent
        frame.Visible = true
        parent.CurrentTab = {Button = button, Content = frame}
    end)

    if not parent.CurrentTab then button.MouseButton1Click:Fire() end

    local TabObject = {Button = button, Content = frame}
    table.insert(parent.Tabs, TabObject)
    return TabObject
end

-- Create a section inside a tab
function Talentless:CreateSection(tab, name)
    assert(tab and tab.Content, "Invalid tab provided")
    local section = Instance.new("Frame")
    section.Name = name.."Section"
    section.Size = UDim2.new(1, -20, 0, 100)
    section.BackgroundColor3 = self.Theme.SectionBackground
    section.Parent = tab.Content
    applyRoundCorners(section, 6)

    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, 0, 0, 24)
    title.BackgroundTransparency = 1
    title.Text = name
    title.TextColor3 = self.Theme.TextColor
    title.Font = Enum.Font.SourceSansBold
    title.TextSize = 14
    title.Parent = section

    local contentFrame = Instance.new("Frame")
    contentFrame.Name = "Items"
    contentFrame.Size = UDim2.new(1, 0, 1, -24)
    contentFrame.Position = UDim2.new(0, 0, 0, 24)
    contentFrame.BackgroundTransparency = 1
    contentFrame.Parent = section

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 4)
    layout.Parent = contentFrame

    return {Container = contentFrame, Items = {}}
end

-- Button
function Talentless:CreateButton(section, name, callback)
    local btn = Instance.new("TextButton")
    btn.Name = name.."Button"
    btn.Size = UDim2.new(1, 0, 0, 28)
    btn.BackgroundColor3 = self.Theme.Accent
    btn.Text = name
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 16
    btn.Parent = section.Container
    applyRoundCorners(btn, 4)
    btn.MouseButton1Click:Connect(callback)
    table.insert(section.Items, btn)
    return btn
end

-- Toggle
function Talentless:CreateToggle(section, name, default, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 28)
    frame.BackgroundTransparency = 1
    frame.Parent = section.Container

    local label = Instance.new("TextLabel")
    label.Text = name
    label.Size = UDim2.new(0.8, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = self.Theme.TextColor
    label.Font = Enum.Font.SourceSans
    label.TextSize = 16
    label.Parent = frame

    local toggle = Instance.new("Frame")
    toggle.Size = UDim2.new(0, 40, 0, 20)
    toggle.Position = UDim2.new(1, -45, 0.5, -10)
    toggle.BackgroundColor3 = Color3.fromRGB(100,100,100)
    applyRoundCorners(toggle, 10)
    toggle.Parent = frame

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 18, 0, 18)
    knob.Position = UDim2.new(default and 1 or 0, default and -18 or 0, 0, 0)
    knob.BackgroundColor3 = self.Theme.WindowBackground
    applyRoundCorners(knob, 9)
    knob.Parent = toggle

    local state = default
    toggle.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            state = not state
            tween(knob, {Position = UDim2.new(state and 1 or 0, state and -18 or 0, 0, 0)})
            callback(state)
        end
    end)
    table.insert(section.Items, frame)
    return frame
end

-- Dropdown
function Talentless:CreateDropdown(section, name, options, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 28)
    frame.BackgroundTransparency = 1
    frame.Parent = section.Container

    local label = Instance.new("TextLabel")
    label.Text = name
    label.Size = UDim2.new(0.5, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = self.Theme.TextColor
    label.Font = Enum.Font.SourceSans
    label.TextSize = 16
    label.Parent = frame

    local button = Instance.new("TextButton")
    button.Text = options[1] or "Select"
    button.Size = UDim2.new(0.5, -10, 1, 0)
    button.Position = UDim2.new(0.5, 10, 0, 0)
    button.BackgroundColor3 = self.Theme.Accent
    button.TextColor3 = Color3.new(1,1,1)
    button.Font = Enum.Font.SourceSansBold
    button.TextSize = 16
    applyRoundCorners(button, 4)
    button.Parent = frame

    local listFrame = Instance.new("Frame")
    listFrame.Size = UDim2.new(0, button.AbsoluteSize.X, 0, #options * 24)
    listFrame.Position = UDim2.new(0.5, 10, 1, 2)
    listFrame.BackgroundColor3 = self.Theme.SectionBackground
    applyRoundCorners(listFrame, 4)
    listFrame.Visible = false
    listFrame.Parent = frame

    local layout = Instance.new("UIListLayout")
    layout.Parent = listFrame

    for _, opt in ipairs(options) do
        local optBtn = Instance.new("TextButton")
        optBtn.Size = UDim2.new(1, 0, 0, 24)
        optBtn.Text = opt
        optBtn.BackgroundTransparency = 1
        optBtn.TextColor3 = self.Theme.TextColor
        optBtn.Font = Enum.Font.SourceSans
        optBtn.TextSize = 16
        optBtn.Parent = listFrame
        optBtn.MouseButton1Click:Connect(function()
            button.Text = opt
            listFrame.Visible = false
            callback(opt)
        end)
    end

    button.MouseButton1Click:Connect(function()
        listFrame.Visible = not listFrame.Visible
    end)
    table.insert(section.Items, frame)
    return frame
end

-- Slider
function Talentless:CreateSlider(section, name, min, max, default, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 28)
    frame.BackgroundTransparency = 1
    frame.Parent = section.Container

    local label = Instance.new("TextLabel")
    label.Text = name
    label.Size = UDim2.new(0.4, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = self.Theme.TextColor
    label.Font = Enum.Font.SourceSans
    label.TextSize = 16
    label.Parent = frame

    local sliderBg = Instance.new("Frame")
    sliderBg.Size = UDim2.new(0.5, 0, 0, 6)
    sliderBg.Position = UDim2.new(0.45, 0, 0.5, -3)
    sliderBg.BackgroundColor3 = Color3.fromRGB(100,100,100)
    applyRoundCorners(sliderBg, 3)
    sliderBg.Parent = frame

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((default-min)/(max-min), 0, 1, 0)
    fill.BackgroundColor3 = self.Theme.Accent
    applyRoundCorners(fill, 3)
    fill.Parent = sliderBg

    local dragging = false
    sliderBg.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local rel = math.clamp((input.Position.X - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X, 0, 1)
            fill.Size = UDim2.new(rel, 0, 1, 0)
            local value = min + (max-min)*rel
            callback(value)
        end
    end)
    table.insert(section.Items, frame)
    return frame
end

-- Color Picker
function Talentless:CreateColorPicker(section, name, defaultColor, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 28)
    frame.BackgroundTransparency = 1
    frame.Parent = section.Container

    local label = Instance.new("TextLabel")
    label.Text = name
    label.Size = UDim2.new(0.4, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = self.Theme.TextColor
    label.Font = Enum.Font.SourceSans
    label.TextSize = 16
    label.Parent = frame

    local chooser = Instance.new("Frame")
    chooser.Size = UDim2.new(0, 28, 0, 28)
    chooser.Position = UDim2.new(0.45, 0, 0, 0)
    chooser.BackgroundColor3 = defaultColor or self.Theme.Accent
    applyRoundCorners(chooser, 4)
    chooser.Parent = frame

    local pickerFrame = Instance.new("Frame")
    pickerFrame.Size = UDim2.new(0, 150, 0, 150)
    pickerFrame.Position = UDim2.new(0.45, 32, 1, 4)
    pickerFrame.BackgroundColor3 = self.Theme.SectionBackground
    applyRoundCorners(pickerFrame, 6)
    pickerFrame.Visible = false
    pickerFrame.Parent = frame

    -- Basic grayscale gradient and color selection omitted for brevity
    -- For demo, just toggle visibility and pick random color
    chooser.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            pickerFrame.Visible = not pickerFrame.Visible
            if not pickerFrame.Visible then
                local col = Color3.new(math.random(), math.random(), math.random())
                chooser.BackgroundColor3 = col
                callback(col)
            end
        end
    end)

    table.insert(section.Items, frame)
    return frame
end

return Talentless
