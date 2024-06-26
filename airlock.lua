--[[
	Airlock v1.0
	by Juicebox829
	
	June 20th, 2024
	Update: Jun 22th, 2024

	States of airlock: (initial) enter airlock -> seal -> rocket room
                       rocket room -> seal -> enter airlock

                       0 -> 1 -> 2
]]--

function main()
	state = 0
    term.clear()
	term.setCursorPos(1,1)

	monSide = 'back'
	speakSide = 'bottom'

    mon = peripheral.wrap(monSide)
    speak = peripheral.wrap(speakSide)

    mon.setBackgroundColor(colors.black)

	-- first check if the term.isColor function exists
	if not mon.isColor then
		print("Please attach an advanced monitor to the ["..monSide.."] side of the computer.")
		exit()
	    --This is a pre ComputerCraft 1.45 computer, there are only normal computers! Text is always white and the background is always black
	elseif not mon.isColor() then
		print("Please attach an advanced monitor to the ["..monSide.."] side of the computer.")
		exit()
	end

    engageSealDisplay()

    print("Airlock is now Active!")
    -- Airlock state machine
    while true do
        
        -- Closing/sealing airlock
        if state == 1 then
            parallel.waitForAll(sealAirlock, sealAirlockDisplay)
            state = 2
            
        -- Opening an airlock door
        elseif state == 2 then
            openAirlockDisplay()
            touchMonitor()
            openAirlock(readTouchInput())
            state = 0

        -- Initial state
        else
            engageSealDisplay()
            touchMonitor()
            state = readTouchInput()
        end
    end

end

--[[
    Closes either door of the airlock, activates oxygen distributor for a
    brief moment, and makes a "pressure" sound
]]--
function sealAirlock()
    
    -- Close airlock doors
    redstone.setOutput("left", false)
    redstone.setOutput("right", false)

    sleep(5)

    -- Activate oxygen distributor
    redstone.setOutput("top", true)

    -- Make "pressure" sound
    for i = 0, 4, 1 do
        speak.playSound("minecraft:block.lava.extinguish", 1, 0.5)
        sleep(1)
    end
    
    -- Disable oxygen distributor
    redstone.setOutput("top", false)
    
    -- Make "completion" sound
    local function completionSound()
        speak.playNote("bit", 1, 10)
        sleep(0.3)
        speak.playNote("bit", 1, 10)
        sleep(0.3)
        speak.playNote("bit", 1, 10)
    end

    parallel.waitForAll(completionSound, sealSuccessDisplay)
end

--[[
	Changes the monitor's display to show that the airlock is being sealed
]]--
function sealAirlockDisplay()
        mon.clear()
        mon.setTextScale(0.5)
        mon.setTextColor(colors.yellow)
        mon.setBackgroundColor(colors.yellow)
        
        -- Yellow Exclamation Mark
        mon.setCursorPos(8, 2) mon.write(" ")
        mon.setCursorPos(8, 3) mon.write(" ")
        mon.setCursorPos(8, 4) mon.write(" ")
        mon.setCursorPos(8, 6) mon.write(" ")
        
        -- Yellow "Sealing..." Text
        mon.setCursorPos(4, 8)
        mon.setBackgroundColor(colors.black)
        mon.write("Sealing...")

        -- White Countdown
        mon.setTextColor(colors.white)
        countDown(10)
end

--[[
    Changes the monitor's display to show a button to seal the
    airlock.
]]--
function engageSealDisplay()
	mon.clear()
	mon.setTextScale(0.5)
	mon.setTextColor(colors.white)
	mon.setBackgroundColor(colors.red)

	-- "ENGAGE SEAL" Button
	mon.setCursorPos(3, 4) mon.write("           ")
	mon.setCursorPos(3, 5) mon.write("  ENGAGE   ")
	mon.setCursorPos(3, 6) mon.write("  SEAL     ")
	mon.setCursorPos(3, 7) mon.write("           ")

    mon.setBackgroundColor(colors.black)
end

--[[
	Changes the monitor's display to show that sealing the airlock has been
    successful
]]--
function sealSuccessDisplay()
	mon.clear()
	mon.setTextScale(0.5)
	mon.setTextColor(colors.green)
	mon.setBackgroundColor(colors.green)

	-- Green Checkmark
	mon.setCursorPos(5, 4) mon.write(" ")
	mon.setCursorPos(6, 5) mon.write(" ")
	mon.setCursorPos(7, 6) mon.write(" ")
	mon.setCursorPos(8, 5) mon.write(" ")
	mon.setCursorPos(9, 4) mon.write(" ")
	mon.setCursorPos(10, 3) mon.write(" ")
	mon.setCursorPos(11, 2) mon.write(" ")

	-- Green "SUCCESS" Text
	mon.setCursorPos(5, 8) 
	mon.setBackgroundColor(colors.black)
	mon.write("SUCCESS")

	-- White Countdown
	mon.setTextColor(colors.white) 
	mon.setCursorPos(8, 10)
	countDown(3)
end


--[[
    Opens one of the doors

    @param door - An integer value of 2 (left), 3 (right), or 4 (both)
]]--
function openAirlock(door)
    -- Left door
    if door == 2 then
        redstone.setOutput("right", true)
    -- Right door
    elseif door == 3 then
        redstone.setOutput("left", true)
    -- Both doors
    elseif door == 4 then
        redstone.setOutput("left", true)
        redstone.setOutput("right", true)
    end
end

--[[
    Changes the monitor's display to show two buttons to open an airlock door
]]--
function openAirlockDisplay()
	mon.clear()
	mon.setTextScale(1)
	mon.setBackgroundColor(colors.white)

	-- Left/Right Door Buttons
	mon.setCursorPos(4, 1) mon.write(" ")
    mon.setCursorPos(4, 2) mon.write(" ")
    mon.setCursorPos(1, 3)
    mon.setBackgroundColor(colors.black) mon.write("<--")
    mon.setBackgroundColor(colors.white) mon.write(" ")
    mon.setBackgroundColor(colors.black) mon.write("-->")
    mon.setBackgroundColor(colors.white)
    mon.setCursorPos(4, 4) mon.write(" ")
    mon.setCursorPos(4, 5) mon.write(" ")

    mon.setBackgroundColor(colors.black)
end

--[[
    Gets the monitor's specific coordinates of where the player touched the
    screen
]]--
function touchMonitor()
    event, side, x, y = os.pullEvent("monitor_touch")
end

--[[
    Button functionality when button is pressed on the monitor
]]--
function readTouchInput()
    -- State 0 button
    if x >= 3 and x <= 13 and y >= 4 and y <= 7 and state == 0 then
        return 1
    -- State 2 left door button
    elseif x >= 1 and x < 4 and state == 2 then
        return 2
    -- State 2 right door button
    elseif x > 4 and x <= 7 and state == 2 then
        return 3
    -- State 2 both doors
    elseif x == 4 and state == 2 then
        return 4
    -- Invalid button press
    else
        return -1
    end
end

--[[
	Helper function that displays a countdown from a number at the bottom of
	the monitor screen.

	@param number - An integer value
]]--
function countDown(number)
	if type(number) ~= "number" then
		return
	end

	local tNum = number

	while tNum > -1 do
		-- If # is >= 10, then position to mon.setCursorPos(7, 10) instead to be centered
		if (tNum >= 10) then
			mon.setCursorPos(7, 10)
		else
			mon.setCursorPos(8, 10)
			mon.clearLine()
		end

		mon.write(tostring(tNum))
		tNum = tNum - 1
		sleep(1)
	end
end

main()
