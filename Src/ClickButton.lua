local VirtualInputManager = game:GetService("VirtualInputManager")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer

local ClickButton = {}
ClickButton.__index = ClickButton

local function resolveTarget(target, timeout)
    timeout = timeout or 5

    if typeof(target) == "Instance" then
        return target
    end

    if type(target) ~= "string" then
        return nil, "Target must be an Instance or string path"
    end

    local root = LocalPlayer:WaitForChild("PlayerGui", timeout)
    if not root then
        return nil, "PlayerGui not found"
    end

    local node = root
    for segment in string.gmatch(target, "[^%.]+") do
        if segment == "PlayerGui" and node == root then

        else
            local child = node:WaitForChild(segment, timeout)
            if not child then
                return nil, "Missing segment: " .. segment
            end
            node = child
        end
    end

    return node
end

local function virtualClick(button)
    local absPos  = button.AbsolutePosition
    local absSize = button.AbsoluteSize
    local x = absPos.X + absSize.X / 2
    local y = absPos.Y + absSize.Y / 2

    VirtualInputManager:SendMouseButtonEvent(x, y, 0, true,  game, 0)
    task.wait()
    VirtualInputManager:SendMouseButtonEvent(x, y, 0, false, game, 0)
end

local env = getfenv()
local fireSignalFn = rawget(env, "firesignal") or rawget(_G, "firesignal")

local function fastClick(button)
    if button:IsA("GuiButton") then
        if type(fireSignalFn) == "function" and button.MouseButton1Click then
            local ok = pcall(fireSignalFn, button.MouseButton1Click)
            if ok then return end
        end

        local ok2 = pcall(function()
            button:Activate()
        end)
        if ok2 then return end
    end

    virtualClick(button)
end

----------------------------------------------------------------------
-- Public API
----------------------------------------------------------------------
function ClickButton.Click(target, opts)
    opts = opts or {}
    local button, err = resolveTarget(target, opts.Timeout)
    if not button then
        return false, err
    end

    if opts.RequireVisible and button:IsA("GuiObject") and not button.Visible then
        return false, "Button not visible"
    end

    local ok, callErr = pcall(fastClick, button)
    if not ok then
        return false, callErr
    end
    return true
end

function ClickButton.ClickPath(path, opts)
    return ClickButton.Click(path, opts)
end

function ClickButton.Start(opts)
    assert(type(opts) == "table", "Start expects an options table")
    assert(opts.Target ~= nil, "Target is required")

    local session = setmetatable({
        _running = true,
        _opts = opts,
    }, ClickButton)

    task.spawn(function()
        while session._running do
            local delay = session._opts.Delay or 0.1
            local ok, err = ClickButton.Click(session._opts.Target, {
                RequireVisible = session._opts.RequireVisible ~= false,
                Timeout        = session._opts.Timeout,
            })
            if not ok and session._opts.OnError then
                pcall(session._opts.OnError, err)
            end
            task.wait(delay)
        end
    end)

    return session
end

function ClickButton:Stop()
    self._running = false
end

function ClickButton:IsRunning()
    return self._running == true
end

function ClickButton:SetDelay(delay)
    self._opts.Delay = delay
end

function ClickButton:SetTarget(target)
    self._opts.Target = target
end

return ClickButton