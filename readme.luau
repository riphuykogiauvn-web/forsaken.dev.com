-- Tải thư viện WindUI
local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()

-- Khởi tạo Cửa sổ chính (Window)
local Window = WindUI:CreateWindow({
    Title = "AMETHYST HUB", 
    Icon = "diamond", 
    Author = "HUYKOGIAUVN",
    Folder = "AmethystHub_Config", 
    Size = UDim2.fromOffset(600, 450), 
    Transparent = true, 
    Theme = "Midnight", 
    SideBarWidth = 180,
    HasOutline = true
})

-- Tạo nút mở/đóng Menu nổi trên màn hình cho Delta X
Window:EditOpenButton({
    Title = "AMETHYST HUB",
    Icon = "menu",
    CornerRadius = UDim.new(0, 10),
    StrokePixels = 1,
    StrokeColor = Color3.fromRGB(138, 43, 226) 
})

-- ==========================================
-- HỆ THỐNG GẮN ẢNH NỀN (BACKGROUND) CHO MENU (Bypass gethui & Decal ID)
-- ==========================================
task.spawn(function()
    task.wait(2.5) -- Đợi UI load hoàn toàn 100% và chạy xong animation
    pcall(function()
        -- BÍ QUYẾT: Dùng gethui() để xuyên qua lớp bảo vệ của Executor (Delta, ArceusX, CodeX...)
        local guiHoster = (gethui and gethui()) or game:GetService("CoreGui")
        local foundMain = false -- Chốt chặn: Chỉ cho phép dán 1 ảnh duy nhất!
        
        for _, screen in pairs(guiHoster:GetChildren()) do
            if screen:IsA("ScreenGui") and not foundMain then
                for _, frame in pairs(screen:GetDescendants()) do
                    if (frame:IsA("Frame") or frame:IsA("CanvasGroup")) and not foundMain then
                        local defaultBg = frame:FindFirstChild("Background")
                        
                        -- Lọc tìm khung tổng ngoài cùng, bỏ qua các khung nội dung nhỏ
                        if defaultBg and defaultBg:IsA("ImageLabel") and frame.AbsoluteSize.X > 250 and frame.AbsoluteSize.Y > 200 then
                            foundMain = true -- Đã tìm thấy khung chính, khóa vòng lặp lại!
                            
                            if not frame:FindFirstChild("Amethyst_BG") then
                                
                                -- FIX LỖI ẢNH TỐI MỜ CHUẨN XÁC: Đánh bay lớp kính nền đen mặc định của thư viện WindUI
                                defaultBg.ImageTransparency = 0.45 -- ĐỘ MỜ MENU LÀ 0.45 (KHÔNG PHẢI ẢNH)
                                
                                -- FIX LỖI TỐI LẠI KHI MỞ MENU LẦN 2 (Chống Lag - Dùng Event):
                                -- Bắt thóp hiệu ứng tắt/mở của WindUI, khóa vĩnh viễn không cho nó đen hơn 0.45
                                defaultBg:GetPropertyChangedSignal("ImageTransparency"):Connect(function()
                                    if defaultBg.ImageTransparency < 0.45 then
                                        defaultBg.ImageTransparency = 0.45
                                    end
                                end)
                                
                                local bg = Instance.new("ImageLabel")
                                bg.Name = "Amethyst_BG"
                                bg.Size = UDim2.new(1, 0, 1, 0)
                                bg.Position = UDim2.new(0, 0, 0, 0)
                                bg.BackgroundTransparency = 1
                                
                                -- Ép load ảnh bằng định dạng siêu cấp rbxthumb để bypass lỗi Decal ID
                                bg.Image = "rbxthumb://type=Asset&id=123903292773405&w=420&h=420"
                                
                                -- Độ mờ ảnh giữ nguyên 15%
                                bg.ImageTransparency = 0.15 
                                bg.ScaleType = Enum.ScaleType.Crop
                                bg.ZIndex = 0 -- Đưa ảnh xuống dưới để lớp mờ menu 0.45 phủ lên làm tối ảnh như cũ
                                bg.Parent = frame
                                
                                local corner = Instance.new("UICorner")
                                corner.CornerRadius = UDim.new(0, 10)
                                corner.Parent = bg
                            end
                        end
                    end
                end
            end
        end
    end)
end)

-------------------------------------------------------------------------
-- HÀM HỖ TRỢ ESP (SIÊU NHẸ - TỐI ƯU FPS)
-------------------------------------------------------------------------
local function AddESP(Target, Name, HP, Color)
    -- NÂNG CẤP: Cập nhật HP liên tục theo thời gian thực nếu ESP đã tồn tại
    if Target:FindFirstChild("Amethyst_Billboard") then
        local existingText = Target.Amethyst_Billboard:FindFirstChild("TextLabel")
        if existingText then
            local finalText = Name
            if HP then finalText = finalText .. " | HP: " .. tostring(math.floor(HP)) end
            existingText.Text = finalText
        end
    end

    -- Tránh trùng lặp tạo mới Highlight/Aura nếu đã có
    if Target:FindFirstChild("Amethyst_Highlight") then return end
    
    -- 1. Tạo Aura (Highlight)
    local Highlight = Instance.new("Highlight")
    Highlight.Name = "Amethyst_Highlight"
    Highlight.Adornee = Target
    Highlight.FillColor = Color
    Highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    Highlight.FillTransparency = 0.5
    Highlight.OutlineTransparency = 0.2
    Highlight.Parent = Target
    
    -- 2. Tạo Text hiển thị Tên + HP
    local Billboard = Instance.new("BillboardGui")
    Billboard.Name = "Amethyst_Billboard"
    Billboard.Adornee = Target
    Billboard.Size = UDim2.new(0, 150, 0, 40)
    Billboard.StudsOffset = Vector3.new(0, 4, 0) -- Nổi lên trên đầu
    Billboard.AlwaysOnTop = true
    
    local Text = Instance.new("TextLabel")
    Text.Name = "TextLabel"
    Text.Size = UDim2.new(1, 0, 1, 0)
    Text.BackgroundTransparency = 1
    
    -- Gộp Tên và HP nếu có
    local finalText = Name
    if HP then finalText = finalText .. " | HP: " .. tostring(math.floor(HP)) end
    
    Text.Text = finalText
    Text.TextColor3 = Color
    Text.TextStrokeTransparency = 0 -- Viền đen để dễ đọc chữ
    Text.TextScaled = false
    Text.TextSize = 14
    Text.Font = Enum.Font.SourceSansBold
    Text.Parent = Billboard
    
    Billboard.Parent = Target
end

local function RemoveESP(Target)
    if Target then
        if Target:FindFirstChild("Amethyst_Highlight") then Target.Amethyst_Highlight:Destroy() end
        if Target:FindFirstChild("Amethyst_Billboard") then Target.Amethyst_Billboard:Destroy() end
    end
end

-------------------------------------------------------------------------
-- TẠO CÁC TAB & GIAO DIỆN
-------------------------------------------------------------------------

-- ======================================================================
-- ĐẦU MỤC: HOME
-- ======================================================================
Window:Divider({ Title = "HOME" })

-- INFORMATION (Icon: info)
local TabInformation = Window:Tab({ Title = "Information", Icon = "info" })

-- 1. THÔNG TIN TÁC GIẢ
TabInformation:Section({ Title = "Thông Tin Chung" })
TabInformation:Paragraph({
    Title = "Tác Giả & Phiên Bản",
    Desc = "Tác giả: HUYKOGIAUVN\nPhiên bản: 1.0\n\nCẢM ƠN MỌI NGƯỜI ĐÃ DÙNG SCRIPT ^-^"
})

-- 2. NHẬT KÝ CẬP NHẬT (Changelog)
TabInformation:Section({ Title = "Nhật Ký Cập Nhật (Update Log)" })
TabInformation:Paragraph({
    Title = "[Phiên bản 1.0] - Cập nhật mới",
    Desc = "- Khởi tạo thành công khung giao diện AMETHYST HUB.\n- Thêm ESP Player, Items, PizzaDeliveryRig.\n- FIX LAG TRIỆT ĐỂ: Dùng Event thay thế vòng lặp cho phần quét.\n- FIX HIỂN THỊ HP: Máu cập nhật chuẩn xác theo thời gian thực.\n- Thêm mục AZURE (GroundBulbModel, VineModel).\n- FIX NHẬN NHẦM: 007N7 ESP bỏ qua người thật, tự xóa khi Clone chết.\n- CẬP NHẬT MỚI (VII TAPH): Thêm ESP cho SubspaceTripmine và TaphTripwire.\n- CẬP NHẬT GIAO DIỆN (HOT): Đã fix lỗi giấu UI của executor, ép load ảnh nền thành công bằng phương thức rbxthumb Bypass.\n- FIX ÁNH SÁNG UI (CHUẨN): Đã chọc thẳng vào nhân (Background) của WindUI để tẩy trong suốt lớp nền đen của Theme Dark. Giờ Waifu đã nổi bật 100%!\n- FIX VĨNH VIỄN LỖI ẢNH TỐI: Gắn thêm Event siêu mượt để chống lại việc thư viện WindUI tự động reset lớp màu nền đen mỗi khi đóng/mở menu.\n- AUTO SAVE TỐI THƯỢNG: Hệ thống quét lõi siêu ngầm, tự động lưu lại toàn bộ các nút ESP và Theme vào máy, 0% lag, vào lại game vẫn y nguyên.\n- CẬP NHẬT MỚI (III PizzaDeliveryRig): Gộp thêm 4 Bot MAFIA (MAFIA1, MAFIA2, MAFIA3, MAFIA4) vào tính năng ESP, tự động nhận diện và hiển thị chính xác tên gốc của từng Bot trên định vị.\n- CẬP NHẬT MỚI (STAMINA): Đã trích xuất và lắp ráp thành công tính năng Bất tử thể lực (Infinity Stamina) vào Tab Stamina và hỗ trợ tùy chỉnh tối đa 10.000.\n- CẬP NHẬT MỚI (SURVIVE): Thêm chức năng CHANCE nhận diện súng Flintlock trên tay để Auto Aimbot Pizza Guy. BẢN CẬP EVENT KÉP CHỐNG LAG TỐI THƯỢNG.\n- CẬP NHẬT MỚI (SURVIVE): Thêm chức năng SHEDLETSKY nhận diện kiếm Sword trên tay để Auto Aimbot Pizza Guy (40 Studs).\n- CẬP NHẬT MỚI (SURVIVE - JANE DOE): Đã COPY FULL BẢN GỐC CHUẨN XÁC TỪ FILE V27 TÍCH HỢP VIP SHIFTLOCK THEO ĐÚNG LỆNH SẾP.\n- CẬP NHẬT MỚI (SURVIVE - JANE DOE): Thay đổi cơ chế Aimbot Ném Lọ (Crystal Pitch) tự động đọc giao diện Thanh Xanh Lá (Charge).\n- FIX ESP (SURVIVE & KILLER): Cập nhật công nghệ HealthChanged Event, cho phép máu của Killer và Survivor tuột ngay lập tức trên màn hình định vị.\n- FIX ESP (SUBSPACE TRIPMINE): Đã tháo bỏ giới hạn nhận diện Part lẻ, bây giờ Aura sẽ bao phủ và làm sáng rực toàn bộ 100% thân của quả mìn.\n- FIX ẢNH NỀN (HOT): Đã dập tắt lỗi dán 2 ảnh Waifu đè nhau trên điện thoại.\n- CẬP NHẬT MỚI (GENERATOR): Bê thành công lõi Auto Farm V3 (Sửa luân phiên từng vạch) từ bản cũ đắp sang. Thêm tính năng sửa nhanh 1.2s/vạch không tự giữ nút E."
})

