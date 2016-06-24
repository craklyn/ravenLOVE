numGame = {}

require("lua/button")
--require("lua/states")

-- Game State
-- Where the actual playing takes place
Game = {}
Game.__index = Game

function Game.create()
	
	local temp = {}
	setmetatable(temp, Game)
	
	math.randomseed(os.time()) -- randomize (for good measure)
	
	-- Setup the randomized grid
	temp.grid = {}
	for x = 1,numGame.size do
		temp.grid[x] = {}
		for y = 1, numGame.size do
			num = math.random(1,3)
			if num == 1 then
				temp.grid[x][y] = false
			else
				temp.grid[x][y] = true
			end
		end
	end
	
	-- Create the text along the top
	local count = 0
	temp.horizontal = {}
	for x = 1,numGame.size do
		temp.horizontal[x] = ""
		for y = 1,numGame.size do
			if temp.grid[x][y] then
				count = count + 1
			elseif count ~= 0 then
				temp.horizontal[x] = temp.horizontal[x] .. count .. "\n"
				count = 0
			end
		end
		
		if count ~= 0 then
			temp.horizontal[x] = temp.horizontal[x] .. count .. "\n"
		end
		
		count = 0
	end
	
	-- Create the text along the side
	temp.vertical = {}
	for y = 1,numGame.size do
		temp.vertical[y] = ""
		for x = 1,numGame.size do
			if temp.grid[x][y] then
				count = count + 1
			elseif count ~= 0 then
				temp.vertical[y] = temp.vertical[y] .. count .. " "
				count = 0
			end
		end
		
		if count ~= 0 then
			temp.vertical[y] = temp.vertical[y] .. count .. " "
		end
		
		count = 0
	end
	
	-- Setup the user-entered grid
	temp.grid = {}
	for x = 1,numGame.size do
		temp.grid[x] = {}
		for y = 1, numGame.size do
			temp.grid[x][y] = 0
		end
	end
	
	-- Other variables
	temp.time = 0 -- the time for this game
	temp.win = -999 -- if the game is won and timer for fadein
	temp.pause = false -- if the game is paused
	temp.button = {	new = Button.create("New Game", 300, 400),
					resume = Button.create("Resume", 300, 400),
					quit = Button.create("Quit", 525, 400) }
	
	return temp
	
end

function Game:draw()
	
	local gs = numGame.size*50
	local gx = (love.graphics.getWidth() - gs) / 2
	local gy = (love.graphics.getHeight() - gs) / 2 + (numGame.size / 2 * 10)	
	local offset = 0
	
	-- Grid items
	for x=1,numGame.size do
		for y=1,numGame.size do
			if numGame.state.grid[x][y] == 1 then
				love.graphics.draw(numGame.graphics["set"], gx+(x*50)-25, gy+(y*50)-25, 0, 1, 1, 25, 25)
			elseif numGame.state.grid[x][y] == 2 then
				love.graphics.draw(numGame.graphics["notset"], gx+(x*50)-25, gy+(y*50)-25, 0, 1, 1, 25, 25)
			end
		end
	end
	
	-- The grid
	love.graphics.setColor(unpack(numGame.color["main"]))
	love.graphics.setLine(2, "rough")
	love.graphics.rectangle("line",gx,gy,gs,gs) -- surrounding rectangle
	love.graphics.setLine(1)
	for i=1,numGame.size do
		offset = offset + (gs/numGame.size)
		love.graphics.line(gx+offset, gy, gx+offset, gy+gs) -- vertical lines
		love.graphics.line(gx, gy+offset, gx+gs, gy+offset) -- horizontal lines
	end
	
	-- Text
	love.graphics.setColor(unpack(numGame.color["text"]))
	love.graphics.setFont(numGame.font["default"])
	for i=1,numGame.size do
		love.graphics.printf(numGame.state.horizontal[i],
					gx+(50*i)-50,
					gy-((numGame.state.horizontal[i]:len()/2) * numGame.font["default"]:getHeight() * numGame.font["default"]:getLineHeight()),
					50, "center")
		love.graphics.printf(numGame.state.vertical[i], 0, gy+(50*i)-36, gx, "right")
	end
	
	-- Time (removed)
	--love.graphics.setColor(color["text"])
	--love.graphics.setFont(font["default"])
	--love.graphics.draw(string.format("%.2fs", numGame.state.time), 700, 40)
	
	if numGame.state.win ~= -999 then
		-- You won!
		if numGame.state.win > 0 then
			love.graphics.setColor(255,255,255,235-(235*(numGame.state.win/0.5)))
			love.graphics.rectangle("fill",0,0,love.graphics.getWidth(),love.graphics.getHeight())
		else
			love.graphics.setColor(unpack(color["overlay"]))
			love.graphics.rectangle("fill",0,0,love.graphics.getWidth(),love.graphics.getHeight())
			love.graphics.setColor(unpack(color["main"]))
			love.graphics.setFont(font["huge"])
			love.graphics.printf("CONGRATULATIONS", 0, 150, love.graphics.getWidth(), "center")
      print("Congratulations!  YOU WIN")
			love.graphics.setColor(unpack(color["text"]))
			love.graphics.setFont(font["default"])
			love.graphics.printf("You completed a level " .. numGame.size .. " puzzle in: \n" .. string.format("%.2f", numGame.state.time) .. " seconds", 0, 200+64, love.graphics.getWidth(), "center")
			-- Buttons
			self.button["new"]:draw()
			self.button["quit"]:draw()
		end
	else
	end
	
