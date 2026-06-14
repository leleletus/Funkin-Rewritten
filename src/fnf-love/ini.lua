-- ini.lua
-- Simple INI file parser and writer

local ini = {}

function ini.load(filename)
    local t = {}
    local currentSection
    for line in love.filesystem.lines(filename) do
        -- Remove comments (;)
        local commentPos = line:find(";")
        if commentPos then
            line = line:sub(1, commentPos-1)
        end
        -- Trim whitespace
        line = line:match("^%s*(.-)%s*$")
        if line ~= "" then
            -- Section?
            local sectionName = line:match("^%[(.+)%]$")
            if sectionName then
                currentSection = sectionName
                t[currentSection] = t[currentSection] or {}
            else
                -- Key=value
                local key, value = line:match("^([^=]+)%s*=%s*(.+)$")
                if key and value and currentSection then
                    key = key:match("^%s*(.-)%s*$")
                    value = value:match("^%s*(.-)%s*$")
                    t[currentSection][key] = value
                end
            end
        end
    end
    return t
end

function ini.save(t, filename)
    local lines = {}
    for section, kv in pairs(t) do
        table.insert(lines, "[" .. section .. "]")
        for k, v in pairs(kv) do
            table.insert(lines, k .. "=" .. v)
        end
        table.insert(lines, "")
    end
    local content = table.concat(lines, "\n")
    return love.filesystem.write(filename, content)
end

function ini.readKey(t, section, key)
    if t[section] and t[section][key] then
        return t[section][key]
    end
    return nil
end

function ini.writeKey(t, section, key, value)
    if not t[section] then
        t[section] = {}
    end
    t[section][key] = value
end

return ini