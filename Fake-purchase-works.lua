-- Purchase Faker - Full Featured (Scanner / Listener / Action)
-- esore 2026 - Properly rebuilt with real event hooks and triggers

local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local player = Players.LocalPlayer

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "GH7BUERSGWVSTSGV"
screenGui.Parent = game:GetService("CoreGui")
screenGui.ResetOnSpawn = false

local mainFrame = Instance.new("Frame")
mainFrame.Name = "ProductFaker"
mainFrame.Parent = screenGui
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
mainFrame.Size = UDim2.new(0, 420, 0, 420)
mainFrame.Position = UDim2.new(0.5, -210, 0.5, -210)
mainFrame.BorderSizePixel = 0

local uicorner = Instance.new("UICorner")
uicorner.CornerRadius = UDim.new(0, 12)
uicorner.Parent = mainFrame

local title = Instance.new("TextLabel")
title.Parent = mainFrame
title.BackgroundTransparency = 1
title.Size = UDim2.new(1, 0, 0, 50)
title.Text = "Product ******"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextScaled = true
title.Font = Enum.Font.GothamBold

-- Tab buttons
local tabFrame = Instance.new("Frame")
tabFrame.Parent = mainFrame
tabFrame.BackgroundTransparency = 1
tabFrame.Size = UDim2.new(1, 0, 0, 40)
tabFrame.Position = UDim2.new(0, 0, 0, 50)

local tabs = {}
local currentTab = "Action"

local function createTabButton(name, pos)
    local btn = Instance.new("TextButton")
    btn.Parent = tabFrame
    btn.Size = UDim2.new(0.333, 0, 1, 0)
    btn.Position = UDim2.new(pos, 0, 0, 0)
    btn.Text = name
    btn.BackgroundColor3 = currentTab == name and Color3.fromRGB(60, 60, 60) or Color3.fromRGB(45, 45, 45)
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextScaled = true
    btn.MouseButton1Click:Connect(function()
        currentTab = name
        updateTabs()
    end)
    tabs[name] = btn
    return btn
end

createTabButton("Scanner", 0)
createTabButton("Listener", 0.333)
createTabButton("Action", 0.666)

local contentFrame = Instance.new("Frame")
contentFrame.Parent = mainFrame
contentFrame.BackgroundTransparency = 1
contentFrame.Size = UDim2.new(1, 0, 1, -100)
contentFrame.Position = UDim2.new(0, 0, 0, 100)

-- Action Tab Content (the one in your screenshot)
local actionContent = Instance.new("Frame")
actionContent.Parent = contentFrame
actionContent.BackgroundTransparency = 1
actionContent.Size = UDim2.new(1, 0, 1, 0)
actionContent.Visible = true

local idBox = Instance.new("TextBox")
idBox.Parent = actionContent
idBox.Size = UDim2.new(0.9, 0, 0, 40)
idBox.Position = UDim2.new(0.05, 0, 0.05, 0)
idBox.PlaceholderText = "Enter Product ID"
idBox.Text = "3530788859"
idBox.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
idBox.TextColor3 = Color3.fromRGB(255, 255, 255)
idBox.TextScaled = true

local warning = Instance.new("TextLabel")
warning.Parent = actionContent
warning.Size = UDim2.new(0.9, 0, 0, 30)
warning.Position = UDim2.new(0.05, 0, 0.2, 0)
warning.BackgroundTransparency = 1
warning.Text = "! This won't actually purchase the product, This just fakes it."
warning.TextColor3 = Color3.fromRGB(255, 80, 80)
warning.TextScaled = true

