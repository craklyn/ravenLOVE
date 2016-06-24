function love.load()
    -- our tiles
    tile = {}
    for i=0,3 do -- change 3 to the number of tile images minus 1.
        tile[i] = love.graphics.newImage( "tile"..i..".png" )
    end
    
    -- the map (random junk + copy and paste)
    map={
    { 3, 3, 3, 3, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3, 0, 0, 0, 0}, 
    { 3, 1, 0, 0, 2, 2, 2, 0, 3, 0, 3, 0, 1, 1, 1, 0, 0, 3, 0, 0, 0},
    { 3, 1, 0, 0, 2, 0, 2, 0, 3, 0, 3, 0, 1, 0, 0, 0, 0, 0, 3, 0, 0},
    { 3, 1, 1, 0, 2, 2, 2, 0, 0, 3, 0, 0, 1, 1, 0, 0, 0, 0, 0, 3, 0},
    { 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 3},
    { 0, 1, 0, 1, 1, 1, 0, 0, 0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 0, 0, 2},
    { 0, 1, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
    { 0, 1, 0, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
    { 0, 1, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
    { 0, 1, 0, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
    { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
    { 0, 2, 2, 2, 0, 3, 3, 3, 0, 1, 1, 1, 0, 2, 0, 0, 0, 0, 0, 0, 0},
    { 0, 2, 0, 0, 0, 3, 0, 3, 0, 1, 0, 1, 0, 2, 0, 0, 0, 0, 0, 0, 1},
    { 0, 2, 0, 0, 0, 3, 0, 3, 0, 1, 0, 1, 0, 2, 0, 0, 0, 0, 0, 0, 0},
    { 0, 2, 2, 2, 0, 3, 3, 3, 0, 1, 1, 1, 0, 2, 2, 2, 0, 0, 0, 0, 0},
    { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
    { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
    { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
    { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
    { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
    { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}, 
    { 0, 1, 0, 0, 2, 2, 2, 0, 3, 0, 3, 0, 1, 1, 1, 0, 0, 0, 0, 0, 0},
    { 0, 1, 0, 0, 2, 0, 2, 0, 3, 0, 3, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0},
    { 0, 1, 1, 0, 2, 2, 2, 0, 0, 3, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0},
    { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 3},
    { 0, 1, 0, 1, 1, 1, 0, 0, 0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 0, 0, 0},
    { 0, 1, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
    { 0, 1, 0, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
    { 0, 1, 0, 0, 0, 1, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
    }
        
    -- map variables
    map_w = #map[1] -- Obtains the width of the first row of the map
    map_h = #map -- Obtains the height of the map
    map_x = 0
    map_y = 0
    map_display_buffer = 2 -- We have to buffer one tile before and behind our viewpoint.
                           -- Otherwise, the tiles will just pop into view, and we don't want that.
    map_display_w = 20
    map_display_h = 15
    tile_w = 16
    tile_h = 16
end
    
function draw_map()
    offset_x = map_x % tile_w
    offset_y = map_y % tile_h
    firstTile_x = math.floor(map_x / tile_w)
    firstTile_y = math.floor(map_y / tile_h)
    
    for y=1, (map_display_h + map_display_buffer) do
        for x=1, (map_display_w + map_display_buffer) do
            -- Note that this condition block allows us to go beyond the edge of the map.
            if y+firstTile_y >= 1 and y+firstTile_y <= map_h
                and x+firstTile_x >= 1 and x+firstTile_x <= map_w
            then
                love.graphics.draw(
                    tile[map[y+firstTile_y][x+firstTile_x]], 
                    (x*tile_w) - offset_x - tile_w/2, 
                    (y*tile_h) - offset_y - tile_h/2)
            end
        end
    end
end

function love.update( dt )
    -- get input
    if love.keyboard.isDown( "up" ) then
        map_y = map_y-2
    end
    if love.keyboard.isDown( "down" ) then
        map_y = map_y+2
    end

    if love.keyboard.isDown( "left" ) then
        map_x = map_x -2
    end
    if love.keyboard.isDown( "right" ) then
        map_x = map_x+2
    end
    if love.keyboard.isDown( "escape" ) then
        love.event.push( "q" )
    end

    -- check boundaries. remove this section if you don't wish to be constrained to the map.
    if map_x < 0 then
        map_x = 0
    end

    if map_y < 0 then
        map_y = 0
    end 
 
    if map_x > map_w * tile_w - map_display_w * tile_w then
        map_x = map_w * tile_w - map_display_w * tile_w
    end
 
    if map_y > map_h * tile_h - map_display_h * tile_h then
        map_y = map_h * tile_h - map_display_h * tile_h
    end
end

function love.draw()
    draw_map()
end


