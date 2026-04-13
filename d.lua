-- =============================================
-- FLUX UI LIBRARY (PlayerGui Version)
-- =============================================
local FluxUI = {}
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Visual Configuration
local Theme = {
    Background = Color3.fromRGB(15, 15, 18),
    Header = Color3.fromRGB(22, 22, 27),
    Card = Color3.fromRGB(30, 30, 35),
    Accent = Color3.fromRGB(0, 255, 128), -- Neon Green
    Text = Color3.fromRGB(240, 240, 240),
    TextDim = Color3.fromRGB(120, 120, 120),
    ToggleOff = Color3.fromRGB(50, 50, 55)
}

-- Helper: Safe Instance Creation
local function Create(cls, props)
    local obj = Instance.new(cls)
    for k, v in pairs(props) do
        if k == "Parent" then
            obj.Parent = v
        elseif k == "CornerRadius" then
            local corner = Instance.new("UICorner", obj)
            corner.CornerRadius = v
        elseif k == "Stroke" then
            local stroke = Instance.new("UIStroke", obj)
            stroke.Color = v.Color
            stroke.Thickness = v.Thickness or 1
        elseif k == "Padding" then
            local pad = Instance.new("UIPadding", obj)
            pad.PaddingTop = v.Top or UDim.new(0,0)
            pad.PaddingBottom = v.Bottom or UDim.new(0,0)
            pad.PaddingLeft = v.Left or UDim.new(0,0)
            pad.PaddingRight = v.Right or UDim.new(0,0)
        elseif typeof(v) == "Color3" or typeof(v) == "UDim2" or typeof(v) == "UDim" then
            obj[k] = v
        else
            obj[k] = v
        end
    end
    return obj
end

