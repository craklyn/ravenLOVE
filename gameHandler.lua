-- Setup
local loader = require("AdvTiledLoader.Loader")
loader.path = "maps/"
require("AnAL")
local HUD = require("HUD")
local damageHandler = require("damageHandler")
local mobHandler = require("mobHandler")
global.hitBoxes = false

local numGame = require("numGame")
numGame.load()

canvas = love.graphics.newCanvas(3200, 2400)
canvas:setFilter("nearest", "nearest")

local map = {
  TeamScreen  = nil,
  TitleScreen = nil,
}
local teamScreenImage  = love.graphics.newImage("images/layers/team_logo.png")
local titleScreenImage = love.graphics.newImage("images/layers/raven_logo.png")

local musicList = {
  "sounds/music/Lancefield_-_Ethereal(nop_mix).ogg",
  "sounds/music/gurdonark_-_Restless_Sleep.ogg",
  "sounds/music/cdk_-_Look_to_la_Luna_.ogg",
  "sounds/music/Fireproof_Babies_-_Swim_below_as_Leviathans.ogg",
}

soundEffect = {
  charSwordAttack = "sounds/effects/LTTP_Sword3.wav",
  charArrowAttack = "sounds/effects/LTTP_Arrow_Shoot.wav",
  enemyPreSwordAttack = "sounds/effects/LTTP_Net.wav",
  enemySwordAttack = "sounds/effects/LTTP_BallAndChain.wav",
}


require "TEsound"
local currentSong = 1
TEsound.playLooping(musicList[currentSong], "music")

local currentMap = "TeamScreen"

local displayTime = 0 
local displayMax = 2

global.damageList = {}

-- This is the char we'll be moving around.
Char = require("char")

function roundNum(val, decimal)
  if (decimal) then
    return math.floor(((val * 10^decimal) + 0.5) / (10^decimal))
  else
    return math.floor(val+0.5)
  end
end

-- Move the char around the tiles
function Char.moveTile(x,y,dt,blockSlide)
  -- Change the facing direction
  if x > 0 then Char.facing = "right"
  elseif x < 0 then Char.facing = "left"
  elseif y > 0 then Char.facing = "down"
  elseif y < 0 then Char.facing = "up" end

  if blockSlide then
    local tempTile = map[currentMap].tl["Affects"].tileData(roundNum(Char.tileX - 1.0, 0), roundNum(Char.tileY - 0.75, 0))
    if tempTile ~= nil and tempTile.properties.pushX then
      x = x + dt * tempTile.properties.pushX
    end
    if tempTile ~= nil and tempTile.properties.pushY then 
      y = y + dt * tempTile.properties.pushY
    end
  end
  
  local tile1, tile2, tile3, tile4
  local slimWidth = 4/32
  local tileX1 = roundNum(Char.tileX - 1.5 + slimWidth + x, 0)
  local tileX2 = roundNum(Char.tileX - 0.5 - slimWidth + x, 0)
  local tileY1 = roundNum(Char.tileY - 1.5 + 3*slimWidth + y, 0)
  local tileY2 = roundNum(Char.tileY - 0.5 - slimWidth + y, 0)
  --local tileX1, tileY1 = roundNum(Char.tileX+x + 4/32,0),                   roundNum(Char.tileY-(Char.height/32)/2+y + 4/32, 0)
  --local tileX2, tileY2 = roundNum(Char.tileX+(Char.width/32)/2+x - 4/32,0), roundNum(Char.tileY+(Char.height/32)/2+y - 4/32, 0)

  -- Grab the tiles
  tile1 = map[currentMap].tl["Ground"].tileData(tileX1, tileY1)
  tile2 = map[currentMap].tl["Ground"].tileData(tileX2, tileY1)
  tile3 = map[currentMap].tl["Ground"].tileData(tileX1, tileY2)
  tile4 = map[currentMap].tl["Ground"].tileData(tileX2, tileY2)
  
  -- Assign damage if the character is on the tile.
  local damageTile = (tile1 ~= nil and tile1.properties.suffer and tile1) or
               (tile2 ~= nil and tile2.properties.suffer and tile2) or
               (tile3 ~= nil and tile3.properties.suffer and tile3) or
               (tile4 ~= nil and tile4.properties.suffer and tile4) or nil

  if damageTile ~= nil and damageTile.properties.suffer then
    local tempDamage = {}
    tempDamage["damageVal"] = damageTile.properties.suffer
    if damageTile.properties.damageType then
      tempDamage["damageType"] = damageTile.properties.damageType
    else
      tempDamage["damageType"] = ""
    end
    table.insert(global.damageList, tempDamage)
  end
  
  -- If the tile is a door, push the char through the door!
  if tile1 ~= nil and tile1.properties.transferX and tile1.properties.transferY then
    Char.tileX = tile1.properties.transferX
    Char.tileY = tile1.properties.transferY
    Char:moveTo((Char.tileX-1)*map[currentMap].tileWidth, (Char.tileY-1)*map[currentMap].tileHeight-40) 
    return
  end
	
  -- If the tile doesn't exist or is an obstacle then exit the function
  if (tile1 == nil or tile1.properties.obstacle) or
     (tile2 == nil or tile2.properties.obstacle) or
     (tile3 == nil or tile3.properties.obstacle) or
     (tile4 == nil or tile4.properties.obstacle) then 
    if math.abs(y) > 0 and  math.abs(x) > 0 then 
      if Char.moveTile(x,0,dt,false) == "fail" then
        Char.moveTile(0,y,dt,false) 
      end
    end
    return "fail"
  end

  -- Otherwise change the char's tile
  Char.tileX =  x + Char.tileX
  Char.tileY =  y + Char.tileY 
  Char:moveTo((Char.tileX-1)*map[currentMap].tileWidth, (Char.tileY-1)*map[currentMap].tileHeight) 
