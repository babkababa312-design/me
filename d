-- =============================================
-- FLUX UI LIBRARY (Custom Build)
-- =============================================
local FluxUI = {}
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- Visual Configuration (Distinct from Rayfield)
local Theme = {
    Background = Color3.fromRGB(15, 15, 18),      -- Very Dark
    Header = Color3.fromRGB(22, 22, 27),          -- Slightly lighter
    Card = Color3.fromRGB(30, 30, 35),            -- Card Background
    Accent = Color3.fromRGB(0, 255, 128),         -- Neon Green/Teal
    Text = Color3.fromRGB(240, 240, 240),         -- Off-white
    TextDim = Color3.fromRGB(120, 120, 120),      -- Grey
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
    ScreenGui.Parent = game:GetService("CoreGui")

    -- Main Container
    local MainFrame = Create("Frame", {
        Name = "Window",
        BackgroundColor3 = Theme.Background,
        Size = UDim2.new(0, 550, 0, 400),
        Position = UDim2.new(0.5, -275, 0.5, -200),
        Parent = ScreenGui,
        CornerRadius = UDim.new(0, 12)
    })
    
    -- Border Glow/Stroke
    Create("UIStroke", {
        Color = Theme.Accent,
        Thickness = 1.5,
        Parent = MainFrame
    })

    -- Dragging Logic
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

    -- Top Navigation Bar (Tabs go here)
    local TopBar = Create("Frame", {
        Name = "TopBar",
        BackgroundColor3 = Theme.Header,
        Size = UDim2.new(1, 0, 0, 40),
        Parent = MainFrame,
        CornerRadius = UDim.new(0, 12) -- Rounded top only visually via clipping or just full round
    })
    -- Create a frame to cover the bottom rounded corners of the TopBar
    local TopBarCover = Create("Frame", {
        BackgroundColor3 = Theme.Header,
        Size = UDim2.new(1, 0, 0.5, 0),
        Position = UDim2.new(0, 0, 0.5, 0),
        BorderSizePixel = 0,
        Parent = TopBar
    })

    -- Window Title
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

    -- Content Area
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

    local WindowObj = {
        Tabs = {}
    }

    -- Function: Create a Tab (Top Bar Button)
    function WindowObj:Tab(tabName)
        -- Tab Button
        local TabBtn = Create("TextButton", {
            Text = tabName,
            TextColor3 = Theme.TextDim,
            TextSize = 14,
            Font = Enum.Font.Gotham,
            BackgroundTransparency = 1,
            Size = UDim2.new(0, 100, 1, 0),
            Parent = TopBar
        })
        
        -- Create a Tab Page (Container)
        local Page = Create("Frame", {
            Name = tabName.."Page",
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 0), -- Auto-sizes
            Parent = ContentFrame,
            Visible = false
        })
        local PageList = Create("UIListLayout", {
            Padding = UDim.new(0, 10),
            Parent = Page
        })

        -- Switch Logic
        TabBtn.MouseButton1Click:Connect(function()
            -- Hide all pages
            for _, tabData in pairs(WindowObj.Tabs) do
                tabData.Page.Visible = false
                tabData.Button.TextColor3 = Theme.TextDim
            end
            -- Show current
            Page.Visible = true
            TabBtn.TextColor3 = Theme.Accent
            
            -- Tween size adjustment for content frame
            Page.Size = UDim2.new(1, 0, 0, PageList.AbsoluteContentSize.Y + 10)
        end)

        -- First tab auto-select
        if #WindowObj.Tabs == 0 then
            Page.Visible = true
            TabBtn.TextColor3 = Theme.Accent
            task.wait()
            Page.Size = UDim2.new(1, 0, 0, PageList.AbsoluteContentSize.Y + 10)
        end

        table.insert(WindowObj.Tabs, {Button = TabBtn, Page = Page})

        local TabObj = {}

        -- Function: Create a Card (Section replacement)
        function TabObj:Card(cardTitle)
            local Card = Create("Frame", {
                BackgroundColor3 = Theme.Card,
                Size = UDim2.new(1, 0, 0, 30), -- Auto size
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

            -- Auto-size card
            local function updateCardSize()
                Card.Size = UDim2.new(1, 0, 0, CardLayout.AbsoluteContentSize.Y + (cardTitle and 20 or 0))
            end
            CardLayout.Changed:Connect(updateCardSize)

            local CardObj = {}

            -- Widget: Label
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

            -- Widget: Button
            function CardObj:Button(btnConfig)
                local Btn = Create("TextButton", {
                    Text = btnConfig.Name,
                    TextColor3 = Color3.fromRGB(0,0,0), -- Black text for contrast on bright green
                    TextSize = 14,
                    Font = Enum.Font.GothamBold,
                    BackgroundColor3 = Theme.Accent,
                    Size = UDim2.new(1, 0, 0, 28),
                    Parent = Card,
                    CornerRadius = UDim.new(0, 6)
                })
                Btn.MouseButton1Click:Connect(function()
                    pcall(btnConfig.Callback)
                end)
                updateCardSize()
            end

            -- Widget: Toggle (Pill Style)
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

                -- Pill Background
                local Pill = Create("Frame", {
                    BackgroundColor3 = Theme.ToggleOff,
                    Size = UDim2.new(0, 40, 0, 20),
                    Position = UDim2.new(1, -40, 0.5, -10),
                    Parent = Container,
                    CornerRadius = UDim.new(0, 10) -- Full circle
                })

                -- Knob
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
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        setState(not togConfig.CurrentValue)
                    end
                end)

                setState(togConfig.CurrentValue)
                updateCardSize()
            end

            -- Widget: Slider
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
                            else
                                moveConn:Disconnect()
                            end
                        end)
                    end
                end)

                -- Init
                local initPct = (sliConfig.CurrentValue - sliConfig.Range[1]) / (sliConfig.Range[2] - sliConfig.Range[1])
                Fill.Size = UDim2.new(initPct, 0, 1, 0)
                updateCardSize()
            end

            -- Widget: Dropdown
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

    -- Notification
    function WindowObj:Notify(cfg)
        local notifGui = Instance.new("ScreenGui")
        notifGui.Parent = game:GetService("CoreGui")
        
        local notifFrame = Create("Frame", {
            BackgroundColor3 = Theme.Header,
            Size = UDim2.new(0, 260, 0, 50),
            Position = UDim2.new(1, 270, 1, -60),
            Parent = notifGui,
            CornerRadius = UDim.new(0, 6)
        })
        Create("UIStroke", {Color = Theme.Accent, Thickness = 1, Parent = notifFrame})
        
        Create("TextLabel", {
            Text = cfg.Title,
            TextColor3 = Theme.Accent,
            TextSize = 15,
            Font = Enum.Font.GothamBold,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, -50, 0.5, 0),
            Position = UDim2.new(0, 10, 0, 0),
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = notifFrame
        })
        Create("TextLabel", {
            Text = cfg.Content,
            TextColor3 = Theme.Text,
            TextSize = 13,
            Font = Enum.Font.Gotham,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, -10, 0.5, 0),
            Position = UDim2.new(0, 10, 0.5, 0),
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = notifFrame
        })

        notifFrame:TweenPosition(UDim2.new(1, -270, 1, -60), "Out", "Quad", 0.5)
        task.wait(cfg.Duration)
        notifFrame:TweenPosition(UDim2.new(1, 270, 1, -60), "In", "Quad", 0.5, true)
        task.wait(0.5)
        notifGui:Destroy()
    end

    return WindowObj
