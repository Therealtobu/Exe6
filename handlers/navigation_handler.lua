-- handlers/navigation_handler.lua

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local screenGui = playerGui:WaitForChild("EXE6")

local mainFrame  = screenGui:WaitForChild("main_frame")
local content    = mainFrame:WaitForChild("content")
local navigation = content:WaitForChild("navigation")
local screen     = content:WaitForChild("screen")
local pageLayout = screen:WaitForChild("page")

local TWEEN = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

-- Pages theo đúng thứ tự UIPageLayout
local PAGE_ORDER = {
	"home", "people", "bans", "announcements",
	"utilities", "activity_audits", "team_connect", "system"
}

local currentPage = nil

-- Tìm button trong navigation tương ứng với page
-- Convention: button.Name == page name HOẶC button có Attribute "Page"
local function findNavBtn(pageName)
	for _, obj in ipairs(navigation:GetDescendants()) do
		if (obj:IsA("ImageButton") or obj:IsA("TextButton")) then
			local attr = obj:GetAttribute("Page")
			if (attr and attr == pageName) or obj.Name == pageName then
				return obj
			end
		end
	end
end

local function setActive(btn, active)
	if not btn then return end
	for _, child in ipairs(btn:GetDescendants()) do
		if child:IsA("ImageLabel") then
			TweenService:Create(child, TWEEN, {
				ImageTransparency = active and 0 or 0.5
			}):Play()
		elseif child:IsA("TextLabel") then
			TweenService:Create(child, TWEEN, {
				TextTransparency = active and 0 or 0.4
			}):Play()
		end
	end
	-- Active indicator bar
	local bar = btn:FindFirstChild("indicator") or btn:FindFirstChild("active") or btn:FindFirstChild("bar")
	if bar then
		TweenService:Create(bar, TWEEN, {
			BackgroundTransparency = active and 0 or 1
		}):Play()
	end
end

local function navigateTo(pageName)
	if pageName == currentPage then return end
	local page = screen:FindFirstChild(pageName)
	if not page then return end

	-- Deactivate nút cũ
	if currentPage then
		setActive(findNavBtn(currentPage), false)
	end

	pageLayout:JumpTo(page)
	currentPage = pageName
	setActive(findNavBtn(pageName), true)
end

-- Bind tất cả nav button
for _, pageName in ipairs(PAGE_ORDER) do
	local btn = findNavBtn(pageName)
	if btn then
		btn.Activated:Connect(function()
			navigateTo(pageName)
		end)
	end
end

-- User display (avatar + name)
local userFrame = navigation:FindFirstChild("user")
if userFrame then
	task.spawn(function()
		local avatar = userFrame:FindFirstChild("avatar", true)
			or userFrame:FindFirstChildWhichIsA("ImageLabel")
		local nameLabel = userFrame:FindFirstChild("name", true)
			or userFrame:FindFirstChildWhichIsA("TextLabel")

		if avatar then
			local ok, img = pcall(Players.GetUserThumbnailAsync, Players,
				player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
			if ok then avatar.Image = img end
		end
		if nameLabel then
			nameLabel.Text = player.DisplayName
		end
	end)
end

-- Sync khi UIPageLayout tự thay đổi
pageLayout:GetPropertyChangedSignal("CurrentPage"):Connect(function()
	local p = pageLayout.CurrentPage
	if p then currentPage = p.Name end
end)

-- Default: mở home
navigateTo("home")

_G.EXE6_Navigation = {
	goto = navigateTo,
	getCurrent = function() return currentPage end,
}
