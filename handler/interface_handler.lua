-- handlers/interface_handler.lua
-- Executor-compatible: tìm UI qua PlayerGui thay vì script.Parent

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local screenGui = playerGui:WaitForChild("EXE6")

local tooltip = screenGui:WaitForChild("interface_handler"):WaitForChild("tooltip")
local frame = tooltip:WaitForChild("frame")
local container = frame:WaitForChild("container")
local label = container:WaitForChild("label")

-- Config
local TWEEN_IN  = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local TWEEN_OUT = TweenInfo.new(0.1,  Enum.EasingStyle.Quad, Enum.EasingDirection.In)
local OFFSET = Vector2.new(14, -10)

tooltip.Visible = false
tooltip.GroupTransparency = 1

local currentTween
local function tweenTooltip(visible)
	if currentTween then currentTween:Cancel() end
	if visible then tooltip.Visible = true end
	currentTween = TweenService:Create(tooltip, visible and TWEEN_IN or TWEEN_OUT, {
		GroupTransparency = visible and 0 or 1
	})
	currentTween:Play()
	if not visible then
		currentTween.Completed:Connect(function()
			tooltip.Visible = false
		end)
	end
end

-- Cursor follow
RunService.RenderStepped:Connect(function()
	if not tooltip.Visible then return end
	local mouse = UserInputService:GetMouseLocation()
	local sx = screenGui.AbsoluteSize.X
	local sy = screenGui.AbsoluteSize.Y
	local tx = tooltip.AbsoluteSize.X
	local ty = tooltip.AbsoluteSize.Y
	tooltip.Position = UDim2.fromOffset(
		math.clamp(mouse.X + OFFSET.X, 0, sx - tx),
		math.clamp(mouse.Y + OFFSET.Y - ty, 0, sy - ty)
	)
end)

-- Auto-bind các element có Attribute "Tooltip"
local function bind(obj)
	if not obj:IsA("GuiObject") then return end
	local text = obj:GetAttribute("Tooltip")
	if not text or text == "" then return end
	obj.MouseEnter:Connect(function() label.Text = text; tweenTooltip(true) end)
	obj.MouseLeave:Connect(function() tweenTooltip(false) end)
end

for _, obj in ipairs(screenGui:GetDescendants()) do bind(obj) end
screenGui.DescendantAdded:Connect(bind)

-- API
_G.EXE6_Tooltip = {
	show = function(text) label.Text = text; tweenTooltip(true) end,
	hide = function() tweenTooltip(false) end,
}
