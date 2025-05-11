-- Zaphire UI Library (v2.1) - Adjusted size/position and latest raw URL

-- Constants
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local Lighting = game:GetService("Lighting")

-- Clean up old instances
if CoreGui:FindFirstChild("ZaphireUI") then CoreGui.ZaphireUI:Destroy() end
if CoreGui:FindFirstChild("ZaphireLoading") then CoreGui.ZaphireLoading:Destroy() end
if Lighting:FindFirstChild("ZaphireBlur") then Lighting.ZaphireBlur:Destroy() end

-- Loading Screen
local function showLoading()
    local screen = Instance.new("ScreenGui", CoreGui)
    screen.Name = "ZaphireLoading"
    screen.ResetOnSpawn = false

    local frame = Instance.new("Frame", screen)
    frame.Size = UDim2.new(0, 250, 0, 120)
    frame.Position = UDim2.new(0.5, -125, 0.5, -60)
    frame.AnchorPoint = Vector2.new(0.5, 0.5)
    frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    frame.BorderSizePixel = 0
    local corner = Instance.new("UICorner", frame)
    corner.CornerRadius = UDim.new(0, 12)

    local text = Instance.new("TextLabel", frame)
    text.Size = UDim2.new(1,0,0.4,0)
    text.Position = UDim2.new(0,0,0.6,0)
    text.BackgroundTransparency = 1
    text.Text = "Loading Zaphire..."
    text.TextColor3 = Color3.fromRGB(255,255,255)
    text.Font = Enum.Font.GothamBold
    text.TextSize = 18

    local spinner = Instance.new("ImageLabel", frame)
    spinner.Size = UDim2.new(0,40,0,40)
    spinner.Position = UDim2.new(0.5,-20,0.2,-20)
    spinner.BackgroundTransparency = 1
    spinner.Image = "rbxassetid://7733960981"
    spawn(function()
        while spinner and spinner.Parent do
            spinner.Rotation = spinner.Rotation + 6
            task.wait(0.02)
        end
    end)

    return screen
end

-- Predefined themes
local Themes = {
    Normal   = { BG=Color3.fromRGB(35,35,35), Accent=Color3.fromRGB(0,170,255), Text=Color3.fromRGB(255,255,255) },
    RedMoon  = { BG=Color3.fromRGB(25,0,0), Accent=Color3.fromRGB(255,70,70), Text=Color3.fromRGB(255,230,230) },
    Esmerald = { BG=Color3.fromRGB(0,30,0), Accent=Color3.fromRGB(0,255,170), Text=Color3.fromRGB(230,255,240) },
    Discord  = { BG=Color3.fromRGB(54,57,63), Accent=Color3.fromRGB(114,137,218), Text=Color3.fromRGB(255,255,255) },
}

local function applyCorner(obj, radius)
    local c = Instance.new("UICorner", obj)
    c.CornerRadius = UDim.new(0, radius or 6)
end

-- Main library table
local Zaphire = {}
Zaphire.__index = Zaphire

