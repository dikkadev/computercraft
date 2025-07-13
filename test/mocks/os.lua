local mock_os = {}

mock_os.sleep_calls = {}
mock_os.time_value = 0

function mock_os.sleep(duration)
    table.insert(mock_os.sleep_calls, duration)
end

function mock_os.time()
    return mock_os.time_value
end

function mock_os.clock()
    return mock_os.time_value
end

function mock_os.reset()
    mock_os.sleep_calls = {}
    mock_os.time_value = 0
end

function mock_os.advance_time(amount)
    mock_os.time_value = mock_os.time_value + amount
end

function mock_os.get_total_sleep_time()
    local total = 0
    for _, duration in ipairs(mock_os.sleep_calls) do
        total = total + duration
    end
    return total
end

return mock_os