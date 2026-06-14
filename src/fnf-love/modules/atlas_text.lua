-- modules/atlas_text.lua
local alphabet = require("sprites.alphabet")

local AtlasText = {}
AtlasText.__index = AtlasText

-- Mapeo de caracteres para el estilo normal (usa "capital" y "lowercase")
local charToAnim = {
    ['#'] = 'hashtag',
    ['$'] = 'dollarsign',
    ['%'] = '%',
    ['&'] = 'amp',
    ['('] = '(',
    [')'] = ')',
    ['*'] = '*',
    ['+'] = '+',
    ['-'] = '-',
    ['0'] = '0',
    ['1'] = '1',
    ['2'] = '2',
    ['3'] = '3',
    ['4'] = '4',
    ['5'] = '5',
    ['6'] = '6',
    ['7'] = '7',
    ['8'] = '8',
    ['9'] = '9',
    [':'] = ':',
    [';'] = ';',
    ['<'] = '<',
    ['='] = '=',
    ['>'] = '>',
    ['@'] = '@',
    ['A'] = 'A capital',
    ['B'] = 'B capital',
    ['C'] = 'C capital',
    ['D'] = 'D capital',
    ['E'] = 'E capital',
    ['F'] = 'F capital',
    ['G'] = 'G capital',
    ['H'] = 'H capital',
    ['I'] = 'I capital',
    ['J'] = 'J capital',
    ['K'] = 'K capital',
    ['L'] = 'L capital',
    ['M'] = 'M capital',
    ['N'] = 'N capital',
    ['O'] = 'O capital',
    ['P'] = 'P capital',
    ['Q'] = 'Q capital',
    ['R'] = 'R capital',
    ['S'] = 'S capital',
    ['T'] = 'T capital',
    ['U'] = 'U capital',
    ['V'] = 'V capital',
    ['W'] = 'W capital',
    ['X'] = 'X capital',
    ['Y'] = 'Y capital',
    ['Z'] = 'Z capital',
    ['a'] = 'a lowercase',
    ['b'] = 'b lowercase',
    ['c'] = 'c lowercase',
    ['d'] = 'd lowercase',
    ['e'] = 'e lowercase',
    ['f'] = 'f lowercase',
    ['g'] = 'g lowercase',
    ['h'] = 'h lowercase',
    ['i'] = 'i lowercase',
    ['j'] = 'j lowercase',
    ['k'] = 'k lowercase',
    ['l'] = 'l lowercase',
    ['m'] = 'm lowercase',
    ['n'] = 'n lowercase',
    ['o'] = 'o lowercase',
    ['p'] = 'p lowercase',
    ['q'] = 'q lowercase',
    ['r'] = 'r lowercase',
    ['s'] = 's lowercase',
    ['t'] = 't lowercase',
    ['u'] = 'u lowercase',
    ['v'] = 'v lowercase',
    ['w'] = 'w lowercase',
    ['x'] = 'x lowercase',
    ['y'] = 'y lowercase',
    ['z'] = 'z lowercase',
    ['!'] = 'exclamation point',
    ['?'] = 'question mark',
    ['.'] = 'period',
    [','] = 'comma',
    ["'"] = 'apostraphie',
    ['"'] = 'start quote',
    ['-'] = 'dash',
    ['_'] = '_',
    ['~'] = '~',
    ['^'] = '^',
    ['\\'] = '\\',
    ['/'] = 'forward slash',
    ['|'] = '|',
    ['['] = '[',
    [']'] = ']',
    ['{'] = '{',   -- Puede no existir
    ['}'] = '}',
    ['♥'] = 'heart',
    ['♡'] = 'heart',
    ['←'] = 'left arrow',
    ['→'] = 'right arrow',
    ['↑'] = 'up arrow',
    ['↓'] = 'down arrow',
    ['😠'] = 'angry faic',
}

local SPACE_WIDTH = 40

