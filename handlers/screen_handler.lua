-- handlers/screen_handler.lua
-- Pure frontend: animate page transitions, setup button states trong từng page

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local screenGui = playerGui:WaitForChild("EXE6")

local screen = screenGui:WaitForChild("main_frame")
	:WaitForChild("content")
	:WaitForChild("screen")

local pageLayout = screen:WaitForChild("page")

local FADE_IN = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

-- Fade in page khi chuyển
local function onPageChanged()
	local page = pageLayout.CurrentPage
	if not page then return end

	-- Nếu page là CanvasGroup thì fade
	if page:IsA("CanvasGroup") then
		page.GroupTransparency = 1
		TweenService:Create(page, FADE_IN, { GroupTransparency = 0 }):Play()
	end

	-- Setup từng page lần đầu (chỉ 1 lần)
	if page:GetAttribute("_initialized") then return end
	page:SetAttribute("_initialized", true)

	-- ===============================================
	-- HOME page
	-- ===============================================
	if page.Name == "home" then
		local function updateStats()
			local function setVal(name, val)
				local el = page:FindFirstChild(name, true)
				if el and el:IsA("TextLabel") then el.Text = tostring(val) end
			end
			setVal("player_count", #Players:GetPlayers())
			setVal("place_id", game.PlaceId)
			setVal("job_id", game.JobId ~= "" and game.JobId:sub(1,8).."…" or "Studio")
		end
		updateStats()
		Players.PlayerAdded:Connect(updateStats)
		Players.PlayerRemoving:Connect(function() task.wait(0.05); updateStats() end)

	-- ===============================================
	-- PEOPLE page
	-- ===============================================
	elseif page.Name == "people" then
		local list = page:FindFirstChildWhichIsA("ScrollingFrame")
		local template = list and list:FindFirstChildOfClass("Frame")

		local function renderList()
			if not list or not template then return end
			for _, c in ipairs(list:GetChildren()) do
				if c ~= template and c:IsA("GuiObject") then c:Destroy() end
			end
			for i, p in ipairs(Players:GetPlayers()) do
				local entry = template:Clone()
				entry.Name = p.Name
				entry.LayoutOrder = i
				entry.Visible = true

				local nameEl = entry:FindFirstChild("name", true)
				if nameEl and nameEl:IsA("TextLabel") then
					nameEl.Text = p.DisplayName .. "  @" .. p.Name
				end

				local avatarEl = entry:FindFirstChildWhichIsA("ImageLabel")
				if avatarEl then
					task.spawn(function()
						local ok, img = pcall(Players.GetUserThumbnailAsync, Players,
							p.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size60x60)
						if ok then avatarEl.Image = img end
					end)
				end

				-- Click → mở profile modal
				if entry:IsA("ImageButton") or entry:IsA("TextButton") then
					entry.Activated:Connect(function()
						if _G.EXE6_Modal then
							_G.EXE6_Modal.open("profile", { player = p })
						end
					end)
				end

				entry.Parent = list
			end
		end

		renderList()
		Players.PlayerAdded:Connect(renderList)
		Players.PlayerRemoving:Connect(function() task.wait(0.05); renderList() end)

	-- ===============================================
	-- Các page còn lại: chỉ bind button chung
	-- ===============================================
	else
		-- Bind nút Close/Back nếu có
		for _, btn in ipairs(page:GetDescendants()) do
			if (btn:IsA("ImageButton") or btn:IsA("TextButton")) then
				local n = btn.Name:lower()
				if n == "close" or n == "back" or n == "exit" then
					btn.Activated:Connect(function()
						if _G.EXE6_Navigation then
							_G.EXE6_Navigation.goto("home")
						end
					end)
				end
			end
		end
	end
end

pageLayout:GetPropertyChangedSignal("CurrentPage"):Connect(onPageChanged)

-- Init page hiện tại
task.defer(onPageChanged)

_G.EXE6_Screen = {
	getPage = function(name) return screen:FindFirstChild(name) end,
}
