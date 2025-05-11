
-- Zaphire UI Library (Moderna, funcional y con soporte para "Acrylic")

local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local Zaphire = {}
Zaphire.__index = Zaphire

local Themes = {
    Normal = {
        Background = Color3.fromRGB(30, 30, 30),
        Accent = Color3.fromRGB(0, 170, 255),
        Text = Color3.fromRGB(255, 255, 255)
    },
    RedMoon = {
        Background = Color3.fromRGB(25, 0, 0),
        Accent = Color3.fromRGB(255, 70, 70),
        Text = Color3.fromRGB(255, 230, 230)
    },
    Esmerald = {
        Background = Color3.fromRGB(0, 25, 15),
        Accent = Color3.fromRGB(0, 255, 170),
        Text = Color3.fromRGB(230, 255, 240)
    },
    Discord = {
        Background = Color3.fromRGB(54, 57, 63),
        Accent = Color3.fromRGB(114, 137, 218),
        Text = Color3.fromRGB(255, 255, 255)
    }
}

local function createUIStroke(obj)
    local stroke = Instance.new("UIStroke")
    stroke.Thickness = 1
    stroke.Color = Color3.fromRGB(100, 100, 100)
    stroke.Parent = obj
end

local function createAcrylic(frame)
    local blur = Instance.new("ImageLabel")
    blur.Size = UDim2.new(1, 0, 1, 0)
    blur.BackgroundTransparency = 1
    blur.Image = "rbxassetid://13083289757"
    blur.ImageTransparency = 0.65
    blur.ScaleType = Enum.ScaleType.Slice
    blur.SliceCenter = Rect.new(10, 10, 118, 118)
    blur.ZIndex = frame.ZIndex - 1
    blur.Parent = frame
end