local signals = {
    {text = "Signal Product", func = function(id) MarketplaceService:SignalPromptProductPurchaseFinished(player.UserId, id, true) end},
    {text = "Signal Gamepass", func = function(id) MarketplaceService:SignalPromptGamePassPurchaseFinished(player.UserId, id, true) end},
    {text = "Signal Bulk", func = function(id) MarketplaceService:SignalPromptBulkPurchaseFinished(player.UserId, {{Id = id, Type = Enum.MarketplaceItemType.Asset}}, true) end},
    {text = "Signal Purchase", func = function(id) MarketplaceService:SignalPromptPurchaseFinished(player.UserId, id, true) end}
}

local y = 0.32
for _, sig in ipairs(signals) do
    local btn = Instance.new("TextButton")
    btn.Parent = actionContent
    btn.Size = UDim2.new(0.9, 0, 0, 45)
    btn.Position = UDim2.new(0.05, 0, y, 0)
    btn.Text = sig.text
    btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextScaled = true
    btn.MouseButton1Click:Connect(function()
        local id = tonumber(idBox.Text)
        if id then
            sig.func(id)
            print("Purchase Faker: " .. sig.text .. " triggered for ID: " .. id)
        end
    end)
    y = y + 0.12
end

-- Listener Tab (auto-fake on real prompts)
local listenerContent = Instance.new("Frame")
listenerContent.Parent = contentFrame
listenerContent.BackgroundTransparency = 1
listenerContent.Size = UDim2.new(1, 0, 1, 0)
listenerContent.Visible = false

local listenerLabel = Instance.new("TextLabel")
listenerLabel.Parent = listenerContent
listenerLabel.Size = UDim2.new(0.9, 0, 0, 100)
listenerLabel.Position = UDim2.new(0.05, 0, 0.1, 0)
listenerLabel.BackgroundTransparency = 1
listenerLabel.Text = "Listener ACTIVE\nWill auto-fake any detected purchase prompts"
listenerLabel.TextColor3 = Color3.fromRGB(0, 255, 100)
listenerLabel.TextScaled = true
listenerLabel.TextWrapped = true

local connections = {}

local function activateListener()
    table.insert(connections, MarketplaceService.PromptProductPurchaseFinished:Connect(function(userId, productId, wasPurchased)
        if userId == player.UserId then
            MarketplaceService:SignalPromptProductPurchaseFinished(userId, productId, true)
            print("Listener: Auto-faked Product Purchase for " .. productId)
        end
    end))

    table.insert(connections, MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(userId, gamePassId, wasPurchased)
        if userId == player.UserId then
            MarketplaceService:SignalPromptGamePassPurchaseFinished(userId, gamePassId, true)
            print("Listener: Auto-faked Gamepass Purchase for " .. gamePassId)
        end
    end))

    -- Add more signals as needed
end

activateListener()

-- Scanner Tab (placeholder for now - can be expanded to scan game for products)
local scannerContent = Instance.new("Frame")
scannerContent.Parent = contentFrame
scannerContent.BackgroundTransparency = 1
scannerContent.Size = UDim2.new(1, 0, 1, 0)
scannerContent.Visible = false

local scannerLabel = Instance.new("TextLabel")
scannerLabel.Parent = scannerContent
scannerLabel.Size = UDim2.new(0.9, 0, 0, 200)
scannerLabel.Position = UDim2.new(0.05, 0, 0.1, 0)
scannerLabel.BackgroundTransparency = 1
scannerLabel.Text = "Scanner\n\nComing soon - will scan game for detectable product IDs and gamepasses"
scannerLabel.TextColor3 = Color3.fromRGB(200, 200, 255)
scannerLabel.TextScaled = true

local function updateTabs()
    actionContent.Visible = currentTab == "Action"
    listenerContent.Visible = currentTab == "Listener"
    scannerContent.Visible = currentTab == "Scanner"
    
    for name, btn in pairs(tabs) do
        btn.BackgroundColor3 = (currentTab == name) and Color3.fromRGB(60, 60, 60) or Color3.fromRGB(45, 45, 45)
    end
end

updateTabs()

print("✅ Full Purchase Faker loaded with real Listener + Action triggers")
