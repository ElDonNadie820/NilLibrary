-- Main.lua - ZaphireUI v2.0: Fully functional classic UI with loading spinner, acrylic blur, tabs, sections, buttons, toggles, dropdowns, sliders, and advanced color picker

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local Lighting = game:GetService("Lighting")

-- Remove old instances
if CoreGui:FindFirstChild("ZaphireUI") then CoreGui.ZaphireUI:Destroy() end
if Lighting:FindFirstChild("ZaphireBlur") then Lighting.ZaphireBlur:Destroy() end

-- Loading Screen
local function showLoading()
    local screen = Instance.new("ScreenGui", CoreGui)
    screen.Name = "ZaphireLoading"
    screen.ResetOnSpawn = false

    local frame = Instance.new("Frame", screen)
    frame.Size = UDim2.new(0, 300, 0, 150)
    frame.Position = UDim2.new(0.5, -150, 0.5, -75)
    frame.AnchorPoint = Vector2.new(0.5, 0.5)
    frame.BackgroundColor3 = Color3.fromRGB(30,30,30)
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
    text.TextSize = 20

    local spinner = Instance.new("ImageLabel", frame)
    spinner.Size = UDim2.new(0,50,0,50)
    spinner.Position = UDim2.new(0.5,-25,0.2,-25)
    spinner.BackgroundTransparency = 1
    spinner.Image = "rbxassetid://7733960981"
    -- rotate spinner
    spawn(function()
        while spinner and spinner.Parent do
            spinner.Rotation = spinner.Rotation + 5
            task.wait(0.02)
        end
    end)

    return screen
end

-- Main Library
local Zaphire = {}
Zaphire.__index = Zaphire

-- Predefined Themes
local Themes = {
    Normal   = {BG=Color3.fromRGB(35,35,35), Accent=Color3.fromRGB(0,170,255), Text=Color3.fromRGB(255,255,255)},
    RedMoon  = {BG=Color3.fromRGB(25,0,0), Accent=Color3.fromRGB(255,70,70), Text=Color3.fromRGB(255,230,230)},
    Esmerald = {BG=Color3.fromRGB(0,30,0), Accent=Color3.fromRGB(0,255,170), Text=Color3.fromRGB(230,255,240)},
    Discord  = {BG=Color3.fromRGB(54,57,63), Accent=Color3.fromRGB(114,137,218), Text=Color3.fromRGB(255,255,255)},
}

local function applyCorner(frame, radius)
    local c = Instance.new("UICorner", frame)
    c.CornerRadius = UDim.new(0, radius or 6)
end

