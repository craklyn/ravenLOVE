-- Our HUD class
HUD = {}
local loader = require("char")

local fullHeart      = love.graphics.newQuad( 0, 0,28,23,84,23)
local halfHeart      = love.graphics.newQuad(28, 0,28,23,84,23)
local emptyHeart     = love.graphics.newQuad(56, 0,28,23,84,23) 

-- The image of our HUD
HUD.image = love.graphics.newImage("images/hud/HUD.png")

-- Called from love.draw()
function HUD.draw()
    heartSize = 28

    tempHealth = Char.health
	posX = 772 - heartSize * Char.maxHealth
	drawImage = emptyHeart
	
	for i=1,Char.maxHealth do
	  if tempHealth >= 1 then
		drawImage = fullHeart
	  elseif tempHealth > 0 and tempHealth < 1 then
		drawImage = halfHeart
	  else
	    drawImage = emptyHeart
	  end  

	  love.graphics.drawq(HUD.image, drawImage, posX, 15)
      tempHealth = tempHealth - 1
	  posX = posX + heartSize
	end
end

return HUD
