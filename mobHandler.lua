-- Setup

local mobHandler = {}
local imageBlobGreen  = love.graphics.newImage("images/mobs/blobGreen.png")
local imageBlobBlue   = love.graphics.newImage("images/mobs/blobBlue.png")
local imageBlobPuddleBlue = love.graphics.newImage("images/mobs/blobPuddleBlue.png")
local imageBlobShotGreen = love.graphics.newImage("images/mobs/blobShotGreen.png")
local imageCharacterArrowQuad = love.graphics.newQuad(0, 4, 20, 14, 130, 20)
local imageCharacterArrow = love.graphics.newImage("images/characters/wa/arrow.png")
local animCritterSnake = love.graphics.newImage("images/mobs/snake.png")
local imageAnacondaHead = love.graphics.newImage("images/mobs/motherAnaconda/motherAnacondaHead.png")
local imageAnacondaBody = love.graphics.newImage("images/mobs/motherAnaconda/motherAnacondaBody.png")
local cloudImage = love.graphics.newImage("demos080/particles/part1.png");
local imageSkeletonWarrior = love.graphics.newImage("images/mobs/skeleton/skeletonStand.png")
local animSkeletonAttackRight = love.graphics.newImage("images/mobs/skeleton/skeletonAttackRight.png")
local animSkeletonAttackLeft = love.graphics.newImage("images/mobs/skeleton/skeletonAttackLeft.png")