-- 3. MẠNG XÃ HỘI & DISCORD (Có đếm member)
TabInformation:Section({ Title = "Cộng Đồng (Discord)" })

-- Code lấy dữ liệu API từ mã mời Discord
local inviteCode = "TXws5EF4C"
local memberCount = "Đang tải..."
local onlineCount = "Đang tải..."

pcall(function()
    local HttpService = game:GetService("HttpService")
    local req = game:HttpGet("https://discord.com/api/v9/invites/" .. inviteCode .. "?with_counts=true")
    local decoded = HttpService:JSONDecode(req)
    if decoded and decoded.approximate_member_count then
        memberCount = tostring(decoded.approximate_member_count)
        onlineCount = tostring(decoded.approximate_presence_count)
    end
end)

TabInformation:Paragraph({
    Title = "Thống Kê Server AMETHYST HUB",
    Desc = "Tổng thành viên: " .. memberCount .. "\nĐang hoạt động (Online): " .. onlineCount
})

TabInformation:Button({
    Title = "Tham gia Discord Server",
    Desc = "Nhấn vào đây để Copy Link",
    Callback = function()
        if setclipboard then
            setclipboard("https://discord.gg/TXws5EF4C")
            WindUI:Notify({
                Title = "Thành Công",
                Content = "Đã copy link Discord vào khay nhớ tạm!",
                Duration = 3,
                Icon = "check"
            })
        end
    end
})

-- 4. THÔNG TIN NGƯỜI CHƠI & EXECUTOR
TabInformation:Section({ Title = "Thông Số Của Bạn" })
local executorName = identifyexecutor and identifyexecutor() or "Không xác định"
local playerName = game.Players.LocalPlayer.Name
local displayName = game.Players.LocalPlayer.DisplayName

TabInformation:Paragraph({
    Title = "Dữ Liệu Người Dùng",
    Desc = "Tên hiển thị: " .. displayName .. "\nTên tài khoản (User): " .. playerName .. "\nPhần mềm chạy (Executor): " .. executorName
})

-- 5. LỜI KHUYÊN / CẢNH BÁO
TabInformation:Section({ Title = "Cảnh Báo An Toàn" })
TabInformation:Paragraph({
    Title = "Chú ý khi dùng Script!",
    Desc = "1. Khuyến cáo nên dùng tài khoản phụ (Clone) để test trước khi dùng ở acc chính.\n2. Lạm dụng tính năng Auto quá đà có thể khiến game bị lỗi văng hoặc bị hệ thống game phát hiện (Ban).\n3. Hãy bật chức năng ở mức độ vừa phải để có trải nghiệm an toàn nhất!"
})

-- ======================================================================
-- ĐẦU MỤC: MAIN
-- ======================================================================
Window:Divider({ Title = "MAIN" })

-- 1. MAIN (Icon: Ngôi nhà)
local TabMain = Window:Tab({ Title = "Main", Icon = "house" })
TabMain:Paragraph({
    Title = "Thông Báo",
    Desc = "Chức năng đang được Update..."
})

-- 2. STAMINA (Icon: Năng lượng)
local TabStamina = Window:Tab({ Title = "Stamina", Icon = "zap" })

TabStamina:Section({ Title = "I INFINITY STAMINA" })

TabStamina:Toggle({
    Title = "Bất tử thể lực (Gốc)",
    Desc = "Bơm liên tục và giữ thể lực luôn ở mức 100",
    Default = false,
    Callback = function(State)
        getgenv().InfStamina_Basic = State
        if State then
            task.spawn(function()
                while getgenv().InfStamina_Basic do
                    task.wait()
                    pcall(function()
                        require(game.ReplicatedStorage.Systems.Character.Game.Sprinting).Stamina = 100
                    end)
                end
            end)
        end
    end
})

TabStamina:Section({ Title = "II INFINITY STAMINA CHỈNH" })

getgenv().Amethyst_StaminaAmount = 100 -- Biến lưu trữ thể lực (Mặc định 100)

TabStamina:Input({
    Title = "Mức Thể Lực (Max 10000)",
    Default = "100",
    Placeholder = "Nhập số lượng...",
    Numeric = true,
    Finished = true,
    Callback = function(Text)
        local num = tonumber(Text)
        if num then
            -- Chốt chặn 10.000 để chống văng/lỗi game
            if num > 10000 then num = 10000 end
            getgenv().Amethyst_StaminaAmount = num
            WindUI:Notify({
                Title = "AMETHYST HUB",
                Content = "Đã chỉnh mức Thể lực thành: " .. num,
                Duration = 2,
                Icon = "check"
            })
        end
    end
})

TabStamina:Toggle({
    Title = "Bơm Thể Lực (Tùy Chỉnh)",
    Desc = "Bơm liên tục và giữ cứng ở mức thể lực đã gõ",
    Default = false,
    Callback = function(State)
        getgenv().InfStamina_Custom = State
        if State then
            task.spawn(function()
                while getgenv().InfStamina_Custom do
                    task.wait()
                    pcall(function()
                        require(game.ReplicatedStorage.Systems.Character.Game.Sprinting).Stamina = getgenv().Amethyst_StaminaAmount
                    end)
                end
            end)
        end
    end
})

-- 3. SURVIVE (Icon: Hình người)
local TabSurvive = Window:Tab({ Title = "Survive", Icon = "user" })

TabSurvive:Section({ Title = "I CHANCE" })

TabSurvive:Toggle({
    Title = "Aimbot Pizza Guy (Flintlock)",
    Desc = "Auto Aimbot NPC Pizza Guy (150 Studs) | HỆ THỐNG EVENT KÉP CHỐNG LAG TỐI ĐA",
    Default = false,
    Callback = function(State)
        getgenv().Amethyst_ChanceAimbot = State
        
        if State then
            local LocalPlayer = game.Players.LocalPlayer
            
            -- [HỆ THỐNG BỘ NHỚ ĐỆM KÉP: PIZZA GUY VÀ SÚNG]
            getgenv().Amethyst_PizzaGuyList = {}
            getgenv().Amethyst_CachedFlintlock = nil
            
            -- Hàm nạp Pizza Guy
            local function checkAndAddPizzaGuy(obj)
                if obj:IsA("Model") then
                    local lowerName = string.lower(obj.Name)
                    if string.match(lowerName, "pizza guy") or string.match(lowerName, "pizzaguy") then
                        table.insert(getgenv().Amethyst_PizzaGuyList, obj)
                    end
                end
            end
            
            -- Hàm nạp Súng (Flintlock)
            local function checkAndCacheGun(obj)
                if string.match(string.lower(obj.Name), "flintlock") then
                    getgenv().Amethyst_CachedFlintlock = obj
                end
            end
            
            -- Quét 1 lần duy nhất để tìm các con Pizza Guy đang có sẵn
            for _, obj in pairs(workspace:GetDescendants()) do
                checkAndAddPizzaGuy(obj)
            end
            
            -- Quét 1 lần duy nhất tìm súng trên người nếu đã cầm sẵn
            if LocalPlayer.Character then
                for _, obj in pairs(LocalPlayer.Character:GetDescendants()) do
                    checkAndCacheGun(obj)
                end
            end
            
            -- Canh chừng Event 1: Spawn Pizza Guy
            getgenv().Amethyst_ChanceAimbotConn = workspace.DescendantAdded:Connect(function(obj)
                task.wait(0.5) 
                if getgenv().Amethyst_ChanceAimbot then
                    checkAndAddPizzaGuy(obj)
                end
            end)
            
            -- Canh chừng Event 2: Móc súng vào Character (Chống lag tuyệt đối thay vì quét vòng lặp)
            local function hookChar(char)
                if getgenv().Amethyst_GunDescendantConn then getgenv().Amethyst_GunDescendantConn:Disconnect() end
                getgenv().Amethyst_GunDescendantConn = char.DescendantAdded:Connect(function(obj)
                    if getgenv().Amethyst_ChanceAimbot then
                        checkAndCacheGun(obj)
                    end
                end)
            end
            
            if LocalPlayer.Character then hookChar(LocalPlayer.Character) end
            getgenv().Amethyst_CharAddedConn = LocalPlayer.CharacterAdded:Connect(function(char)
                task.wait(0.5)
                if getgenv().Amethyst_ChanceAimbot then
                    -- Quét lại súng phòng trường hợp respawn có sẵn
                    for _, obj in pairs(char:GetDescendants()) do checkAndCacheGun(obj) end
                    hookChar(char)
                end
            end)

            -- [VÒNG LẶP AIMBOT SIÊU NHẸ]
            task.spawn(function()
                while getgenv().Amethyst_ChanceAimbot do
                    task.wait()
                    pcall(function()
                        local char = LocalPlayer.Character
                        if not char then return end
                        local hrp = char:FindFirstChild("HumanoidRootPart")
                        local humanoid = char:FindFirstChild("Humanoid")
                        if not hrp or not humanoid then return end
                        
                        -- Lấy súng từ Bộ nhớ đệm (0% LAG)
                        local hasFlintlock = false
                        local gun = getgenv().Amethyst_CachedFlintlock
                        
                        -- Kiểm tra súng có tồn tại và đang dính trên người không
                        if gun and gun.Parent and gun:IsDescendantOf(char) then
                            if gun:IsA("Tool") then
                                hasFlintlock = true
                            elseif gun:IsA("Model") or gun:IsA("BasePart") then
                                local isVisible = false
                                if gun:IsA("BasePart") and gun.Transparency < 1 then isVisible = true end
                                for _, part in pairs(gun:GetDescendants()) do
                                    if (part:IsA("BasePart") or part:IsA("MeshPart")) and part.Transparency < 1 then
                                        isVisible = true
                                        break
                                    end
                                end
                                if isVisible then hasFlintlock = true end
                            end
                        end
                        
                        -- Nếu thỏa mãn điều kiện lôi súng ra
                        if hasFlintlock then
                            humanoid.AutoRotate = false -- Khóa xoay tự do để màn hình chốt mục tiêu
                            
                            local closestDist = 150 -- Tầm ngắm bắn 150 Studs
                            local targetPart = nil
                            
                            -- TỐI ƯU SIÊU TỐC: Chỉ quét trong cái list PizzaGuy mình đã tóm
                            for i = #getgenv().Amethyst_PizzaGuyList, 1, -1 do
                                local obj = getgenv().Amethyst_PizzaGuyList[i]
                                
                                -- Tự dọn rác nếu con NPC chết hoặc biến mất
                                if not obj or not obj.Parent then
                                    table.remove(getgenv().Amethyst_PizzaGuyList, i)
                                else
                                    local tHrp = obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChild("Torso") or obj.PrimaryPart
                                    if tHrp then
                                        local dist = (hrp.Position - tHrp.Position).Magnitude
                                        if dist <= closestDist then
                                            closestDist = dist
                                            targetPart = tHrp
                                        end
                                    end
                                end
                            end
                            
                            -- Nếu có Pizza Guy trong list và nằm trong tầm ngắm 150m
                            if targetPart then
                                local lookPos = Vector3.new(targetPart.Position.X, hrp.Position.Y, targetPart.Position.Z)
                                -- Đã xóa Lerp để ngắm chuẩn 100% không lệch tâm khi vừa chạy vừa bắn
                                hrp.CFrame = CFrame.lookAt(hrp.Position, lookPos)
                            end
                        else
                            if not getgenv().Amethyst_ShedletskyAimbot then
                                humanoid.AutoRotate = true -- Trả lại xoay tự do khi cất súng
                            end
                        end
                    end)
                end
                
                -- Đảm bảo trả lại AutoRotate khi tắt chức năng
                pcall(function()
                    if not getgenv().Amethyst_ShedletskyAimbot then
                        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                            LocalPlayer.Character.Humanoid.AutoRotate = true
                        end
                    end
                end)
            end)
        else
            -- KHI TẮT NÚT: Hủy toàn bộ Event và xóa danh sách đệm
            if getgenv().Amethyst_ChanceAimbotConn then getgenv().Amethyst_ChanceAimbotConn:Disconnect() getgenv().Amethyst_ChanceAimbotConn = nil end
            if getgenv().Amethyst_GunDescendantConn then getgenv().Amethyst_GunDescendantConn:Disconnect() getgenv().Amethyst_GunDescendantConn = nil end
            if getgenv().Amethyst_CharAddedConn then getgenv().Amethyst_CharAddedConn:Disconnect() getgenv().Amethyst_CharAddedConn = nil end
            getgenv().Amethyst_PizzaGuyList = nil
            getgenv().Amethyst_CachedFlintlock = nil
        end
    end
})

