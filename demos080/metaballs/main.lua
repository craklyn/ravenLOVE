local balls = {
	{400,300}, -- this one will be controlled by the mouse

	{400,300}, -- these will
	{400,300}, -- fly
	{400,300}, -- around

	-- the rest just sits there
	{50,50}, {50,550}, {750,50}, {750,550}
}

function love.load()
	assert(love.graphics.isSupported('pixeleffect'), 'Pixel effects are not supported on your hardware. Sorry about that.')

	-- yep, Lua can be used for meta-programming an effect :D
	local loop_unroll = {}
	for i = 1,#balls do
		loop_unroll[i] = ("p += metaball(pc - balls[%d]);"):format(i-1)
	end
	local src = [[
		extern vec2[%d] balls;
		extern vec4 palette;

		float metaball(vec2 x)
		{
			x /= 30.0;
			return 1.0 / (dot(x, x) + .00001) * 3.0;
			//return exp(-dot(x,x)/6000.0) * 3.0;
		}

		number _hue(number s, number t, number h)
		{
			h = mod(h, 1.);
			number six_h = 6.0 * h;
			if (six_h < 1.) return (t-s) * six_h + s;
			if (six_h < 3.) return t;
			if (six_h < 4.) return (t-s) * (4.-six_h) + s;
			return s;
		}

		vec4 hsl_to_rgb(vec4 c)
		{
			if (c.y == 0)
				return vec4(vec3(c.z), c.a);

			number t = (c.z < .5) ? c.y*c.z + c.z : -c.y*c.z + (c.y+c.z);
			number s = 2.0 * c.z - t;
			#define Q 1.0/3.0
			return vec4(_hue(s,t,c.x+Q), _hue(s,t,c.x), _hue(s,t,c.x-Q), c.w);
		}

		vec4 effect(vec4 color, Image tex, vec2 tc, vec2 pc)
		{
			float p = 0.0;
			%s

			color = .5 * (p + ceil(p*5.)/5.) * hsl_to_rgb(palette);
			return color;
		}
	]]
	src = src:format(#balls, table.concat(loop_unroll))
	--print(src)

	effect = love.graphics.newPixelEffect(src)
	effect:send('balls', unpack(balls))
	effect:send('palette', {0, 0, 0, 10})
end

function love.draw()
	love.graphics.setPixelEffect(effect)
	love.graphics.rectangle('fill', 0,0,love.graphics.getWidth(), love.graphics.getHeight())
end

t = 0
function love.update(dt)
	t = t + dt

	balls[1] = {
		love.mouse.getX(),
		-- y coordinate is flipped in pixel effects
		love.graphics.getHeight() - love.mouse.getY()
	}
	balls[2] = {
		math.sin(2*t) * 120 + love.graphics.getWidth()/2,
		math.cos(t)   * 120 + love.graphics.getHeight()/2
	}
	balls[3] = {
		math.sin(t)   * 120 + love.graphics.getWidth()/2,
		math.cos(2*t) * 120 + love.graphics.getHeight()/2
	}
	balls[4] = {
		math.sin(t) * (110 + math.sin(.01*t) * 110)  + love.graphics.getWidth()/2,
		math.cos(t) * (110 + math.sin(.01*t) * 110)  + love.graphics.getHeight()/2,
	}

	effect:send('balls', unpack(balls))
	effect:send('palette', {t/10,.5 + .5*math.cos(t/5), .5, 10.0})
end