end

return FluxUI

-- =============================================
-- HELICITY SCRIPT LOGIC (INTEGRATED)
-- =============================================

local UI = FluxUI -- Use the custom Flux library
local VirtualInputManager = game:GetService("VirtualInputManager")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

local player = Players.LocalPlayer
repeat task.wait() until player and player.Character

local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

local vehicleSpawned = false
local originalTorque = nil 

-- Find Wind Speed
local windSpeedObject = nil
for _, v in pairs(game.ReplicatedStorage:GetDescendants()) do
    if (v.Name == "WindSpeed" or v.Name == "Wind" or v.Name == "WindSpeedValue") and (v:IsA("NumberValue") or v:IsA("StringValue") or v:IsA("IntValue")) then
        windSpeedObject = v; break
    end
end
if not windSpeedObject then
    for _, v in pairs(player:GetDescendants()) do
        if (v.Name == "WindSpeed" or v.Name == "Wind" or v.Name == "WindSpeedValue") and (v:IsA("NumberValue") or v:IsA("StringValue") or v:IsA("IntValue")) then
            windSpeedObject = v; break
        end
    end
end

-- Settings Table
local settings = {
    walkSpeed = 16, jumpPower = 50, godmode = false, infiniteJump = false, noclip = false,
    flySpeed = 50, flying = false,
    autoTPTornado = false, tornadoTPDelay = 0.5, selectedVehicleName = "Dominator 3",
    autoPlaceProbe = false, autoBuyProbes = false,
    vehicleAccel = 1, vehicleJump = false, vehicleJumpPower = 60, vehicleFlying = false, vehicleFlySpeed = 100
}