end

-- Draw our char. This function is passed to TileSet.drawAfterTile() which calls it passing the
-- x and y value of the bottom left corner of the tile.
function Char.draw() 
  for i, damageParticleSystem in pairs(damageHandler.damageType) do	
    love.graphics.draw(damageParticleSystem, math.floor(Char.x), math.floor(Char.y))
  end
  
  local tempTileX, tempTileY = math.floor(Char.tileX*32)/32, math.floor(Char.tileY*32)/32

  if Char.anim then
    if Char.anim.playing == false then 
      Char.state = "normal"
	  Char.anim = nil
    else Char.anim:draw(Char.x, Char.y, 0, 1, 1, Char.anim.offsetX, Char.anim.offsetY) end
  end
  
  if not Char.anim then
    love.graphics.drawq(Char.normalImage, Char.normalQuads[Char.facing], Char.x, Char.y)
  end
					    
  love.graphics.setColor(150,50,50,200)
  love.graphics.rectangle("line", Char.tileX*map[currentMap].tileWidth - 2, Char.tileY*map[currentMap].tileWidth - 2, 4, 4)
  love.graphics.setColor(255,255,255,255)
              
  if global.hitBoxes then
    love.graphics.setColor(150,50,50,200)
    --love.graphics.rectangle("line", Char.x , Char.y, Char.width, Char.height)
    love.graphics.rectangle("line", math.floor(Char.x) - 2, math.floor(Char.y) - 2, 4, 4)
    love.graphics.rectangle("line", math.floor(Char.x) + (Char.width) - 2, math.floor(Char.y) + (Char.height) - 2, 4, 4)
    love.graphics.setColor(25,25,25,200)
    --love.graphics.rectangle("fill", Char.x, Char.y, Char.width, Char.height)
    love.graphics.rectangle("fill", math.floor(Char.x) - 2, math.floor(Char.y) - 2, 4, 4)
    love.graphics.rectangle("fill", math.floor(Char.x) + (Char.width) - 2, math.floor(Char.y) + (Char.height) - 2, 4, 4)
    love.graphics.setColor(255,255,255,255)
  end
   
