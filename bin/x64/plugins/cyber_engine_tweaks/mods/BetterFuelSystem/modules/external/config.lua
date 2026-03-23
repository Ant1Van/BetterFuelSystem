local config = {}

function config.fileExists(filename)
    local f = io.open(filename, "r")
    if f ~= nil then io.close(f) return true else return false end
end

function config.tryCreateConfig(path, data)
    if not config.fileExists(path) then
        local file, err = io.open(path, "w")
        if not file then
            return
        end
        
        local jconfig = json.encode(data)
        file:write(jconfig)
        file:close()
    end
end

function config.loadFile(path)
    local file, err = io.open(path, "r")
    if not file then
        return {} -- Возвращаем пустую таблицу, чтобы мод не крашился дальше
    end
    
    local content = file:read("*a")
    file:close()
    
    -- Защита от пустого файла или битого JSON
    if not content or content == "" then
        return {}
    end
    
    local success, result = pcall(function() return json.decode(content) end)
    if success then
        return result
    else
        return {}
    end
end

function config.saveFile(path, data)
    local file, err = io.open(path, "w")
    
    -- ГЛАВНАЯ ЗАЩИТА ОТ ТВОЕЙ ОШИБКИ
    if not file then
        --print("[BetterFuelSystem][config.saveFile] FAILED to open file for write: " .. tostring(path) .. " | error: " .. tostring(err))
        return -- Просто выходим, не пытаясь писать в nil
    end

    local jconfig = json.encode(data)
    file:write(jconfig)
    file:close()

    -- Отладочное сообщение, чтобы было видно, что сохранение прошло успешно
    --print("[BetterFuelSystem][config.saveFile] Saved file: " .. tostring(path))
end

function config.backwardComp(path, data)
    local existing = config.loadFile(path)
    -- Если файл не загрузился, existing будет пустой таблицей, цикл не упадет
    if existing then
        for k, v in pairs(data) do
            if existing[k] == nil then
                existing[k] = v
            end
        end
        config.saveFile(path, existing)
    end
end

return config