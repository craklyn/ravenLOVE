-----------------------
-- NO: A game of numbers
-- Created: 23.08.08 by Michael Enger
-- Version: 0.2
-- Website: http://www.facemeandscream.com
-- Licence: ZLIB
-----------------------
-- States used.
-----------------------

-- Menu State
-- Main menu...
Menu = {}
Menu.__index = Menu

function Menu.create()
	local temp = {}
	setmetatable(temp, Menu)
	temp.button = {	new = Button.create("New Game", 400, 250),
					instructions = Button.create("Instructions", 400, 300),
					options = Button.create("Options", 400, 350),
					quit = Button.create("Quit", 400, 550) }
	return temp
end

function Menu:draw()

	love.graphics.draw(numGame.graphics["logo"], 400, 125, 0, 1, 1, 100, 75)
	
	for n,b in pairs(self.button) do
		b:draw()
	end

end

function Menu:update(dt)
	
	for n,b in pairs(self.button) do
		b:update(dt)
	end
	
end

function Menu:mousepressed(x,y,button)
	
	for n,b in pairs(self.button) do
		if b:mousepressed(x,y,button) then
			if n == "new" then
				state = Game.create()
			elseif n == "instructions" then
				state = Instructions.create()
			elseif n == "options" then
				state = Options.create()
			elseif n == "quit" then
				love.event.push("quit")
			end
		end
	end
	
end

function Menu:keypressed(key)
	if key == "escape" then
		love.event.push("q")
	end
end


-- Instructions State
-- Shows the instructions
Instructions = {}
Instructions.__index = Instructions

function Instructions.create()
	local temp = {}
	setmetatable(temp, Instructions)
	temp.button = {	back = Button.create("Back", 400, 550) }
	return temp
end

function Instructions:draw()

	love.graphics.draw(graphics["logo"], 400, 125, 0, 1, 1, 100, 75)
	
	love.graphics.setColor(unpack(color["text"]))
	love.graphics.setFont(font["small"])
	love.graphics.printf("The point of this game is to fill out a standard, randomly generated, nonogram by using the mouse. The left mouse button fills in (or \"un-fills\") an area whilst the right mouse button is used to set hints where you think an area shouldn't be filled.\nUse the escape key to pause the game.\n\nGood luck.", 100, 250, 600, "center")
	
	for n,b in pairs(self.button) do
		b:draw()
	end

end

function Instructions:update(dt)
	
	for n,b in pairs(self.button) do
		b:update(dt)
	end
	
end

function Instructions:mousepressed(x,y,button)
	
	for n,b in pairs(self.button) do
		if b:mousepressed(x,y,button) then
			if n == "back" then
				state = Menu.create()
			end
		end
	end
	
end

function Instructions:keypressed(key)
	
	if key == "escape" then
		state = Menu.create()
	end
	
end


-- Options State
-- Shows the options
Options = {}
Options.__index = Options

function Options.create()
	local temp = {}
	setmetatable(temp, Options)
	temp.button = {	on = Button.create("On", 425, 300),
					off = Button.create("Off", 550, 300),
					five = Button.create(" 5 ", 375, 375),
					six = Button.create(" 6 ", 425, 375),
					seven = Button.create(" 7 ", 475, 375),
					eight = Button.create(" 8 ", 525, 375),
					--nine = Button.create(" 9 ", 575, 375),
					back = Button.create("Back", 400, 550) }
	return temp
end

function Options:draw()

	love.graphics.draw(graphics["logo"], 400, 125, 0, 1, 1, 100, 75)
	
	love.graphics.setColor(unpack(color["text"]))
	love.graphics.setFont(font["large"])
	love.graphics.print("Audio:", 250, 270)
	love.graphics.print("Level:", 250, 345)
	
	love.graphics.setColor(unpack(color["main"]))
	love.graphics.setLine(4, "rough")
	
	if audio then
		love.graphics.line(400,305,450,305)
	else
		love.graphics.line(525,305,575,305)
	end
	
	love.graphics.line(360+((size-5)*50),380,390+((size-5)*50),380)
	
	for n,b in pairs(self.button) do
		b:draw()
	end

end

function Options:update(dt)
	
	for n,b in pairs(self.button) do
		b:update(dt)
	end
	
end

function Options:mousepressed(x,y,button)
	
	for n,b in pairs(self.button) do
		if b:mousepressed(x,y,button) then
			if n == "on" then
				audio = true
				love.audio.resume()
			elseif n == "off" then
				audio = false
				love.audio.pause()
			elseif n == "five" then
				size = 5
			elseif n == "six" then
				size = 6
			elseif n == "seven" then
				size = 7
			elseif n == "eight" then
				size = 8
			elseif n == "nine" then
				size = 9
			elseif n == "back" then
				state = Menu.create()
			end
		end
	end
	
end

function Options:keypressed(key)
	
	if key == "escape" then
		state = Menu.create()
	end
	
end