end

function Game:update(dt)
	
	if self.win ~= -999 then
		if self.win > 0 then
			self.win = self.win - dt
		end
		self.button["new"]:update(dt)
		self.button["quit"]:update(dt)
	elseif self.pause then
		self.button["resume"]:update(dt)
		self.button["quit"]:update(dt)
	else
		self.time = self.time + dt
	end
	
end

function Game:mousepressed(x, y, mb)
    local gs = numGame.size*50
		local gx = (love.graphics.getWidth() - gs) / 2
		local gy = (love.graphics.getHeight() - gs) / 2 + (numGame.size / 2 * 10)
    
    local x, y = love.mouse.getPosition()
		-- Set the positions relative to the grid
		x = Char.x + Char.width/2  - gx
		y = Char.y + Char.height/2 - gy
    
		-- Is the mouse within the grid?
		if x > 0
			and x < gs
			and y > 0
			and y < gs then
			
			-- Get the cell they clicked in
			x = math.ceil(x / 50)
			y = math.ceil(y / 50)
      
			-- Make the change
			if mb == "l" then
				if numGame.state.grid[x][y] == 1 then
					numGame.state.grid[x][y] = 0
				else
					numGame.state.grid[x][y] = 1
				end
			elseif mb == "r" then
				if numGame.state.grid[x][y] == 2 then
					numGame.state.grid[x][y] = 0
				else
					numGame.state.grid[x][y] = 2
				end
			end
			
			-- Check if the new answer is correct
			if Game:testSolution() then
				numGame.state.win = 0.5
			end
		end
	
end

function Game:testSolution()

	local count = 0
	
	-- Make horizontal and vertical number lists for the entred solution
	th = {}
	for x = 1,numGame.size do
		th[x] = ""
		for y = 1,numGame.size do
			if numGame.state.grid[x][y] == 1 then
				count = count + 1
			elseif count ~= 0 then
				th[x] = th[x] .. count .. "\n"
				count = 0
			end
		end
		if count ~= 0 then
			th[x] = th[x] .. count .. "\n"
		end
		count = 0
	end
	tv = {}
	for y = 1,numGame.size do
		tv[y] = ""
		for x = 1,numGame.size do
			if numGame.state.grid[x][y] == 1 then
				count = count + 1
			elseif count ~= 0 then
				tv[y] = tv[y] .. count .. " "
				count = 0
			end
		end
		if count ~= 0 then
			tv[y] = tv[y] .. count .. " "
		end
		count = 0
	end
	
	-- Compare against real numbers, stopping where it fails
	for i=1,numGame.size do
		if numGame.state.horizontal[i] ~= th[i] or numGame.state.vertical[i] ~= tv[i] then
			return false
		end
	end
	
	return true -- default action

end


function numGame.load()
	-- Resources
	numGame.color =	 {	background = {240,243,247},
				main = {63,193,245},
				text = {76,77,78},
				overlay = {255,255,255,235} }
	numGame.font = {	default = love.graphics.newFont(24),
				large = love.graphics.newFont(32),
				huge = love.graphics.newFont(72),
				small = love.graphics.newFont(22) }
	numGame.graphics = {logo = love.graphics.newImage("media/logo.png"),
				fmas = love.graphics.newImage("media/fmas.png"),
				set = love.graphics.newImage("media/set.png"),
				notset = love.graphics.newImage("media/notset.png") }
	numGame.sound =	{	click = love.audio.newSource("media/click.ogg", "static"),
				shush = love.audio.newSource("media/shh.ogg", "static"),
				pling = love.audio.newSource("media/pling.ogg", "static") }
	
	-- Variables
	numGame.size = 6				-- size of the grid
	numGame.state = Game.create()	-- current game state
	
	-- Setup
	love.graphics.setBackgroundColor(unpack(numGame.color["background"]))
end

function numGame.draw()
	numGame.state:draw()
	
	love.graphics.draw(numGame.graphics["fmas"], 700, 590, 0, 1, 1, 100, 10)
end

function numGame.update(dt)
	state:update(dt)
end

function numGame.mousepressed(x, y, button)
  numGame.state:mousepressed(x, y, button)
end

function numGame.keypressed(key)
	numGame.state:keypressed(key)
end

return numGame
