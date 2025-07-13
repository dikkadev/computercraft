while true do
    success, block = turtle.inspect()

    if success then
        if block.name == "ae2:quartz_cluster" then
            print('Fully grown, mining...')
            turtle.dig()
        else
            print('Not fully grown, waiting...')
        end
    end

    os.sleep(5)
end