-- Constructor: ahora acepta un tercer parámetro opcional 'style' ("normal" o "bold")
function AtlasText.new(x, y, text, style)
    local self = setmetatable({}, AtlasText)
    self.x = x or 0
    self.y = y or 0
    self.scaleX = 1
    self.scaleY = 1
    self.style = style or "normal"  -- por defecto "normal"
    self.letters = {}
    self:setText(text or "")
    return self
end

function AtlasText:setText(newText)
    self.text = newText or ""
    self.letters = {}

    -- Si el estilo es bold, convertimos todo el texto a mayúsculas
    local textToRender = self.text  
    if self.style == "bold" then
        textToRender = string.upper(textToRender)
    end

    local xPos = 0
    local yPos = 0
    local maxHeight = 0
    local defaultAnim = "hashtag"

    for i = 1, #textToRender do
        local char = textToRender:sub(i, i)
        if char == " " then
            xPos = xPos + SPACE_WIDTH * self.scaleX
        elseif char == "\n" then
            xPos = 0
            yPos = yPos + maxHeight
            maxHeight = 0
        else
            local animName
            if self.style == "bold" and char:match("%a") then
                -- Para letras en bold, usamos el nombre de la animación "X bold"
                animName = char .. " bold"
            else
                -- Para el resto (incluyendo números y signos), usamos el mapeo normal
                animName = charToAnim[char]
            end
            if not animName then
                animName = "question mark"  -- fallback
            end

            local letter = alphabet.new()
            if not letter then
                goto continue
            end

            -- Intentar animar con el nombre correspondiente
            local success = pcall(function()
                letter:animate(animName, true)
            end)
            if not success then
                -- Si falla, usar la animación por defecto
                pcall(function() letter:animate(defaultAnim, true) end)
            end

            -- Aplicar escala
            letter.sizeX = self.scaleX
            letter.sizeY = self.scaleY

            -- Posicionar
            letter.x = self.x + xPos
            letter.y = self.y + yPos

            table.insert(self.letters, letter)

            -- Calcular ancho aproximado usando el primer frame de la animación actual
            local width = 40
            local currentAnim = letter:getAnimName() or defaultAnim
            if alphabet.anims and alphabet.anims[currentAnim] then
                local frameIndex = alphabet.anims[currentAnim].start
                if alphabet.frames and alphabet.frames[frameIndex] then
                    width = alphabet.frames[frameIndex].width
                end
            end
            letter.width = width  -- guardamos el ancho en la propia letra
            xPos = xPos + width * self.scaleX
            if width > maxHeight then maxHeight = width end

            ::continue::
        end
    end
end

-- El resto de funciones permanecen igual
function AtlasText:setPosition(x, y)
    local dx = x - self.x
    local dy = y - self.y
    self.x = x
    self.y = y
    for _, letter in ipairs(self.letters) do
        letter.x = letter.x + dx
        letter.y = letter.y + dy
    end
end

function AtlasText:setScale(sx, sy)
    self.scaleX = sx or 1
    self.scaleY = sy or sx or 1
    -- Reconstruimos el texto para recalcular posiciones
    local oldText = self.text
    self:setText(oldText)
end

function AtlasText:draw()
    for _, letter in ipairs(self.letters) do
        letter:draw()
    end
end

function AtlasText:update(dt)
    for _, letter in ipairs(self.letters) do
        letter:update(dt)
    end
end

function AtlasText:getWidth()
    if #self.letters == 0 then return 0 end
    local last = self.letters[#self.letters]
    local currentAnim = last:getAnimName()
    local width = 40
    if alphabet.anims and alphabet.anims[currentAnim] then
        local frameIndex = alphabet.anims[currentAnim].start
        if alphabet.frames and alphabet.frames[frameIndex] then
            width = alphabet.frames[frameIndex].width
        end
    end
    return last.x - self.x + width * self.scaleX
end

return AtlasText