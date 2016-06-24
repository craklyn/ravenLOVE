require("AnAL")

-- Our char class
local char = {}
char.maxHealth = 3
char.health = 3
char.timeLastHurt = love.timer.getTime()
char.timeLastRegen = love.timer.getTime()
char.timeLastShot = love.timer.getTime()
char.shotCooldown = 0.8 -- Number of seconds the character must wait before shooting again
char.tileX = 13		-- The horizontal tile
char.tileY = 24		-- The vertical tile
char.speedBase = 6  -- An arbitrary constant for controlling player speed
char.speedPenalty = 0
char.state = "normal"
char.attackDamage = 1

-- Collision detection function.
-- Checks if an object overlaps with the character.
function char.CheckCollision(object)
  local char1x, char2x = Char.x + 9, Char.x + Char.width - 9
  local char1y, char2y = Char.y + 3, Char.y + Char.height - 3

--  if object.hitBox then
--   local object2x = object.x + object.hitBox.X2
--    local object2y = object.y + object.hitBox.Y2
--    return Char.x < object2x and char2x > object.x + object.hitBox.X1 and Char.y < object2y and char2y > object.y + object.hitBox.Y1 
--  else
    local object2x = object.x + object.width
    local object2y = object.y + object.height
    return char1x < object2x and char2x > object.x and char1y < object2y and char2y > object.y  
--  end
end

function char.draw()
	love.graphics.drawq(Char.normalImage, Char.normalQuads[Char.facing], Char.x, Char.y)
end

function char.CheckAttackCollision(object)
  if Char.state ~= "swordAttack" then return false end

  local char1x, char2x = Char.x, Char.x + Char.width 
  local char1y, char2y = Char.y, Char.y + Char.height 

  if Char.facing == "down" or Char.facing == "up" then 
    char1x = char1x - Char.width/2
    char2x = char2x + Char.width/2
    if Char.facing == "down"   then char1y,char2y = char1y + Char.height, char2y + Char.height/2
    elseif Char.facing == "up" then char1y,char2y = char1y - Char.height/2, char2y - Char.height end
  end
  if Char.facing == "right" or Char.facing == "left" then
    char1y = char1y - Char.height/2
    char2y = char2y + Char.height/2
    if Char.facing == "right" then char1x,char2x = char1x + Char.width, char2x + Char.width/2
    elseif Char.facing == "left" then char1x,char2x = char1x - Char.width/2, char2x - Char.width end
  end

  local object2x = object.x + object.width
  local object2y = object.y + object.height

  return char1x < object2x and char2x > object.x and char1y < object2y and char2y > object.y
end

function char.getDist2(object)
  return math.pow(Char.x - object.x, 2) + math.pow(Char.y - object.y, 2)
end

char.facing = "down"	-- The direction our char is facing
char.normalQuads = {		-- The frames of the image
  down  = love.graphics.newQuad(0,0,32,32,134,32),
  up    = love.graphics.newQuad(34,0,32,32,134,32),
  right = love.graphics.newQuad(68,0,32,32,134,32),
  left  = love.graphics.newQuad(102,0,32,32,134,32),
}

-- The image of our char
char.normalImage = love.graphics.newImage("images/characters/wa/knight_stand.png")
--char.width = char.normalImage:getWidth()
--char.height = char.normalImage:getHeight()

char.attackImage = {
  down = love.graphics.newImage("images/characters/wa/knightAttackDown.png"),
  up = love.graphics.newImage("images/characters/wa/knightAttackUp.png"),
  right = love.graphics.newImage("images/characters/wa/knightAttackRight.png"),
  left = love.graphics.newImage("images/characters/wa/knightAttackLeft.png")
}
char.attackAnim = {
  down = newAnimation(char.attackImage["down"], 53, 50, 0.06, 0),
  up   = newAnimation(char.attackImage["up"], 58, 51, 0.06, 0),
  right = newAnimation(char.attackImage["right"], 44, 45, 0.06, 0),
  left = newAnimation(char.attackImage["left"], 44, 45, 0.06, 0)
}
char.attackImage.offsetX = {
  up = 6,
  down = 13,
  right = -8,
  left = 20
}
char.attackImage.offsetY = {
  up = 19,
  down = 1,
  right = 0,
  left = 0
}

char.moveImage = {
  down = love.graphics.newImage("images/characters/wa/KnightWalkDown.png"),
  up = love.graphics.newImage("images/characters/wa/KnightWalkUp.png"),
  right = love.graphics.newImage("images/characters/wa/knight_walk_right.png"),
  left = love.graphics.newImage("images/characters/wa/knight_walk_left.png")
}
char.moveAnim = {
  down = newAnimation(char.moveImage["down"], 27, 34, 0.08, 0),
  up   = newAnimation(char.moveImage["up"], 27, 34, 0.08, 0),
  right = newAnimation(char.moveImage["right"], 22, 34, 0.06, 0),
  left = newAnimation(char.moveImage["left"], 22, 34, 0.06, 0)
}
char.moveImage.offsetX = {
  up = -4,
  down = -2,
  right = 0,
  left = 0
}
char.moveImage.offsetY = {
  up = 2,
  down = 2,
  right = 0,
  left = 0
}


return char