TabSurvive:Section({ Title = "II SHEDLETSKY" })

TabSurvive:Toggle({
    Title = "Aimbot Pizza Guy (Sword)",
    Desc = "Auto Aimbot NPC Pizza Guy (40 Studs) | HỆ THỐNG EVENT KÉP CHỐNG LAG TỐI ĐA",
    Default = false,
    Callback = function(State)
        getgenv().Amethyst_ShedletskyAimbot = State
        
        if State then
            local LocalPlayer = game.Players.LocalPlayer
            
            -- [HỆ THỐNG BỘ NHỚ ĐỆM KÉP: PIZZA GUY VÀ KIẾM]
            getgenv().Amethyst_Shedletsky_PizzaList = {}
            getgenv().Amethyst_CachedSword = nil
            
            -- Hàm nạp Pizza Guy
            local function checkAndAddPizzaGuyShed(obj)
                if obj:IsA("Model") then
                    local lowerName = string.lower(obj.Name)
                    if string.match(lowerName, "pizza guy") or string.match(lowerName, "pizzaguy") then
                        table.insert(getgenv().Amethyst_Shedletsky_PizzaList, obj)
                    end
                end
            end
            
            -- Hàm nạp Kiếm (Sword)
            local function checkAndCacheSword(obj)
                if string.match(string.lower(obj.Name), "sword") then
                    getgenv().Amethyst_CachedSword = obj
                end
            end
            
            -- Quét 1 lần duy nhất để tìm các con Pizza Guy đang có sẵn
            for _, obj in pairs(workspace:GetDescendants()) do
                checkAndAddPizzaGuyShed(obj)
            end
            
            -- Quét 1 lần duy nhất tìm kiếm trên người nếu đã cầm sẵn
            if LocalPlayer.Character then
                for _, obj in pairs(LocalPlayer.Character:GetDescendants()) do
                    checkAndCacheSword(obj)
                end
            end
            
            -- Canh chừng Event 1: Spawn Pizza Guy
            getgenv().Amethyst_ShedletskyAimbotConn = workspace.DescendantAdded:Connect(function(obj)
                task.wait(0.5) 
                if getgenv().Amethyst_ShedletskyAimbot then
                    checkAndAddPizzaGuyShed(obj)
                end
            end)
            
            -- Canh chừng Event 2: Móc kiếm vào Character (Chống lag tuyệt đối thay vì quét vòng lặp)
            local function hookCharShed(char)
                if getgenv().Amethyst_SwordDescendantConn then getgenv().Amethyst_SwordDescendantConn:Disconnect() end
                getgenv().Amethyst_SwordDescendantConn = char.DescendantAdded:Connect(function(obj)
                    if getgenv().Amethyst_ShedletskyAimbot then
                        checkAndCacheSword(obj)
                    end
                end)
            end
            
            if LocalPlayer.Character then hookCharShed(LocalPlayer.Character) end
            getgenv().Amethyst_SwordCharAddedConn = LocalPlayer.CharacterAdded:Connect(function(char)
                task.wait(0.5)
                if getgenv().Amethyst_ShedletskyAimbot then
                    -- Quét lại kiếm phòng trường hợp respawn có sẵn
                    for _, obj in pairs(char:GetDescendants()) do checkAndCacheSword(obj) end
                    hookCharShed(char)
                end
            end)

            -- [VÒNG LẶP AIMBOT SIÊU NHẸ]
            task.spawn(function()
                while getgenv().Amethyst_ShedletskyAimbot do
                    task.wait()
                    pcall(function()
                        local char = LocalPlayer.Character
                        if not char then return end
                        local hrp = char:FindFirstChild("HumanoidRootPart")
                        local humanoid = char:FindFirstChild("Humanoid")
                        if not hrp or not humanoid then return end
                        
                        -- Lấy kiếm từ Bộ nhớ đệm (0% LAG)
                        local hasSword = false
                        local sword = getgenv().Amethyst_CachedSword
                        
                        -- Kiểm tra kiếm có tồn tại và đang dính trên người không
                        if sword and sword.Parent and sword:IsDescendantOf(char) then
                            if sword:IsA("Tool") then
                                hasSword = true
                            elseif sword:IsA("Model") or sword:IsA("BasePart") then
                                local isVisible = false
                                if sword:IsA("BasePart") and sword.Transparency < 1 then isVisible = true end
                                for _, part in pairs(sword:GetDescendants()) do
                                    if (part:IsA("BasePart") or part:IsA("MeshPart")) and part.Transparency < 1 then
                                        isVisible = true
                                        break
                                    end
                                end
                                if isVisible then hasSword = true end
                            end
                        end
                        
                        -- Nếu thỏa mãn điều kiện lôi kiếm ra
                        if hasSword then
                            humanoid.AutoRotate = false -- Khóa xoay tự do để màn hình chốt mục tiêu
                            
                            local closestDist = 40 -- Tầm ngắm 40 Studs
                            local targetPart = nil
                            
                            -- TỐI ƯU SIÊU TỐC: Chỉ quét trong cái list PizzaGuy mình đã tóm
                            for i = #getgenv().Amethyst_Shedletsky_PizzaList, 1, -1 do
                                local obj = getgenv().Amethyst_Shedletsky_PizzaList[i]
                                
                                -- Tự dọn rác nếu con NPC chết hoặc biến mất
                                if not obj or not obj.Parent then
                                    table.remove(getgenv().Amethyst_Shedletsky_PizzaList, i)
                                else
                                    local tHrp = obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChild("Torso") or obj.PrimaryPart
                                    if tHrp then
                                        local dist = (hrp.Position - tHrp.Position).Magnitude
                                        if dist <= closestDist then
                                            closestDist = dist
                                            targetPart = tHrp
                                        end
                                    end
                                end
                            end
                            
                            -- Nếu có Pizza Guy trong list và nằm trong tầm ngắm 40m
                            if targetPart then
                                local lookPos = Vector3.new(targetPart.Position.X, hrp.Position.Y, targetPart.Position.Z)
                                -- Đã xóa Lerp để ngắm chuẩn 100% không lệch tâm khi vừa chạy vừa chém
                                hrp.CFrame = CFrame.lookAt(hrp.Position, lookPos)
                            end
                        else
                            -- Trả lại tự do nếu không có Aimbot nào khác đang kích hoạt
                            if not getgenv().Amethyst_ChanceAimbot then
                                humanoid.AutoRotate = true
                            end
                        end
                    end)
                end
                
                -- Đảm bảo trả lại AutoRotate khi tắt chức năng
                pcall(function()
                    if not getgenv().Amethyst_ChanceAimbot then
                        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                            LocalPlayer.Character.Humanoid.AutoRotate = true
                        end
                    end
                end)
            end)
        else
            -- KHI TẮT NÚT: Hủy toàn bộ Event và xóa danh sách đệm
            if getgenv().Amethyst_ShedletskyAimbotConn then getgenv().Amethyst_ShedletskyAimbotConn:Disconnect() getgenv().Amethyst_ShedletskyAimbotConn = nil end
            if getgenv().Amethyst_SwordDescendantConn then getgenv().Amethyst_SwordDescendantConn:Disconnect() getgenv().Amethyst_SwordDescendantConn = nil end
            if getgenv().Amethyst_SwordCharAddedConn then getgenv().Amethyst_SwordCharAddedConn:Disconnect() getgenv().Amethyst_SwordCharAddedConn = nil end
            getgenv().Amethyst_Shedletsky_PizzaList = nil
            getgenv().Amethyst_CachedSword = nil
        end
    end
})