end

-- Our example class
DesertExample = {}

function DesertExample.loadMap(currentMap)
  map[currentMap] = loader.load(currentMap .. ".tmx")
  global.mapStartTime = love.timer.getTime()
end

-- Called from love.keypressed()
function DesertExample.keypressed(k)
  if k == 'g' then
    if map[currentMap].filter == nil then
      map[currentMap].filter = love.graphics.newImage("images/layers/cave_sight.png")
      map[currentMap].cameraScale = 1.6
	else
      map[currentMap].filter = nil
      map[currentMap].cameraScale = 1.0
    end
  elseif k == 'r' then
    if currentMap == "desert" then
      currentMap = "desert2"
    elseif currentMap == "desert2" then
      currentMap = "cave"
    elseif currentMap == "cave" then
      currentMap = "numGame"
      Char.tileX = 3
      Char.tileY = 3
      Char.x = 45
      Char.y = 45
    else
      currentMap = "desert"
    end
    DesertExample.loadMap(currentMap)
	
    tempChar = Char
    Char = map[currentMap].ol["Object1"]:newObject("Char", "Entity",0,0,32,32)
    for k,v in pairs(tempChar) do
      if Char[k] then else
        Char[k] = v
      end
    end
    Char.draw = tempChar.draw

    -- Do this once to make sure the char is drawn correctly.
    Char.moveTile(0,0)
    Char.facing = "down"

    DesertExample.reset()
  elseif k == 'h' then
    global.hitBoxes = not global.hitBoxes
  elseif k == 'k' then
    for k,v in pairs(map[currentMap].ol["Object1"].objects) do
      if v.type == "MobEntity" then 
        map[currentMap].ol["Object1"].objects[k] = nil
      end
	end
  elseif k == 'i' then
    TEsound.stop("music")
    currentSong = currentSong + 1
	  if currentSong > #musicList then currentSong = 0 end
	  if currentSong > 0 then TEsound.playLooping(musicList[currentSong], "music") end
  end
  
end

function DesertExample.mousepressed(x, y, mb)
  if mb == "l" then
    Char.state = "swordAttack"
    Char.anim = Char.attackAnim[Char.facing]
    Char.anim.offsetX = Char.attackImage.offsetX[Char.facing]
    Char.anim.offsetY = Char.attackImage.offsetY[Char.facing]
    Char.anim:setMode("once")
    Char.anim:reset()
    Char.anim:play()
    TEsound.play(soundEffect["charSwordAttack"], "CharEffect")
  end
  
  if currentMap == "numGame" then
    numGame.mousepressed(x, y, mb)
  end
end

-- Resets the example
function DesertExample.reset()
  global.tx = -5
  global.ty = -434
  Char.tileX = 3
  Char.tileY = 3
  Char.moveTile(0,0)
  Char.facing = "down"
  displayTime = 0
  
  print("Reseting desert example")
  for k,v in pairs(map[currentMap].ol["Object1"].objects) do
    if v.type == "MobEntity" then 
	  print("Setting mob to nil")
          map[currentMap].ol["Object1"].objects[k] = nil
	end
  end
end