function mobHandler.addMob(map, currentMap, name, tileX, tileY)
  local enemy
  if name == "CharacterArrow" then enemy = map[currentMap].ol["Object1"]:newObject("Mob", "MobEntity",0,0,20,10)
  else enemy = map[currentMap].ol["Object1"]:newObject("Mob", "MobEntity",0,0,32,32) end
  
  enemy.tileX = tileX
  enemy.tileY = tileY
  enemy.speedX = 0
  enemy.speedY = 0
  enemy.dead = false
  enemy.timeLastAttack = love.timer.getTime()
  enemy.soundStarted = false
  
  enemy:moveTo((enemy.tileX-1)*map[currentMap].tileWidth, (enemy.tileY-1)*map[currentMap].tileHeight)
  
  enemy:updateDrawInfo() 
  
  function enemy.update(dt)
    -- If the creature has its own custom abilities, update them first
    if enemy.personalUpdate then enemy.personalUpdate(dt)	end
	
	-- Ignore stuff which is far away
    if enemy.x and enemy.y and Char.getDist2(enemy) > 700000 then 
      if name == "greenBlobShot"  or name == "characterArrow" then enemy.dead = true end
      return 
    end

    if enemy.hitPoint <= 0 then enemy.dead = true end
  
    enemy.move(dt)
    if enemy.anim then enemy.anim:update(dt) end
	
    -- If the mob is on an intraversable space, kill it
    local tempTile = map[currentMap].tl["Ground"].tileData(roundNum(enemy.tileX - 1, 0), roundNum(enemy.tileY - 1, 0))
    if tempTile == nil or tempTile.properties.obstacle then enemy.dead = true end
	
    if enemy.isEnemy and Char.CheckAttackCollision(enemy) then
      enemy.hitPoint = enemy.hitPoint - Char.attackDamage
      if enemy.hitPoint <= 0 then enemy.dead = true end
    end

    if enemy.isEnemy and not enemy.isDead and enemy.touchDamage > 0 and Char.CheckCollision(enemy) then
      local tempDamage = {}
      tempDamage["damageVal"] = enemy.touchDamage
      tempDamage["damageType"] = enemy.damageType
      table.insert(global.damageList, tempDamage)
    end
	
    if enemy.touchSlow < 0 and Char.CheckCollision(enemy) then
      Char.speedPenalty = enemy.touchSlow
    end
	
    if not enemy.isEnemy and enemy.touchDamage > 0 then
      for k,v in pairs(map[currentMap].ol["Object1"].objects) do
        if v.type == "MobEntity" and v.isEnemy then
           if mobHandler.checkCollision(enemy, v) then
             enemy.hitPoint = enemy.hitPoint - v.touchDamage
             v.hitPoint = v.hitPoint - enemy.touchDamage
           end
        end
      end
    end

    if enemy.followTarget then
      local angle = math.atan2(enemy.followTarget.tileY - enemy.tileY, enemy.followTarget.tileX - enemy.tileX)
    
      if math.pow(enemy.x - enemy.followTarget.x, 2) + math.pow(enemy.y - enemy.followTarget.y, 2) > (enemy.width-4) * (enemy.followTarget.width-4) * enemy.drawScale * enemy.followTarget.drawScale then
        local masterSpeed = math.sqrt(enemy.followTarget.speedX*enemy.followTarget.speedX + enemy.followTarget.speedY*enemy.followTarget.speedY)
        if masterSpeed > 4.5 then masterSpeed = 4.5 end
      enemy.speedX = masterSpeed*math.cos(angle)
      enemy.speedY = masterSpeed*math.sin(angle)
    end

    if enemy.particleSystem then 
      enemy.particleSystem:update(dt) 
      if enemy.particleSystem:count() < 45 then enemy.particleSystem:start() end
    end

  end
    
  if name == "greenBlob" and love.timer.getTime() > enemy.timeLastAttack + 2.5 then
      mobHandler.addMob(map, currentMap, "greenBlobShot", enemy.tileX, enemy.tileY)
      enemy.timeLastAttack = love.timer.getTime()
    end
	  if name == "blueBlob" and love.timer.getTime() > enemy.timeLastAttack + 10 then
          print(roundNum(enemy.tileX,0))
          print(roundNum(enemy.tileY,0))
	  local tempTile = map[currentMap].tl["Ground"].tileData(roundNum(enemy.tileX,0), roundNum(enemy.tileY,0))
	  if tempTile ~= nil then
	    mobHandler.addMob(map, currentMap, "blobPuddleBlue", enemy.tileX, enemy.tileY)
        enemy.timeLastAttack = love.timer.getTime()
      end
    end
  end
  
  function enemy.move(dt)
    x = dt * enemy.speedX
    y = dt * enemy.speedY
	
    if enemy.isSeeker then
      local angle = math.atan2(Char.tileY - enemy.tileY, Char.tileX - enemy.tileX)
      local speed = math.sqrt(math.pow(enemy.speedX, 2) + math.pow(enemy.speedY, 2))
      enemy.speedX = speed * math.cos(angle)
      enemy.speedY = speed * math.sin(angle)
    end
  
    -- Grab the tile
    local tile = map[currentMap].tl["Ground"].tileData(roundNum(enemy.tileX + x, 0), roundNum(enemy.tileY + y, 0))

    -- Grab the tile corners
    local tile1, tile2, tile3, tile4
    local slimWidth = 4/32
    local tileX1 = roundNum(enemy.tileX - 1.5 + slimWidth + x, 0)
    local tileX2 = roundNum(enemy.tileX - 0.5  - slimWidth + x, 0)
    local tileY1 = roundNum(enemy.tileY - 1.5 + 3*slimWidth + y, 0)
    local tileY2 = roundNum(enemy.tileY - 0.5 - slimWidth + y, 0)
    tile1 = map[currentMap].tl["Ground"].tileData(roundNum(tileX1, 0), roundNum(tileY1, 0))
    tile2 = map[currentMap].tl["Ground"].tileData(roundNum(tileX2, 0), roundNum(tileY1, 0))
    tile3 = map[currentMap].tl["Ground"].tileData(roundNum(tileX1, 0), roundNum(tileY2, 0))
    tile4 = map[currentMap].tl["Ground"].tileData(roundNum(tileX2, 0), roundNum(tileY2, 0))
  
    -- If the tile doesn't exist or is an obstacle then choose a new direction and exit the function
    if (tile1 == nil or tile1.properties.obstacle) or
       (tile2 == nil or tile2.properties.obstacle) or
       (tile3 == nil or tile3.properties.obstacle) or
       (tile4 == nil or tile4.properties.obstacle) then
      enemy.hitsWall()
      return
    end
  
    -- Otherwise change the enemy's tile
    enemy.tileX =  x + enemy.tileX
    enemy.tileY =  y + enemy.tileY 
    enemy:moveTo((enemy.tileX-1)*map[currentMap].tileWidth, (enemy.tileY-1)*map[currentMap].tileHeight) 
  end
  
  loadMob(enemy, name, map, currentMap)
 
  return enemy
end