TabSurvive:Section({ Title = "III JANE DOE" })

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")

-- [[ BIẾN CẤU HÌNH TỪ FILE V27 ]] --
local Config = {
    TargetMode = "Sát Nhân (Killer)",
    EnableCrystalAim = false,
    EnableHatchetAim = false,
    AimRange = 150,
    PredictionTime = 0.08,
    -- [VIP] Shiftlock Config cho Ném Lọ
    VIPOffset = Vector3.new(0, 5.141, 10.148),
    VIPFov = 70
}

local IsAimingCrystalPitch = false
local IsAimingHatchet = false
local AimTarget = nil 

-- [[ HÀM TÌM MỤC TIÊU CHUNG (XUYÊN TƯỜNG - MAGNITUDE) ]] --
local function FindClosestTarget(maxRange)
    local closest = nil
    local minDist = maxRange
    local myChar = LocalPlayer.Character
    local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
    
    if not myRoot then return nil end

    if Config.TargetMode == "Sát Nhân (Killer)" then
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character then
                local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    local isKiller = false
                    if plr.Team and (plr.Team.Name == "Killers" or plr.Team.Name == "Killer") then
                        isKiller = true
                    elseif plr.Character.Parent and plr.Character.Parent.Name == "Killers" then
                        isKiller = true
                    end
                    
                    if isKiller and plr.Character:FindFirstChild("Humanoid") and plr.Character.Humanoid.Health > 0 then
                        local dist = (hrp.Position - myRoot.Position).Magnitude
                        if dist < minDist then 
                            minDist = dist
                            closest = hrp 
                        end
                    end
                end
            end
        end
    elseif Config.TargetMode == "NPC Pizza Guy" then
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("Model") then
                local nameLower = string.lower(obj.Name)
                if string.find(nameLower, "pizza guy") or string.find(nameLower, "pizzadeliveryrig") then
                    local hrp = obj.PrimaryPart or obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChildWhichIsA("BasePart")
                    if hrp then
                        local dist = (hrp.Position - myRoot.Position).Magnitude
                        if dist < minDist then
                            minDist = dist
                            closest = hrp
                        end
                    end
                end
            end
        end
    end

    return closest
end

-- [[ KIỂM TRA NÚT KỸ NĂNG VÀ HỒI CHIÊU ]] --
local function CheckButtonName(btn, keyword)
    local btnName = string.lower(btn.Name)
    local targetKeyword = string.lower(keyword)
    if string.find(btnName, targetKeyword) then return true end
    for _, child in pairs(btn:GetDescendants()) do
        if child:IsA("TextLabel") or child:IsA("TextButton") then
            if string.find(string.lower(child.Text), targetKeyword) then return true end
        end
    end
    return false
end

local function IsSkillOnCooldown(btn)
    if not btn then return false end
    for _, obj in pairs(btn:GetDescendants()) do
        if obj:IsA("TextLabel") and obj.Visible then
            local text = string.gsub(obj.Text, "%s+", "")
            local num = tonumber(text)
            if num and num > 0 and num < 100 then return true end
        end
    end
    return false
end

-- [[ BỘ QUÉT THANH CHARGE XANH LÁ (THAY THẾ HOÀN TOÀN NÚT CRYSTAL PITCH) ]] --
local lastCrystalChargeTime = 0
task.spawn(function()
    while true do
        task.wait(0.05)
        pcall(function()
            if Config.EnableCrystalAim then
                local isCharging = false
                local char = LocalPlayer.Character
                if char then
                    local hasCrystal = false
                    for _, tool in pairs(char:GetChildren()) do
                        if string.match(string.lower(tool.Name), "crystal") then
                            hasCrystal = true
                            break
                        end
                    end
                    
                    if hasCrystal then
                        -- Quét trên màn hình PlayerGui
                        local gui = LocalPlayer:FindFirstChild("PlayerGui")
                        if gui then
                            for _, obj in pairs(gui:GetDescendants()) do
                                if obj:IsA("TextLabel") and obj.Text ~= "" and string.match(string.lower(obj.Text), "charge") then
                                    local p = obj
                                    local isReallyVisible = true
                                    while p and p:IsA("GuiObject") do
                                        if not p.Visible then
                                            isReallyVisible = false
                                            break
                                        end
                                        p = p.Parent
                                    end
                                    if isReallyVisible then
                                        isCharging = true
                                        break
                                    end
                                end
                            end
                        end
                        -- Quét trên BillboardGui (Trên đầu nhân vật) nếu PlayerGui không có
                        if not isCharging then
                            for _, obj in pairs(char:GetDescendants()) do
                                if obj:IsA("TextLabel") and obj.Text ~= "" and string.match(string.lower(obj.Text), "charge") then
                                    local p = obj
                                    local isReallyVisible = true
                                    while p and p:IsA("GuiObject") do
                                        if not p.Visible then
                                            isReallyVisible = false
                                            break
                                        end
                                        p = p.Parent
                                    end
                                    if isReallyVisible then
                                        isCharging = true
                                        break
                                    end
                                end
                            end
                        end
                    end
                end
                
                -- Khởi động Aim khi thấy Thanh Xanh Lá
                if isCharging then
                    IsAimingCrystalPitch = true
                    lastCrystalChargeTime = tick()
                    if not AimTarget then
                        AimTarget = FindClosestTarget(Config.AimRange)
                    end
                else
                    -- Mất Thanh Xanh Lá -> Chờ 2 giây rồi mới tắt Aim
                    if IsAimingCrystalPitch and (tick() - lastCrystalChargeTime >= 2) then
                        IsAimingCrystalPitch = false
                        if not IsAimingHatchet then AimTarget = nil end
                    end
                end
            else
                if IsAimingCrystalPitch then
                    IsAimingCrystalPitch = false
                    if not IsAimingHatchet then AimTarget = nil end
                end
            end
        end)
    end
end)

-- [[ MÓC NÚT ĐỂ BẬT/TẮT AIM KHI CHẠM VÀO KỸ NĂNG ]] --
local function HookJaneDoeButtons()
    local gui = LocalPlayer:FindFirstChild("PlayerGui")
    if not gui then return end
    
    local mainUI = gui:FindFirstChild("MainUI")
    if not mainUI then return end
    
    local container = mainUI:FindFirstChild("AbilityContainer")
    if not container then return end
    
    for _, btn in pairs(container:GetDescendants()) do
        if btn:IsA("GuiButton") then
            if not btn:FindFirstChild("AmethystHookedV27") then
                
                local tag = Instance.new("BoolValue")
                tag.Name = "AmethystHookedV27"
                tag.Parent = btn

                -- HATCHET (CHÉM RÌU)
                if CheckButtonName(btn, "hatchet") then
                    btn.InputBegan:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
                            if Config.EnableHatchetAim then
                                if not IsSkillOnCooldown(btn) then
                                    IsAimingHatchet = true
                                    AimTarget = FindClosestTarget(Config.AimRange)
                                end
                            end
                        end
                    end)
                    
                    btn.InputEnded:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
                            if IsAimingHatchet then
                                task.delay(1, function() 
                                    IsAimingHatchet = false
                                    if not IsAimingCrystalPitch then AimTarget = nil end
                                end)
                            end
                        end
                    end)
                end
                
            end
        end
    end
end

task.spawn(function()
    while true do
        HookJaneDoeButtons()
        task.wait(2)
    end
end)

-- ==================================================
-- [[ ĐỘNG CƠ CAMERA SHIFTLOCK VIP (THAY THẾ TOÀN BỘ HỆ THỐNG CŨ) ]] --
-- ==================================================
RunService:BindToRenderStep("AmethystVIPShiftlock", 201, function()
    -- [[ BỘ XẢ KHÓA NHANH ]]
    -- Nếu KHÔNG bấm gồng chiêu Ném lọ -> Trả Camera và cơ thể về bình thường lập tức!
    if not (IsAimingCrystalPitch and Config.EnableCrystalAim) then 
        local cam = Workspace.CurrentCamera
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChild("Humanoid")
        
        -- Nhả từ Scriptable về Custom
        if cam and cam.CameraType == Enum.CameraType.Scriptable then
            cam.CameraType = Enum.CameraType.Custom
            if hum then cam.CameraSubject = hum end
        end
        
        -- [ĐOẠN CHỈNH SỬA DUY NHẤT]: BẺ CỔ NHÂN VẬT KHI XÀI CHÉM RÌU!
        if IsAimingHatchet and Config.EnableHatchetAim and AimTarget and AimTarget.Parent and char then
            local root = char:FindFirstChild("HumanoidRootPart")
            if root and hum then
                hum.AutoRotate = false
                local gyro = root:FindFirstChild("AmethystVIPGyro")
                if not gyro then
                    gyro = Instance.new("BodyGyro")
                    gyro.Name = "AmethystVIPGyro"
                    gyro.MaxTorque = Vector3.new(0, 400000, 0)
                    gyro.D = 50
                    gyro.P = 50000
                    gyro.Parent = root
                end
                local tPos = AimTarget.Position
                gyro.CFrame = CFrame.lookAt(root.Position, Vector3.new(tPos.X, root.Position.Y, tPos.Z))
            end
            return -- Dừng ở đây, không xuống bước dưới để hủy Gyro!
        end
        -- [KẾT THÚC CHỈNH SỬA]
        
        -- Phá hủy BodyGyro VIP
        if char then
            if hum then hum.AutoRotate = true end
            local root = char:FindFirstChild("HumanoidRootPart")
            if root and root:FindFirstChild("AmethystVIPGyro") then
                root.AmethystVIPGyro:Destroy()
            end
        end
        return 
    end
    
    -- [[ KHI ĐANG GỒNG NÉM LỌ -> KHÓA CAMERA VIP MAX NGẮM THÂN ]]
    local target = AimTarget
    local cam = Workspace.CurrentCamera
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChild("Humanoid")
    
    if target and cam and root and hum then
        -- Cướp quyền Camera
        cam.CameraType = Enum.CameraType.Scriptable
        cam.FieldOfView = Config.VIPFov
        
        -- Găm thẳng vào THÂN (HumanoidRootPart)
        local targetPos = target.Position 
        local headPos = root.Position + Vector3.new(0, 1.5, 0) 
        
        local lookCFrame = CFrame.lookAt(headPos, targetPos)
        local desiredCamCFrame = lookCFrame * CFrame.new(Config.VIPOffset)
        
        -- CUSTOM POPPERCAM (Trượt tường thông minh)
        local rayOrigin = headPos
        local rayDirection = desiredCamCFrame.Position - headPos
        
        local raycastParams = RaycastParams.new()
        raycastParams.FilterDescendantsInstances = {char, target, target.Parent} 
        raycastParams.FilterType = Enum.RaycastFilterType.Exclude
        raycastParams.IgnoreWater = true
        
        local result = Workspace:Raycast(rayOrigin, rayDirection, raycastParams)
        
        local finalCamPos
        if result then
            -- Nếu đụng tường, trượt Camera lên phía trước mặt tường
            finalCamPos = result.Position + (result.Normal * 0.5) 
        else
            finalCamPos = desiredCamCFrame.Position
        end
        
        cam.CFrame = CFrame.lookAt(finalCamPos, targetPos)
        
        -- BODYGYRO MỚI (Xoay nhân vật theo tâm ngắm)
        hum.AutoRotate = false 
        local gyro = root:FindFirstChild("AmethystVIPGyro")
        if not gyro then
            gyro = Instance.new("BodyGyro")
            gyro.Name = "AmethystVIPGyro"
            gyro.MaxTorque = Vector3.new(0, 400000, 0) 
            gyro.D = 50
            gyro.P = 50000
            gyro.Parent = root
        end
        gyro.CFrame = CFrame.lookAt(root.Position, Vector3.new(targetPos.X, root.Position.Y, targetPos.Z))
        
        -- VẼ ĐƯỜNG ĐẠN / MŨI TÊN ĐỎ
        local aimPos = targetPos + (target.Velocity * Config.PredictionTime)
        local ingameFolder = workspace:FindFirstChild("Ingame")
        if ingameFolder then
            local endPoint = ingameFolder:FindFirstChild("EndPoint")
            if endPoint and endPoint:IsA("BasePart") then
                endPoint.CFrame = CFrame.new(aimPos)
            end
        end
    else
        -- An toàn: Mất mục tiêu giữa chừng
        if cam.CameraType == Enum.CameraType.Scriptable then
            cam.CameraType = Enum.CameraType.Custom
            cam.CameraSubject = hum
        end
        if char then
            local t_root = char:FindFirstChild("HumanoidRootPart")
            if t_root and t_root:FindFirstChild("AmethystVIPGyro") then
                t_root.AmethystVIPGyro:Destroy()
            end
        end
    end
end)

