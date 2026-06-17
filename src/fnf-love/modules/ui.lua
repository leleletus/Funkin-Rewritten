-- modules/ui.lua  –  Psych Engine-style floating box GUI
local M = {}

-- ============================================================
-- Color palette (Psych Engine DEFAULT theme)
-- ============================================================
local function hex(r, g, b, a)
    return {r/255, g/255, b/255, a or 1}
end
local C = {
    BOX_BG      = hex(0x1E, 0x1E, 0x1E, 0.97),
    BOX_BORDER  = hex(0x55, 0x55, 0x55),
    TITLE_BG    = hex(0x38, 0x38, 0x38),
    TAB_SEL     = hex(0x40, 0x40, 0x40),
    TAB_INACT   = hex(0x28, 0x28, 0x28),
    TAB_TEXT    = {1, 1, 1, 1},
    TAB_INACT_T = hex(0x80, 0x80, 0x80),
    INPUT_BG    = hex(0x1A, 0x1A, 0x1A),
    INPUT_BD    = hex(0x44, 0x44, 0x44),
    INPUT_FOC   = hex(0x00, 0xAF, 0xFF),
    BTN_NORM    = hex(0x55, 0x55, 0x55),
    BTN_HOVER   = hex(0x70, 0x70, 0x70),
    BTN_RED     = hex(0x8B, 0x00, 0x00),
    BTN_RED_H   = hex(0xC0, 0x10, 0x10),
    BTN_GREEN   = hex(0x00, 0x55, 0x00),
    BTN_GREEN_H = hex(0x00, 0x80, 0x00),
    DD_BG       = hex(0xF0, 0xF0, 0xF0),
    DD_HOVER    = hex(0x00, 0x66, 0xFF),
    SL_TRACK    = hex(0x30, 0x30, 0x30),
    SL_FILL     = hex(0x50, 0x50, 0x50),
    SL_THUMB    = hex(0xCC, 0xCC, 0xCC),
    LABEL       = hex(0xAA, 0xAA, 0xAA),
    WHITE       = {1, 1, 1, 1},
    BLACK       = {0, 0, 0, 1},
}

-- ============================================================
-- Module state
-- ============================================================
M._boxes        = {}
M._focused      = nil
M._openDropdown = nil
M._dragging     = nil
M._sliderDrag   = nil
M._mx, M._my   = 0, 0

local FONT_SM, FONT_MD, FONT_PREV

local TITLE_H  = 24
local TAB_H    = 22
local PAD      = 8
local ROW_H    = 22
local ROW_GAP  = 4
local LABEL_H  = 13

-- ============================================================
-- Helpers
-- ============================================================
local function col(c) love.graphics.setColor(c[1], c[2], c[3], c[4] or 1) end
local function rect(mode, x, y, w, h) love.graphics.rectangle(mode, x, y, w, h) end

local function hitRect(mx, my, x, y, w, h)
    return mx >= x and mx < x+w and my >= y and my < y+h
end

local function clamp(v, lo, hi) return math.max(lo, math.min(hi, v)) end

local function roundDec(v, d)
    local p = 10 ^ (d or 0)
    return math.floor(v * p + 0.5) / p
end

local function getStr(w)
    local g = w.getter and w.getter()
    if g == nil then return "" end
    if w.decimals and w.decimals > 0 then
        return string.format("%." .. w.decimals .. "f", g)
    end
    return tostring(g)
end

-- ============================================================
-- Button shape
-- ============================================================
local function drawBtnShape(x, y, w, h, hov, style)
    local bg
    if style == "red"   then bg = hov and C.BTN_RED_H   or C.BTN_RED
    elseif style == "green" then bg = hov and C.BTN_GREEN_H or C.BTN_GREEN
    else                     bg = hov and C.BTN_HOVER    or C.BTN_NORM
    end
    col(bg);         rect("fill", x, y, w, h)
    col(C.BOX_BORDER); rect("line", x, y, w, h)
end

local function drawBtnText(x, y, w, h, text)
    love.graphics.setFont(FONT_MD)
    col(C.WHITE)
    local tw = FONT_MD:getWidth(text)
    local th = FONT_MD:getHeight()
    love.graphics.print(text,
        x + math.floor((w - tw) / 2),
        y + math.floor((h - th) / 2))
end

