local Http = game:GetService("HttpService")
local userKey = _G.TanPhatKey -- Đọc từ _G

-- 1. KIỂM TRA XEM LOADER CÓ GỬI KEY QUA KHÔNG
if not userKey or userKey == "" then
    game.Players.LocalPlayer:Kick("\n[TanPhatHub]\nLỗi: Loader chưa truyền được Key qua _G!")
    return
end

-- 2. DÙNG HÀM REQUEST ĐỂ GỬI DỮ LIỆU (Tương thích mọi Executor)
local req = (syn and syn.request) or (http and http.request) or http_request or (fluxus and fluxus.request) or request

local success, response = pcall(function()
    return req({
        Url = "https://bmwkrsduqbajhstpynqs.supabase.co/functions/v1/check-key",
        Method = "POST",
        Headers = { ["Content-Type"] = "application/json" },
        Body = Http:JSONEncode({
            key = userKey,
            hwid = game:GetService("RbxAnalyticsService"):GetClientId()
        })
    })
end)

-- 3. XỬ LÝ PHẢN HỒI TỪ SERVER
if success and response then
    local data = Http:JSONDecode(response.Body)
    
    if data and data.valid then
        -- THÀNH CÔNG: Hiện thời gian còn lại
        local s = math.floor((data.remaining_hours or 0) * 3600)
        local timeStr = string.format("%d ngày, %02d:%02d:%02d", s/86400, s/3600%24, s/60%60, s%60)
        
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "TanPhatHub | Thành Công",
            Text = "Hạn dùng: " .. timeStr,
            Duration = 5
        })
        print("✅ Xác thực thành công: " .. timeStr)
    else
        -- THẤT BẠI: Báo lỗi cụ thể từ Dashboard (Sai HWID, Hết hạn...)
        local msg = data and data.message or "Key không hợp lệ!"
        game.Players.LocalPlayer:Kick("\n[TanPhatHub]\n" .. msg .. "\nKey gửi đi: " .. tostring(userKey))
        return
    end
else
    game.Players.LocalPlayer:Kick("\n[TanPhatHub]\nLỗi kết nối Server!")
    return
end

loadstring(game:HttpGet("https://raw.githubusercontent.com/duongngoctuan571-jpg/File-23454-25421-89-432/main/code.lua"))()
