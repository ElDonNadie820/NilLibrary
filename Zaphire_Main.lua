
-- Zaphire UI Library

local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Remove existing instance if reloading
if CoreGui:FindFirstChild("ZaphireUI") then
    CoreGui.ZaphireUI:Destroy()
end

-- ScreenGui base
local ZaphireUI = Instance.new("ScreenGui")
ZaphireUI.Name = "ZaphireUI"
ZaphireUI.Parent = CoreGui
ZaphireUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ZaphireUI.ResetOnSpawn = false

-- Blur effect (acrylic style)
local BlurEffect = Instance.new("BlurEffect")
BlurEffect.Size = 0
BlurEffect.Parent = game:GetService("Lighting")

-- Loading Screen
local LoadingFrame = Instance.new("Frame")
LoadingFrame.Name = "LoadingFrame"
LoadingFrame.Size = UDim2.new(0, 300, 0, 150)
LoadingFrame.Position = UDim2.new(0.5, -150, 0.5, -75)
LoadingFrame.AnchorPoint = Vector2.new(0.5, 0.5)
LoadingFrame.BackgroundTransparency = 0.2
LoadingFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
LoadingFrame.BorderSizePixel = 0
LoadingFrame.Parent = ZaphireUI

local UICorner = Instance.new("UICorner", LoadingFrame)
UICorner.CornerRadius = UDim.new(0, 16)

local TextLabel = Instance.new("TextLabel")
TextLabel.Name = "LoadingText"
TextLabel.Size = UDim2.new(1, 0, 0.3, 0)
TextLabel.Position = UDim2.new(0, 0, 0.6, 0)
TextLabel.BackgroundTransparency = 1
TextLabel.Text = "Loading Zaphire..."
TextLabel.Font = Enum.Font.GothamBold
TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TextLabel.TextScaled = true
TextLabel.Parent = LoadingFrame

local Spinner = Instance.new("ImageLabel")
Spinner.Name = "Spinner"
Spinner.Size = UDim2.new(0, 50, 0, 50)
Spinner.Position = UDim2.new(0.5, -25, 0.2, -25)
Spinner.BackgroundTransparency = 1
Spinner.Image = "rbxassetid://7733960981"
Spinner.Parent = LoadingFrame

-- Rotation animation for spinner
spawn(function()
    while true do
        Spinner.Rotation = Spinner.Rotation + 5
        task.wait(0.02)
    end
end)

-- Simulate loading and then remove loading screen
task.delay(3, function()
    LoadingFrame:Destroy()
    BlurEffect:Destroy()
end)

-- Example API for testing
local Zaphire = {}

function Zaphire:CreateWindow(opts)
    opts = opts or {}
    local theme = opts.Theme or "Normal"
    local acrylic = opts.Acrylic or false

    if acrylic then
        BlurEffect.Size = 20
    end

    -- Window frame
    local Window = Instance.new("Frame")
    Window.Size = UDim2.new(0, 450, 0, 300)
    Window.Position = UDim2.new(0.5, -225, 0.5, -150)
    Window.AnchorPoint = Vector2.new(0.5, 0.5)
    Window.BackgroundTransparency = 0
    Window.BackgroundColor3 = theme == "Normal" and Color3.fromRGB(35, 35, 35) or Color3.fromRGB(60, 60, 90)
    Window.BorderSizePixel = 0
    Window.Parent = ZaphireUI

    local corner = Instance.new("UICorner", Window)
    corner.CornerRadius = UDim.new(0, 12)

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 40)
    title.BackgroundTransparency = 1
    title.Text = opts.Name or "Zaphire Window"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 20
    title.Parent = Window

    return {
        CreateTab = function(self, data)
            local tab = Instance.new("Frame")
            tab.Name = data.Name or "Tab"
            tab.Size = UDim2.new(1, 0, 1, -40)
            tab.Position = UDim2.new(0, 0, 0, 40)
            tab.BackgroundTransparency = 1
            tab.Parent = Window
            return tab
        end,
        CreateButton = function(_, parent, text, callback)
            local button = Instance.new("TextButton")
            button.Size = UDim2.new(0, 200, 0, 40)
            button.Position = UDim2.new(0, 20, 0, 60)
            button.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
            button.Text = text
            button.Font = Enum.Font.Gotham
            button.TextColor3 = Color3.fromRGB(255, 255, 255)
            button.TextSize = 16
            button.Parent = parent

            local corner = Instance.new("UICorner", button)
            corner.CornerRadius = UDim.new(0, 8)

            button.MouseButton1Click:Connect(function()
                pcall(callback)
            end)
        end
    }
end

return Zaphire
