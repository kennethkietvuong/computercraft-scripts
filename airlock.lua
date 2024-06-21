--[[
	Airlock v1.0
	by Juicebox829
	
	June 20th, 2024
	Update: Jun 18th, 2024

	States of airlock: (initial) enter airlock -> seal -> rocket room
                       rocket room -> seal -> enter airlock

                       0 -> 1 -> 2
]]--

function main()
	local state = 0
    term.clear()
	term.setCursorPos(1,1)

	powerSide = 'back'
	monSide = 'top'
	speakSide = 'bottom'

    mon = peripheral.wrap(monSide)
    speak = peripheral.wrap(speakSide)

	-- first check if the term.isColor function exists
	if not mon.isColor then
		print("Please attach an advanced monitor to the ["..monSide.."] side of the computer.")
		exit()
	    --This is a pre ComputerCraft 1.45 computer, there are only normal computers! Text is always white and the background is always black
	elseif not mon.isColor() then
		print("Please attach an advanced monitor to the ["..monSide.."] side of the computer.")
		exit()
	end

    -- Airlock state machine
    while true do
        -- Initial state
        if state == 0 then
            touchMonitor()
            enterAirlockDisplay()
        -- Closing/sealing airlock
        elseif state == 1 then
            sealAirlock()
        -- Opening airlock
        elseif state == 2 then

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
        speak.playSound("minecraft:block.lava_extinguish", 1, 0.5)
        sleep(1)
    end
    
    -- Disable oxygen distributor
    redstone.setOutput("top", false)

    -- Make "completion" sound
    --speak.playNote()
end

--[[
    Changes the monitor's display to show a button to seal the
    airlock.
]]--
function enterAirlockDisplay()

end

--[[
    Choose one of the doors to open
]]--
function openAirlock()
    
end

--[[
    Gets the monitor's specific coordinates of where the player touched the
    screen
]]--
function touchMonitor()
    local event, side, x, y = os.pullEvent("monitor_touch")
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