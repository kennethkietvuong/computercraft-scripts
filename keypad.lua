--[[
	KeyPad v1.4
	by Fwacer
	adapted by Jfernald
	modified by Juicebox829
	
	June 10th, 2014
	Update: Jun 18th, 2024

	Note: for single monitors
		setTextScale(0.5) ->  Horizontal Center = setCursorPos(8, #)
		setTextScale(0.5) ->  Vertical Center = setCursorPos(#, 5 or 6) (cannot do 5.5)
]]--

local args = {...}

if #args ~= 2 then
  print(
    "Usage: program <pin code (4 digits)> <auto lock time (seconds)>")
  return
end

local pinCode = tonumber(args[1])
local lockTime = tonumber(args[2])
local failedAttempts = 0

function main()
	code = 0
	term.clear()
	term.setCursorPos(1,1)
	--This checks for a changed password
	code = pinCode
	powerSide = 'back'
	monSide = 'top'
	speakSide = 'bottom'

	local userCode = 0
	local count = 0
	local loop = true
	local num = 0
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
	
	printKey()
	print("Keypad is now Active!")
	print("PIN is: " .. pinCode)
	print("Lock time is: " .. lockTime .. " seconds")
	while loop do
		if count < 4 then
			touch()
		end

	  	num = codeConvert()
	  
	  	if num == -1 then
			printKey()
			count = 0
			userCode = 0

	  	elseif num == -2 then
			--repeat because of invalid press

	  	elseif count < 4 then
			userCode = (userCode * 10) + num
			count = count + 1
			mon.write(tostring(num))

	  	else
			print(" ")
			print("userCode: " .. userCode)
        	print(" ")
			
			-- If PIN code is correct
			if code == userCode then
				print("Correct PIN entered!")
				redstone.setOutput(powerSide, true)
				speak.playNote("bell", 3, 10)
				sleep(0.5)
				speak.playNote("bell", 3, 6)
				correctCodeDisplay()
				printKey()
				redstone.setOutput(powerSide, false)
				userCode = 0
				count = 0
				failedAttempts = 0

			-- If PIN code is incorrect
			else
				failedAttempts = failedAttempts + 1
				print("Incorrect PIN entered!")

				if failedAttempts == 3 then
					redstone.setOutput("left", true)
					failedAttemptsDisplay()
					print("Too many attempts made!")
					printKey()
					redstone.setOutput("left", false)
					userCode = 0
					count = 0

				else 
					speak.playNote("bass", 3, 0)
					incorrectCodeDisplay()
					printKey()
					userCode = 0
					count = 0
				end
			end
		end
	end
end

--[[
	Function that changes the monitor's display to show that the correct PIN
	code has been entered.
]]--
function correctCodeDisplay()
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
	countDown(lockTime)
end

--[[
	Function that changes the monitor's display to show that the incorrect PIN
	code has been entered.
]]--
function incorrectCodeDisplay()
	mon.clear()
	mon.setTextScale(0.5)
	mon.setTextColor(colors.red)
	mon.setBackgroundColor(colors.red)

	-- Red X
	mon.setCursorPos(6, 2) mon.write(" ")
	mon.setCursorPos(10, 2) mon.write(" ")
	mon.setCursorPos(7, 3) mon.write(" ")
	mon.setCursorPos(9, 3) mon.write(" ")
	mon.setCursorPos(8, 4) mon.write(" ")
	mon.setCursorPos(7, 5) mon.write(" ")
	mon.setCursorPos(9, 5) mon.write(" ")
	mon.setCursorPos(6, 6) mon.write(" ")
	mon.setCursorPos(10, 6) mon.write(" ")
	
	-- Red "FAILURE" Text
	mon.setCursorPos(5, 8)
	mon.setBackgroundColor(colors.black)
	mon.write("FAILURE")

	-- White Countdown
	mon.setTextColor(colors.white)
	countDown(2)
end

--[[
	Function that changes the monitor's display to show that too many failed
	attempts have been made.
	]]--
function failedAttemptsDisplay()
	mon.clear()
	mon.setTextScale(0.5)
	mon.setTextColor(colors.yellow)
	mon.setBackgroundColor(colors.yellow)
	
	-- Yellow Exclamation Mark
	mon.setCursorPos(8, 2) mon.write(" ")
	mon.setCursorPos(8, 3) mon.write(" ")
	mon.setCursorPos(8, 4) mon.write(" ")
	mon.setCursorPos(8, 6) mon.write(" ")
	
	-- Yellow "Too many failed attempts!" Text
	mon.setCursorPos(1, 8)
	mon.setBackgroundColor(colors.black)
	mon.write("Too many failed")
	mon.setCursorPos(4, 9)
	mon.write("attempts!")
	
	-- White Countdown
	mon.setTextColor(colors.white)
	countDown(10)
	
	failedAttempts = 0
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

function touch()
	local event, side
	event, side, xPos, yPos = os.pullEvent("monitor_touch") --Gets the coordinates of where the player touched the screen
end

function printKey()
	mon.clear()
	mon.setTextColor(colors.white)
	mon.setCursorPos(1,1)
	mon.setTextScale(1.25)
	mon.write(" 1 2 3")
	mon.setCursorPos(1,2.5)
	mon.write(" 4 5 6")
	mon.setCursorPos(1,3.5)
	mon.write(" 7 8 9")
	mon.setCursorPos(4,4.5)
	mon.write("0")
	mon.setCursorPos(1,5)
	mon.setBackgroundColor(colors.red)
	mon.setTextScale(1)
	mon.write("\215")
	mon.setCursorPos(4,5)
    mon.setBackgroundColor(colors.black)
	mon.setTextColor(colors.purple)
end

function codeConvert()
	local x = xPos
	local y = yPos
	local xVar
	local num = -2
	local isValid
  --Change the xPos into blocks 1,2,3
	if x == 1 or x == 2 then
		xVar = 1
	elseif x == 3 or x == 4 or x == 5 then
		xVar = 2
	else
		xVar = 3
	end

	if y < 4 then
		isValid = true
	elseif y == 4 then
		if xVar == 2 then
			isValid = true
		else
			isValid = false
		end
	elseif y == 5 then --CLS button
		if x < 4 then
		mon.clear()
		num = -1
		end
	end
	--Now to determine the numbers picked
	if isValid then
		if xVar == 1 then
			if y == 1 then
				num = 1
			elseif y == 2 then
				num = 4
			elseif y == 3 then
				num = 7
			end
		elseif xVar	== 2 then
			if y==1 then
				num = 2
			elseif y == 2 then
				num = 5
			elseif y == 3 then
				num = 8
			elseif y == 4 then
				num = 0
			end
		elseif xVar == 3 then
			if y == 1 then
				num = 3
			elseif y == 2 then
				num = 6
			elseif y == 3 then
				num = 9
			end
		end
	end

	if num == -2 then --If the player hits an invalid space
	elseif num > -1 then
		write(num)
	end

	return num
end

main()