-- ============================================================
-- Per-widget draw  (updates _lastSX/_lastSY/_lastW for hit-test)
-- ============================================================
local function drawWidget(w, wx, wy, ww, mx, my)
    local t = w.type

    if t == "sep" then
        col(C.BOX_BORDER)
        love.graphics.line(wx, wy + 3, wx + ww, wy + 3)

    elseif t == "label" then
        local text = type(w.text) == "function" and w.text() or (w.text or "")
        love.graphics.setFont(FONT_SM)
        col(w.color or C.LABEL)
        love.graphics.print(text, wx, wy + 1)

    elseif t == "button" then
        local hov = hitRect(mx, my, wx, wy, ww, w.height)
        drawBtnShape(wx, wy, ww, w.height, hov, w.style)
        drawBtnText(wx, wy, ww, w.height, w.text or "")

    elseif t == "checkbox" then
        local bx, by = wx, wy + math.floor((w.height - 14) / 2)
        local checked = w.getter and w.getter() or false
        col(C.INPUT_BG);  rect("fill", bx, by, 14, 14)
        col(C.INPUT_BD);  rect("line", bx, by, 14, 14)
        if checked then
            col(C.WHITE)
            love.graphics.setLineWidth(2)
            love.graphics.line(bx+2, by+8, bx+5, by+12, bx+12, by+3)
            love.graphics.setLineWidth(1)
        end
        love.graphics.setFont(FONT_MD)
        col(C.WHITE)
        love.graphics.print(w.label or "", bx+18,
            wy + math.floor((w.height - FONT_MD:getHeight()) / 2))

    elseif t == "input" then
        love.graphics.setFont(FONT_SM); col(C.LABEL)
        love.graphics.print(w.label or "", wx, wy + 1)
        local fy  = wy + LABEL_H
        local foc = M._focused == w
        col(C.INPUT_BG); rect("fill", wx, fy, ww, ROW_H)
        col(foc and C.INPUT_FOC or C.INPUT_BD); rect("line", wx, fy, ww, ROW_H)
        love.graphics.setFont(FONT_MD); col(C.WHITE)
        local disp = foc and ((w._buf or "") .. "|")
                         or tostring(w.getter and w.getter() or "")
        love.graphics.print(disp, wx+3, fy + math.floor((ROW_H - FONT_MD:getHeight()) / 2))

    elseif t == "stepper" then
        love.graphics.setFont(FONT_SM); col(C.LABEL)
        love.graphics.print(w.label or "", wx, wy + 1)
        local cy   = wy + LABEL_H
        local btnW = 24
        local valW = ww - 2 * btnW
        -- < button
        local hL = hitRect(mx, my, wx, cy, btnW, ROW_H)
        drawBtnShape(wx, cy, btnW, ROW_H, hL, nil)
        drawBtnText(wx, cy, btnW, ROW_H, "<")
        -- value field
        col(C.INPUT_BG); rect("fill", wx+btnW, cy, valW, ROW_H)
        col(C.INPUT_BD); rect("line", wx+btnW, cy, valW, ROW_H)
        love.graphics.setFont(FONT_MD); col(C.WHITE)
        local vs = getStr(w)
        love.graphics.print(vs,
            wx+btnW + math.floor((valW - FONT_MD:getWidth(vs)) / 2),
            cy + math.floor((ROW_H - FONT_MD:getHeight()) / 2))
        -- > button
        local hR = hitRect(mx, my, wx+btnW+valW, cy, btnW, ROW_H)
        drawBtnShape(wx+btnW+valW, cy, btnW, ROW_H, hR, nil)
        drawBtnText(wx+btnW+valW, cy, btnW, ROW_H, ">")

    elseif t == "dropdown" then
        love.graphics.setFont(FONT_SM); col(C.LABEL)
        love.graphics.print(w.label or "", wx, wy + 1)
        local fy   = wy + LABEL_H
        local open = M._openDropdown == w
        col(C.INPUT_BG); rect("fill", wx, fy, ww, ROW_H)
        col(open and C.INPUT_FOC or C.INPUT_BD); rect("line", wx, fy, ww, ROW_H)
        -- current display text
        local curVal = w.getter and w.getter()
        local disp = ""
        for _, item in ipairs(w.items or {}) do
            if item[2] == curVal then disp = item[1]; break end
        end
        if disp == "" and curVal ~= nil then disp = tostring(curVal) end
        love.graphics.setFont(FONT_MD); col(C.WHITE)
        love.graphics.print(disp, wx+3,
            fy + math.floor((ROW_H - FONT_MD:getHeight()) / 2))
        local arrow = open and "\226\150\178" or "\226\150\188"  -- ▲ / ▼
        love.graphics.print(arrow,
            wx + ww - FONT_MD:getWidth(arrow) - 4,
            fy + math.floor((ROW_H - FONT_MD:getHeight()) / 2))
        -- stash list geometry (needed by drawOpenDropdown + mousepressed)
        if open then
            local items  = w.items or {}
            local ih     = 20
            local listH  = #items * ih
            local listY  = fy + ROW_H
            if listY + listH > 720 then listY = fy - listH end
            w._listX, w._listY, w._listW, w._listH = wx, listY, ww, listH
            w._itemH = ih
        end

    elseif t == "slider" then
        love.graphics.setFont(FONT_SM); col(C.LABEL)
        local v   = w.getter and w.getter() or w.min or 0
        local dec = w.decimals or 2
        love.graphics.print(string.format("%s  %." .. dec .. "f", w.label or "", v), wx, wy + 1)
        local ty    = wy + LABEL_H
        local trackH = 10
        local ty2   = ty + math.floor((ROW_H - trackH) / 2)
        col(C.SL_TRACK); rect("fill", wx, ty2, ww, trackH)
        local t2 = clamp((v - (w.min or 0)) / math.max(0.0001, (w.max or 1) - (w.min or 0)), 0, 1)
        local fw = math.floor(t2 * ww)
        col(C.SL_FILL); rect("fill", wx, ty2, fw, trackH)
        col(C.SL_THUMB); rect("fill", wx + fw - 4, ty - 3, 8, ROW_H - 4)
        col(C.BOX_BORDER); rect("line", wx, ty2, ww, trackH)
    end

    w._lastSX, w._lastSY, w._lastW = wx, wy, ww
    return w.height
