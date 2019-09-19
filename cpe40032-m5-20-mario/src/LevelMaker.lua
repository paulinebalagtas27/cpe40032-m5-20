--[[
    CMPE40032
    Super Mario Bros. Remake

    -- LevelMaker Class --

]]

LevelMaker = Class{}

function LevelMaker.generate(width, height)
    local tiles = {}
    local entities = {}
    local objects = {}

    local tileID = TILE_ID_GROUND

    -- whether we should draw our tiles with toppers
    local topper = true
    local tileset = math.random(20)
    local topperset = math.random(20)
    -- declaration for spwning of key and lock 
    keyAndLockColor = math.random(1,4)
    local spawnKey = 4
    local spawnLock = width - 8
    keyTaken = false
    

    -- insert blank tables into tiles for later access
    for x = 1, height do
        table.insert(tiles, {})
    end

    -- column by column generation instead of row; sometimes better for platformers
    for x = 1, width do
        local tileID = TILE_ID_EMPTY

        -- lay out the empty space
        for y = 1, 6 do
            table.insert(tiles[y],
                Tile(x, y, tileID, nil, tileset, topperset))
        end

        -- chance to just be emptiness
        if math.random(7) == 1 and x > 5 and x~= lockPosition and x < width - 3 then
            for y = 7, height do
                table.insert(tiles[y],
                    Tile(x, y, tileID, nil, tileset, topperset))
            end
        else
            tileID = TILE_ID_GROUND

            local blockHeight = 4

            for y = 7, height do
                table.insert(tiles[y],
                    Tile(x, y, tileID, y == 7 and topper or nil, tileset, topperset))
            end

            -- chance to generate a pillar
            if math.random(8) == 1 and x  > 5 and x ~= lockPosition and x < width - 3 then
                blockHeight = 2

                -- chance to generate bush on pillar
                if math.random(8) == 1 then
                    table.insert(objects,
                        GameObject {
                            texture = 'bushes',
                            x = (x - 1) * TILE_SIZE,
                            y = (4 - 1) * TILE_SIZE,
                            width = 16,
                            height = 16,

                            -- select random frame from bush_ids whitelist, then random row for variance
                            frame = BUSH_IDS[math.random(#BUSH_IDS)] + (math.random(4) - 1) * 7
                        }
                    )
                end

                -- pillar tiles
                tiles[5][x] = Tile(x, 5, tileID, topper, tileset, topperset)
                tiles[6][x] = Tile(x, 6, tileID, nil, tileset, topperset)
                tiles[7][x].topper = nil

            -- chance to generate bushes
            elseif math.random(8) == 1 then
                table.insert(objects,
                    GameObject {
                        texture = 'bushes',
                        x = (x - 1) * TILE_SIZE,
                        y = (6 - 1) * TILE_SIZE,
                        width = 16,
                        height = 16,
                        frame = BUSH_IDS[math.random(#BUSH_IDS)] + (math.random(4) - 1) * 7,
                        collidable = false
                    }
                )
            end

            -- chance to spawn a block
            if math.random(10) == 1 and x~= keyPosition and x~= lockPosition and x < width - 3 then
                table.insert(objects,

                    -- jump block
                    GameObject {
                        texture = 'jump-blocks',
                        x = (x - 1) * TILE_SIZE,
                        y = (blockHeight - 1) * TILE_SIZE,
                        width = 16,
                        height = 16,

                        -- make it a random variant
                        frame = math.random(#JUMP_BLOCKS),
                        collidable = true,
                        hit = false,
                        solid = true,

                        -- collision function takes itself
                        onCollide = function(obj)

                            -- spawn a gem if we haven't already hit the block
                            if not obj.hit then

                                -- chance to spawn gem is guaranteed
                                    local gem = GameObject {
                                        texture = 'gems',
                                        x = (x - 1) * TILE_SIZE,
                                        y = (blockHeight - 1) * TILE_SIZE - 4,
                                        width = 16,
                                        height = 16,
                                        frame = math.random(#GEMS),
                                        collidable = true,
                                        consumable = true,
                                        solid = false,

                                        -- gem has its own function to add to the player's score
                                        onConsume = function(player, object)
                                            gSounds['pickup']:play()
                                            player.score = player.score + 100
                                        end
                                    }

                                    -- make the gem move up from the block and play a sound
                                    Timer.tween(0.1, {
                                        [gem] = {y = (blockHeight - 2) * TILE_SIZE}
                                    })
                                    gSounds['powerup-reveal']:play()

                                    table.insert(objects, gem)

                                obj.hit = true
                            end

                            gSounds['empty-block']:play()
                        end
                    }
                )
            end
            --to spawn a key
            if x == spawnKey then
                table.insert(objects, GameObject {
                    texture = 'keys-and-locks',
                    x = (x - 1) * TILE_SIZE,
                    y = (blockHeight - 1) * TILE_SIZE,
                    width = 16,
                    height = 16,
            
                    --random key  color
                    frame = keyAndLockColor,
                    collidable = true,
                    consumable = true,
                    hit = false,
                    solid = false,
            
                    --key obtain outcome
                    onConsume = function(player, object)
                        gSounds['powerup-reveal']:play()
                        player.keyTaken = true
                        keyTaken = true
                    end
                })
                
    --to spawn lock
         elseif x == spawnLock then
         table.insert(objects, GameObject {
            texture = 'keys-and-locks',
            x = (x - 1) * TILE_SIZE,
            y = (blockHeight - 1) * TILE_SIZE,
            width = 16,
            height = 16,
            
    --random lock color = same with key
            frame = 4 + keyAndLockColor,
            collidable = true,
            hit = false,
            solid = true,

    --unlocked function 
            onCollide = function(obj)           
            gSounds['powerup-reveal']:play()
            for k, object in pairs(objects) do
            if keyTaken and object == obj then
            table.remove(objects, k)
    --spawning a flag
            table.insert(objects, 
            GameObject {
            texture = 'flags',
            x = (x + 6) * TILE_SIZE + 8,
            y = (blockHeight - 1) * TILE_SIZE,
                width = 16,
                height = 16,
    --flag               
            frame = 7,
            collidable = false,
            solid = false,
            onCollide = function()   end,
            onConsume = function()   end
                                })
    --in spawning a pole
            table.insert(objects,
            GameObject {
            texture = 'flag-poles',
            x = (x + 6) * TILE_SIZE,
            y = (blockHeight - 1) * TILE_SIZE,
                width = 14,
                height = 64,
    
    --random pole color
            frame = 2 + keyAndLockColor,
            collidable = false,
            consumable = true,
            hit = false,
            solid = false,
                            
    --collide the pole
            onCollide = function(obj)           
            gSounds['powerup-reveal']:play()  end,
                                    
    --reach the pole 
            onConsume = function(player, object)
            gStateMachine:change('play', {score = player.score, currentLevel = player.currentLevel})  end
             })
    --spawn his Alien Bro
            table.insert(objects, GameObject{
            texture = 'green-alien',
            x = (x + 5) *TILE_SIZE - 10,
            y = (blockHeight + 1) *TILE_SIZE - 5,
                width = 16,
                height = 20,
            frame = 1,
            collidable = false,
            consumable = false,
            hit = false,
            solid = false,


            onCollide = function(obj) end,
            onConsume = function (obj) end 
            })
        end
    end
end,
            onConsume = function(player, object)
            player.keyTaken = false
            keyTaken = false
            end
            })
        end 
    end
end
    local map = TileMap(width, height)
    map.tiles = tiles

    return GameLevel(entities, objects, map)
end