function loadMob(enemy, name, map, currentMap)
  enemy.isEnemy = true
  enemy.touchDamage = 0
  enemy.touchSlow   = 0
  enemy.hitPoint = 1
  enemy.angle = 0

  if name == "greenBlob" or name == "blueBlob" then 
    enemy.hitBox = {
	  X1 = 4,
	  X2 = 28,
	  Y1 = 4,
	  Y2 = 28
	  }
    enemy.touchDamage = 0.5
    enemy.damageType = "poison"
    function enemy.hitsWall()
      -- Character moves in a new direction...
      local temp = math.random() * 2 * math.pi
      enemy.speedX = 0.7*math.cos(temp)
      enemy.speedY = 0.7*math.sin(temp)
    end 
    enemy.hitsWall() -- sets initial speedX and speedY

    function enemy.draw()
      enemy.anim:draw(math.floor(enemy.x), math.floor(enemy.y))
        if global.hitBoxes then
	    love.graphics.setColor(60,60,60,150)
        love.graphics.rectangle("line",enemy.x + enemy.hitBox.X1, enemy.y + enemy.hitBox.Y1, enemy.hitBox.X2 - enemy.hitBox.X1,enemy.hitBox.Y2 - enemy.hitBox.Y1)
        love.graphics.setColor(35,225,20,150)
		love.graphics.rectangle("fill",enemy.x + enemy.hitBox.X1, enemy.y + enemy.hitBox.Y1, enemy.hitBox.X2 - enemy.hitBox.X2, enemy.hitBox.Y2 - enemy.hitBox.Y1)
        love.graphics.setColor(255,255,255,255)
      end
    end
	
    if name == "greenBlob" then enemy.anim = newAnimation(imageBlobGreen, 32, 32, 0.2, 0)
    else enemy.anim = newAnimation(imageBlobBlue, 32, 32, 0.2, 0) end
  
  elseif name == "greenBlobShot" then
    enemy.hitBox = {
	  X1 = 2,
	  X2 = 12,
	  Y1 = 2,
	  Y2 = 12
	  }    
    enemy.touchDamage = 0.5
    enemy.damageType = "poison"
	  -- Have the mob fire in the direction of the character, +/- 0.4 radians
	  local angle = math.atan2(Char.tileY - enemy.tileY, Char.tileX - enemy.tileX) + (0.8*(math.random()-0.5))
    enemy.speedX = 6*math.cos(angle)
    enemy.speedY = 6*math.sin(angle)
	
	  function enemy.hitsWall()
	    enemy.dead = true
	    return 
	  end 
	
	  function enemy.draw()
      love.graphics.draw(imageBlobShotGreen, enemy.x, enemy.y)
      if global.hitBoxes then
        love.graphics.setColor(60,60,60,150)
        love.graphics.rectangle("line",enemy.x + enemy.hitBox.X1, enemy.y + enemy.hitBox.Y1, enemy.hitBox.X2 - enemy.hitBox.X1,enemy.hitBox.Y2 - enemy.hitBox.Y1)
	      love.graphics.setColor(225,20,20,150)
		    love.graphics.rectangle("fill",enemy.x + enemy.hitBox.X1, enemy.y + enemy.hitBox.Y1, enemy.hitBox.X2 - enemy.hitBox.X2, enemy.hitBox.Y2 - enemy.hitBox.Y1)
        love.graphics.setColor(255,255,255,255)
      end
    end
  
  elseif name == "characterArrow" then
    enemy.isEnemy = false
    enemy.touchDamage = 0.5
    enemy.damageType = "physical"
    local mouseX, mouseY = love.mouse.getPosition()
    enemy.angle = math.atan2(mouseY/global.scale - global.ty - Char.y - Char.height/2, mouseX/global.scale - global.tx - Char.x - Char.width/2) 

    enemy.speedX = 11*math.cos(enemy.angle)
    enemy.speedY = 11*math.sin(enemy.angle)
    enemy.tileX = enemy.tileX + (enemy.speedX * 0.08)
    enemy.tileY = enemy.tileY + (enemy.speedY * 0.08)
	
    function enemy.hitsWall()
      enemy.dead = true
      return 
    end 
	
    function enemy.draw()
      --love.graphics.drawq(imageCharacterArrow, imageCharacterArrowQuad, enemy.x, enemy.y, enemy.angle, 1, 1, enemy.width/2, enemy.height/2)
	  love.graphics.drawq(imageCharacterArrow, imageCharacterArrowQuad, enemy.x, enemy.y, enemy.angle, 1, 1, (enemy.width)/2, 6)
      if global.hitBoxes then
        love.graphics.setColor(200,60,60,150)
        love.graphics.rectangle("fill",enemy.x - 3, enemy.y - 3, 6, 6)
        love.graphics.setColor(255,255,255,255)
      end
    end
	
  elseif name == "blobPuddleBlue" then
    enemy.speedX = 0
    enemy.speedY = 0
    enemy.touchSlow = -3

    function enemy.draw()
      love.graphics.draw(imageBlobPuddleBlue, enemy.x, enemy.y, 0, 1, 1)
      if global.hitBoxes then
        love.graphics.setColor(200,60,60,150)
        love.graphics.rectangle("fill",enemy.x - 3, enemy.y - 3, 6, 6)
        love.graphics.setColor(255,255,255,255)
      end
    end

  elseif name == "skeletonWarrior" then
    enemy.touchDamage = 1.5
    enemy.damageType = "physical"
    enemy.normalQuads = {		-- The frames of the image
    down  = love.graphics.newQuad(0,0,34,32,150,32),
    up    = love.graphics.newQuad(34,0,34,32,150,32),
    right = love.graphics.newQuad(68,0,42,32,150,32),
    left  = love.graphics.newQuad(110,0,42,32,150,32),
    }
    
    function enemy.personalUpdate()
      if love.timer.getTime() > enemy.timeLastAttack + 4 and math.abs(enemy.y - Char.y) < 32 and math.abs(enemy.x - Char.x) < 64 then        
        enemy.timeLastAttack = love.timer.getTime()
        if Char.x - enemy.x > 0 then enemy.anim = newAnimation(animSkeletonAttackRight, 66, 44, 0.1, 0) 
        else enemy.anim = newAnimation(animSkeletonAttackLeft, 66, 44, 0.1, 0) end
        enemy.anim:setMode("once")
        enemy.speedX = enemy.speedX / 1000
        enemy.speedY = enemy.speedY / 1000
        TEsound.play(soundEffect["enemyPreSwordAttack"], "EnemyEffect")
        enemy.soundStarted = false
      end
      
      local tempAngle = math.atan2(enemy.speedY, enemy.speedX)
      local cosAngle = math.cos(tempAngle)
      local sinAngle = math.sin(tempAngle)
      enemy.facing = cosAngle > 0.707 and "right" or 
                     cosAngle < -0.707 and "left" or
                     sinAngle < -0.707 and "up" or
                     "down"                     
    end
	
    function enemy.hitsWall()
      -- Character moves in a new direction...
      local tempAngle = math.random(4)*math.pi/2
      local tempSpeed = 1.3 + math.random(5) / 10
      enemy.speedX = tempSpeed*math.cos(tempAngle)
      enemy.speedY = tempSpeed*math.sin(tempAngle)
    end
    enemy.hitsWall() -- sets initial speedX and speedY
    
    function enemy.draw()
      if enemy.anim then
        if enemy.anim.position > 6 and enemy.soundStarted == false then 
        --if true then 
          TEsound.play(soundEffect["enemySwordAttack"], "EnemeyEffect") 
          enemy.soundStarted = true
        end
        if enemy.anim.playing == false then 
	        enemy.anim = nil
          local tempAngle = math.atan2(enemy.speedY, enemy.speedX)
          enemy.speedX = 1.5*math.cos(tempAngle)
          enemy.speedY = 1.5*math.sin(tempAngle)
        else
          enemy.anim:draw(math.floor(enemy.x), math.floor(enemy.y))
        end
      end
      
      if not enemy.anim then
        love.graphics.drawq(imageSkeletonWarrior, enemy.normalQuads[enemy.facing], enemy.x, enemy.y)
      end
    end
    
  elseif name == "critterSnake" then
    enemy.anim = newAnimation(animCritterSnake, 10, 30, 0.3, 0)
    
    function enemy.personalUpdate(dt)
      local angle = math.atan2(enemy.speedY, enemy.speedX)
      angle = angle + 6*dt*(math.random() - 0.5)
      local speed = math.random()
      enemy.speedX = speed*math.cos(angle)
      enemy.speedY = speed*math.sin(angle)
    end
    
    function enemy.hitsWall()
      -- Character moves in a new direction...
      local temp = math.random() * 2 * math.pi
      --enemy.speedX = 0.6*math.cos(temp)
      --enemy.speedY = 0.6*math.sin(temp)
      enemy.speedX = 0
      enemy.speedY = 0.001
    end 
    enemy.hitsWall() -- sets initial speedX and speedY
    
    function enemy.draw()
      local angle = math.atan2(enemy.speedY, enemy.speedX) - math.pi/2
      enemy.anim:draw(enemy.x + enemy.anim.fw/2, enemy.y + enemy.anim.fh/2, angle, 0.8, 0.8, enemy.anim.fw/2, enemy.anim.fh/2)
    end

  elseif name == "motherAnaconda" then    
    enemy.dead = true
    local leader = mobHandler.addMob(map, currentMap, "motherAnacondaHead", enemy.tileX, enemy.tileY)
    leader.drawScale= 1.0
    
    for i=1,25 do
      local follower = mobHandler.addMob(map, currentMap, "motherAnacondaBody", enemy.tileX, enemy.tileY)
      follower.drawScale = 0.9 + 0.5*math.sin(i * math.pi / 25)
	  if i >= 20 then
	    follower.drawThickness = 0.7*math.cos((i-20)*math.pi/10)*math.cos((i-20) * math.pi/10) + 0.4
	  else
	    follower.drawThickness = 1.0
      end
      follower.followTarget = leader
      leader = follower
    end
          
  elseif name == "motherAnacondaBody" then
    enemy.isEnemy = true
    enemy.touchDamage = 1.0
    enemy.damageType = "physical"
    enemy.speedX, enemy.speedY = 0,0

    enemy.particleSystem = love.graphics.newParticleSystem(cloudImage, 50)
    enemy.particleSystem:setEmissionRate(20)
    enemy.particleSystem:setSpeed(300, 400)
    enemy.particleSystem:setGravity(0)
    enemy.particleSystem:setSizes(0.5, 0.5)
    enemy.particleSystem:setColors(0, 255, 0, 255, 60, 60, 60, 25)
    enemy.particleSystem:setPosition(16, 16)
    enemy.particleSystem:setLifetime(1)
    enemy.particleSystem:setParticleLife(1)
    enemy.particleSystem:setDirection(0)
    enemy.particleSystem:setSpread(250)
    enemy.particleSystem:setRadialAcceleration(-2000)
    enemy.particleSystem:setTangentialAcceleration(500)
    enemy.particleSystem:start()

    function enemy.draw()
      local angle
      if enemy.followTarget then
        angle = math.atan2(enemy.followTarget.tileY - enemy.tileY, enemy.followTarget.tileX - enemy.tileX) + math.pi/2
      else
        angle = 0
      end
    
      love.graphics.draw(imageAnacondaBody, enemy.x + enemy.width/2, enemy.y + enemy.width/2, angle, enemy.drawScale*enemy.drawThickness, enemy.drawScale, enemy.width/2, enemy.height/2)
      if enemy.particleSystem then 
        love.graphics.draw(enemy.particleSystem, math.floor(enemy.x), math.floor(enemy.y)) 
      end
    end
    function enemy.hitsWall()
      -- do nothing
    end

  elseif name == "motherAnacondaHead" then
    enemy.isEnemy = true
    enemy.isSeeker = true
    enemy.touchDamage = 1.0
    enemy.damageType = "physical"
    
    function enemy.hitsWall()
      -- Character moves in a new direction...
      local temp = math.random() * 2 * math.pi
      enemy.speedX = 4.5*math.cos(temp)
      enemy.speedY = 4.5*math.sin(temp)
    end 
    enemy.hitsWall() -- sets initial speedX and speedY

    function enemy.draw()
      local angle = math.atan2(enemy.speedY, enemy.speedX) - math.pi/2
      love.graphics.draw(imageAnacondaHead, enemy.x + enemy.width/2, enemy.y + enemy.width/2, angle, enemy.drawScale, enemy.drawScale, enemy.width/2, enemy.height/2)
    end
  
  else
    -- TODO: Set up some default condition in case an undefined mob is created
  end
end

function mobHandler.checkCollision(a, b)
  local ax2 = a.x + a.width
  local ay2 = a.y + a.height
  local bx2 = b.x + b.width
  local by2 = b.y + b.height

  return a.x < bx2 and ax2 > b.x and a.y < by2 and ay2 > b.y
end

return mobHandler