-- Initialize UI
local Win = UI:Window({
    Name = "Helicity Flux"
})

-- Main Tab
local MainTab = Win:Tab("Main")
local PlayerCard = MainTab:Card("Player Options")
PlayerCard:Slider({Name = "Walk Speed", Range = {16, 555}, Increment = 1, Suffix = " spd", CurrentValue = 16, Callback = function(v) settings.walkSpeed = v; if humanoid then humanoid.WalkSpeed = v end end})
PlayerCard:Slider({Name = "Jump Power", Range = {50, 555}, Increment = 1, Suffix = " pwr", CurrentValue = 50, Callback = function(v) settings.jumpPower = v; if humanoid then humanoid.JumpPower = v end end})
PlayerCard:Toggle({Name = "Godmode", CurrentValue = false, Callback = function(v) settings.godmode = v; if v then Win:Notify({Title="Godmode", Content="Enabled", Duration=3}) end end})
PlayerCard:Toggle({Name = "Infinite Jump", CurrentValue = false, Callback = function(v) settings.infiniteJump = v end})
PlayerCard:Toggle({Name = "Noclip", CurrentValue = false, Callback = function(v) settings.noclip = v end})

local ProbesCard = MainTab:Card("Probe Automation")
ProbesCard:Toggle({Name = "Auto Place Probe", CurrentValue = false, Callback = function(v) settings.autoPlaceProbe = v; if v then Win:Notify({Title="Probes", Content="Auto placing enabled", Duration=3}) end end})
ProbesCard:Label("Logic: Place >80mph, Pickup <50mph")
ProbesCard:Toggle({Name = "Auto Buy Probes", CurrentValue = false, Callback = function(v) settings.autoBuyProbes = v; if v then Win:Notify({Title="Shop", Content="Auto buying enabled", Duration=3}) end end})

local TornadoCard = MainTab:Card("Tornado Teleport")
TornadoCard:Dropdown({Name = "Select Vehicle", Options = {"Dominator 3", "Dominator 2", "Dominator 1", "TIV 2", "TIV 1", "Probe", "Interceptor"}, CurrentOption = {"Dominator 3"}, Callback = function(opt) settings.selectedVehicleName = opt[1] end})
TornadoCard:Toggle({Name = "Auto TP to Tornado", CurrentValue = false, Callback = function(v) settings.autoTPTornado = v; vehicleSpawned = false; if v then findAndSpawnBestVehicle(); Win:Notify({Title="Tornado TP", Content="Spawning vehicle...", Duration=4}) end end})
TornadoCard:Slider({Name = "TP Delay", Range = {0.1, 5}, Increment = 0.1, Suffix = "s", CurrentValue = 0.5, Callback = function(v) settings.tornadoTPDelay = v end})

local FlyCard = MainTab:Card("Flight")
FlyCard:Toggle({Name = "Fly", CurrentValue = false, Callback = function(v) settings.flying = v; if v then startFlying() else stopFlying() end end})
FlyCard:Slider({Name = "Fly Speed", Range = {10, 555}, Increment = 5, Suffix = " spd", CurrentValue = 50, Callback = function(v) settings.flySpeed = v end})

