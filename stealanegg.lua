local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")
local ProximityPromptService = game:GetService("ProximityPromptService")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer

-- Загрузка Fluent UI с GitHub
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

pcall(function()
    StarterGui:SetCore("SendNotification", {
        Title = "TP Walk Hub",
        Text = "Скрипт успешно запущен через L1me Loader!",
        Duration = 5,
    })
end)

ProximityPromptService.PromptShown:Connect(function(prompt)
    prompt.HoldDuration = 0
end)

-- Создание окна
local Window = Fluent:CreateWindow({
    Title = "TP Walk & Utilities Hub",
    SubTitle = "by L1me Hub",
    TabWidth = 160,
    Size = UDim2.fromOffset(500, 380),
    Acrylic = true,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
})

-- Создание вкладок
local Tabs = {
    Main = Window:AddTab({ Title = "Главная", Icon = "home" }),
    Settings = Window:AddTab({ Title = "Настройки", Icon = "settings" })
}

local Options = Fluent.Options

-- Переменные функций
local tpSpeed = 50
local tpWalkEnabled = false

-- Функция сброса с отвязкой от тренажеров и принудительным падением
local function forceFallAndReset(character)
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    
    if humanoid then
        humanoid.Sit = false
        humanoid.PlatformStand = true
    end

    if rootPart then
        rootPart.Anchored = false
        for _, part in pairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
        
        local connection
        local elapsed = 0
        connection = RunService.RenderStepped:Connect(function(dt)
            elapsed = elapsed + dt
            if rootPart and rootPart.Parent then
                rootPart.CFrame = rootPart.CFrame - Vector3.new(0, dt * 40, 0)
            end
            if elapsed > 0.4 then
                connection:Disconnect()
            end
        end)
    end
    
    task.delay(0.45, function()
        if character and character.Parent then
            character:BreakJoints()
        end
    end)
end

-- Вкладка Main (Главная)
Tabs.Main:AddToggle("BypassToggle", {
    Title = "Bypass Anti-cheat",
    Description = "Включить или выключить обход",
    Default = false,
    Callback = function(Value)
        local character = LocalPlayer.Character
        if not character then return end

        if Value then
            Fluent:Notify({ Title = "Bypass", Content = "Anti-cheat включен (Humanoid заменен)", Duration = 3 })
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid:Destroy()
            end
            local replacementHumanoid = Instance.new("Humanoid")
            replacementHumanoid.Parent = character
        else
            Fluent:Notify({ Title = "Bypass", Content = "Anti-cheat выключен. Сходим с тренажера и падаем...", Duration = 3 })
            forceFallAndReset(character)
        end
    end
})

Tabs.Main:AddButton({
    Title = "Respawn Character",
    Description = "Сбросить персонажа с падением",
    Callback = function()
        local character = LocalPlayer.Character
        if character then
            forceFallAndReset(character)
        end
    end
})

-- Вкладка Settings (Настройки)
Tabs.Settings:AddToggle("TPWalkToggle", {
    Title = "TP Walk",
    Description = "Включить телепортацию при ходьбе",
    Default = false,
    Callback = function(Value)
        tpWalkEnabled = Value
    end
})

Tabs.Settings:AddSlider("TPSpeedSlider", {
    Title = "TP Speed",
    Description = "Скорость перемещения через TP Walk",
    Default = 50,
    Min = 1,
    Max = 1000,
    Rounding = 0,
    Callback = function(Value)
        tpSpeed = Value
    end
})

-- Логика TP Walk (Heartbeat)
RunService.Heartbeat:Connect(function(deltaTime)
    if not tpWalkEnabled then return end
    local character = LocalPlayer.Character
    if not character then return end

    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local rootPart = character:FindFirstChild("HumanoidRootPart")

    if humanoid and rootPart and humanoid.MoveDirection.Magnitude > 0 then
        rootPart.CFrame = rootPart.CFrame + humanoid.MoveDirection * tpSpeed * deltaTime
    end
end)

-- Выбор вкладки по умолчанию
Window:SelectTab(1)

Fluent:Notify({
    Title = "L1me Hub",
    Content = "Скрипт успешно очищен от Move to Stand!",
    Duration = 6
})
