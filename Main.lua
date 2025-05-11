-- TalentlessRemake: Modern Roblox UI Library with Themed Presets, Drag, Minimize, Maximize & Close
-- Author: ChatGPT
-- Version: 1.3

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

-- Predefined theme presets
local Themes = {
    Normal = {
        WindowBackground = Color3.fromRGB(30, 30, 30),
        TabBackground = Color3.fromRGB(45, 45, 45),
        SectionBackground = Color3.fromRGB(50, 50, 50),
        Accent = Color3.fromRGB(0, 170, 255),
        TextColor = Color3.new(1,1,1)
    },
    Light = {
        WindowBackground = Color3.fromRGB(240, 240, 240),
        TabBackground = Color3.fromRGB(220, 220, 220),
        SectionBackground = Color3.fromRGB(200, 200, 200),
        Accent = Color3.fromRGB(0, 120, 215),
        TextColor = Color3.new(0,0,0)
    },
    Dark = {
        WindowBackground = Color3.fromRGB(15, 15, 15),
        TabBackground = Color3.fromRGB(30, 30, 30),
        SectionBackground = Color3.fromRGB(45, 45, 45),
        Accent = Color3.fromRGB(255, 85, 0),
        TextColor = Color3.new(1,1,1)
    },
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

local Talentless = {}
Talentless.__index = Talentless

function Talentless:CreateWindow(config)
    assert(config and config.Name, "Window must have a Name")
    -- determine theme
    local theme = type(config.Theme) == "string" and Themes[config.Theme] or config.Theme or Themes.Normal
    assert(theme, "Invalid theme string provided")

    -- create ScreenGui
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = config.Name
    screenGui.ResetOnSpawn = false
    screenGui.Parent = game:GetService("CoreGui")

    -- main window frame
    local window = Instance.new("Frame")
    window.Name = "Window"
    window.Size = UDim2.new(0, 500, 0, 350)
    window.Position = UDim2.new(0.5, -250, 0.5, -175)
    window.BackgroundColor3 = theme.WindowBackground
    window.Parent = screenGui
    applyRoundCorners(window, 12)

    -- title bar
    local titleBar = Instance.new("Frame")
    titleBar.Name = "TitleBar"
    titleBar.Size = UDim2.new(1, 0, 0, 30)
    titleBar.BackgroundTransparency = 1
    titleBar.Parent = window

    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, -90, 1, 0)
    title.Position = UDim2.new(0, 10, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = config.Name
    title.TextColor3 = theme.TextColor
    title.Font = Enum.Font.SourceSansBold
    title.TextSize = 18
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = titleBar

    -- control buttons
    local function makeButton(name, symbol, xOffset)
        local btn = Instance.new("TextButton")
        btn.Name = name
        btn.Size = UDim2.new(0, 30, 0, 30)
        btn.Position = UDim2.new(1, xOffset, 0, 0)
        btn.BackgroundTransparency = 1
        btn.Text = symbol
        btn.TextColor3 = theme.TextColor
        btn.Font = Enum.Font.SourceSansBold
        btn.TextSize = 18
        btn.Parent = titleBar
        return btn
    end

    local maxBtn = makeButton("Maximize", "▢", -90)
    local minBtn = makeButton("Minimize", "—", -60)
    local closeBtn = makeButton("Close", "✕", -30)

    -- tabs
    local tabsFrame = Instance.new("Frame")
    tabsFrame.Name = "Tabs"
    tabsFrame.Size = UDim2.new(0, 120, 1, -30)
    tabsFrame.Position = UDim2.new(0, 0, 0, 30)
    tabsFrame.BackgroundColor3 = theme.TabBackground
    tabsFrame.Parent = window
    applyRoundCorners(tabsFrame, 8)
    local tabLayout = Instance.new("UIListLayout")
    tabLayout.FillDirection = Enum.FillDirection.Vertical
    tabLayout.Parent = tabsFrame

    -- content area
    local contentFrame = Instance.new("Frame")
    contentFrame.Name = "Content"
    contentFrame.Size = UDim2.new(1, -120, 1, -30)
    contentFrame.Position = UDim2.new(0, 120, 0, 30)
    contentFrame.BackgroundTransparency = 1
    contentFrame.Parent = window

    -- dragging
    local drag = {active = false}
    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            drag.active = true
            drag.startPos = input.Position
            drag.windowPos = window.Position
        end
    end)
    titleBar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            drag.input = input
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            drag.active = false
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if drag.active and input == drag.input then
            local delta = input.Position - drag.startPos
            window.Position = drag.windowPos + UDim2.new(0, delta.X, 0, delta.Y)
        end
    end)

    -- minimize / restore icon
    local restoreIcon
    local function createRestoreIcon()
        restoreIcon = Instance.new("ImageButton")
        restoreIcon.Name = "Restore"
        restoreIcon.Size = UDim2.new(0, 40, 0, 40)
        restoreIcon.Position = UDim2.new(0, 10, 0, 10)
        restoreIcon.BackgroundColor3 = theme.Accent
        applyRoundCorners(restoreIcon, 8)
        restoreIcon.Parent = screenGui
        -- draggable
        local rdrag = {active=false}
        restoreIcon.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 then
                rdrag.active = true
                rdrag.startPos = i.Position
                rdrag.iconPos = restoreIcon.Position
            end
        end)
        restoreIcon.InputChanged:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseMovement then
                rdrag.input = i
            end
        end)
        UserInputService.InputEnded:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 then
                rdrag.active = false
            end
        end)
        UserInputService.InputChanged:Connect(function(i)
            if rdrag.active and i == rdrag.input then
                local delta = i.Position - rdrag.startPos
                restoreIcon.Position = rdrag.iconPos + UDim2.new(0, delta.X, 0, delta.Y)
            end
        end)
        restoreIcon.MouseButton1Click:Connect(function()
            window.Visible = true
            restoreIcon:Destroy()
        end)
    end
    minBtn.MouseButton1Click:Connect(function()
        window.Visible = false
        createRestoreIcon()
    end)

    -- maximize
    local isMax = false
    local original = {pos = window.Position, size = window.Size}
    maxBtn.MouseButton1Click:Connect(function()
        if not isMax then
            original.pos = window.Position
            original.size = window.Size
            window.Size = UDim2.new(0.95, 0, 0.95, 0)
            window.Position = UDim2.new(0.025, 0, 0.025, 0)
        else
            window.Position = original.pos
            window.Size = original.size
        end
        isMax = not isMax
    end)

    -- close
    closeBtn.MouseButton1Click:Connect(function()
        screenGui:Destroy()
        if restoreIcon then restoreIcon:Destroy() end
    end)

    -- return window object
    local obj = setmetatable({
        ScreenGui = screenGui,
        Container = contentFrame,
        Tabs = {},
        CurrentTab = nil,
        Theme = theme
    }, Talentless)
    return obj
end

-- CreateTab, CreateSection, CreateButton, CreateToggle, CreateDropdown, CreateSlider, CreateColorPicker follow unchanged implementations...

-- (Omitted here for brevity; see v1.2 for full definitions)

return Talentless