-- Vehicle Tab
local VehTab = Win:Tab("Vehicle")
local VehCard = VehTab:Card("Vehicle Mods")
VehCard:Slider({Name = "Acceleration", Range = {1, 10}, Increment = 0.5, Suffix = "x", CurrentValue = 1, Callback = function(v) settings.vehicleAccel = v end})
VehCard:Toggle({Name = "Vehicle Jump (Space)", CurrentValue = false, Callback = function(v) settings.vehicleJump = v; if v then Win:Notify({Title="Veh Jump", Content="Press Space to jump!", Duration=3}) end end})
VehCard:Slider({Name = "Jump Power", Range = {20, 555}, Increment = 5, Suffix = " pwr", CurrentValue = 60, Callback = function(v) settings.vehicleJumpPower = v end})
VehCard:Toggle({Name = "Vehicle Fly", CurrentValue = false, Callback = function(v) settings.vehicleFlying = v; if v then Win:Notify({Title="Veh Fly", Content="Sit in car to fly", Duration=3}); if humanoid.SeatPart and humanoid.SeatPart:IsA("VehicleSeat") then startVehicleFlying() end else stopVehicleFlying() end end})
VehCard:Slider({Name = "Veh Fly Speed", Range = {10, 555}, Increment = 5, Suffix = " spd", CurrentValue = 100, Callback = function(v) settings.vehicleFlySpeed = v end})

-- Teleport Tab
local TeleTab = Win:Tab("Teleport")
local TeleCard = TeleTab:Card("Player TP")
local PlayerDD = TeleCard:Dropdown({Name = "Select Player", Options = {}, CurrentOption = {"None"}, Callback = function(o) end})
TeleCard:Button({Name = "Teleport to Player", Callback = function()
    local sel = PlayerDD.CurrentOption[1]
    if sel and sel ~= "None" then
        local t = Players:FindFirstChild(sel)
        if t and t.Character and t.Character:FindFirstChild("HumanoidRootPart") then
            humanoidRootPart.CFrame = t.Character.HumanoidRootPart.CFrame
        end
    end
end})
TeleCard:Button({Name = "Refresh List", Callback = function() 
    local names = {} 
    for _, p in pairs(Players:GetPlayers()) do if p ~= player then table.insert(names, p.Name) end end 
    Win:Notify({Title="List", Content="Updated list (refresh UI to see)", Duration=2}) 
end})

-- Misc Tab
local MiscTab = Win:Tab("Misc")
local MiscCard = MiscTab:Card("Settings")
MiscCard:Toggle({Name = "Fullbright", CurrentValue = false, Callback = function(v)
    if v then game.Lighting.Brightness = 2; game.Lighting.ClockTime = 14; game.Lighting.FogEnd = 1e5; game.Lighting.GlobalShadows = false; game.Lighting.OutdoorAmbient = Color3.fromRGB(128,128,128)
    else game.Lighting.Brightness = 1; game.Lighting.ClockTime = 12; game.Lighting.FogEnd = 1e5; game.Lighting.GlobalShadows = true; game.Lighting.OutdoorAmbient = Color3.fromRGB(70,70,70) end
end})
MiscCard:Button({Name = "Remove Fog", Callback = function() game.Lighting.FogEnd = 1e5 end})

-- =============================================
-- GAME FUNCTIONS
-- =============================================