-- ============================================
-- WINDOW SYSTEM
-- ============================================
function FluxUI:Window(windowConfig)
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "FluxUI"
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.Parent = PlayerGui

    local MainFrame = Create("Frame", {
        Name = "Window",
        BackgroundColor3 = Theme.Background,
        Size = UDim2.new(0, 550, 0, 400),
        Position = UDim2.new(0.5, -275, 0.5, -200),
        Parent = ScreenGui,
        CornerRadius = UDim.new(0, 12)
    })
    
    Create("UIStroke", {
        Color = Theme.Accent,
        Thickness = 1.5,
        Parent = MainFrame
    })

    local dragToggle, dragInput, dragStart, startPos
    MainFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragToggle = true
            dragStart = input.Position
            startPos = MainFrame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragToggle = false
                end
            end)
        end
    end)
    MainFrame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement and dragToggle then
            local delta = input.Position - dragStart
            MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    local TopBar = Create("Frame", {
        Name = "TopBar",
        BackgroundColor3 = Theme.Header,
        Size = UDim2.new(1, 0, 0, 40),
        Parent = MainFrame,
        CornerRadius = UDim.new(0, 12)
    })
    local TopBarCover = Create("Frame", {
        BackgroundColor3 = Theme.Header,
        Size = UDim2.new(1, 0, 0.5, 0),
        Position = UDim2.new(0, 0, 0.5, 0),
        BorderSizePixel = 0,
        Parent = TopBar
    })

    Create("TextLabel", {
        Text = windowConfig.Name,
        TextColor3 = Theme.Accent,
        TextSize = 18,
        Font = Enum.Font.GothamBold,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -40, 1, 0),
        Position = UDim2.new(0, 15, 0, 0),
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = TopBar
    })

    local ContentFrame = Create("ScrollingFrame", {
        Name = "Content",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, -40),
        Position = UDim2.new(0, 0, 0, 40),
        ScrollBarThickness = 4,
        ScrollBarImageColor3 = Theme.Accent,
        Parent = MainFrame
    })
    local ContentList = Create("UIListLayout", {
        Padding = UDim.new(0, 10),
        Parent = ContentFrame
    })
    Create("UIPadding", {
        PaddingTop = UDim.new(0, 10),
        PaddingLeft = UDim.new(0, 10),
        PaddingRight = UDim.new(0, 10),
        PaddingBottom = UDim.new(0, 10),
        Parent = ContentFrame
    })

    local WindowObj = { Tabs = {} }

    function WindowObj:Tab(tabName)
        local TabBtn = Create("TextButton", {
            Text = tabName,
            TextColor3 = Theme.TextDim,
            TextSize = 14,
            Font = Enum.Font.Gotham,
            BackgroundTransparency = 1,
            Size = UDim2.new(0, 100, 1, 0),
            Parent = TopBar
        })
        
        local Page = Create("Frame", {
            Name = tabName.."Page",
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 0),
            Parent = ContentFrame,
            Visible = false
        })
        local PageList = Create("UIListLayout", {
            Padding = UDim.new(0, 10),
            Parent = Page
        })

        TabBtn.MouseButton1Click:Connect(function()
            for _, tabData in pairs(WindowObj.Tabs) do
                tabData.Page.Visible = false
                tabData.Button.TextColor3 = Theme.TextDim
            end
            Page.Visible = true
            TabBtn.TextColor3 = Theme.Accent
            Page.Size = UDim2.new(1, 0, 0, PageList.AbsoluteContentSize.Y + 10)
        end)

        if #WindowObj.Tabs == 0 then
            Page.Visible = true
            TabBtn.TextColor3 = Theme.Accent
            task.wait()
            Page.Size = UDim2.new(1, 0, 0, PageList.AbsoluteContentSize.Y + 10)
        end

        table.insert(WindowObj.Tabs, {Button = TabBtn, Page = Page})
        local TabObj = {}

        function TabObj:Card(cardTitle)
            local Card = Create("Frame", {
                BackgroundColor3 = Theme.Card,
                Size = UDim2.new(1, 0, 0, 30),
                Parent = Page,
                CornerRadius = UDim.new(0, 8)
            })
            Create("UIStroke", {
                Color = Color3.fromRGB(60, 60, 65),
                Thickness = 1,
                Parent = Card
            })
            Create("UIPadding", {
                PaddingTop = UDim.new(0, 10),
                PaddingLeft = UDim.new(0, 10),
                PaddingRight = UDim.new(0, 10),
                PaddingBottom = UDim.new(0, 10),
                Parent = Card
            })
            
            if cardTitle then
                Create("TextLabel", {
                    Text = cardTitle,
                    TextColor3 = Theme.Text,
                    TextSize = 15,
                    Font = Enum.Font.GothamBold,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 20),
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = Card
                })
            end

            local CardLayout = Create("UIListLayout", {
                Padding = UDim.new(0, 8),
                Parent = Card
            })

            local function updateCardSize()
                Card.Size = UDim2.new(1, 0, 0, CardLayout.AbsoluteContentSize.Y + (cardTitle and 20 or 0))
            end
            CardLayout.Changed:Connect(updateCardSize)

            local CardObj = {}

            function CardObj:Label(text)
                Create("TextLabel", {
                    Text = text,
                    TextColor3 = Theme.TextDim,
                    TextSize = 13,
                    Font = Enum.Font.Gotham,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 15),
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextWrapped = true,
                    Parent = Card
                })
                updateCardSize()
            end

            function CardObj:Button(btnConfig)
                local Btn = Create("TextButton", {
                    Text = btnConfig.Name,
                    TextColor3 = Color3.fromRGB(0,0,0),
                    TextSize = 14,
                    Font = Enum.Font.GothamBold,
                    BackgroundColor3 = Theme.Accent,
                    Size = UDim2.new(1, 0, 0, 28),
                    Parent = Card,
                    CornerRadius = UDim.new(0, 6)
                })
                Btn.MouseButton1Click:Connect(function() pcall(btnConfig.Callback) end)
                updateCardSize()
            end

            function CardObj:Toggle(togConfig)
                local Container = Create("Frame", {
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 25),
                    Parent = Card
                })
                Create("TextLabel", {
                    Text = togConfig.Name,
                    TextColor3 = Theme.Text,
                    TextSize = 14,
                    Font = Enum.Font.Gotham,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, -50, 1, 0),
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = Container
                })
                local Pill = Create("Frame", {
                    BackgroundColor3 = Theme.ToggleOff,
                    Size = UDim2.new(0, 40, 0, 20),
                    Position = UDim2.new(1, -40, 0.5, -10),
                    Parent = Container,
                    CornerRadius = UDim.new(0, 10)
                })
                local Knob = Create("Frame", {
                    BackgroundColor3 = Color3.fromRGB(200, 200, 200),
                    Size = UDim2.new(0, 16, 0, 16),
                    Position = UDim2.new(0, 2, 0.5, -8),
                    Parent = Pill,
                    CornerRadius = UDim.new(0, 8)
                })
                local function setState(state)
                    togConfig.CurrentValue = state
                    if state then
                        TweenService:Create(Pill, TweenInfo.new(0.2), {BackgroundColor3 = Theme.Accent}):Play()
                        TweenService:Create(Knob, TweenInfo.new(0.2), {Position = UDim2.new(1, -18, 0.5, -8), BackgroundColor3 = Color3.fromRGB(255,255,255)}):Play()
                    else
                        TweenService:Create(Pill, TweenInfo.new(0.2), {BackgroundColor3 = Theme.ToggleOff}):Play()
                        TweenService:Create(Knob, TweenInfo.new(0.2), {Position = UDim2.new(0, 2, 0.5, -8), BackgroundColor3 = Color3.fromRGB(200,200,200)}):Play()
                    end
                    pcall(togConfig.Callback, state)
                end
                Pill.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then setState(not togConfig.CurrentValue) end
                end)
                setState(togConfig.CurrentValue)
                updateCardSize()
            end

            function CardObj:Slider(sliConfig)
                local Container = Create("Frame", {
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 35),
                    Parent = Card
                })
                local TitleVal = Create("TextLabel", {
                    Text = sliConfig.Name .. " [" .. sliConfig.CurrentValue .. sliConfig.Suffix .. "]",
                    TextColor3 = Theme.Text,
                    TextSize = 13,
                    Font = Enum.Font.Gotham,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 20),
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = Container
                })
                local Bar = Create("Frame", {
                    BackgroundColor3 = Color3.fromRGB(40, 40, 45),
                    Size = UDim2.new(1, 0, 0, 6),
                    Position = UDim2.new(0, 0, 1, -6),
                    Parent = Container,
                    CornerRadius = UDim.new(0, 3)
                })
                local Fill = Create("Frame", {
                    BackgroundColor3 = Theme.Accent,
                    Size = UDim2.new(0, 0, 1, 0),
                    Parent = Bar,
                    CornerRadius = UDim.new(0, 3)
                })
                local Circle = Create("Frame", {
                    BackgroundColor3 = Color3.fromRGB(255,255,255),
                    Size = UDim2.new(0, 12, 0, 12),
                    Position = UDim2.new(0, -6, 0.5, -6),
                    Parent = Fill,
                    CornerRadius = UDim.new(0, 6)
                })
                local function update(input)
                    local pct = math.clamp((input.Position.X - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X, 0, 1)
                    Fill.Size = UDim2.new(pct, 0, 1, 0)
                    local val = math.floor(sliConfig.Range[1] + (sliConfig.Range[2] - sliConfig.Range[1]) * pct)
                    val = math.floor(val / sliConfig.Increment) * sliConfig.Increment
                    TitleVal.Text = sliConfig.Name .. " [" .. val .. sliConfig.Suffix .. "]"
                    sliConfig.CurrentValue = val
                    pcall(sliConfig.Callback, val)
                end
                Bar.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        update(input)
                        local moveConn; moveConn = RunService.RenderStepped:Connect(function()
                            if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
                                update({Position = UserInputService:GetMouseLocation()})
                            else moveConn:Disconnect() end
                        end)
                    end
                end)
                local initPct = (sliConfig.CurrentValue - sliConfig.Range[1]) / (sliConfig.Range[2] - sliConfig.Range[1])
                Fill.Size = UDim2.new(initPct, 0, 1, 0)
                updateCardSize()
            end

            function CardObj:Dropdown(ddConfig)
                local Container = Create("Frame", {
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 25),
                    Parent = Card
                })
                local MainBtn = Create("TextButton", {
                    Text = ddConfig.Name .. ": " .. ddConfig.CurrentOption[1],
                    TextColor3 = Theme.Text,
                    TextSize = 14,
                    Font = Enum.Font.Gotham,
                    BackgroundColor3 = Color3.fromRGB(40, 40, 45),
                    Size = UDim2.new(1, 0, 0, 25),
                    Parent = Container,
                    CornerRadius = UDim.new(0, 4)
                })
                local ListFrame = Create("Frame", {
                    BackgroundColor3 = Theme.Header,
                    Size = UDim2.new(1, 0, 0, 0),
                    Position = UDim2.new(0, 0, 1, 0),
                    Parent = Container,
                    ClipsDescendants = true,
                    CornerRadius = UDim.new(0, 4)
                })
                local ListLayout = Create("UIListLayout", {Padding = UDim.new(0,1), Parent = ListFrame})
                local isOpen = false
                local function toggle()
                    isOpen = not isOpen
                    if isOpen then
                        ListFrame:TweenSize(UDim2.new(1, 0, 0, #ddConfig.Options * 25), "Out", "Quad", 0.2, true)
                        Container.Size = UDim2.new(1, 0, 0, 25 + (#ddConfig.Options * 25))
                    else
                        ListFrame:TweenSize(UDim2.new(1, 0, 0, 0), "Out", "Quad", 0.2, true)
                        Container.Size = UDim2.new(1, 0, 0, 25)
                    end
                    updateCardSize()
                end
                MainBtn.MouseButton1Click:Connect(toggle)
                for _, opt in pairs(ddConfig.Options) do
                    local OptBtn = Create("TextButton", {
                        Text = opt,
                        TextColor3 = Theme.TextDim,
                        TextSize = 13,
                        Font = Enum.Font.Gotham,
                        BackgroundTransparency = 1,
                        Size = UDim2.new(1, 0, 0, 25),
                        Parent = ListFrame
                    })
                    OptBtn.MouseButton1Click:Connect(function()
                        ddConfig.CurrentOption = {opt}
                        MainBtn.Text = ddConfig.Name .. ": " .. opt
                        toggle()
                        pcall(ddConfig.Callback, {opt})
                    end)
                    OptBtn.MouseEnter:Connect(function() OptBtn.TextColor3 = Theme.Accent end)
                    OptBtn.MouseLeave:Connect(function() OptBtn.TextColor3 = Theme.TextDim end)
                end
                updateCardSize()
            end
            return CardObj
        end
        return TabObj
    end

    function WindowObj:Notify(cfg)
        local notifGui = Instance.new("ScreenGui")
        notifGui.Parent = PlayerGui
        local notifFrame = Create("Frame", {
            BackgroundColor3 = Theme.Header,
            Size = UDim2.new(0, 260, 0, 50),
            Position = UDim2.new(1, 270, 1, -60),
            Parent = notifGui,
            CornerRadius = UDim.new(0, 6)
        })
        Create("UIStroke", {Color = Theme.Accent, Thickness = 1, Parent = notifFrame})
        Create("TextLabel", {
            Text = cfg.Title, TextColor3 = Theme.Accent, TextSize = 15, Font = Enum.Font.GothamBold,
            BackgroundTransparency = 1, Size = UDim2.new(1, -50, 0.5, 0), Position = UDim2.new(0, 10, 0, 0),
            TextXAlignment = Enum.TextXAlignment.Left, Parent = notifFrame
        })
        Create("TextLabel", {
            Text = cfg.Content, TextColor3 = Theme.Text, TextSize = 13, Font = Enum.Font.Gotham,
            BackgroundTransparency = 1, Size = UDim2.new(1, -10, 0.5, 0), Position = UDim2.new(0, 10, 0.5, 0),
            TextXAlignment = Enum.TextXAlignment.Left, Parent = notifFrame
        })
        notifFrame:TweenPosition(UDim2.new(1, -270, 1, -60), "Out", "Quad", 0.5)
        task.wait(cfg.Duration)
        notifFrame:TweenPosition(UDim2.new(1, 270, 1, -60), "In", "Quad", 0.5, true)
        task.wait(0.5)
        notifGui:Destroy()
    end
    return WindowObj
end

-- THIS IS THE FIX:
return FluxUI