-- Update the display time for the character control instructions
function DesertExample.update(dt)
  TEsound.cleanup() 

  local speedBonus = 0
  
  if Char.anim then Char.anim:update(dt) end
  
  -- If map is nil, then we're in some special circumstance that we are handling differently :)  E.g. Title Screen
  if map[currentMap] ~= nil then 
    local tileX = roundNum(Char.tileX - 0.5, 0)
    local tileY = roundNum(Char.tileY - 0.5, 0)
    local tile = map[currentMap].tl["Ground"].tileData(tileX, tileY)
    if tile ~= nil and tile.properties.speed then
      speedBonus = tile.properties.speed
    end
    if love.keyboard.isDown("lshift") then speedBonus = speedBonus + 3 end
  
    speed = Char.speedBase + speedBonus + Char.speedPenalty
   
    displayTime = displayTime + dt

    dx=0
    dy=0
    if love.keyboard.isDown("w") then dy=-1
    elseif love.keyboard.isDown("s") then dy=1 end
    if love.keyboard.isDown("a") then dx=-1
    elseif love.keyboard.isDown("d") then dx=1 end

    if dx~= 0 and dy~=0 then 
      dx = dx/math.sqrt(2)
      dy = dy/math.sqrt(2)
    end
  
    if Char.state ~= "swordAttack" then 
      if (dx ~= 0 or dy ~= 0) then
        if Char.anim ~= Char.moveAnim[Char.facing] then 
          Char.anim = Char.moveAnim[Char.facing] 
          Char.anim.offsetX = Char.moveImage.offsetX[Char.facing]
          Char.anim.offsetY = Char.moveImage.offsetY[Char.facing]
          Char.anim:setMode("loop")
          Char.anim:reset()
          Char.anim:play()
        end
	  else
	    Char.anim = nil
	  end
	end
  
    Char.moveTile(dx*dt*speed,dy*dt*speed, dt, true)

    if love.keyboard.isDown("e") then else DesertExample.centerCamera(dt) end
  
    if love.keyboard.isDown("return") then 
      if currentMap == "desert" then 
        --mobHandler.addMob(map, currentMap, "greenBlob", Char.tileX - 3, Char.tileY - 3) 
        mobHandler.addMob(map, currentMap, "critterSnake", Char.tileX - 3, Char.tileY - 3) 
      elseif currentMap == "desert2" then mobHandler.addMob(map, currentMap, "motherAnaconda", Char.tileX - 3, Char.tileY - 3) 
      elseif currentMap == "cave" then mobHandler.addMob(map, currentMap, "skeletonWarrior", Char.tileX - 3, Char.tileY - 3)  end
    end

    if love.mouse.isDown("r") and love.timer.getTime() > Char.timeLastShot + Char.shotCooldown then 
      TEsound.play(soundEffect["charArrowAttack"], "CharEffect")
      mobHandler.addMob(map, currentMap, "characterArrow", Char.tileX + (Char.width/2)/32, Char.tileY + (Char.height/2)/32) 
      Char.timeLastShot = love.timer.getTime()
    end
  
    -- reset figures for next go-round
  	Char.speedPenalty = 0
  
    for k,v in pairs(map[currentMap].ol["Object1"].objects) do
      if v.type == "MobEntity" then 
        if v.dead == true then
          table.remove(map[currentMap].ol["Object1"].objects,k)
        else
          v.update(dt)
          if v.dead == true then
            table.remove(map[currentMap].ol["Object1"].objects,k)
          end
        end
      end
    end
       
    damageHandler.update(dt)  
    -- reset figures for next go-round
    global.damageList = {}

  end
  
  if mapName == "numGame" then
    numGame.update()
  end
  
end

function DesertExample.centerCamera(dt)
  global.tx = math.floor(-Char.tileX * 32 + 400/global.scale + Char.width/2)
  global.ty = math.floor(-Char.tileY * 32 + 300/global.scale + Char.height/2)
  if map[currentMap].cameraScale then 
    map[currentMap].cameraScale = 0.5 + Char.tileX/16
    global.scale = (global.scale*1.5 + map[currentMap].cameraScale*dt) / (dt + 1.5) 
  end
  
  local mapWidth = map[currentMap].width*map[currentMap].tileWidth
  local mapHeight = map[currentMap].height*map[currentMap].tileHeight
  if -global.tx > mapWidth -  800/global.scale then global.tx = -mapWidth  + 800/global.scale
  elseif global.tx > 0 then global.tx = 0 end
  if -global.ty > mapHeight - 600/global.scale then global.ty = -mapHeight + 600/global.scale
  elseif global.ty > 0 then global.ty = 0 end
end
  