end

-- ============================================================
-- Open dropdown list (drawn z-top after all boxes)
-- ============================================================
local function drawOpenDropdown()
    local dd = M._openDropdown
    if not dd or not dd._listX then return end
    local lx, ly, lw = dd._listX, dd._listY, dd._listW
    local items = dd.items or {}
    local ih    = dd._itemH or 20
    local mx, my = M._mx, M._my

    for i, item in ipairs(items) do
        local iy  = ly + (i - 1) * ih
        local hov = hitRect(mx, my, lx, iy, lw, ih)
        if hov then col(C.DD_HOVER) else col(C.DD_BG) end
        rect("fill", lx, iy, lw, ih)
        love.graphics.setFont(FONT_MD)
        col(hov and C.WHITE or C.BLACK)
        love.graphics.print(item[1], lx+4,
            iy + math.floor((ih - FONT_MD:getHeight()) / 2))
        col(C.BOX_BORDER)
        love.graphics.line(lx, iy+ih, lx+lw, iy+ih)
    end
    col(C.BOX_BORDER); rect("line", lx, ly, lw, #items * ih)
end

-- ============================================================
-- Box content start Y
-- ============================================================
local function contentStartY(box)
    local y = box.y + TITLE_H
    if not box.minimized and box.tabs and #box.tabs > 0 then
        y = y + TAB_H
    end
    return y
end

-- ============================================================
-- Draw a full box
-- ============================================================
local function drawBox(box)
    local mx, my = M._mx, M._my
    local bx, by, bw, bh = box.x, box.y, box.w, box.h
    local dispH = box.minimized and TITLE_H or bh

    -- shadow
    col({0, 0, 0, 0.35})
    rect("fill", bx+3, by+3, bw, dispH)
    -- body
    col(C.BOX_BG)
    rect("fill", bx, by, bw, dispH)
    -- title bar
    col(C.TITLE_BG)
    rect("fill", bx, by, bw, TITLE_H)
    love.graphics.setFont(FONT_MD); col(C.WHITE)
    love.graphics.print(box.title or "", bx+PAD,
        by + math.floor((TITLE_H - FONT_MD:getHeight()) / 2))
    -- minimize button
    local mbx, mby = bx + bw - 20, by + 3
    local mbHov = hitRect(mx, my, mbx, mby, 18, 18)
    col(mbHov and C.BTN_HOVER or C.TITLE_BG)
    rect("fill", mbx, mby, 18, 18)
    col(C.WHITE)
    love.graphics.print(box.minimized and "+" or "-", mbx+4, mby+3)
    -- outer border
    col(C.BOX_BORDER); rect("line", bx, by, bw, dispH)

    if box.minimized then return end

    -- tab row
    if box.tabs and #box.tabs > 0 then
        local ty   = by + TITLE_H
        local tabW = math.floor(bw / #box.tabs)
        for i, name in ipairs(box.tabs) do
            local tx = bx + (i-1) * tabW
            local tw = (i == #box.tabs) and (bw - (i-1)*tabW) or tabW
            local act = box._activeTab == i
            col(act and C.TAB_SEL or C.TAB_INACT); rect("fill", tx, ty, tw, TAB_H)
            col(C.BOX_BORDER);                      rect("line", tx, ty, tw, TAB_H)
            love.graphics.setFont(FONT_MD)
            col(act and C.TAB_TEXT or C.TAB_INACT_T)
            local nw = FONT_MD:getWidth(name)
            love.graphics.print(name,
                tx + math.floor((tw - nw) / 2),
                ty + math.floor((TAB_H - FONT_MD:getHeight()) / 2))
        end
    end

    -- content
    local csy = contentStartY(box)
    local cww  = bw - 2 * PAD

    if box.infoLines then
        local lines = box.infoLines()
        love.graphics.setFont(FONT_SM); col(C.LABEL)
        local lh = FONT_SM:getHeight() + 2
        for i, line in ipairs(lines) do
            love.graphics.print(line, bx+PAD, csy + PAD + (i-1) * lh)
        end
    else
        local ws = box.contents and box.contents[box._activeTab] or {}
        local wy = csy + PAD - (box._scroll or 0)
        local totalH = 0
        for _, w in ipairs(ws) do
            if wy + w.height >= csy and wy < by + bh then
                drawWidget(w, bx+PAD, wy, cww, mx, my)
            else
                w._lastSX, w._lastSY, w._lastW = bx+PAD, wy, cww
            end
            wy = wy + w.height + ROW_GAP
            totalH = totalH + w.height + ROW_GAP
        end
        box._totalContentH = totalH
    end
end

-- ============================================================
-- Widget press (returns true if consumed)
-- ============================================================
local function pressWidget(w, mx, my, btn)
    if not w._lastSX then return false end
    local wx, wy, ww = w._lastSX, w._lastSY, w._lastW
    local t = w.type

    if t == "button" then
        if btn == 1 and hitRect(mx, my, wx, wy, ww, w.height) then
            if w.action then w.action() end; return true
        end

    elseif t == "checkbox" then
        if btn == 1 and hitRect(mx, my, wx, wy, ww, w.height) then
            if w.setter then w.setter(not (w.getter and w.getter() or false)) end
            return true
        end

    elseif t == "input" then
        local fy = wy + LABEL_H
        if btn == 1 and hitRect(mx, my, wx, fy, ww, ROW_H) then
            if M._focused and M._focused ~= w then
                local prev = M._focused
                if prev.setter and prev._buf ~= nil then prev.setter(prev._buf) end
                prev._buf = nil
            end
            M._focused = w
            w._buf = tostring(w.getter and w.getter() or "")
            return true
        end

    elseif t == "stepper" then
        local cy   = wy + LABEL_H
        local btnW = 24
        local valW = ww - 2 * btnW
        local v    = w.getter and w.getter() or 0
        if btn == 1 and hitRect(mx, my, wx, cy, btnW, ROW_H) then
            v = roundDec(v - (w.step or 1), w.decimals or 0)
            v = clamp(v, w.min or -math.huge, w.max or math.huge)
            if w.setter then w.setter(v) end; return true
        end
        if btn == 1 and hitRect(mx, my, wx+btnW+valW, cy, btnW, ROW_H) then
            v = roundDec(v + (w.step or 1), w.decimals or 0)
            v = clamp(v, w.min or -math.huge, w.max or math.huge)
            if w.setter then w.setter(v) end; return true
        end

    elseif t == "dropdown" then
        local fy = wy + LABEL_H
        if btn == 1 and hitRect(mx, my, wx, fy, ww, ROW_H) then
            if M._openDropdown == w then
                M._openDropdown = nil
            else
                -- close any other open dropdown
                M._openDropdown = w
                -- list geometry set on next draw; pre-set for immediate click
                w._listX, w._listY, w._listW = wx, fy + ROW_H, ww
                w._itemH = 20
                local listH = #(w.items or {}) * 20
                if fy + ROW_H + listH > 720 then w._listY = fy - listH end
                w._listH = listH
            end
            return true
        end

    elseif t == "slider" then
        local ty = wy + LABEL_H
        if btn == 1 and hitRect(mx, my, wx, ty, ww, ROW_H) then
            M._sliderDrag = w
            local tt = clamp((mx - wx) / math.max(1, ww), 0, 1)
            local v  = roundDec(
                (w.min or 0) + tt * ((w.max or 1) - (w.min or 0)),
                w.decimals or 2)
            if w.setter then w.setter(v) end
            return true
        end
    end

    return false
end

-- ============================================================
-- Box press (returns true if consumed)
-- ============================================================
local function pressBox(box, mx, my, btn)
    local bx, by, bw, bh = box.x, box.y, box.w, box.h
    local dispH = box.minimized and TITLE_H or bh
    if not hitRect(mx, my, bx, by, bw, dispH) then return false end

    -- minimize button
    local mbx = bx + bw - 20
    if btn == 1 and hitRect(mx, my, mbx, by+3, 18, 18) then
        box.minimized = not box.minimized
        return true
    end
    -- title drag
    if btn == 1 and hitRect(mx, my, bx, by, bw, TITLE_H) then
        if box.draggable ~= false then
            M._dragging = {box = box, offX = mx - bx, offY = my - by}
        end
        return true
    end
    if box.minimized then return true end

    -- tab row
    if box.tabs and #box.tabs > 0 then
        local ty = by + TITLE_H
        if hitRect(mx, my, bx, ty, bw, TAB_H) then
            if btn == 1 then
                local tw = math.floor(bw / #box.tabs)
                local idx = clamp(math.floor((mx - bx) / math.max(1, tw)) + 1, 1, #box.tabs)
                box._activeTab = idx
            end
            return true
        end
    end

    -- widgets
    if not box.infoLines then
        local ws = box.contents and box.contents[box._activeTab] or {}
        for _, w in ipairs(ws) do
            if pressWidget(w, mx, my, btn) then return true end
        end
    end

    return true  -- consume click inside box even if no widget hit
end

-- ============================================================
-- Public API
-- ============================================================

function M.init()
    if FONT_SM then return end
    FONT_SM = love.graphics.newFont("fonts/vcr.ttf", 9)
    FONT_MD = love.graphics.newFont("fonts/vcr.ttf", 11)
end

function M.reset()
    M._boxes        = {}
    M._focused      = nil
    M._openDropdown = nil
    M._dragging     = nil
    M._sliderDrag   = nil
end

function M.registerBox(box)
    table.insert(M._boxes, box)
end

function M.draw()
    FONT_PREV = love.graphics.getFont()
    for _, box in ipairs(M._boxes) do
        drawBox(box)
    end
    drawOpenDropdown()
    love.graphics.setColor(1, 1, 1, 1)
    if FONT_PREV then love.graphics.setFont(FONT_PREV) end
end

function M.mousepressed(mx, my, btn)
    M._mx, M._my = mx, my

    -- open dropdown takes priority
    if M._openDropdown then
        local dd = M._openDropdown
        local lx  = dd._listX or 0
        local ly  = dd._listY or 0
        local lw  = dd._listW or 0
        local ih  = dd._itemH or 20
        local lh  = #(dd.items or {}) * ih
        if hitRect(mx, my, lx, ly, lw, lh) then
            local idx = math.floor((my - ly) / ih) + 1
            if idx >= 1 and idx <= #(dd.items or {}) then
                if dd.setter then dd.setter(dd.items[idx][2]) end
            end
            M._openDropdown = nil
            return true
        end
        M._openDropdown = nil
        -- fall through to boxes (don't consume)
    end

    -- unfocus input if clicking outside all boxes
    if M._focused then
        local inAnyBox = false
        for _, box in ipairs(M._boxes) do
            if hitRect(mx, my, box.x, box.y, box.w, box.h) then
                inAnyBox = true; break
            end
        end
        if not inAnyBox then
            local w = M._focused
            if w.setter and w._buf ~= nil then w.setter(w._buf) end
            w._buf = nil; M._focused = nil
        end
    end

    -- boxes in reverse draw order (last = visually on top)
    for i = #M._boxes, 1, -1 do
        if pressBox(M._boxes[i], mx, my, btn) then return true end
    end

    return false
end

function M.mousereleased(mx, my, btn)
    M._mx, M._my = mx, my
    if M._dragging then M._dragging = nil; return true end
    if M._sliderDrag then M._sliderDrag = nil; return true end
    return false
end

function M.mousemoved(mx, my)
    M._mx, M._my = mx, my
    if M._dragging then
        local d = M._dragging
        d.box.x = mx - d.offX
        d.box.y = my - d.offY
        return true
    end
    if M._sliderDrag then
        local w = M._sliderDrag
        if w._lastSX and w._lastW then
            local tt = clamp((mx - w._lastSX) / math.max(1, w._lastW), 0, 1)
            local v  = roundDec(
                (w.min or 0) + tt * ((w.max or 1) - (w.min or 0)),
                w.decimals or 2)
            if w.setter then w.setter(v) end
        end
        return true
    end
    return false
end

function M.keypressed(key)
    local w = M._focused
    if not w or w.type ~= "input" then return false end
    if key == "return" then
        if w.setter then w.setter(w._buf or "") end
        w._buf = nil; M._focused = nil; return true
    elseif key == "escape" then
        w._buf = nil; M._focused = nil; return true
    elseif key == "backspace" then
        w._buf = (w._buf or ""):sub(1, -2); return true
    end
    return false
end

function M.textinput(text)
    local w = M._focused
    if not w or w.type ~= "input" then return end
    if w.opts and w.opts.numbersOnly then
        if not text:match("^[0-9%.%-%+]$") then return end
    end
    w._buf = (w._buf or "") .. text
end

function M.wheelmoved(dx, dy)
    local mx, my = M._mx, M._my
    for i = #M._boxes, 1, -1 do
        local box = M._boxes[i]
        local dispH = box.minimized and TITLE_H or box.h
        if hitRect(mx, my, box.x, box.y, box.w, dispH) and not box.minimized then
            local csy    = contentStartY(box)
            local avail  = box.h - (csy - box.y)
            local maxScr = math.max(0, (box._totalContentH or 0) - avail)
            box._scroll  = clamp((box._scroll or 0) - dy * 20, 0, maxScr)
            return true
        end
    end
    return false
end

-- ============================================================
-- Widget constructors
-- ============================================================

function M.Sep()
    return {type = "sep", height = 8}
end

function M.Label(text, opts)
    opts = opts or {}
    local lh = opts.height or 16
    return {type = "label", text = text, height = lh, color = opts.color}
end

function M.Button(text, action, opts)
    opts = opts or {}
    return {type = "button", text = text, action = action,
            style = opts.style, height = opts.height or ROW_H}
end

function M.Checkbox(label, getter, setter)
    return {type = "checkbox", label = label,
            getter = getter, setter = setter, height = 20}
end

function M.Input(label, getter, setter, opts)
    opts = opts or {}
    return {type = "input", label = label,
            getter = getter, setter = setter, opts = opts,
            height = LABEL_H + ROW_H}
end

function M.Stepper(label, getter, setter, min, max, step, decimals)
    return {type = "stepper", label = label,
            getter = getter, setter = setter,
            min = min or -math.huge, max = max or math.huge,
            step = step or 1, decimals = decimals or 0,
            height = LABEL_H + ROW_H}
end

function M.Dropdown(label, getter, setter, items)
    return {type = "dropdown", label = label,
            getter = getter, setter = setter,
            items = items or {}, height = LABEL_H + ROW_H}
end

function M.Slider(label, getter, setter, min, max, decimals)
    return {type = "slider", label = label,
            getter = getter, setter = setter,
            min = min or 0, max = max or 1,
            decimals = decimals or 2,
            height = LABEL_H + ROW_H}
end

-- ============================================================
-- Box constructor
-- ============================================================

function M.Box(x, y, w, h, opts)
    opts = opts or {}
    return {
        x = x, y = y, w = w, h = h,
        title      = opts.title    or "",
        tabs       = opts.tabs,
        contents   = opts.contents or {},
        infoLines  = opts.infoLines,
        minimized  = opts.minimized or false,
        draggable  = opts.draggable ~= false,
        _activeTab = 1,
        _scroll    = 0,
    }
end

return M