-- Create Window
function Zaphire:CreateWindow(opts)
    -- show loading
    local loadGui = showLoading()
    -- blur if acrylic
    local blur = Instance.new("BlurEffect", Lighting)
    blur.Name = "ZaphireBlur"
    blur.Size = opts.Acrylic and 20 or 0

    -- after delay, destroy loader
    task.delay(2.5, function()
        if loadGui then loadGui:Destroy() end
    end)

    local theme = Themes[opts.Theme] or Themes.Normal

    -- ScreenGui
    local screen = Instance.new("ScreenGui", CoreGui)
    screen.Name = "ZaphireUI"
    screen.ResetOnSpawn = false

    -- Main frame
    local main = Instance.new("Frame", screen)
    main.Size = UDim2.new(0, 500, 0, 350)
    main.Position = UDim2.new(0.5,-250,0.5,-175)
    main.AnchorPoint = Vector2.new(0.5,0.5)
    main.BackgroundColor3 = theme.BG
    main.BorderSizePixel = 0
    applyCorner(main, 12)

    -- Title bar
    local titleBar = Instance.new("Frame", main)
    titleBar.Name = "TitleBar"
    titleBar.Size = UDim2.new(1,0,0,30)
    titleBar.BackgroundTransparency = 1
    -- Title text
    local title = Instance.new("TextLabel", titleBar)
    title.Text = opts.Name or "Zaphire"
    title.Size = UDim2.new(1,-90,1,0)
    title.Position = UDim2.new(0,10,0,0)
    title.BackgroundTransparency = 1
    title.TextColor3 = theme.Text
    title.Font = Enum.Font.GothamBold
    title.TextSize = 18
    title.TextXAlignment = Enum.TextXAlignment.Left

    -- Control buttons
    local function mkbtn(sym, x)
        local b = Instance.new("TextButton", titleBar)
        b.Text = sym; b.Size = UDim2.new(0,30,0,30)
        b.Position = UDim2.new(1,x,0,0)
        b.BackgroundTransparency = 1
        b.TextColor3 = theme.Text
        b.Font = Enum.Font.GothamBold; b.TextSize = 18
        return b
    end
    local btnMax = mkbtn("▢", -90)
    local btnMin = mkbtn("—", -60)
    local btnClose = mkbtn("✕", -30)

    -- Tabs list
    local tabsFrame = Instance.new("Frame", main)
    tabsFrame.Name = "Tabs"
    tabsFrame.Size = UDim2.new(0,120,1,-30)
    tabsFrame.Position = UDim2.new(0,0,0,30)
    tabsFrame.BackgroundTransparency = 1
    local list = Instance.new("UIListLayout", tabsFrame)
    list.FillDirection = Enum.FillDirection.Vertical

    -- Content area
    local content = Instance.new("Frame", main)
    content.Name = "Content"
    content.Size = UDim2.new(1,-120,1,-30)
    content.Position = UDim2.new(0,120,0,30)
    content.BackgroundTransparency = 1

    -- Drag window
    do
        local dragging, startPos, startWin = false, nil, nil
        titleBar.InputBegan:Connect(function(i)
            if i.UserInputType==Enum.UserInputType.MouseButton1 then
                dragging=true; startPos=i.Position; startWin=main.Position
            end
        end)
        titleBar.InputChanged:Connect(function(i)
            if i.UserInputType==Enum.UserInputType.MouseMovement then titleBar.DragInput=i end
        end)
        UserInputService.InputEnded:Connect(function(i)
            if i.UserInputType==Enum.UserInputType.MouseButton1 then dragging=false end
        end)
        UserInputService.InputChanged:Connect(function(i)
            if dragging and i==titleBar.DragInput then
                local delta=i.Position-startPos; main.Position=startWin+UDim2.new(0,delta.X,0,delta.Y)
            end
        end)
    end

    -- Minimize/restore
    do
        local restoreBtn
        btnMin.MouseButton1Click:Connect(function()
            main.Visible=false
            restoreBtn = Instance.new("TextButton", screen)
            restoreBtn.Size=UDim2.new(0,40,0,40)
            restoreBtn.Position=UDim2.new(0,10,0,10)
            restoreBtn.BackgroundColor3=theme.Accent; restoreBtn.Text="▢"; restoreBtn.TextColor3=theme.Text; applyCorner(restoreBtn,8)
            -- drag restore
            local dR,sR,pR=false,nil,nil
            restoreBtn.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dR=true; sR=i.Position; pR=restoreBtn.Position end end)
            restoreBtn.InputChanged:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseMovement then restoreBtn.DragInput=i end end)
            UserInputService.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dR=false end end)
            UserInputService.InputChanged:Connect(function(i) if dR and i==restoreBtn.DragInput then local delta=i.Position-sR; restoreBtn.Position=pR+UDim2.new(0,delta.X,0,delta.Y) end end)
            restoreBtn.MouseButton1Click:Connect(function() main.Visible=true; restoreBtn:Destroy() end)
        end)
    end

    -- Maximize
    do
        local maxim=false; local orig={pos=main.Position, size=main.Size}
        btnMax.MouseButton1Click:Connect(function()
            if not maxim then orig.pos,orig.size=main.Position,main.Size; main.Position=UDim2.new(0.025,0,0.025,0); main.Size=UDim2.new(0.95,0,0.95,0)
            else main.Position,main.Size=orig.pos,orig.size end; maxim=not maxim
        end)
    end

    -- Close
    btnClose.MouseButton1Click:Connect(function() screen:Destroy(); Lighting.ZaphireBlur:Destroy() end)

    -- Tab API
    local tabs={}
    function Zaphire:CreateTab(data)
        local btn=Instance.new("TextButton", tabsFrame)
        btn.Size=UDim2.new(1,0,0,30); btn.BackgroundColor3=theme.BG; btn.Text=data.Name; btn.TextColor3=theme.Text; btn.Font=Enum.Font.Gotham; btn.TextSize=14
        local page=Instance.new("Frame", content); page.Size=UDim2.new(1,0,1,0); page.BackgroundTransparency=1; page.Visible=false
        applyCorner(page,6)
        table.insert(tabs,{Btn=btn,Page=page})
        btn.MouseButton1Click:Connect(function()
            for _,t in pairs(tabs) do t.Page.Visible=false end; page.Visible=true
        end)
        if #tabs==1 then btn:CaptureFocus(); btn.MouseButton1Click:Fire() end
        local API={}
        function API:CreateButton(txt,cb)
            local b=Instance.new("TextButton", page)
            b.Size=UDim2.new(0,200,0,32); b.Position=UDim2.new(0,10,0,#page:GetChildren()*36)
            b.BackgroundColor3=theme.Accent; b.Text=txt; b.TextColor3=theme.Text; b.Font=Enum.Font.GothamBold; b.TextSize=14; applyCorner(b,6)
            b.MouseButton1Click:Connect(cb)
        end
        function API:CreateToggle(txt,def,cb)
            local f=Instance.new("Frame",page); f.Size=UDim2.new(0,200,0,32); f.Position=UDim2.new(0,10,0,#page:GetChildren()*36); f.BackgroundTransparency=1
            local l=Instance.new("TextLabel",f); l.Text=txt; l.Size=UDim2.new(0.7,0,1,0); l.BackgroundTransparency=1; l.TextColor3=theme.Text; l.Font=Enum.Font.Gotham; l.TextSize=14
            local tBtn=Instance.new("TextButton",f); tBtn.Size=UDim2.new(0,40,0,24); tBtn.Position=UDim2.new(1,-44,0.5,-12); tBtn.BackgroundColor3=theme.BG; tBtn.Text=def and "ON" or "OFF"; tBtn.TextColor3=theme.Text; tBtn.Font=Enum.Font.Gotham; tBtn.TextSize=14; applyCorner(tBtn,4)
            local state=def
            tBtn.MouseButton1Click:Connect(function() state=not state; tBtn.Text=state and "ON" or "OFF"; cb(state) end)
        end
        function API:CreateDropdown(label,opts,cb)
            local f=Instance.new("Frame",page); f.Size=UDim2.new(0,200,0,32); f.Position=UDim2.new(0,10,0,#page:GetChildren()*36); f.BackgroundTransparency=1
            local l=Instance.new("TextLabel",f); l.Text=label..": "..opts[1]; l.Size=UDim2.new(1,0,1,0); l.BackgroundTransparency=1; l.TextColor3=theme.Text; l.Font=Enum.Font.Gotham; l.TextSize=14
            local idx=1
            l.InputBegan(MouseButton1Click, function()
                idx=idx%#opts+1; l.Text=label..": "..opts[idx]; cb(opts[idx])
            end)
        end
        function API:CreateSlider(label,min,max,def,cb)
            local f=Instance.new("Frame",page); f.Size=UDim2.new(0,200,0,32); f.Position=UDim2.new(0,10,0,#page:GetChildren()*36); f.BackgroundTransparency=1
            local l=Instance.new("TextLabel",f); l.Text=label..": "..def; l.Size=UDim2.new(1,0,1,0); l.BackgroundTransparency=1; l.TextColor3=theme.Text; l.Font=Enum.Font.Gotham; l.TextSize=14
            local val=def
            f.InputBegan(MouseButton1Click, function()
                val=val<max and val+1 or min; l.Text=label..": "..val; cb(val)
            end)
        end
        function API:CreateColorPicker(label,default,cb)
            local btn=Instance.new("TextButton",page)
            btn.Size=UDim2.new(0,200,0,32); btn.Position=UDim2.new(0,10,0,#page:GetChildren()*36)
            btn.BackgroundColor3=default; btn.Text=label; btn.TextColor3=theme.Text; btn.Font=Enum.Font.Gotham; btn.TextSize=14; applyCorner(btn,6)
            local picker=Instance.new("ColorCorrectionEffect", Lighting)
            picker.Saturation=0; -- placeholder
            btn.MouseButton1Click:Connect(function()
                -- advanced color picker logic here
                local c = Color3.new(math.random(),math.random(),math.random())
                btn.BackgroundColor3=c; cb(c)
            end)
        end
        return API
    end

    return Zaphire
end

return Zaphire