-- Called from love.draw()
function DesertExample.draw()

  -- Set sprite batches if they are different than the settings.
  map.useSpriteBatch = global.useBatch
  
  if map[currentMap] == nil then
    if currentMap == "TeamScreen" then 
      love.graphics.draw(teamScreenImage)
      if love.timer.getTime() > global.mapStartTime + 3 then
        love.graphics.setColor(0,0,0, 250*(love.timer.getTime() - global.mapStartTime - 3)/2)
        love.graphics.rectangle("fill",0,0,800,600)
        if love.timer.getTime() > global.mapStartTime + 5 then 
          currentMap = "TitleScreen" 
          global.mapStartTime = love.timer.getTime()
        end
      end
	  end
    if currentMap == "TitleScreen" then 
      love.graphics.draw(titleScreenImage) 
      if love.timer.getTime() < global.mapStartTime + 1 then
        love.graphics.setColor(0,0,0, 250*(global.mapStartTime + 1 - love.timer.getTime())/1)
        love.graphics.rectangle("fill",0,0,800,600)
      elseif love.timer.getTime() > global.mapStartTime + 4 then
        love.graphics.setColor(0,0,0, 255*(love.timer.getTime() - global.mapStartTime - 4)/1)
        love.graphics.rectangle("fill",0,0, 800, 600)
        love.graphics.setColor(255,255,255,255)
      end  
      if love.timer.getTime() > global.mapStartTime + 5 then 
        currentMap = "desert"
        DesertExample.loadMap(currentMap)
		      
        tempChar = Char
        Char = map[currentMap].ol["Object1"]:newObject("Char", "Entity",0,0,32,32)
        for k,v in pairs(tempChar) do
          if Char[k] then else
            Char[k] = v
          end
        end
        Char.draw = tempChar.draw
 
	    -- Do this once to make sure the char is drawn correctly.
        Char.moveTile(0,0)
        Char.facing = "down"

        DesertExample.reset()
      end
    end
  
    if map[currentMap] == nil then return end
  end
  
  love.graphics.setCanvas(canvas)

  local ftx, fty = math.floor(global.tx), math.floor(global.ty)

  -- Limit the draw range 
  if global.limitDrawing then 
    map[currentMap]:autoDrawRange(ftx, fty, global.scale, -100) 
  else 
    map[currentMap]:autoDrawRange(ftx, fty, global.scale, 50) 
  end
	
  love.graphics.push()
  love.graphics.translate(ftx, fty)
  
  -- Queue our char to be drawn after the tile he's on and then draw the map.
  local maxDraw = global.benchmark and 20 or 1
  for i=1,maxDraw do 
    map[currentMap]:draw() 
  end
 	love.graphics.rectangle("line", map[currentMap]:getDrawRange())
  
  love.graphics.pop()

  love.graphics.setCanvas()

  -- Scale and translate the game screen for map drawing
  local ftx, fty = math.floor(global.tx), math.floor(global.ty)
  love.graphics.push()
  love.graphics.scale(global.scale)
--  love.graphics.translate(ftx, fty)

  love.graphics.draw(canvas)
  canvas:clear()
		
  -- Reset the scale and translation.
  love.graphics.pop()

  if love.timer.getTime() < global.mapStartTime + 2 then
    love.graphics.setColor(0,0,0, 255*(global.mapStartTime + 2 - love.timer.getTime())/2)
    love.graphics.rectangle("fill",0,0, 800, 600)
    love.graphics.setColor(255,255,255,255)
  end
  
  if currentMap == "numGame" then
    numGame.draw()
  end
  
  -- Display movement instructions for a second
--  if displayTime < displayMax then
--    love.graphics.setColor(0,0,0,100)
--    love.graphics.rectangle("fill",0,198,love.graphics.getWidth(),17)
--    love.graphics.setColor(255,255,255,255)
--    love.graphics.print("Use WASD to move me!", 330, 200)
--  end
	
  if map[currentMap].filter ~= nil then
    love.graphics.draw(map[currentMap].filter)
  end
	  
  -- HUD display
  damageHandler.draw()
  HUD.draw()
end

return DesertExample