function Zaphire:CreateWindow(settings)
    local theme = Themes[settings.Theme or "Normal"] or Themes["Normal"]
    local acrylic = settings.Acrylic or false

    local screenGui = Instance.new("ScreenGui", PlayerGui)
    screenGui.Name = "ZaphireUI"
    screenGui.ResetOnSpawn = false

    local mainFrame = Instance.new("Frame", screenGui)
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 500, 0, 350)
    mainFrame.Position = UDim2.new(0.5, -250, 0.5, -175)
    mainFrame.BackgroundColor3 = theme.Background
    mainFrame.BorderSizePixel = 0
    mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)

    local uicorner = Instance.new("UICorner", mainFrame)
    uicorner.CornerRadius = UDim.new(0, 12)

    if acrylic then
        createAcrylic(mainFrame)
    end

    local title = Instance.new("TextLabel", mainFrame)
    title.Text = settings.Name or "Zaphire"
    title.Size = UDim2.new(1, 0, 0, 40)
    title.BackgroundTransparency = 1
    title.TextColor3 = theme.Text
    title.Font = Enum.Font.GothamBold
    title.TextSize = 22

    local tabContainer = Instance.new("Frame", mainFrame)
    tabContainer.Name = "Tabs"
    tabContainer.Position = UDim2.new(0, 0, 0, 40)
    tabContainer.Size = UDim2.new(0, 120, 1, -40)
    tabContainer.BackgroundTransparency = 1

    local contentFrame = Instance.new("Frame", mainFrame)
    contentFrame.Name = "Content"
    contentFrame.Position = UDim2.new(0, 120, 0, 40)
    contentFrame.Size = UDim2.new(1, -120, 1, -40)
    contentFrame.BackgroundTransparency = 1

    local tabs = {}

    function Zaphire:CreateTab(tabData)
        local tab = {}
        local button = Instance.new("TextButton", tabContainer)
        button.Text = tabData.Name
        button.Size = UDim2.new(1, 0, 0, 35)
        button.BackgroundColor3 = theme.Accent
        button.TextColor3 = theme.Text
        button.Font = Enum.Font.Gotham
        button.TextSize = 16

        local tabPage = Instance.new("Frame", contentFrame)
        tabPage.Visible = false
        tabPage.Size = UDim2.new(1, 0, 1, 0)
        tabPage.BackgroundTransparency = 1

        button.MouseButton1Click:Connect(function()
            for _, t in ipairs(tabs) do
                t.Page.Visible = false
            end
            tabPage.Visible = true
        end)

        tab.Button = button
        tab.Page = tabPage
        table.insert(tabs, tab)

        return {
            CreateButton = function(_, text, callback)
                local btn = Instance.new("TextButton", tabPage)
                btn.Text = text
                btn.Size = UDim2.new(0, 200, 0, 30)
                btn.Position = UDim2.new(0, 10, 0, #tabPage:GetChildren() * 35)
                btn.BackgroundColor3 = theme.Accent
                btn.TextColor3 = theme.Text
                btn.Font = Enum.Font.Gotham
                btn.TextSize = 14
                btn.MouseButton1Click:Connect(callback)
                createUIStroke(btn)
            end,

            CreateToggle = function(_, text, default, callback)
                local toggle = Instance.new("TextButton", tabPage)
                toggle.Text = text .. ": " .. (default and "ON" or "OFF")
                toggle.Size = UDim2.new(0, 200, 0, 30)
                toggle.Position = UDim2.new(0, 10, 0, #tabPage:GetChildren() * 35)
                toggle.BackgroundColor3 = theme.Accent
                toggle.TextColor3 = theme.Text
                toggle.Font = Enum.Font.Gotham
                toggle.TextSize = 14

                local state = default
                toggle.MouseButton1Click:Connect(function()
                    state = not state
                    toggle.Text = text .. ": " .. (state and "ON" or "OFF")
                    callback(state)
                end)
                createUIStroke(toggle)
            end,

            CreateDropdown = function(_, label, options, callback)
                local dropdown = Instance.new("TextButton", tabPage)
                dropdown.Text = label .. ": " .. options[1]
                dropdown.Size = UDim2.new(0, 200, 0, 30)
                dropdown.Position = UDim2.new(0, 10, 0, #tabPage:GetChildren() * 35)
                dropdown.BackgroundColor3 = theme.Accent
                dropdown.TextColor3 = theme.Text
                dropdown.Font = Enum.Font.Gotham
                dropdown.TextSize = 14
                local index = 1
                dropdown.MouseButton1Click:Connect(function()
                    index = index + 1
                    if index > #options then index = 1 end
                    dropdown.Text = label .. ": " .. options[index]
                    callback(options[index])
                end)
                createUIStroke(dropdown)
            end,

            CreateSlider = function(_, label, min, max, default, callback)
                local value = default
                local slider = Instance.new("TextButton", tabPage)
                slider.Text = label .. ": " .. tostring(value)
                slider.Size = UDim2.new(0, 200, 0, 30)
                slider.Position = UDim2.new(0, 10, 0, #tabPage:GetChildren() * 35)
                slider.BackgroundColor3 = theme.Accent
                slider.TextColor3 = theme.Text
                slider.Font = Enum.Font.Gotham
                slider.TextSize = 14
                slider.MouseButton1Click:Connect(function()
                    value = value + 1
                    if value > max then value = min end
                    slider.Text = label .. ": " .. tostring(value)
                    callback(value)
                end)
                createUIStroke(slider)
            end,

            CreateColorPicker = function(_, label, default, callback)
                local button = Instance.new("TextButton", tabPage)
                button.Text = label
                button.Size = UDim2.new(0, 200, 0, 30)
                button.Position = UDim2.new(0, 10, 0, #tabPage:GetChildren() * 35)
                button.BackgroundColor3 = default
                button.TextColor3 = theme.Text
                button.Font = Enum.Font.Gotham
                button.TextSize = 14
                button.MouseButton1Click:Connect(function()
                    callback(button.BackgroundColor3)
                end)
                createUIStroke(button)
            end
        }
    end

    return Zaphire
end

return Zaphire
