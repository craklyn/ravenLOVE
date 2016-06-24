
part1 = love.graphics.newImage("demos080/particles/part1.png");

local damageHandler = {}

damageHandler.damageType = {
  poison = love.graphics.newParticleSystem(part1, 1000),
  fire   = love.graphics.newParticleSystem(part1, 1000),
  physical = love.graphics.newParticleSystem(part1, 1000)
}


damageHandler.damageType["poison"]:setEmissionRate(100)
damageHandler.damageType["poison"]:setSpeed(300, 400)
damageHandler.damageType["poison"]:setGravity(0)
damageHandler.damageType["poison"]:setSizes(0.5, 0.5)
damageHandler.damageType["poison"]:setColors(0, 255, 0, 255, 60, 60, 60, 25)
damageHandler.damageType["poison"]:setPosition(16, 16)
damageHandler.damageType["poison"]:setLifetime(1)
damageHandler.damageType["poison"]:setParticleLife(1)
damageHandler.damageType["poison"]:setDirection(0)
damageHandler.damageType["poison"]:setSpread(250)
damageHandler.damageType["poison"]:setRadialAcceleration(-2000)
damageHandler.damageType["poison"]:setTangentialAcceleration(500)
damageHandler.damageType["poison"]:stop()

damageHandler.damageType["fire"]:setEmissionRate(100)
damageHandler.damageType["fire"]:setSpeed(300, 400)
damageHandler.damageType["fire"]:setGravity(0)
damageHandler.damageType["fire"]:setSizes(0.5, 1)
damageHandler.damageType["fire"]:setColors(255, 0, 0, 255, 60, 60, 60, 25)
damageHandler.damageType["fire"]:setPosition(16, 16)
damageHandler.damageType["fire"]:setLifetime(1)
damageHandler.damageType["fire"]:setParticleLife(1)
damageHandler.damageType["fire"]:setDirection(0)
damageHandler.damageType["fire"]:setSpread(250)
damageHandler.damageType["fire"]:setRadialAcceleration(-2000)
damageHandler.damageType["fire"]:setTangentialAcceleration(1000)
damageHandler.damageType["fire"]:stop()

function damageHandler.start(damageType) 
  if damageType == "" or damageType == nil then return end
  damageHandler.damageType[damageType]:start()
end

-- Resets the damage output
function damageHandler.reset()
  damageHandler.damageType["poison"]:reset()
  damageHandler.damageType["fire"]:reset()
end

-- Update the display time for the character control instructions
function damageHandler.update(dt)
  for i, damageParticleSystem in pairs(damageHandler.damageType) do	
    damageParticleSystem:update(dt)
  end
  
  local maxDamIndex = 0
  for i,damageItem in pairs(global.damageList) do
    damageHandler.start(damageItem["damageType"])  
	if (damageItem["damageVal"] > 0 and maxDamIndex == 0) or (maxDamIndex > 0 and damageItem["damageVal"] > global.damageList[maxDamIndex]["damageVal"]) then maxDamIndex = i end
  end
  
  realDamage = nil
  if maxDamIndex > 0 then 
    realDamage = global.damageList[maxDamIndex] 
  end
  
  if realDamage then
	if love.timer.getTime() > Char.timeLastHurt + 0.5 then
	  Char.health = math.max(Char.health - realDamage["damageVal"], 0)
	  Char.timeLastHurt = love.timer.getTime()
	end
  elseif love.timer.getTime() > Char.timeLastRegen + 3.5 then
    Char.health = math.min(Char.health + 0.5, Char.maxHealth)
	Char.timeLastRegen = Char.timeLastRegen + 3.5
  end
  
end

function damageHandler.draw(dt)
  if realDamage then
    love.graphics.setColor(0,0,0,100)
    love.graphics.rectangle("fill",0,198,love.graphics.getWidth(),17)
    love.graphics.setColor(255,255,255,255)
    love.graphics.print("You take " .. realDamage["damageVal"] .. " " .. realDamage["damageType"] .. " damage!", 330, 200)
  end
end

return damageHandler
