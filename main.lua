-- ================================================
--    Blox Spin Fixed & Optimized Script
-- ================================================

getgenv().script_mode = getgenv().script_mode or "FARM"
getgenv().IgnoredFish = getgenv().IgnoredFish or {["Mythic"] = true}

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")

local Settings = {
    UndergroundDepth = -50,
    KickOnDamage = true
}

-- 1. نظام الحماية (Kick عند الدمج)
local function initAntiDamage()
    local function monitor(char)
        local hum = char:WaitForChild("Humanoid", 10)
        if hum then
            hum.HealthChanged:Connect(function(health)
                if Settings.KickOnDamage and health < hum.MaxHealth then
                    LocalPlayer:Kick("[Protection] تم طردك للحفاظ على مواردك بسبب دمج اللاعبين!")
                end
            end)
        end
    end
    if LocalPlayer.Character then monitor(LocalPlayer.Character) end
    LocalPlayer.CharacterAdded:Connect(monitor)
end

-- 2. تشغيل وضع التفريم
if getgenv().script_mode == "FARM" then
    print("[Blox Spin] FARM Mode Running...")
    initAntiDamage()

    -- التثبيت تحت الأرض للسيارة واللاعب بشكل آمن
    RunService.Stepped:Connect(function()
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            local hum = char:FindFirstChildOfClass("Humanoid")
            local targetPart = char.HumanoidRootPart

            -- التحقق الآمن من ركوب السيارة
            if hum and hum.SeatPart then
                local vehicle = hum.SeatPart.Parent
                if vehicle and vehicle:IsA("Model") then
                    targetPart = vehicle.PrimaryPart or vehicle:FindFirstChildWhichIsA("BasePart") or targetPart
                end
            end

            if targetPart and targetPart.Position.Y > Settings.UndergroundDepth then
                targetPart.CFrame = CFrame.new(targetPart.Position.X, Settings.UndergroundDepth, targetPart.Position.Z)
            end

            -- إيقاف الاصطدام (Noclip) لتجنب التعليق
            for _, v in pairs(char:GetDescendants()) do
                if v:IsA("BasePart") then
                    v.CanCollide = false
                end
            end
        end
    end)

    -- فلترة الأسماك الآمنة
    workspace.ChildAdded:Connect(function(child)
        pcall(function()
            local fishName = child.Name
            local rarityObj = child:FindFirstChild("Rarity")
            local rarityValue = rarityObj and (rarityObj.Value or rarityObj.Text) or ""
            
            if getgenv().IgnoredFish[fishName] or getgenv().IgnoredFish[rarityValue] then
                print("[Filter] Skipped: " .. fishName)
                child:Destroy()
            end
        end)
    end)

elseif getgenv().script_mode == "PVP" then
    print("[Blox Spin] PVP Mode Active.")
end
