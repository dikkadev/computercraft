local dbg = {}

dbg.enabled = false

function dbg.setEnabled(enabled)
    dbg.enabled = enabled
end

function dbg.print(...)
    if dbg.enabled then
        local args = {...}
        local output = "[DBG] "
        for i, arg in ipairs(args) do
            if i > 1 then
                output = output .. " "
            end
            output = output .. tostring(arg)
        end
        print(output)
    end
end

function dbg.printf(format, ...)
    if dbg.enabled then
        print("[DBG] " .. string.format(format, ...))
    end
end

function dbg.inspect(name, value)
    if dbg.enabled then
        if type(value) == "table" then
            print("[DBG] " .. name .. ":")
            for k, v in pairs(value) do
                print("[DBG]   " .. tostring(k) .. " = " .. tostring(v))
            end
        else
            print("[DBG] " .. name .. " = " .. tostring(value))
        end
    end
end

function dbg.pos(mv)
    if dbg.enabled and mv then
        print("[DBG] Position: " .. mv.X .. "," .. mv.Y .. "," .. mv.Z .. " facing:" .. mv.heading)
    end
end

function dbg.fuel()
    if dbg.enabled then
        local fuel = turtle.getFuelLevel()
        print("[DBG] Fuel: " .. tostring(fuel))
    end
end

function dbg.inventory()
    if dbg.enabled then
        print("[DBG] Inventory:")
        for i = 1, 16 do
            local count = turtle.getItemCount(i)
            if count > 0 then
                local detail = turtle.getItemDetail(i)
                local name = detail and detail.name or "unknown"
                print("[DBG]   Slot " .. i .. ": " .. count .. "x " .. name)
            end
        end
    end
end

return dbg