-- [[ GẮN NÚT ĐIỀU KHIỂN JANE DOE VÀO TAB SURVIVE ]] --
TabSurvive:Dropdown({
    Title = "🎯 Chế Độ Nhắm (Target Mode)",
    Values = {"Sát Nhân (Killer)", "NPC Pizza Guy"},
    Value = "Sát Nhân (Killer)",
    Callback = function(val) Config.TargetMode = val end
})

TabSurvive:Toggle({ Title = "Aimbot Gồng Ném Lọ (Kèm Camera VIP)", Default = false, Callback = function(s) Config.EnableCrystalAim = s end })
TabSurvive:Toggle({ Title = "Aimbot Chém Rìu (Hatchet)", Default = false, Callback = function(s) Config.EnableHatchetAim = s end })
TabSurvive:Input({ Title = "Phạm Vi Kỹ Năng (Range)", Default = "150", Numeric = true, Finished = true, Callback = function(v) if tonumber(v) then Config.AimRange = tonumber(v) end end })

WindUI:Notify({ Title = "JANE DOE V27", Content = "Đã tích hợp chế độ dò Thanh Tiến Độ (Charge) ngắm bắn độc lập!", Duration = 5 })

-- 4. KILLER (Icon: Đầu lâu)
local TabKiller = Window:Tab({ Title = "Killer", Icon = "skull" })
TabKiller:Paragraph({
    Title = "Thông Báo",
    Desc = "Chức năng đang được Update..."
})

-- 5. GENERATOR (Icon: Bánh răng)
local TabGenerator = Window:Tab({ Title = "Generator", Icon = "settings" })

TabGenerator:Section({ Title = "I AUTO GEN" })

local MaxSearchDistance = 3000
local IgnoreList = {}
local HitCycle = {}
local LastGenerator = nil

local RepairOffsets = {
    CFrame.new(0, 0, -6),
    CFrame.new(6, 0, 0),
    CFrame.new(-6, 0, 0)
}

local function GetProgress(gen)
    local p = gen:FindFirstChild("Progress")
    if p and p:IsA("NumberValue") then return p.Value end
    return nil
end

local function IsSpotBlocked(position)
    for _, plr in pairs(game.Players:GetPlayers()) do
        if plr ~= game.Players.LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            if (plr.Character.HumanoidRootPart.Position - position).Magnitude < 3.5 then return true end
        end
    end
    return false
end

local function GetBestRepairSpot(gen)
    local pivot = gen:GetPivot()
    for _, offset in ipairs(RepairOffsets) do
        local spotPos = (pivot * offset).Position
        if not IsSpotBlocked(spotPos) then return spotPos end
    end
    return nil
end

local function GetNextGenerator_V3()
    if not workspace:FindFirstChild("Map") then return nil, false, false end
    local ingame = workspace.Map:FindFirstChild("Ingame")
    if not ingame then return nil, false, false end
    local GameMap = ingame:FindFirstChild("Map")
    if not GameMap then return nil, false, false end

    local root = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not root then return nil, true, false end

    local TotalGens = 0
    local Unfinished = 0
    local ValidGens = {}

    for _, obj in ipairs(GameMap:GetChildren()) do
        if obj.Name == "Generator" and obj:IsA("Model") then
            local progress = GetProgress(obj)
            if progress ~= nil then
                TotalGens = TotalGens + 1
                if progress < 100 and not IgnoreList[obj] then
                    Unfinished = Unfinished + 1
                    local main = obj.PrimaryPart or obj:FindFirstChild("Main")
                    local pos = main and main.Position or obj:GetPivot().Position
                    local dist = (root.Position - pos).Magnitude
                    table.insert(ValidGens, {obj = obj, progress = progress, dist = dist})
                end
            end
        end
    end

    if Unfinished == 0 then return nil, true, (TotalGens > 0), nil end

    local minBar = 4
    for _, data in ipairs(ValidGens) do
        local bar = math.floor(data.progress / 25)
        if bar < minBar then minBar = bar end
    end

    local closest = 99999
    local target = nil
    local ChosenSpot = nil
    local CountInMinBar = 0
    local ValidForCycle = 0

    for _, data in ipairs(ValidGens) do
        local bar = math.floor(data.progress / 25)
        if bar == minBar then 
            CountInMinBar = CountInMinBar + 1
            if not HitCycle[data.obj] then
                ValidForCycle = ValidForCycle + 1
                if data.dist <= MaxSearchDistance then
                    local spot = GetBestRepairSpot(data.obj)
                    if spot and data.dist < closest then
                        closest = data.dist
                        target = data.obj
                        ChosenSpot = spot
                    end
                end
            end
        end
    end

    if CountInMinBar > 0 and ValidForCycle == 0 then
        table.clear(HitCycle)
        if CountInMinBar > 1 and LastGenerator then HitCycle[LastGenerator] = true end
        return GetNextGenerator_V3() 
    end

    return target, true, false, ChosenSpot
end

TabGenerator:Toggle({
    Title = "Auto Farm Gen V3",
    Desc = "Hit & Run: Sửa đồng loạt các máy, nhích từng vạch.",
    Default = false,
    Callback = function(State)
        getgenv().Amethyst_AutoFarmV3 = State
        if State then
            task.spawn(function()
                local LocalPlayer = game.Players.LocalPlayer
                while getgenv().Amethyst_AutoFarmV3 do
                    pcall(function()
                        local gen, mapLoaded, allFinished, targetPos = GetNextGenerator_V3()
                        
                        if not mapLoaded then
                            table.clear(IgnoreList)
                            table.clear(HitCycle)
                        else
                            if allFinished then
                                -- Đã xóa code tự sát (reset nhân vật) theo lệnh
                                task.wait(3)
                            end
                            
                            if gen and targetPos then
                                local char = LocalPlayer.Character
                                if not char then return end
                                local root = char:FindFirstChild("HumanoidRootPart")
                                if not root then return end

                                local pivot = gen:GetPivot()
                                local dropHeight = 2.0 
                                local dropPos = targetPos + Vector3.new(0, dropHeight, 0)
                                local lookAt = Vector3.new(pivot.Position.X, dropPos.Y, pivot.Position.Z)
                                
                                while getgenv().Amethyst_AutoFarmV3 and (root.Position - dropPos).Magnitude > 3 do
                                    if IsSpotBlocked(targetPos) then break end
                                    root.CFrame = CFrame.lookAt(dropPos, lookAt)
                                    root.Velocity = Vector3.zero
                                    task.wait()
                                end
                                
                                if getgenv().Amethyst_AutoFarmV3 then
                                    root.Anchored = false
                                    task.wait(0.25)
                                    
                                    local prompt = gen:FindFirstChild("Main") and gen.Main:FindFirstChild("Prompt")
                                    if prompt then fireproximityprompt(prompt) end
                                    
                                    task.wait(1.2)
                                    
                                    local startProgress = GetProgress(gen)
                                    local checkProgress = 100 
                                    local currentBar = math.floor(startProgress / 25) 
                                    local targetProgress = (currentBar + 1) * 25      
                                    if targetProgress > 100 then targetProgress = 100 end
                                    checkProgress = targetProgress - 1 
                                    
                                    local lastInteract = 0
                                    
                                    while getgenv().Amethyst_AutoFarmV3 and GetProgress(gen) < 100 do
                                        if (root.Position - dropPos).Magnitude > 4 then break end
                                        
                                        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
                                        if hum and (hum.PlatformStand or hum.Sit) then
                                            hum.PlatformStand = false; hum.Sit = false
                                            hum:ChangeState(Enum.HumanoidStateType.GettingUp)
                                            task.wait(1.5); break 
                                        end
                                        if hum and hum.Jump then break end
                                        
                                        if tick() - lastInteract >= 0.3 then
                                            if prompt then pcall(function() prompt:InputHoldBegin() end) end
                                            if gen:FindFirstChild("Remotes") and gen.Remotes:FindFirstChild("RE") then gen.Remotes.RE:FireServer() end
                                            lastInteract = tick()
                                        end
                                        
                                        task.wait(0.1)
                                        
                                        if GetProgress(gen) >= checkProgress then
                                            if prompt then pcall(function() prompt:InputHoldEnd() end) end 
                                            HitCycle[gen] = true
                                            LastGenerator = gen 
                                            break 
                                        end
                                    end
                                    
                                    if prompt then pcall(function() prompt:InputHoldEnd() end) end
                                    root.Anchored = false
                                    if GetProgress(gen) >= 100 then IgnoreList[gen] = true end
                                end
                            end
                        end
                    end)
                    task.wait(0.2)
                end
            end)
        end
    end
})