function startFlying()
    if humanoidRootPart:FindFirstChild("FluxBodyVel") then return end
    local bv = Instance.new("BodyVelocity", humanoidRootPart); bv.Name = "FluxBodyVel"; bv.Velocity = Vector3.new(0,0,0); bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    local bg = Instance.new("BodyGyro", humanoidRootPart); bg.MaxTorque = Vector3.new(9e9, 9e9, 9e9); bg.P = 9e4
    spawn(function()
        while settings.flying and humanoidRootPart:FindFirstChild("FluxBodyVel") do
            local cam = workspace.CurrentCamera
            local dir = Vector3.new(0,0,0)
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir = dir + cam.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir = dir - cam.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir = dir - cam.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir = dir + cam.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.new(0,1,0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then dir = dir - Vector3.new(0,1,0) end
            bv.Velocity = dir * settings.flySpeed; bg.CFrame = cam.CFrame; wait()
        end
    end)
end
function stopFlying()
    if humanoidRootPart:FindFirstChild("FluxBodyVel") then humanoidRootPart.FluxBodyVel:Destroy() end
    if humanoidRootPart:FindFirstChild("BodyGyro") then humanoidRootPart.BodyGyro:Destroy() end
end

function startVehicleFlying()
    if not humanoid.SeatPart or not humanoid.SeatPart:IsA("VehicleSeat") then return end
    local seat = humanoid.SeatPart
    if seat:FindFirstChild("FluxVehVel") then return end
    local bv = Instance.new("BodyVelocity", seat); bv.Name = "FluxVehVel"; bv.Velocity = Vector3.new(0,0,0); bv.MaxForce = Vector3.new(1e9,1e9,1e9)
    local bg = Instance.new("BodyGyro", seat); bg.MaxTorque = Vector3.new(1e9,1e9,1e9); bg.P = 1e5
    spawn(function()
        while settings.vehicleFlying and seat and seat.Parent and humanoid.SeatPart == seat do
            local cam = workspace.CurrentCamera
            local dir = Vector3.new(0,0,0)
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir = dir + cam.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir = dir - cam.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir = dir - cam.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir = dir + cam.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.new(0,1,0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then dir = dir - Vector3.new(0,1,0) end
            bv.Velocity = dir * settings.vehicleFlySpeed; bg.CFrame = cam.CFrame; wait()
        end
        if bv then bv:Destroy() end; if bg then bg:Destroy() end
    end)
end
function stopVehicleFlying()
    if humanoid.SeatPart and humanoid.SeatPart:IsA("VehicleSeat") then
        if humanoid.SeatPart:FindFirstChild("FluxVehVel") then humanoid.SeatPart.FluxVehVel:Destroy() end
        if humanoid.SeatPart:FindFirstChild("BodyGyro") then humanoid.SeatPart.BodyGyro:Destroy() end
    end
end

function findNearestTornado()
    local near, dist = nil, math.huge
    for _, o in pairs(workspace:GetDescendants()) do
        local p = (o:IsA("Model") and (o.Name:lower():find("tornado") or o.Name:lower():find("twister")) and (o:FindFirstChild("HumanoidRootPart") or o:FindFirstChild("Core") or o:FindFirstChild("Center") or o.PrimaryPart)) or (o:IsA("BasePart") and (o.Name:lower():find("tornado") or o.Name:lower():find("twister")) and o)
        if p then
            local d = (humanoidRootPart.Position - p.Position).Magnitude
            if d < dist then dist = d; near = p end
        end
    end
    return near
end

function findAndSpawnBestVehicle()
    if vehicleSpawned then return end
    local target = settings.selectedVehicleName
    Win:Notify({Title="Spawner", Content="Searching for "..target, Duration=2})
    
    local pg = player.PlayerGui
    local sb = pg:FindFirstChild("SideBar")
    if sb then
        local f1 = sb:FindFirstChild("Frame")
        if f1 then
            local f2 = f1:FindFirstChild("Frame")
            if f2 then
                for _, b in pairs(f2:GetChildren()) do
                    if (b:IsA("TextButton") or b:IsA("ImageButton")) and (string.lower(b.Name) == "dealership" or string.lower(b.Text) == "dealership") then
                        pcall(function() b.MouseButton1Click:Fire() end)
                        task.wait(0.5)
                        break
                    end
                end
            end
        end
    end
    
    local cs = pg:FindFirstChild("CarSpawner")
    if cs and not cs.Enabled then
        local t = 0
        while not cs.Enabled and t < 10 do task.wait(0.1); t = t+1 end
    end
    
    if cs and cs.Enabled then
        local mf = cs:FindFirstChild("Frame")
        if mf then
            local sf = mf:FindFirstChild("ScrollingFrame")
            if sf then
                for _, c in pairs(sf:GetDescendants()) do
                    if c:IsA("TextButton") then
                        local n = string.lower(c.Name or "")
                        local t = string.lower(c.Text or "")
                        local tl = string.lower(target)
                        if n == tl or t == tl or string.find(t, tl) or string.find(n, tl) then
                            Win:Notify({Title="Found", Content="Spawning!", Duration=1})
                            pcall(function() c.MouseButton1Click:Fire() end)
                            vehicleSpawned = true
                            return
                        end
                    end
                end
            end
        end
    end
end

-- LOOPS
spawn(function()
    while task.wait(settings.tornadoTPDelay) do
        if settings.autoTPTornado and humanoidRootPart then
            local t = findNearestTornado()
            if t then humanoidRootPart.CFrame = CFrame.new(t.Position + Vector3.new(0,5,0)) end
        end
    end
end)

spawn(function()
    while task.wait(1) do
        if settings.autoBuyProbes then
            if not (function() for _,t in pairs(player.Backpack:GetChildren()) do if t:IsA("Tool") and t.Name:lower():find("probe") then return true end end return false end)() then
                for _,g in pairs(player.PlayerGui:GetDescendants()) do
                    if g:IsA("TextButton") and (g.Name:lower():find("buy") or g.Text:lower():find("buy")) and (g.Name:lower():find("probe") or g.Text:lower():find("probe")) then g.MouseButton1Click:Fire(); return end
                end
                for _,r in pairs(game.ReplicatedStorage:GetDescendants()) do
                    if r:IsA("RemoteEvent") and r.Name:lower():find("buy") and r.Name:lower():find("probe") then r:FireServer(); return end
                end
            end
        end
        if settings.autoPlaceProbe then
            local ws = tonumber(tostring(windSpeedObject and windSpeedObject.Value or 0)) or 0
            local tool = (function() for _,t in pairs(player.Backpack:GetChildren()) do if t:IsA("Tool") and t.Name:lower():find("probe") then return t end end return nil end)()
            if ws >= 80 and tool then
                if not character:FindFirstChild(tool.Name) then humanoid:EquipTool(tool); task.wait(0.5) end
                VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game); task.wait(0.1); VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
                for _,r in pairs(game.ReplicatedStorage:GetDescendants()) do if r:IsA("RemoteEvent") and r.Name:lower():find("place") and r.Name:lower():find("probe") then r:FireServer() end end
            elseif ws < 50 then
                VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game); task.wait(0.1); VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
                for _,r in pairs(game.ReplicatedStorage:GetDescendants()) do if r:IsA("RemoteEvent") and (r.Name:lower():find("pick") or r.Name:lower():find("grab")) and r.Name:lower():find("probe") then r:FireServer() end end
            end
        end
    end
end)

