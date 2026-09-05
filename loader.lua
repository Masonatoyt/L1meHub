local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local StarterGui = game:GetService("StarterGui")

-- Загружаем Fluent UI
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

pcall(function()
    StarterGui:SetCore("SendNotification", {
        Title = "L1me Loader",
        Text = "Инициализация системы...",
        Duration = 3,
    })
end)

-- 1. Окно загрузки (Loader)
local LoadWindow = Fluent:CreateWindow({
    Title = "L1me Loader | Free Hub",
    SubTitle = "Подготовка...",
    TabWidth = 160,
    Size = UDim2.fromOffset(450, 280),
    Acrylic = true,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
})

local LoadTab = LoadWindow:AddTab({ Title = "Загрузка", Icon = "loader" })

LoadTab:AddParagraph({
    Title = "Подождите",
    Content = "Загрузка лоадера L1me Hub..."
})

local ProgressBar = LoadTab:AddParagraph({
    Title = "Прогресс",
    Content = "Статус: Подготовка [0%]"
})

-- Функция открытия главного меню выбора игр
local function OpenMainMenu()
    -- 2. Главное меню выбора скриптов
    local MainMenu = Fluent:CreateWindow({
        Title = "L1me Hub | Выберите скрипт",
        SubTitle = "Нажмите на нужную кнопку",
        TabWidth = 160,
        Size = UDim2.fromOffset(500, 350),
        Acrylic = true,
        Theme = "Dark",
        MinimizeKey = Enum.KeyCode.LeftControl
    })

    local Tabs = {
        Games = MainMenu:AddTab({ Title = "Скрипты", Icon = "gamepad-2" }),
        Info = MainMenu:AddTab({ Title = "Инфо", Icon = "info" })
    }

    Tabs.Games:AddParagraph({
        Title = "Доступные игры",
        Content = "При нажатии на кнопку интерфейс закроется, и загрузится скрипт."
    })

    -- Кнопка для Steal An Egg
    Tabs.Games:AddButton({
        Title = "Steal An Egg",
        Description = "Загрузить скрипт для Steal An Egg",
        Callback = function()
            MainMenu:Destroy()
            Fluent:Notify({ Title = "L1me Hub", Content = "Загрузка Steal An Egg...", Duration = 3 })
            
            -- Вызов твоего скрипта с GitHub через loadstring
            local success, err = pcall(function()
                loadstring(game:HttpGet("https://raw.githubusercontent.com/Masonatoyt/L1meHub/main/stealanegg.lua"))()
            end)
            
            if not success then
                Fluent:Notify({ Title = "Ошибка!", Content = tostring(err), Duration = 8 })
                warn("Ошибка загрузки: " .. tostring(err))
            end
        end
    })

    -- Вкладка информации
    Tabs.Info:AddParagraph({
        Title = "О разработчике",
        Content = "L1me Hub — бесплатный сборник скриптов."
    })

    MainMenu:SelectTab(1)

    Fluent:Notify({
        Title = "L1me Hub",
        Content = "Готово к работе!",
        Duration = 4,
    })
end

-- Анимация прогресса и автоматический переход к меню
task.spawn(function()
    for i = 1, 100 do
        task.wait(0.01)
        ProgressBar:SetDesc("Статус: Загрузка [" .. i .. "%]")
    end
    
    task.wait(0.2)
    LoadWindow:Destroy() -- Уничтожаем окно загрузки
    OpenMainMenu()        -- Открываем меню выбора
end)