TabGenerator:Section({ Title = "II GEN NO PUZZLE" })

TabGenerator:Toggle({
    Title = "Sửa Máy Nhanh (No QTE)",
    Desc = "Người chơi tự giữ E, tool tự động hack 1.2s/vạch",
    Default = false,
    Callback = function(State)
        getgenv().Amethyst_NoQTE = State
        if State then
            task.spawn(function()
                local LocalPlayer = game.Players.LocalPlayer
                while getgenv().Amethyst_NoQTE do
                    pcall(function()
                        local char = LocalPlayer.Character
                        if char and char:FindFirstChild("HumanoidRootPart") then
                            local root = char.HumanoidRootPart
                            local ingame = workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("Ingame")
                            local GameMap = ingame and ingame:FindFirstChild("Map")
                            if GameMap then
                                for _, obj in ipairs(GameMap:GetChildren()) do
                                    if obj.Name == "Generator" and obj:IsA("Model") then
                                        local main = obj.PrimaryPart or obj:FindFirstChild("Main")
                                        if main and (root.Position - main.Position).Magnitude <= 15 then
                                            local p = obj:FindFirstChild("Progress")
                                            if p and p:IsA("NumberValue") and p.Value < 100 then
                                                -- Bỏ auto giữ E, người chơi phải tự giữ tay
                                                if obj:FindFirstChild("Remotes") and obj.Remotes:FindFirstChild("RE") then
                                                    obj.Remotes.RE:FireServer()
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end)
                    task.wait(1.2) -- Đã thay đổi thành 1.2s một vạch
                end
            end)
        end
    end
})

-- 6. VISUAL (Icon: Con mắt)
local TabVisual = Window:Tab({ Title = "Visual", Icon = "eye" })

-- ĐẮP CHỨC NĂNG VISUAL VÀO ĐÂY
TabVisual:Section({ Title = "I PLAYER" })

TabVisual:Toggle({
    Title = "Survive ESP",
    Desc = "Dò liên tục tự động, Aura xanh biển nhạt, Hiện Tên + HP",
    Default = false,
    Callback = function(State)
        getgenv().Amethyst_SurviveESP = State
        if State then
            task.spawn(function()
                while getgenv().Amethyst_SurviveESP do
                    for _, player in pairs(game.Players:GetPlayers()) do
                        if player ~= game.Players.LocalPlayer and player.Character and player.Character:FindFirstChild("Humanoid") then
                            local humanoid = player.Character.Humanoid
                            local hp = math.floor(humanoid.Health)
                            local maxHp = humanoid.MaxHealth
                            -- Lọc Survivor: Thường có MaxHealth <= 200 (Ở đây là 100)
                            if maxHp <= 200 then
                                -- Màu xanh biển nhạt (Light Blue)
                                AddESP(player.Character, player.Name, hp, Color3.fromRGB(173, 216, 230))
                                
                                -- BẢN VÁ: Gắn sự kiện cập nhật máu lập tức
                                if not player.Character:FindFirstChild("Amethyst_HPHook_Survive") then
                                    local tag = Instance.new("BoolValue")
                                    tag.Name = "Amethyst_HPHook_Survive"
                                    tag.Parent = player.Character
                                    
                                    humanoid.HealthChanged:Connect(function(newHp)
                                        if getgenv().Amethyst_SurviveESP then
                                            AddESP(player.Character, player.Name, math.floor(newHp), Color3.fromRGB(173, 216, 230))
                                        end
                                    end)
                                end
                            end
                        end
                    end
                    task.wait(1) -- Dãn vòng lặp ra 1s vì đã có Event lo cập nhật máu tức thời
                end
            end)
        else
            for _, player in pairs(game.Players:GetPlayers()) do
                if player.Character and player.Character:FindFirstChild("Humanoid") then
                    if player.Character.Humanoid.MaxHealth <= 200 then
                        RemoveESP(player.Character)
                    end
                end
            end
        end
    end
})

TabVisual:Toggle({
    Title = "Killer ESP",
    Desc = "Dò liên tục tự động, Aura đỏ, Hiện Tên + HP",
    Default = false,
    Callback = function(State)
        getgenv().Amethyst_KillerESP = State
        if State then
            task.spawn(function()
                while getgenv().Amethyst_KillerESP do
                    for _, player in pairs(game.Players:GetPlayers()) do
                        if player ~= game.Players.LocalPlayer and player.Character and player.Character:FindFirstChild("Humanoid") then
                            local humanoid = player.Character.Humanoid
                            local hp = math.floor(humanoid.Health)
                            local maxHp = humanoid.MaxHealth
                            -- Lọc Killer: Thường có MaxHealth rất lớn (Ở đây là > 100k)
                            if maxHp > 200 then
                                -- Màu đỏ (Red)
                                AddESP(player.Character, player.Name, hp, Color3.fromRGB(255, 0, 0))
                                
                                -- BẢN VÁ: Gắn sự kiện cập nhật máu lập tức
                                if not player.Character:FindFirstChild("Amethyst_HPHook_Killer") then
                                    local tag = Instance.new("BoolValue")
                                    tag.Name = "Amethyst_HPHook_Killer"
                                    tag.Parent = player.Character
                                    
                                    humanoid.HealthChanged:Connect(function(newHp)
                                        if getgenv().Amethyst_KillerESP then
                                            AddESP(player.Character, player.Name, math.floor(newHp), Color3.fromRGB(255, 0, 0))
                                        end
                                    end)
                                end
                            end
                        end
                    end
                    task.wait(1) -- Dãn vòng lặp ra 1s vì đã có Event lo cập nhật máu tức thời
                end
            end)
        else
            for _, player in pairs(game.Players:GetPlayers()) do
                if player.Character and player.Character:FindFirstChild("Humanoid") then
                    if player.Character.Humanoid.MaxHealth > 200 then
                        RemoveESP(player.Character)
                    end
                end
            end
        end
    end
})

TabVisual:Section({ Title = "II ITEMS" })

TabVisual:Toggle({
    Title = "Bloxy Cola ESP",
    Desc = "Chống Lag (Chỉ dò định dạng Tool/Item), Aura nâu, Hiện Tên",
    Default = false,
    Callback = function(State)
        getgenv().Amethyst_BloxyESP = State
        
        if State then
            -- Quét 1 lần duy nhất lúc vừa bật để tìm các bình nước có sẵn
            for _, v in pairs(workspace:GetDescendants()) do
                if v:IsA("Tool") then
                    if string.match(string.lower(v.Name), "bloxy cola") or string.match(string.lower(v.Name), "cola") then
                        AddESP(v, "Bloxy Cola", nil, Color3.fromRGB(139, 69, 19))
                    end
                end
            end
            
            -- Lắng nghe sự kiện khi có vật phẩm mới (Tuyệt đối không gây lag)
            getgenv().Amethyst_BloxyConn = workspace.DescendantAdded:Connect(function(v)
                task.wait(0.1) -- Chờ vài mili-giây để vật phẩm load đầy đủ thông tin
                if getgenv().Amethyst_BloxyESP then
                    if v:IsA("Tool") then
                        if string.match(string.lower(v.Name), "bloxy cola") or string.match(string.lower(v.Name), "cola") then
                            AddESP(v, "Bloxy Cola", nil, Color3.fromRGB(139, 69, 19))
                        end
                    end
                end
            end)
        else
            -- Tắt lắng nghe sự kiện
            if getgenv().Amethyst_BloxyConn then
                getgenv().Amethyst_BloxyConn:Disconnect()
                getgenv().Amethyst_BloxyConn = nil
            end
            
            -- Xóa ESP cũ
            for _, v in pairs(workspace:GetDescendants()) do
                if v:IsA("Tool") then
                    if string.match(string.lower(v.Name), "bloxy cola") or string.match(string.lower(v.Name), "cola") then
                        RemoveESP(v)
                    end
                end
            end
        end
    end
})

TabVisual:Toggle({
    Title = "Medkit ESP",
    Desc = "Chống Lag (Chỉ dò định dạng Tool/Item), Aura xanh lá, Hiện Tên",
    Default = false,
    Callback = function(State)
        getgenv().Amethyst_MedkitESP = State
        
        if State then
            -- Quét 1 lần duy nhất lúc vừa bật
            for _, v in pairs(workspace:GetDescendants()) do
                if v:IsA("Tool") then
                    if string.match(string.lower(v.Name), "medkit") or string.match(string.lower(v.Name), "health") then
                        AddESP(v, "Medkit", nil, Color3.fromRGB(50, 205, 50))
                    end
                end
            end
            
            -- Lắng nghe sự kiện
            getgenv().Amethyst_MedkitConn = workspace.DescendantAdded:Connect(function(v)
                task.wait(0.1)
                if getgenv().Amethyst_MedkitESP then
                    if v:IsA("Tool") then
                        if string.match(string.lower(v.Name), "medkit") or string.match(string.lower(v.Name), "health") then
                            AddESP(v, "Medkit", nil, Color3.fromRGB(50, 205, 50))
                        end
                    end
                end
            end)
        else
            -- Tắt lắng nghe
            if getgenv().Amethyst_MedkitConn then
                getgenv().Amethyst_MedkitConn:Disconnect()
                getgenv().Amethyst_MedkitConn = nil
            end
            
            -- Xóa ESP
            for _, v in pairs(workspace:GetDescendants()) do
                if v:IsA("Tool") then
                    if string.match(string.lower(v.Name), "medkit") or string.match(string.lower(v.Name), "health") then
                        RemoveESP(v)
                    end
                end
            end
        end
    end
})

TabVisual:Section({ Title = "III PizzaDeliveryRig" })

