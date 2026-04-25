-- handlers/modal_handler.lua

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local screenGui = playerGui:WaitForChild("EXE6")
local modalFrame = screenGui:WaitForChild("modal_frame")

local OPEN_INFO  = TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
local CLOSE_INFO = TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
local FADE_INFO  = TweenInfo.new(0.2,  Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

-- Backdrop dim
local backdrop = Instance.new("Frame")
backdrop.Name = "_backdrop"
backdrop.Size = UDim2.fromScale(1, 1)
backdrop.BackgroundColor3 = Color3.new(0, 0, 0)
backdrop.BackgroundTransparency = 1
backdrop.ZIndex = 8
backdrop.Visible = false
backdrop.Parent = screenGui

local currentModal = nil
local isAnimating = false

local function getInnerFrame(modal)
	return modal:FindFirstChild("frame")
end

local function closeModal(cb)
	if not currentModal or isAnimating then
		if cb then cb() end
		return
	end
	isAnimating = true
	local inner = getInnerFrame(currentModal)
	local t1 = TweenService:Create(backdrop, FADE_INFO, { BackgroundTransparency = 1 })
	t1:Play()
	if inner then
		local t2 = TweenService:Create(inner, CLOSE_INFO, {
			Size = inner.Size + UDim2.fromOffset(-20, -20),
		})
		t2:Play()
		t2.Completed:Connect(function()
			currentModal.Visible = false
			backdrop.Visible = false
			inner.Size = inner:GetAttribute("_origSize") or inner.Size
			currentModal = nil
			isAnimating = false
			if cb then cb() end
		end)
	else
		t1.Completed:Connect(function()
			currentModal.Visible = false
			backdrop.Visible = false
			currentModal = nil
			isAnimating = false
			if cb then cb() end
		end)
	end
end

local function openModal(name, data)
	if isAnimating then return end
	local modal = modalFrame:FindFirstChild(name)
	if not modal then warn("[EXE6] Modal not found:", name) return end

	if currentModal and currentModal ~= modal then
		closeModal(function() openModal(name, data) end)
		return
	end

	isAnimating = true
	currentModal = modal

	local inner = getInnerFrame(modal)
	if inner then
		if not inner:GetAttribute("_origSize") then
			inner:SetAttribute("_origSize", inner.Size)
		end
		inner.Size = inner:GetAttribute("_origSize") + UDim2.fromOffset(-30, -30)
	end

	backdrop.ZIndex = 8
	modal.ZIndex = 9
	backdrop.BackgroundTransparency = 1
	backdrop.Visible = true
	modal.Visible = true

	TweenService:Create(backdrop, FADE_INFO, { BackgroundTransparency = 0.55 }):Play()

	if inner then
		local t = TweenService:Create(inner, OPEN_INFO, {
			Size = inner:GetAttribute("_origSize"),
		})
		t:Play()
		t.Completed:Connect(function()
			isAnimating = false
			if data and data.onOpen then data.onOpen(modal) end
		end)
	else
		isAnimating = false
		if data and data.onOpen then data.onOpen(modal) end
	end
end

-- Đóng khi click backdrop
backdrop.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		closeModal()
	end
end)

-- Đóng khi Escape
UserInputService.InputBegan:Connect(function(input, processed)
	if not processed and input.KeyCode == Enum.KeyCode.Escape then
		closeModal()
	end
end)

-- Bind nút close trong từng modal
for _, modal in ipairs(modalFrame:GetChildren()) do
	if not modal:IsA("GuiObject") then continue end
	local inner = getInnerFrame(modal)
	if not inner then continue end
	modal.Visible = false

	-- Tìm close button
	local closeBtn = inner:FindFirstChild("close", true)
		or inner:FindFirstChild("x", true)
		or inner:FindFirstChild("exit", true)
	if closeBtn and (closeBtn:IsA("ImageButton") or closeBtn:IsA("TextButton")) then
		closeBtn.Activated:Connect(function() closeModal() end)
	end
end

_G.EXE6_Modal = {
	open  = openModal,
	close = closeModal,
	get   = function(name) return modalFrame:FindFirstChild(name) end,
}
