local Theme = {
    Current = "dark",
    Themes = {}
}

-- Mock Color3 implementation for non-Roblox environment
local Color3 = {
    fromRGB = function(r, g, b)
        return {
            R = r/255,
            G = g/255,
            B = b/255,
            r = r,
            g = g,
            b = b
        }
    end,
    new = function(r, g, b)
        return {
            R = r,
            G = g,
            B = b,
            r = r*255,
            g = g*255,
            b = b*255
        }
    end
}

-- Initialize themes with mock Color3
Theme.Themes = {
    dark = {
        background = Color3.fromRGB(40, 40, 40),
        foreground = Color3.fromRGB(255, 255, 255),
        accent = Color3.fromRGB(0, 122, 204),
        secondary = Color3.fromRGB(60, 60, 60),
        border = Color3.fromRGB(70, 70, 70),
        success = Color3.fromRGB(39, 174, 96),
        warning = Color3.fromRGB(241, 196, 15),
        error = Color3.fromRGB(231, 76, 60)
    },
    light = {
        background = Color3.fromRGB(240, 240, 240),
        foreground = Color3.fromRGB(0, 0, 0),
        accent = Color3.fromRGB(0, 122, 204),
        secondary = Color3.fromRGB(220, 220, 220),
        border = Color3.fromRGB(200, 200, 200),
        success = Color3.fromRGB(39, 174, 96),
        warning = Color3.fromRGB(241, 196, 15),
        error = Color3.fromRGB(231, 76, 60)
    }
}

function Theme:Apply(themeName)
    if not self.Themes[themeName] then
        warn("Theme not found:", themeName)
        return
    end

    self.Current = themeName
    local theme = self.Themes[themeName]

    if not self:IsRobloxEnvironment() then
        print("Warning: Running outside Roblox environment. Theme changes will not be applied.")
        return
    end

    -- Update UI elements
    local function updateElement(element)
        if element:IsA("Frame") then
            element.BackgroundColor3 = theme.background
        elseif element:IsA("TextLabel") or element:IsA("TextButton") then
            element.TextColor3 = theme.foreground
        elseif element:IsA("ScrollingFrame") then
            element.BackgroundColor3 = theme.secondary
            element.ScrollBarImageColor3 = theme.accent
        end

        -- Update border colors
        if element.BorderSizePixel > 0 then
            element.BorderColor3 = theme.border
        end
    end

    -- Find the ScreenGui
    if game then
        local gui = game:GetService("CoreGui"):FindFirstChild("AdvancedSpy")
        if gui then
            -- Recursively update all UI elements
            local function updateRecursive(parent)
                for _, child in ipairs(parent:GetChildren()) do
                    updateElement(child)
                    updateRecursive(child)
                end
            end

            updateRecursive(gui)
        end
    end
end

function Theme:GetColor(colorName)
    local theme = self.Themes[self.Current]
    return theme and theme[colorName] or Color3.new(1, 1, 1)
end

function Theme:IsRobloxEnvironment()
    return type(game) == "userdata" and type(game.GetService) == "function"
end

function Theme:CreateColorPicker(color, callback)
    if not self:IsRobloxEnvironment() then
        print("Warning: Color picker not available outside Roblox environment")
        return nil
    end

    local picker = Instance.new("Frame")
    picker.Size = UDim2.new(0, 30, 0, 30)
    picker.BackgroundColor3 = color
    picker.BorderSizePixel = 1
    picker.BorderColor3 = self:GetColor("border")

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 4)
    corner.Parent = picker

    picker.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or
           input.UserInputType == Enum.UserInputType.Touch then
            local colors = {
                Color3.fromRGB(255, 0, 0),
                Color3.fromRGB(0, 255, 0),
                Color3.fromRGB(0, 0, 255)
            }

            local currentIndex = 1
            for i, c in ipairs(colors) do
                if c == picker.BackgroundColor3 then
                    currentIndex = i
                    break
                end
            end

            currentIndex = currentIndex % #colors + 1
            picker.BackgroundColor3 = colors[currentIndex]

            if callback then
                callback(colors[currentIndex])
            end
        end
    end)

    return picker
end

-- Print warning if not in Roblox environment
if not Theme:IsRobloxEnvironment() then
    print("Warning: Theme module loaded outside Roblox environment. Some features will be limited.")
end

return Theme