TabVisual:Toggle({
    Title = "PizzaDeliveryRig & MAFIA ESP",
    Desc = "Chống Lag (Sử dụng Event), Aura Xanh lá, Hiện Tên (Pizza + Mafia 1-4)",
    Default = false,
    Callback = function(State)
        getgenv().Amethyst_PizzaESP = State
        
        -- Hàm xử lý gọn gàng: Quét cả Pizza lẫn MAFIA1-4, phát hiện con nào dán tên con đó
        local function CheckAndAddPizzaMafia(v)
            if v:IsA("Model") then
                local lowerName = string.lower(v.Name)
                if string.match(lowerName, "pizzadeliveryrig") then
                    AddESP(v, "PizzaDeliveryRig", nil, Color3.fromRGB(0, 255, 0))
                elseif string.match(lowerName, "mafia1") then
                    AddESP(v, "MAFIA1", nil, Color3.fromRGB(0, 255, 0))
                elseif string.match(lowerName, "mafia2") then
                    AddESP(v, "MAFIA2", nil, Color3.fromRGB(0, 255, 0))
                elseif string.match(lowerName, "mafia3") then
                    AddESP(v, "MAFIA3", nil, Color3.fromRGB(0, 255, 0))
                elseif string.match(lowerName, "mafia4") then
                    AddESP(v, "MAFIA4", nil, Color3.fromRGB(0, 255, 0))
                end
            end
        end
        
        if State then
            -- Quét 1 lần duy nhất lúc vừa bật để tìm các Bot/Nhân bản có sẵn
            for _, v in pairs(workspace:GetDescendants()) do
                CheckAndAddPizzaMafia(v)
            end
            
            -- Lắng nghe sự kiện khi có Bot mới xuất hiện (Tuyệt đối không gây lag)
            getgenv().Amethyst_PizzaConn = workspace.DescendantAdded:Connect(function(v)
                task.wait(2) -- CHỜ ĐÚNG 2 GIÂY SAU KHI XUẤT HIỆN MỚI GẮN ESP
                if getgenv().Amethyst_PizzaESP then
                    CheckAndAddPizzaMafia(v)
                end
            end)
        else
            -- Tắt lắng nghe sự kiện
            if getgenv().Amethyst_PizzaConn then
                getgenv().Amethyst_PizzaConn:Disconnect()
                getgenv().Amethyst_PizzaConn = nil
            end
            
            -- Xóa ESP cũ
            for _, v in pairs(workspace:GetDescendants()) do
                if v:IsA("Model") then
                    local lowerName = string.lower(v.Name)
                    if string.match(lowerName, "pizzadeliveryrig") or string.match(lowerName, "mafia1") or string.match(lowerName, "mafia2") or string.match(lowerName, "mafia3") or string.match(lowerName, "mafia4") then
                        RemoveESP(v)
                    end
                end
            end
        end
    end
})

TabVisual:Section({ Title = "IV AZURE" })

TabVisual:Toggle({
    Title = "GroundBulbModel ESP",
    Desc = "Chống Lag (Event), Aura Tím, Đợi 0.5s gắn định vị",
    Default = false,
    Callback = function(State)
        getgenv().Amethyst_GroundBulbESP = State
        
        if State then
            -- Quét 1 lần duy nhất lúc vừa bật
            for _, v in pairs(workspace:GetDescendants()) do
                if v:IsA("Model") then
                    if string.match(string.lower(v.Name), "groundbulbmodel") then
                        AddESP(v, "GroundBulbModel", nil, Color3.fromRGB(138, 43, 226))
                    end
                end
            end
            
            -- Lắng nghe sự kiện
            getgenv().Amethyst_GroundBulbConn = workspace.DescendantAdded:Connect(function(v)
                task.wait(0.5) -- CHỜ ĐÚNG 0.5 GIÂY SAU KHI XUẤT HIỆN
                if getgenv().Amethyst_GroundBulbESP then
                    if v:IsA("Model") then
                        if string.match(string.lower(v.Name), "groundbulbmodel") then
                            AddESP(v, "GroundBulbModel", nil, Color3.fromRGB(138, 43, 226))
                        end
                    end
                end
            end)
        else
            -- Tắt lắng nghe sự kiện
            if getgenv().Amethyst_GroundBulbConn then
                getgenv().Amethyst_GroundBulbConn:Disconnect()
                getgenv().Amethyst_GroundBulbConn = nil
            end
            
            -- Xóa ESP cũ
            for _, v in pairs(workspace:GetDescendants()) do
                if v:IsA("Model") then
                    if string.match(string.lower(v.Name), "groundbulbmodel") then
                        RemoveESP(v)
                    end
                end
            end
        end
    end
})

TabVisual:Toggle({
    Title = "VineModel ESP",
    Desc = "Chống Lag (Event), Aura Tím, Đợi 0.5s gắn định vị",
    Default = false,
    Callback = function(State)
        getgenv().Amethyst_VineESP = State
        
        if State then
            -- Quét 1 lần duy nhất lúc vừa bật
            for _, v in pairs(workspace:GetDescendants()) do
                if v:IsA("Model") then
                    if string.match(string.lower(v.Name), "vinemodel") then
                        AddESP(v, "VineModel", nil, Color3.fromRGB(138, 43, 226))
                    end
                end
            end
            
            -- Lắng nghe sự kiện
            getgenv().Amethyst_VineConn = workspace.DescendantAdded:Connect(function(v)
                task.wait(0.5)
                if getgenv().Amethyst_VineESP then
                    if v:IsA("Model") then
                        if string.match(string.lower(v.Name), "vinemodel") then
                            AddESP(v, "VineModel", nil, Color3.fromRGB(138, 43, 226))
                        end
                    end
                end
            end)
        else
            -- Tắt lắng nghe sự kiện
            if getgenv().Amethyst_VineConn then
                getgenv().Amethyst_VineConn:Disconnect()
                getgenv().Amethyst_VineConn = nil
            end
            
            -- Xóa ESP cũ
            for _, v in pairs(workspace:GetDescendants()) do
                if v:IsA("Model") then
                    if string.match(string.lower(v.Name), "vinemodel") then
                        RemoveESP(v)
                    end
                end
            end
        end
    end
})

TabVisual:Section({ Title = "V BUILDERMAN" })

TabVisual:Toggle({
    Title = "BuildermanDispenser ESP",
    Desc = "Chống Lag (Event), Sinh Vật, Xóa khi chết (Không hiện HP)",
    Default = false,
    Callback = function(State)
        getgenv().Amethyst_BuilderDispenserESP = State
        
        local function applyDispenserESP(v)
            if v:IsA("Model") and string.match(string.lower(v.Name), "buildermandispenser") then
                -- Ép thành chuẩn Sinh vật: Chỉ nhận Model thực sự chứa Humanoid (tự loại bỏ thư mục/model lồng nhau)
                local humanoid = v:FindFirstChild("Humanoid")
                if humanoid then
                    if game.Players:GetPlayerFromCharacter(v) then return end
                    
                    local hp = nil -- XÓA HIỂN THỊ HP TRÊN ĐỊNH VỊ THEO LỆNH
                    AddESP(v, "BuildermanDispenser", hp, Color3.fromRGB(0, 255, 0))
                    
                    -- Luồng theo dõi HP và xóa khi máu <= 0
                    task.spawn(function()
                        while getgenv().Amethyst_BuilderDispenserESP and v and v.Parent do
                            if humanoid.Health <= 0 then
                                RemoveESP(v)
                                break
                            end
                            -- Liên tục update máu lên bảng (Đã đổi sang nil để ẩn HP)
                            AddESP(v, "BuildermanDispenser", nil, Color3.fromRGB(0, 255, 0))
                            task.wait(0.5)
                        end
                    end)
                end
            end
        end

        if State then
            -- Quét 1 lần duy nhất lúc vừa bật
            for _, v in pairs(workspace:GetDescendants()) do
                applyDispenserESP(v)
            end
            
            -- Lắng nghe sự kiện
            getgenv().Amethyst_BuilderDispenserConn = workspace.DescendantAdded:Connect(function(v)
                task.wait(0.5)
                if getgenv().Amethyst_BuilderDispenserESP then
                    applyDispenserESP(v)
                end
            end)
        else
            -- Tắt lắng nghe sự kiện
            if getgenv().Amethyst_BuilderDispenserConn then
                getgenv().Amethyst_BuilderDispenserConn:Disconnect()
                getgenv().Amethyst_BuilderDispenserConn = nil
            end
            
            -- Xóa ESP cũ
            for _, v in pairs(workspace:GetDescendants()) do
                if v:IsA("Model") and string.match(string.lower(v.Name), "buildermandispenser") then
                    RemoveESP(v)
                end
            end
        end
    end
})

TabVisual:Toggle({
    Title = "BuildermanSentry ESP",
    Desc = "Chống Lag (Event), Sinh Vật, Xóa khi chết (Không hiện HP)",
    Default = false,
    Callback = function(State)
        getgenv().Amethyst_BuilderSentryESP = State
        
        local function applySentryESP(v)
            if v:IsA("Model") and string.match(string.lower(v.Name), "buildermansentry") then
                -- Ép thành chuẩn Sinh vật: Chỉ nhận Model thực sự chứa Humanoid (tự loại bỏ thư mục/model lồng nhau)
                local humanoid = v:FindFirstChild("Humanoid")
                if humanoid then
                    if game.Players:GetPlayerFromCharacter(v) then return end
                    
                    local hp = nil -- XÓA HIỂN THỊ HP TRÊN ĐỊNH VỊ THEO LỆNH
                    AddESP(v, "BuildermanSentry", hp, Color3.fromRGB(0, 255, 0))
                    
                    -- Luồng theo dõi HP và xóa khi máu <= 0
                    task.spawn(function()
                        while getgenv().Amethyst_BuilderSentryESP and v and v.Parent do
                            if humanoid.Health <= 0 then
                                RemoveESP(v)
                                break
                            end
                            -- Liên tục update máu lên bảng (Đã đổi sang nil để ẩn HP)
                            AddESP(v, "BuildermanSentry", nil, Color3.fromRGB(0, 255, 0))
                            task.wait(0.5)
                        end
                    end)
                end
            end
        end

        if State then
            -- Quét 1 lần duy nhất lúc vừa bật
            for _, v in pairs(workspace:GetDescendants()) do
                applySentryESP(v)
            end
            
            -- Lắng nghe sự kiện
            getgenv().Amethyst_BuilderSentryConn = workspace.DescendantAdded:Connect(function(v)
                task.wait(0.5)
                if getgenv().Amethyst_BuilderSentryESP then
                    applySentryESP(v)
                end
            end)
        else
            -- Tắt lắng nghe sự kiện
            if getgenv().Amethyst_BuilderSentryConn then
                getgenv().Amethyst_BuilderSentryConn:Disconnect()
                getgenv().Amethyst_BuilderSentryConn = nil
            end
            
            -- Xóa ESP cũ
            for _, v in pairs(workspace:GetDescendants()) do
                if v:IsA("Model") and string.match(string.lower(v.Name), "buildermansentry") then
                    RemoveESP(v)
                end
            end
        end
    end
})