spawn(function() while task.wait(0.1) do if settings.godmode and humanoid then humanoid.Health = humanoid.MaxHealth end end end)

game:GetService("RunService").Stepped:Connect(function()
    if settings.noclip and character then
        for _, p in pairs(character:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = false end end
    end
    if settings.vehicleAccel > 1 and humanoid.SeatPart and humanoid.SeatPart:IsA("VehicleSeat") and originalTorque then
        humanoid.SeatPart.Torque = originalTorque * settings.vehicleAccel
    end
end)

UserInputService.JumpRequest:Connect(function() if settings.infiniteJump and humanoid then humanoid:ChangeState(Enum.HumanoidStateType.Jumping) end end)

UserInputService.InputBegan:Connect(function(i, p)
    if not p and settings.vehicleJump and humanoid.SeatPart and humanoid.SeatPart:IsA("VehicleSeat") and i.KeyCode == Enum.KeyCode.Space then
        if not settings.vehicleFlying and humanoid.SeatPart.AssemblyLinearVelocity.Y < 10 then
            humanoid.SeatPart.AssemblyLinearVelocity = Vector3.new(humanoid.SeatPart.AssemblyLinearVelocity.X, settings.vehicleJumpPower, humanoid.SeatPart.AssemblyLinearVelocity.Z)
        end
    end
end)

local function seatTrack(h)
    h:GetPropertyChangedSignal("SeatPart"):Connect(function()
        if h.SeatPart and h.SeatPart:IsA("VehicleSeat") then
            originalTorque = h.SeatPart.Torque
            if settings.vehicleFlying then startVehicleFlying() end
        else
            originalTorque = nil
        end
    end)
end
seatTrack(humanoid)

player.CharacterAdded:Connect(function(c)
    character = c
    humanoid = c:WaitForChild("Humanoid")
    humanoidRootPart = c:WaitForChild("HumanoidRootPart")
    humanoid.WalkSpeed = settings.walkSpeed
    humanoid.JumpPower = settings.jumpPower
    seatTrack(humanoid)
    if settings.autoTPTornado then vehicleSpawned = false; task.wait(1); findAndSpawnBestVehicle() end
end)

Win:Notify({Title="FluxUI", Content="Loaded successfully!", Duration=5})