-- Create window
function Zaphire:CreateWindow(opts)
    -- show loader
    local loadScreen = showLoading()
    -- blur
    local blur = Instance.new("BlurEffect", Lighting)
    blur.Name = "ZaphireBlur"
    blur.Size = opts.Acrylic and 20 or 0

    -- remove loader after delay
    task.delay(2.5, function()
        if loadScreen then loadScreen:Destroy() end
    end)

    local theme = Themes[opts.Theme] or Themes.Normal

    -- base ScreenGui
    local screen = Instance.new("ScreenGui", CoreGui)
    screen.Name = "ZaphireUI"
    screen.ResetOnSpawn = false

    -- main frame
    local main = Instance.new("Frame", screen)
    main.Name = "MainWindow"
    main.Size = UDim2.new(0, 460, 0, 320)
    main.Position = UDim2.new(0.5, -230, 0.5, -160)
    main.AnchorPoint = Vector2.new(0.5, 0.5)
    main.BackgroundColor3 = theme.BG
    main.BorderSizePixel = 0
    applyCorner(main, 12)

    -- title bar
    local titleBar = Instance.new("Frame", main)
    titleBar.Name = "TitleBar"
    titleBar.Size = UDim2.new(1,0,0,32)
    titleBar.BackgroundTransparency = 1

    local title = Instance.new("TextLabel", titleBar)
    title.Text = opts.Name or "Zaphire"
    title.Size = UDim2.new(1,-96,1,0)
    title.Position = UDim2.new(0,8,0,0)
    title.BackgroundTransparency = 1
    title.TextColor3 = theme.Text
    title.Font = Enum.Font.GothamBold
    title.TextSize = 18
    title.TextXAlignment = Enum.TextXAlignment.Left

    -- control buttons
    local function mkBtn(sym, xOff)
        local b = Instance.new("TextButton", titleBar)
        b.Text = sym; b.Size = UDim2.new(0,28,0,28)
        b.Position = UDim2.new(1, xOff, 0, 2)
        b.BackgroundTransparency = 1
        b.TextColor3 = theme.Text
        b.Font = Enum.Font.GothamBold; b.TextSize = 18
        return b
    end
    local btnMax = mkBtn("▢", -96)
    local btnMin = mkBtn("—", -64)
    local btnClose = mkBtn("✕", -32)

    -- tabs container
    local tabsFrame = Instance.new("Frame", main)
    tabsFrame.Name = "Tabs"
    tabsFrame.Size = UDim2.new(0, 120, 1, -32)
    tabsFrame.Position = UDim2.new(0, 0, 0, 32)
    tabsFrame.BackgroundTransparency = 1
    local tabLayout = Instance.new("UIListLayout", tabsFrame)
    tabLayout.FillDirection = Enum.FillDirection.Vertical

    -- content container
    local content = Instance.new("Frame", main)
    content.Name = "Content"
    content.Size = UDim2.new(1, -120, 1, -32)
    content.Position = UDim2.new(0, 120, 0, 32)
    content.BackgroundTransparency = 1

    -- dragging logic
    do
        local dragging, sPos, wPos = false, nil, nil
        titleBar.InputBegan:Connect(function(inp)
            if inp.UserInputType==Enum.UserInputType.MouseButton1 then
                dragging=true; sPos=inp.Position; wPos=main.Position
            end
        end)
        titleBar.InputChanged:Connect(function(inp)
            if inp.UserInputType==Enum.UserInputType.MouseMovement then titleBar.DragInput=inp end
        end)
        UserInputService.InputEnded:Connect(function(inp)
            if inp.UserInputType==Enum.UserInputType.MouseButton1 then dragging=false end
        end)
        UserInputService.InputChanged:Connect(function(inp)
            if dragging and inp==titleBar.DragInput then
                local delta=inp.Position - sPos
                main.Position = wPos + UDim2.new(0,delta.X,0,delta.Y)
            end
        end)
    end

    -- minimize/restore
    do
        local restoreBtn
        btnMin.MouseButton1Click:Connect(function()
            main.Visible=false
            restoreBtn = Instance.new("TextButton", screen)
            restoreBtn.Size = UDim2.new(0,36,0,36)
            restoreBtn.Position = UDim2.new(0,8,0,8)
            restoreBtn.BackgroundColor3 = theme.Accent
            restoreBtn.Text = "▢"
            restoreBtn.TextColor3 = theme.Text
            applyCorner(restoreBtn, 8)

            local dR, sR, pR = false, nil, nil
            restoreBtn.InputBegan:Connect(function(inp)
                if inp.UserInputType==Enum.UserInputType.MouseButton1 then
                    dR=true; sR=inp.Position; pR=restoreBtn.Position
                end
            end)
            restoreBtn.InputChanged:Connect(function(inp)
                if inp.UserInputType==Enum.UserInputType.MouseMovement then restoreBtn.DragInput=inp end
            end)
            UserInputService.InputEnded:Connect(function(inp)
                if inp.UserInputType==Enum.UserInputType.MouseButton1 then dR=false end
            end)
            UserInputService.InputChanged:Connect(function(inp)
                if dR and inp==restoreBtn.DragInput then
                    local d=inp.Position - sR
                    restoreBtn.Position = pR + UDim2.new(0,d.X,0,d.Y)
                end
            end)
            restoreBtn.MouseButton1Click:Connect(function()
                main.Visible=true; restoreBtn:Destroy()
            end)
        end)
    end

    -- maximize
    do
        local maxim=false; local orig={pos=main.Position, size=main.Size}
        btnMax.MouseButton1Click:Connect(function()
            if not maxim then orig.pos,orig.size=main.Position,main.Size; main.Position=UDim2.new(0.5,-orig.size.X.Offset/2,0.5,-orig.size.Y.Offset/2); main.Size=UDim2.new(0.95,0,0.95,0)
            else main.Position,main.Size=orig.pos,orig.size end; maxim=not maxim
        end)
    end

    -- close
    btnClose.MouseButton1Click:Connect(function()
        screen:Destroy(); Lighting:FindFirstChild("ZaphireBlur"):Destroy()
    end)

    -- tab API
    local tabs = {}
    function Zaphire:CreateTab(data)
        local btn = Instance.new("TextButton", tabsFrame)
        btn.Size = UDim2.new(1,0,0,30)
        btn.BackgroundColor3 = theme.BG
        btn.Text = data.Name
        btn.TextColor3 = theme.Text
        btn.Font = Enum.Font.Gotham
        btn.TextSize = 14

        local page = Instance.new("Frame", content)
        page.Size = UDim2.new(1,0,1,0)
        page.BackgroundTransparency = 1
        page.Visible = false
        applyCorner(page, 6)
        local layout = Instance.new("UIListLayout", page)
        layout.Padding = UDim.new(0,6)

        table.insert(tabs,{Btn=btn,Page=page})
        btn.MouseButton1Click:Connect(function()
            for _,t in pairs(tabs) do t.Page.Visible=false end; page.Visible=true
        end)
        if #tabs==1 then btn:CaptureFocus(); btn.MouseButton1Click:Fire() end

        local api = {}
        function api:CreateButton(text,cb)
            local b = Instance.new("TextButton", page)
            b.Size = UDim2.new(1,-10,0,32)
            b.Position = UDim2.new(0,5,0,#page:GetChildren()*36)
            b.BackgroundColor3 = theme.Accent; b.Text=text; b.TextColor3=theme.Text
            b.Font = Enum.Font.GothamBold; b.TextSize=14
            applyCorner(b,6)
            b.MouseButton1Click:Connect(cb)
        end
        function api:CreateToggle(text,def,cb)
            local f=Instance.new("Frame",page)
            f.Size=UDim2.new(1,-10,0,32); f.Position=UDim2.new(0,5,0,#page:GetChildren()*36)
            f.BackgroundTransparency=1
            local lbl=Instance.new("TextLabel",f)
            lbl.Text=text; lbl.Size=UDim2.new(0.7,0,1,0)
            lbl.BackgroundTransparency=1; lbl.TextColor3=theme.Text; lbl.Font=Enum.Font.Gotham; lbl.TextSize=14
            local tBtn=Instance.new("TextButton",f)
            tBtn.Size=UDim2.new(0,50,0,24); tBtn.Position=UDim2.new(1,-55,0.5,-12)
            tBtn.BackgroundColor3=theme.Accent; tBtn.Text=def and "ON" or "OFF"; tBtn.TextColor3=theme.Text
            tBtn.Font=Enum.Font.Gotham; tBtn.TextSize=14; applyCorner(tBtn,4)
            local st=def
            tBtn.MouseButton1Click:Connect(function()
                st=not st; tBtn.Text=st and "ON" or "OFF"; cb(st)
            end)
        end
        function api:CreateDropdown(label,opts,cb)
            local f=Instance.new("Frame",page)
            f.Size=UDim2.new(1,-10,0,32); f.Position=UDim2.new(0,5,0,#page:GetChildren()*36)
            f.BackgroundTransparency=1
            local lbl=Instance.new("TextLabel",f)
            lbl.Text=label..": "..opts[1]; lbl.Size=UDim2.new(1,0,1,0)
            lbl.BackgroundTransparency=1; lbl.TextColor3=theme.Text; lbl.Font=Enum.Font.Gotham; lbl.TextSize=14
            local idx=1
            f.InputBegan:Connect(function(inp)
                if inp.UserInputType==Enum.UserInputType.MouseButton1 then
                    idx=idx%#opts+1; lbl.Text=label..": "..opts[idx]; cb(opts[idx])
                end
            end)
        end
        function api:CreateSlider(label,min,max,def,cb)
            local f=Instance.new("Frame",page)
            f.Size=UDim2.new(1,-10,0,32); f.Position=UDim2.new(0,5,0,#page:GetChildren()*36)
            f.BackgroundTransparency=1
            local lbl=Instance.new("TextLabel",f)
            lbl.Text=label..": "..def; lbl.Size=UDim2.new(1,0,1,0)
            lbl.BackgroundTransparency=1; lbl.TextColor3=theme.Text; lbl.Font=Enum.Font.Gotham; lbl.TextSize=14
            local val=def
            f.InputBegan:Connect(function(inp)
                if inp.UserInputType==Enum.UserInputType.MouseButton1 then
                    val=val<max and val+1 or min; lbl.Text=label..": "..val; cb(val)
                end
            end)
        end
        function api:CreateColorPicker(label,default,cb)
            local btn=Instance.new("TextButton",page)
            btn.Size=UDim2.new(1,-10,0,32); btn.Position=UDim2.new(0,5,0,#page:GetChildren()*36)
            btn.BackgroundColor3=default; btn.Text=label; btn.TextColor3=theme.Text; btn.Font=Enum.Font.Gotham; btn.TextSize=14; applyCorner(btn,6)
            btn.MouseButton1Click:Connect(function()
                -- Advanced color picker placeholder
                local newColor=Color3.new(math.random(),math.random(),math.random())
                btn.BackgroundColor3=newColor; cb(newColor)
            end)
        end
        return api
    end

    return Zaphire
end

return Zaphire