TabVisual:Section({ Title = "VI 007N7" })

TabVisual:Toggle({
    Title = "CLONE 007N7 ESP",
    Desc = "Chống Lag (Event), Bỏ qua Player, Xóa ESP khi chết",
    Default = false,
    Callback = function(State)
        getgenv().Amethyst_007N7ESP = State
        
        -- Hàm xử lý gắn ESP và theo dõi cái chết của Clone
        local function apply007N7ESP(v)
            if v:IsA("Model") and string.match(string.lower(v.Name), "007n7") then
                -- Bỏ qua nếu đây là nhân vật của người chơi thật (Player)
                if game.Players:GetPlayerFromCharacter(v) then return end
                
                AddESP(v, "007N7", nil, Color3.fromRGB(0, 255, 0))
                
                -- Tạo luồng chạy ngầm siêu nhẹ theo dõi lúc Clone chết để xóa ESP
                task.spawn(function()
                    local humanoid = v:FindFirstChild("Humanoid")
                    while getgenv().Amethyst_007N7ESP and v and v.Parent do
                        if humanoid and humanoid.Health <= 0 then
                            RemoveESP(v)
                            break
                        end
                        task.wait(0.5)
                    end
                end)
            end
        end

        if State then
            -- Quét 1 lần duy nhất lúc vừa bật
            for _, v in pairs(workspace:GetDescendants()) do
                apply007N7ESP(v)
            end
            
            -- Lắng nghe sự kiện
            getgenv().Amethyst_007N7Conn = workspace.DescendantAdded:Connect(function(v)
                task.wait(0.5)
                if getgenv().Amethyst_007N7ESP then
                    apply007N7ESP(v)
                end
            end)
        else
            -- Tắt lắng nghe sự kiện
            if getgenv().Amethyst_007N7Conn then
                getgenv().Amethyst_007N7Conn:Disconnect()
                getgenv().Amethyst_007N7Conn = nil
            end
            
            -- Xóa ESP cũ
            for _, v in pairs(workspace:GetDescendants()) do
                if v:IsA("Model") and string.match(string.lower(v.Name), "007n7") then
                    RemoveESP(v)
                end
            end
        end
    end
})

TabVisual:Section({ Title = "VII TAPH" })

TabVisual:Toggle({
    Title = "SubspaceTripmine ESP",
    Desc = "Chống Lag (Event), Sinh Vật, Xóa khi chết (Không hiện HP)",
    Default = false,
    Callback = function(State)
        getgenv().Amethyst_SubspaceESP = State
        
        local function applySubspaceESP(v)
            if v:IsA("Model") and string.match(string.lower(v.Name), "subspacetripmine") then
                local humanoid = v:FindFirstChild("Humanoid")
                if humanoid then
                    if game.Players:GetPlayerFromCharacter(v) then return end
                    
                    -- FIX: Áp dụng ESP trực tiếp vào cả Model để hiện toàn phần
                    AddESP(v, "SubspaceTripmine", nil, Color3.fromRGB(0, 255, 0))
                    
                    task.spawn(function()
                        while getgenv().Amethyst_SubspaceESP do
                            local currentHum = v:FindFirstChild("Humanoid")
                            if not v or not v.Parent or not v:IsDescendantOf(workspace) or not currentHum or currentHum.Health <= 0 then
                                RemoveESP(v)
                                break
                            end
                            task.wait(0.5)
                        end
                    end)
                end
            end
        end

        if State then
            for _, v in pairs(workspace:GetDescendants()) do
                applySubspaceESP(v)
            end
            
            getgenv().Amethyst_SubspaceConn = workspace.DescendantAdded:Connect(function(v)
                task.wait(0.5)
                if getgenv().Amethyst_SubspaceESP then
                    applySubspaceESP(v)
                end
            end)
        else
            if getgenv().Amethyst_SubspaceConn then
                getgenv().Amethyst_SubspaceConn:Disconnect()
                getgenv().Amethyst_SubspaceConn = nil
            end
            
            for _, v in pairs(workspace:GetDescendants()) do
                if v:IsA("Model") and string.match(string.lower(v.Name), "subspacetripmine") then
                    RemoveESP(v)
                    for _, child in pairs(v:GetDescendants()) do
                        if child:IsA("BasePart") then
                            RemoveESP(child)
                        end
                    end
                end
            end
        end
    end
})

TabVisual:Toggle({
    Title = "TaphTripwire ESP",
    Desc = "Chống Lag (Event), Bỏ qua Tên Người Chơi, Không hiện HP",
    Default = false,
    Callback = function(State)
        getgenv().Amethyst_TaphTripwireESP = State
        
        local function applyTaphESP(v)
            -- Tìm model có chứa chữ taphtripwire (sẽ bắt được luôn cả các model có dính tên người chơi)
            if v:IsA("Model") and string.match(string.lower(v.Name), "taphtripwire") then
                local humanoid = v:FindFirstChild("Humanoid")
                if humanoid then
                    if game.Players:GetPlayerFromCharacter(v) then return end
                    
                    -- FIX LỖI TÊN NẰM Ở ĐẦU DÂY: Gắn trực tiếp vào Model (v) thay vì 1 Part lẻ để game tự động căn giữa bounding box của cái bẫy
                    local targetPart = v
                    
                    -- CHỈ HIỂN THỊ CHỮ "TaphTripwire" GỌN GÀNG, BỎ QUA CÁI TÊN NGƯỜI CHƠI BỊ LỒNG VÀO
                    AddESP(targetPart, "TaphTripwire", nil, Color3.fromRGB(0, 255, 0))
                    
                    task.spawn(function()
                        while getgenv().Amethyst_TaphTripwireESP do
                            local currentHum = v:FindFirstChild("Humanoid")
                            if not v or not v.Parent or not v:IsDescendantOf(workspace) or not currentHum or currentHum.Health <= 0 then
                                RemoveESP(targetPart)
                                break
                            end
                            task.wait(0.5)
                        end
                    end)
                end
            end
        end

        if State then
            for _, v in pairs(workspace:GetDescendants()) do
                applyTaphESP(v)
            end
            
            getgenv().Amethyst_TaphTripwireConn = workspace.DescendantAdded:Connect(function(v)
                task.wait(0.5)
                if getgenv().Amethyst_TaphTripwireESP then
                    applyTaphESP(v)
                end
            end)
        else
            if getgenv().Amethyst_TaphTripwireConn then
                getgenv().Amethyst_TaphTripwireConn:Disconnect()
                getgenv().Amethyst_TaphTripwireConn = nil
            end
            
            for _, v in pairs(workspace:GetDescendants()) do
                if v:IsA("Model") and string.match(string.lower(v.Name), "taphtripwire") then
                    RemoveESP(v)
                    for _, child in pairs(v:GetDescendants()) do
                        if child:IsA("BasePart") then
                            RemoveESP(child)
                        end
                    end
                end
            end
        end
    end
})

-- 7. AIMBOT (Icon: Ống nhắm)
local TabAimbot = Window:Tab({ Title = "Aimbot", Icon = "crosshair" })
TabAimbot:Paragraph({
    Title = "Thông Báo",
    Desc = "Chức năng đang được Update..."
})

-- 8. SETTING (Icon: Bánh răng khác)
local TabSetting = Window:Tab({ Title = "Setting", Icon = "settings-2" })

TabSetting:Section({ Title = "I THEME" })

TabSetting:Dropdown({
    Title = "Chọn Theme Giao Diện",
    Desc = "Thay đổi màu sắc tổng thể của Menu",
    Values = {
        "Dark", "Light", "Rose", "Plant", "Red", "Indigo", "Sky", "Violet", 
        "Emerald", "Midnight", "Crimson", "MonokaiPro", "CottonCandy", 
        "Mellowsi", "Amber", "Rainbow"
    },
    Value = "Midnight",
    Callback = function(ThemeName)
        WindUI:SetTheme(ThemeName)
    end
})

TabSetting:Section({ Title = "II AUTO SAVE" })

local HttpService = game:GetService("HttpService")
local SaveFileName = "AmethystHub_Config/SaveSettings.json"

local function SaveAll()
    pcall(function()
        local data = {}
        if Window and Window.AllElements then
            for _, element in pairs(Window.AllElements) do
                if element.Title then
                    if element.__type == "Toggle" then
                        data[element.Title] = element.Value
                    elseif element.__type == "Dropdown" then
                        data[element.Title] = element.Value
                    end
                end
            end
            if not isfolder("AmethystHub_Config") then
                makefolder("AmethystHub_Config")
            end
            writefile(SaveFileName, HttpService:JSONEncode(data))
        end
    end)
end

local function LoadAll()
    pcall(function()
        if isfile and isfile(SaveFileName) then
            local data = HttpService:JSONDecode(readfile(SaveFileName))
            if Window and Window.AllElements then
                for _, element in pairs(Window.AllElements) do
                    if element.Title and data[element.Title] ~= nil then
                        if element.__type == "Toggle" then
                            element:Set(data[element.Title])
                        elseif element.__type == "Dropdown" then
                            element:Select(data[element.Title])
                        end
                    end
                end
            end
        end
    end)
end

TabSetting:Toggle({
    Title = "Auto Save Settings",
    Desc = "Tự động lưu cấu hình (ESP, Theme...) mỗi 3 giây (NO LAG)",
    Default = false,
    Callback = function(State)
        getgenv().Amethyst_AutoSave = State
        if State then
            task.spawn(function()
                while getgenv().Amethyst_AutoSave do
                    SaveAll()
                    task.wait(3)
                end
            end)
        else
            SaveAll() -- Lưu lại trạng thái tắt một lần cuối
        end
    end
})

-- Khởi chạy LoadAll() một lần duy nhất khi load xong UI để tự động nạp Save cũ
task.spawn(function()
    task.wait(1.5) -- Đợi UI và các ESP load xong form cơ bản rồi mới nạp Save
    LoadAll()
end)

-- Hiển thị thông báo góc màn hình khi load xong form
WindUI:Notify({
    Title = "AMETHYST HUB",
    Content = "Tải thành công bộ khung UI (Đang chờ update chức năng)",
    Duration = 3,
    Icon = "check"
})
