-- Защита и сервисы
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

-- Загружаем Fluent UI
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

-- Создаем окно скрипта для Steal An Egg
local Window = Fluent:CreateWindow({
    Title = "L1me Hub | Steal An Egg",
    SubTitle = "by L1me Hub",
    TabWidth = 160,
    Size = UDim2.fromOffset(500, 380),
    Acrylic = true,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
})

-- Вкладки
local Tabs = {
    Main = Window:AddTab({ Title = "Фарм", Icon = "egg" }),
    Movement = Window:AddTab({ Title = "Движение", Icon = "move" }),
    Settings = Window:AddTab({ Title = "Настройки", Icon = "settings" })
}

-- ==========================================
-- 1. ЛОГИКА TP WALK (С фиксом выключения)
-- ==========================================
local tpWalkEnabled = false
local tpSpeed = 25
local tpWalkConnection = nil

Tabs.Movement:AddToggle("TPWalkToggle", {
    Title = "TP Walk",
    Description = "Телепортация при ходьбе (ускорение)",
    Default = false,
    Callback = function(Value)
        tpWalkEnabled = Value
        
        if tpWalkEnabled then
            if not tpWalkConnection then
                tpWalkConnection = RunService.Heartbeat:Connect(function(deltaTime)
                    if not tpWalkEnabled then return end
                    local character = LocalPlayer.Character
                    if not character then return end

                    local humanoid = character:FindFirstChildOfClass("Humanoid")
                    local rootPart = character:FindFirstChild("HumanoidRootPart")

                    if humanoid and rootPart and humanoid.MoveDirection.Magnitude > 0 then
                        rootPart.CFrame = rootPart.CFrame + humanoid.MoveDirection * tpSpeed * deltaTime
                    end
                end)
            end
        else
            if tpWalkConnection then
                tpWalkConnection:Disconnect()
                tpWalkConnection = nil
            end
        end
    end
})

Tabs.Movement:AddSlider("TPSpeedSlider", {
    Title = "Скорость TP Walk",
    Description = "Регулировка скорости движения",
    Default = 25,
    Min = 10,
    Max = 100,
    Rounding = 1,
    Callback = function(Value)
        tpSpeed = Value
    end
})

-- ==========================================
-- 2. ЛОГИКА УМНОГО АВТОФАРМА (Биомы -> База)
-- ==========================================
local smartFarmEnabled = false
local isWorking = false

-- ВНИМАНИЕ: Замени на реальные координаты твоей базы в игре!
local basePosition = CFrame.new(0, 5, 0) 

local function moveTo(targetCFrame)
    local character = LocalPlayer.Character
    if not character then return end
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end

    local distance = (rootPart.Position - targetCFrame.Position).Magnitude
    local speed = 60 -- Скорость полета к яйцу
    local duration = distance / speed

    local tween = TweenService:Create(rootPart, TweenInfo.new(duration, Enum.EasingStyle.Linear), {CFrame = targetCFrame + Vector3.new(0, 3, 0)})
    tween:Play()
    tween.Completed:Wait()
end

local function grabEgg(eggPart)
    local character = LocalPlayer.Character
    local rootPart = character and character:FindFirstChild("HumanoidRootPart")
    if not rootPart or not eggPart then return end

    moveTo(eggPart.CFrame)
    
    pcall(function()
        firetouchinterest(rootPart, eggPart, 0)
        task.wait(0.1)
        firetouchinterest(rootPart, eggPart, 1)
    end)
    task.wait(0.5)
end

task.spawn(function()
    while task.wait(1) do
        if smartFarmEnabled and not isWorking then
            isWorking = true
            pcall(function()
                -- Путь к папке карты/биомов (проверь через Explorer в игре)
                local mapFolder = Workspace:FindFirstChild("Map") or Workspace
                
                for _, biome in ipairs(mapFolder:GetChildren()) do
                    if not smartFarmEnabled then break end
                    
                    local eggsFolder = biome:FindFirstChild("Eggs") or biome:FindFirstChild("SpawnedEggs")
                    
                    if eggsFolder then
                        for _, egg in ipairs(eggsFolder:GetChildren()) do
                            if not smartFarmEnabled then break end
                            
                            local eggPart = egg:IsA("Model") and egg.PrimaryPart or egg:IsA("BasePart") and egg
                            if eggPart then
                                -- Летим к яйцу и берем его
                                grabEgg(eggPart)
                                -- Возвращаемся на базу
                                moveTo(basePosition)
                                task.wait(1)
                            end
                        end
                    end
                end
            end)
            isWorking = false
        end
    end
end)

Tabs.Main:AddToggle("SmartFarmToggle", {
    Title = "Умный фарм (Биомы -> База)",
    Description = "Сканирует биомы, собирает яйца и везет на базу",
    Default = false,
    Callback = function(Value)
        smartFarmEnabled = Value
    end
})

-- Вкладка информации
Tabs.Settings:AddParagraph({
    Title = "Информация",
    Content = "Скрипт оптимизирован для Steal An Egg. Используй тугглы для управления."
})

Window:SelectTab(1)

Fluent:Notify({
    Title = "L1me Hub",
    Content = "Скрипт Steal An Egg успешно загружен!",
    Duration = 4
})
