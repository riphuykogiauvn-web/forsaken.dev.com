--[[
    AMETHYST HUB | Auto Farm Level & Auto Attack & Bring Mobs
    - Cập nhật toàn bộ hệ thống Auto Farm Level tự động nhận Quest theo bản gốc
    - Tích hợp đầy đủ chức năng Gom Quái (BringEnemy / Bring Mobs)
    - Giữ nguyên toàn bộ logic Auto Attack bản gốc (RegisterHit + RegisterAttack)
    - Hệ thống chống rơi giật trên không (Anti-Gravity Zero Velocity)
    - Giao diện Menu Draggable với đầy đủ các nút Bật/Tắt
--]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

-- Biến trạng thái & Cấu hình
local autoAttackEnabled = false
local autoFarmLevelEnabled = false
local bringMobEnabled = true -- Trạng thái gom quái

local HIT_ID = "5072bdca"
local ATTACK_DELAY = 0.15 -- Tốc độ đánh (giây)
local MAX_DISTANCE = 150 -- Khoảng cách tối đa để đánh (studs)
local TWEEN_SPEED = 300 -- Vận tốc bay/di chuyển
local Sec = 0.1

-- Lấy thư mục Remote
local Net = ReplicatedStorage:FindFirstChild("Modules") and ReplicatedStorage.Modules:FindFirstChild("Net")
local Remotes = ReplicatedStorage:FindFirstChild("Remotes")

-- Remote Đăng ký Hit và Remote Tấn công (Bản gốc của bạn)
local RegisterHit = Net and Net:FindFirstChild("RE/RegisterHit")
local RegisterAttack = Net and (
    Net:FindFirstChild("RE/RegisterAttack") or 
    Net:FindFirstChild("RE/Attack") or 
    Net:FindFirstChild("RE/Swing") or 
    Net:FindFirstChild("RE/WeaponAttack") or 
    Net:FindFirstChild("RE/Slash")
)

local CommF = Remotes and Remotes:FindFirstChild("CommF_")
local GetPlayerProfileOpened = Remotes and Remotes:FindFirstChild("GetPlayerProfileOpened")
local RFSubmarineWorkerSpeak = Net and Net:FindFirstChild("RF/SubmarineWorkerSpeak")

if not RegisterHit then
    warn("[AutoFarm]: Không tìm thấy RE/RegisterHit!")
    return
end

-- Gọi Remote mở hồ sơ (nếu có)
if GetPlayerProfileOpened then
    pcall(function()
        GetPlayerProfileOpened:InvokeServer()
    end)
end

----------------------------------------------------------------
-- HỆ THỐNG GIẢI MÃ NHIỆM VỤ (QUEST MODULE DYNAMIC RESOLVER)
----------------------------------------------------------------

local Quests = nil
local GuideModule = nil

pcall(function()
    Quests = require(ReplicatedStorage:WaitForChild("Quests"))
end)

pcall(function()
    GuideModule = require(ReplicatedStorage:WaitForChild("GuideModule"))
end)

local blacklistquest = {
    "MarineQuest",
    "BartiloQuest",
    "CitizenQuest",
    "Trainees"
}

local function CheckSea(b)
    if (game.PlaceId == 2753915549 or game.PlaceId == 85211729168715) and b == 1 then
        return true
    elseif (game.PlaceId == 4442272183 or game.PlaceId == 79091703265657) and b == 2 then
        return true
    elseif (game.PlaceId == 7449423635 or game.PlaceId == 100117331123089) and b == 3 then
        return true
    end
    return false
end

local function GetQuestPointFromNPC(npcName)
    local npcs = Workspace:FindFirstChild("NPCs")
    if npcs then
        for _, npc in pairs(npcs:GetChildren()) do
            if npc.Name == npcName and npc:FindFirstChild("HumanoidRootPart") then
                return npc.HumanoidRootPart.CFrame
            end
        end
    end
    local repNPCs = ReplicatedStorage:FindFirstChild("NPCs")
    if repNPCs then
        for _, npc in pairs(repNPCs:GetChildren()) do
            if npc.Name == npcName and npc:FindFirstChild("HumanoidRootPart") then
                return npc.HumanoidRootPart.CFrame
            end
        end
    end
    return nil
end

local function GetQuests()
    local lvl = 1
    if player:FindFirstChild("Data") and player.Data:FindFirstChild("Level") then
        lvl = player.Data.Level.Value
    end

    local LevelReq = 0
    local mmb = {}
    
    if lvl >= 700 and CheckSea(1) then
        mmb["Mob"] = "Galley Captain"
        mmb["NameQuest"] = "FountainQuest"
        mmb["ID"] = 2
        mmb["LevelReq"] = 700
    elseif lvl >= 1500 and CheckSea(2) then
        mmb["Mob"] = "Water Fighter"
        mmb["NameQuest"] = "ForgottenQuest"
        mmb["ID"] = 2
        mmb["LevelReq"] = 1450
    else
        if Quests then
            for r, v in pairs(Quests) do
                for id, v1 in pairs(v) do
                    local LvReq = v1.LevelReq
                    if v1.Task then
                        for nguoi, tinh in pairs(v1.Task) do
                            if lvl >= LvReq and LevelReq <= LvReq and v1.Task[nguoi] > 1 and not table.find(blacklistquest, r) then
                                LevelReq = LvReq
                                mmb["Mob"] = nguoi
                                mmb["NameQuest"] = r
                                mmb["ID"] = id
                                mmb["LevelReq"] = LvReq
                            end
                        end
                    end
                end
            end
        end
    end
    
    return mmb
end

local function GetQuestPoint()
    if GuideModule and GuideModule.Data and GuideModule.Data.LastClosestNPC then
        return GetQuestPointFromNPC(GuideModule.Data.LastClosestNPC)
    end
    return nil
end

local function QuestNeta()
    local questData = GetQuests()
    return {
        = questData.Mob,           
        = questData.ID,             
        [3] = questData.NameQuest,      
        [4] = questData.LevelReq,       
        [5] = questData.Mob,             
        [6] = GetQuestPoint()            
    }
end

local function IsInSubmergedIsland()
    local char = player.Character
    if not char then return false end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end

    local islandXZ = Vector3.new(11520.8017578125, 0, 9829.513671875)
    local playerXZ = Vector3.new(hrp.Position.X, 0, hrp.Position.Z)
    return (playerXZ - islandXZ).Magnitude < 2000
end

----------------------------------------------------------------
-- CHỨC NĂNG GOM QUÁI (BRING ENEMY / BRING MOBS)
----------------------------------------------------------------

local function BringEnemy(Mon)
    if not bringMobEnabled then return end
    
    if not Mon then 
        local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        
        local closestDist = math.huge
        local enemiesFolder = Workspace:FindFirstChild("Enemies")
        if enemiesFolder then
            for _, enemy in ipairs(enemiesFolder:GetChildren()) do
                local hum = enemy:FindFirstChildOfClass("Humanoid")
                local root = enemy:FindFirstChild("HumanoidRootPart")
                if hum and root and hum.Health > 0 then
                    local dist = (root.Position - hrp.Position).Magnitude
                    if dist < closestDist then
                        closestDist = dist
                        Mon = enemy
                    end
                end
            end
        end
        if not Mon then return end
    end
    
    local AreaMob = false
    
    local function Mobs(enemy)
        local hum = enemy:FindFirstChildOfClass("Humanoid")
        local root = enemy:FindFirstChild("HumanoidRootPart")
        return hum and root and hum.Health > 0, root, hum
    end

    local function Network(part)
        if isnetworkowner then
            return isnetworkowner(part)
        end
        return part.ReceiveAge == 0 and not part.Anchored and part.Velocity.Magnitude > 0
    end
    
    pcall(function()
        if sethiddenproperty then 
            sethiddenproperty(player, "SimulationRadius", math.huge)
        end
        
        local targetPos = Mon.HumanoidRootPart.Position
        local enemiesFolder = Workspace:FindFirstChild("Enemies")
        if not enemiesFolder then return end
        
        for _, v in ipairs(enemiesFolder:GetChildren()) do
            if v ~= Mon then
                local alive, root, hum = Mobs(v)
                if alive and v.Name == Mon.Name then
                    local distance = (root.Position - targetPos).Magnitude
                    if distance <= 3000 then
                        local bv = root:FindFirstChild("BodyVelocity")
                        if not bv then
                            bv = Instance.new("BodyVelocity")
                            bv.Name = "BodyVelocity"
                            bv.MaxForce = Vector3.new(1e9, 1e9, 1e9)
                            bv.Velocity = Vector3.zero
                            bv.Parent = root
                        end
                        
                        if distance <= 10 then
                            AreaMob = true
                        end
                        
                        if not AreaMob and Network(root) then
                            root.CFrame = CFrame.new(targetPos)
                        end
                        
                        root.CanCollide = false
                        hum.WalkSpeed = 0
                        hum.JumpPower = 0
                    end
                end
            end
        end
        
        if Mon and Mon:FindFirstChild("HumanoidRootPart") then
            Mon.HumanoidRootPart.CanCollide = false
            local mainHum = Mon:FindFirstChildOfClass("Humanoid")
            if mainHum then
                mainHum.WalkSpeed = 0
                mainHum.JumpPower = 0
            end
        end
    end)
end

----------------------------------------------------------------
-- HỆ THỐNG DI CHUYỂN, NOCLIP & KHÓA VỊ TRÍ TRÊN KHÔNG
----------------------------------------------------------------

local noclipConnection = nil
local currentTween = nil

local function freezePosition(root)
    if not root then return end
    
    local bv = root:FindFirstChild("FarmBodyVelocity")
    if not bv then
        bv = Instance.new("BodyVelocity")
        bv.Name = "FarmBodyVelocity"
        bv.MaxForce = Vector3.new(1e9, 1e9, 1e9)
        bv.Velocity = Vector3.zero
        bv.Parent = root
    else
        bv.Velocity = Vector3.zero
    end
    
    root.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
    root.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
end

local function unfreezePosition(root)
    if root then
        local bv = root:FindFirstChild("FarmBodyVelocity")
        if bv then
            bv:Destroy()
        end
    end
end

local function enableNoclip()
    if not noclipConnection then
        noclipConnection = RunService.Stepped:Connect(function()
            if autoFarmLevelEnabled and player.Character then
                for _, part in ipairs(player.Character:GetDescendants()) do
                    if part:IsA("BasePart") and part.CanCollide then
                        part.CanCollide = false
                    end
                end
            end
        end)
    end
end

local function disableNoclip()
    if noclipConnection then
        noclipConnection:Disconnect()
        noclipConnection = nil
    end
end

local function tweenTo(targetCFrame)
    local char = player.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end

    unfreezePosition(root)

    local distance = (root.Position - targetCFrame.Position).Magnitude
    local time = distance / TWEEN_SPEED

    if time < 0.1 then
        root.CFrame = targetCFrame
        freezePosition(root)
        return
    end

    enableNoclip()

    local tweenInfo = TweenInfo.new(time, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
    currentTween = TweenService:Create(root, tweenInfo, {CFrame = targetCFrame})
    currentTween:Play()
    currentTween.Completed:Wait()

    freezePosition(root)
end

----------------------------------------------------------------
-- GIỮ NGUYÊN HOÀN TOÀN LOGIC AUTO ATTACK BẢN CỦA BẠN
----------------------------------------------------------------

local function getTargetPart(enemy)
    if not enemy or not enemy.Parent then return nil end
    
    local rightArm = enemy:FindFirstChild("RightLowerArm")
    if rightArm and rightArm:IsA("BasePart") then
        return rightArm
    end
    
    local rootPart = enemy:FindFirstChild("HumanoidRootPart")
    if rootPart and rootPart:IsA("BasePart") then
        return rootPart
    end
    
    for _, child in ipairs(enemy:GetChildren()) do
        if child:IsA("BasePart") then
            return child
        end
    end
    
    return nil
end

local function attackEnemy(enemy)
    if not enemy or not enemy.Parent then return end
    
    local humanoid = enemy:FindFirstChildOfClass("Humanoid")
    if not humanoid or humanoid.Health <= 0 then return end
    
    local targetPart = getTargetPart(enemy)
    if not targetPart then return end
    
    -- 1. Gửi Remote kích hoạt trạng thái tấn công (nếu game có Remote này)
    if RegisterAttack then
        pcall(function()
            RegisterAttack:FireServer()
        end)
    end
    
    -- 2. Gửi Remote RegisterHit đăng ký sát thương
    pcall(function()
        RegisterHit:FireServer(targetPart, {}, nil, HIT_ID)
    end)
end

local function getPlayerRoot()
    local char = player.Character
    if char then
        return char:FindFirstChild("HumanoidRootPart")
    end
    return nil
end

----------------------------------------------------------------
-- LOGIC AUTO FARM LEVEL (THEO BẢN UPDATE GỐC)
----------------------------------------------------------------

local alreadyTeleported = false
local teleporting = false

local function autoFarmLevelTick()
    if not autoFarmLevelEnabled then return end
    
    local char = player.Character
    if not char then return end
    
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if not humanoid or humanoid.Health <= 0 then return end
    
    local Root = char:FindFirstChild("HumanoidRootPart")
    if not Root then return end
    
    local level = player:FindFirstChild("Data") and player.Data:FindFirstChild("Level") and player.Data.Level.Value or 1
    local inSub = IsInSubmergedIsland()
    
    local mainGui = player.PlayerGui:FindFirstChild("Main")
    local questUI = mainGui and mainGui:FindFirstChild("Quest")
    local QuestTitle = (questUI and questUI.Visible and questUI:FindFirstChild("Container") and questUI.Container:FindFirstChild("QuestTitle")) and questUI.Container.QuestTitle.Title.Text or ""

    -- 1. Xử lý dịch chuyển đến Submerged Island (Lv 2600+)
    if level >= 2600 and not inSub and not teleporting and not alreadyTeleported then
        teleporting = true
        local npcPos = CFrame.new(-16269.7041, 25.2288494, 1373.65955)
        local teleportAttempts = 0
        
        repeat 
            task.wait(Sec)
            tweenTo(npcPos)
            teleportAttempts = teleportAttempts + 1
        until not autoFarmLevelEnabled or (Root.Position - npcPos.Position).Magnitude <= 8 or teleportAttempts > 20

        if not autoFarmLevelEnabled then 
            teleporting = false
            return 
        end

        task.wait(1)
        
        pcall(function()
            if RFSubmarineWorkerSpeak then
                RFSubmarineWorkerSpeak:InvokeServer("TravelToSubmergedIsland")
            end
        end)

        local timeout = tick()
        repeat 
            task.wait(0.5)
            local currentInSub = IsInSubmergedIsland()
            local farFromNPC = (Root.Position - npcPos.Position).Magnitude > 50
            if currentInSub or farFromNPC then
                break
            end
        until not autoFarmLevelEnabled or tick() - timeout > 15

        task.wait(2)
        alreadyTeleported = true
        teleporting = false
        return
    end

    -- 2. Tiến hành nhận Quest và Farm
    alreadyTeleported = true
    teleporting = false

    local questData = QuestNeta()
    if not questData or not questData then
        task.wait(1)
        return
    end

    -- Hủy quest nếu sai loại quái
    if questUI and questUI.Visible and not string.find(QuestTitle, tostring(questData)) then
        if CommF then
            pcall(function()
                CommF:InvokeServer("AbandonQuest")
            end)
        end
        task.wait(0.2)
        return
    end

    -- Nhận Quest từ NPC nếu chưa có Quest
    if not questUI or not questUI.Visible then
        local questPos = questData[6]
        if questPos then
            if (Root.Position - questPos.Position).Magnitude > 12 then
                tweenTo(questPos)
            else
                freezePosition(Root)
                if CommF then
                    pcall(function()
                        CommF:InvokeServer("StartQuest", questData[3], questData)
                    end)
                end
                task.wait(0.5)
            end
        else
            if CommF then
                pcall(function()
                    CommF:InvokeServer("StartQuest", questData[3], questData)
                end)
            end
            task.wait(0.5)
        end
        return
    end

    -- Tìm và tiêu diệt Quái vật
    local enemyName = questData
    local foundMob = false
    local enemiesFolder = Workspace:FindFirstChild("Enemies")

    if enemiesFolder then
        for _, v in pairs(enemiesFolder:GetChildren()) do
            if v.Name == enemyName and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 and v:FindFirstChild("HumanoidRootPart") then
                foundMob = true
                
                -- Thực hiện gom quái về vị trí quái mục tiêu
                BringEnemy(v)
                
                -- Vị trí Hover cố định 15 studs phía trên quái
                local targetPos = v.HumanoidRootPart.CFrame * CFrame.new(0, 15, 0)
                
                if (Root.Position - v.HumanoidRootPart.Position).Magnitude > 12 then
                    tweenTo(targetPos)
                else
                    freezePosition(Root)
                    Root.CFrame = targetPos
                    attackEnemy(v)
                end
                break
            end
        end
    end

    -- Tìm quái dự phòng trong ReplicatedStorage hoặc Spawns
    if not foundMob then
        for _, v in pairs(ReplicatedStorage:GetChildren()) do
            if v.Name == enemyName and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 and v:FindFirstChild("HumanoidRootPart") then
                foundMob = true
                tweenTo(v.HumanoidRootPart.CFrame * CFrame.new(0, 20, 0))
                break
            end
        end
    end

    if not foundMob then
        local worldOrigin = Workspace:FindFirstChild("_WorldOrigin")
        local spawns = worldOrigin and worldOrigin:FindFirstChild("EnemySpawns")
        if spawns then
            for _, spawnPoint in pairs(spawns:GetChildren()) do
                if string.find(spawnPoint.Name, enemyName) then
                    tweenTo(spawnPoint.CFrame * CFrame.new(0, 20, 0))
                    break
                end
            end
        end
    end
end

----------------------------------------------------------------
-- GIAO DIỆN MENU (GUI)
----------------------------------------------------------------

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AmethystHubGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = player:WaitForChild("PlayerGui")

local Frame = Instance.new("Frame")
Frame.Name = "MainFrame"
Frame.Size = UDim2.new(0, 210, 0, 175)
Frame.Position = UDim2.new(0, 20, 0, 100)
Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Frame.BorderSizePixel = 0
Frame.Active = true
Frame.Parent = ScreenGui

local FrameCorner = Instance.new("UICorner")
FrameCorner.CornerRadius = UDim.new(0, 8)
FrameCorner.Parent = Frame

local FrameStroke = Instance.new("UIStroke")
FrameStroke.Color = Color3.fromRGB(70, 70, 70)
FrameStroke.Thickness = 1.5
FrameStroke.Parent = Frame

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Name = "TitleLabel"
TitleLabel.Size = UDim2.new(1, 0, 0, 25)
TitleLabel.Position = UDim2.new(0, 0, 0, 4)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "AMETHYST HUB"
TitleLabel.TextColor3 = Color3.fromRGB(180, 100, 255)
TitleLabel.Font = Enum.Font.SourceSansBold
TitleLabel.TextSize = 16
TitleLabel.Parent = Frame

-- Nút 1: Auto Attack
local ToggleButton1 = Instance.new("TextButton")
ToggleButton1.Name = "ToggleButton1"
ToggleButton1.Size = UDim2.new(1, -20, 0, 35)
ToggleButton1.Position = UDim2.new(0, 10, 0, 32)
ToggleButton1.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
ToggleButton1.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton1.Text = "Auto Attack: TẮT"
ToggleButton1.Font = Enum.Font.SourceSansBold
ToggleButton1.TextSize = 14
ToggleButton1.Parent = Frame

local Button1Corner = Instance.new("UICorner")
Button1Corner.CornerRadius = UDim.new(0, 6)
Button1Corner.Parent = ToggleButton1

-- Nút 2: Auto Farm Level
local ToggleButton2 = Instance.new("TextButton")
ToggleButton2.Name = "ToggleButton2"
ToggleButton2.Size = UDim2.new(1, -20, 0, 35)
ToggleButton2.Position = UDim2.new(0, 10, 0, 74)
ToggleButton2.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
ToggleButton2.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton2.Text = "Auto Farm Level: TẮT"
ToggleButton2.Font = Enum.Font.SourceSansBold
ToggleButton2.TextSize = 14
ToggleButton2.Parent = Frame

local Button2Corner = Instance.new("UICorner")
Button2Corner.CornerRadius = UDim.new(0, 6)
Button2Corner.Parent = ToggleButton2

-- Nút 3: Gom Quái (Bring Mobs)
local ToggleButton3 = Instance.new("TextButton")
ToggleButton3.Name = "ToggleButton3"
ToggleButton3.Size = UDim2.new(1, -20, 0, 35)
ToggleButton3.Position = UDim2.new(0, 10, 0, 116)
ToggleButton3.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
ToggleButton3.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton3.Text = "Gom Quái: BẬT"
ToggleButton3.Font = Enum.Font.SourceSansBold
ToggleButton3.TextSize = 14
ToggleButton3.Parent = Frame

local Button3Corner = Instance.new("UICorner")
Button3Corner.CornerRadius = UDim.new(0, 6)
Button3Corner.Parent = ToggleButton3

-- Dragging GUI
local dragging = false
local dragInput, dragStart, startPos

local function updateInput(input)
    local delta = input.Position - dragStart
    Frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

Frame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = Frame.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

Frame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        updateInput(input)
    end
end)

-- Cập nhật giao diện nút
local function updateButton1UI()
    if autoAttackEnabled then
        ToggleButton1.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
        ToggleButton1.Text = "Auto Attack: BẬT"
    else
        ToggleButton1.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        ToggleButton1.Text = "Auto Attack: TẮT"
    end
end

local function updateButton2UI()
    if autoFarmLevelEnabled then
        ToggleButton2.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
        ToggleButton2.Text = "Auto Farm Level: BẬT"
    else
        ToggleButton2.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        ToggleButton2.Text = "Auto Farm Level: TẮT"
    end
end

local function updateButton3UI()
    if bringMobEnabled then
        ToggleButton3.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
        ToggleButton3.Text = "Gom Quái: BẬT"
    else
        ToggleButton3.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        ToggleButton3.Text = "Gom Quái: TẮT"
    end
end

ToggleButton1.MouseButton1Click:Connect(function()
    autoAttackEnabled = not autoAttackEnabled
    updateButton1UI()
end)

ToggleButton2.MouseButton1Click:Connect(function()
    autoFarmLevelEnabled = not autoFarmLevelEnabled
    if autoFarmLevelEnabled then
        autoAttackEnabled = true
        updateButton1UI()
    else
        disableNoclip()
        if currentTween then
            currentTween:Cancel()
        end
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            unfreezePosition(player.Character.HumanoidRootPart)
        end
    end
    updateButton2UI()
end)

ToggleButton3.MouseButton1Click:Connect(function()
    bringMobEnabled = not bringMobEnabled
    updateButton3UI()
end)

----------------------------------------------------------------
-- VÒNG LẶP CHÍNH
----------------------------------------------------------------

task.spawn(function()
    while true do
        -- 1. Xử lý Auto Farm Level
        if autoFarmLevelEnabled then
            pcall(autoFarmLevelTick)
        end
        
        -- 2. Xử lý Auto Attack độc lập (khi bật Auto Attack riêng không bật Auto Farm Level)
        if autoAttackEnabled and not autoFarmLevelEnabled then
            local myRoot = getPlayerRoot()
            local enemiesFolder = Workspace:FindFirstChild("Enemies")
            
            if myRoot and enemiesFolder then
                local enemiesList = {}
                
                for _, enemy in ipairs(enemiesFolder:GetChildren()) do
                    if enemy:IsA("Model") then
                        local enemyRoot = enemy:FindFirstChild("HumanoidRootPart")
                        local humanoid = enemy:FindFirstChildOfClass("Humanoid")
                        
                        if enemyRoot and humanoid and humanoid.Health > 0 then
                            local dist = (myRoot.Position - enemyRoot.Position).Magnitude
                            if dist <= MAX_DISTANCE then
                                table.insert(enemiesList, {model = enemy, distance = dist})
                            end
                        end
                    end
                end
                
                -- Sắp xếp ưu tiên kẻ địch gần nhất
                table.sort(enemiesList, function(a, b)
                    return a.distance < b.distance
                end)
                
                if #enemiesList > 0 and bringMobEnabled then
                    BringEnemy(enemiesList.model)
                end
                
                for _, entry in ipairs(enemiesList) do
                    if not autoAttackEnabled then break end
                    attackEnemy(entry.model)
                end
            end
        end
        
        task.wait(ATTACK_DELAY)
    end
end)
