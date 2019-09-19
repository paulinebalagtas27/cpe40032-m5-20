--[[
    CMPE40032
    Super Mario Bros. Remake

    -- StartState Class --

]]

StartState = Class{__includes = BaseState}

function StartState:init()
    self.map = LevelMaker.generate(WIDTH, 10)
    self.background = math.random(3)
end

function StartState:update(dt)
    if love.keyboard.wasPressed('enter') or love.keyboard.wasPressed('return') then
        gStateMachine:change('play')
    end
end

function StartState:render()
    love.graphics.draw(gTextures['backgrounds'], gFrames['backgrounds'][self.background], 0, 0)
    love.graphics.draw(gTextures['backgrounds'], gFrames['backgrounds'][self.background], 0,
        gTextures['backgrounds']:getHeight() / 3 * 2, 0, 1, -1)
    self.map:render()

    love.graphics.setFont(gFonts['title'])
    love.graphics.setColor(0, 51, 25, 255)
    love.graphics.printf(' Meeting Alien Bros', 1, VIRTUAL_HEIGHT / 2 - 40 + 2, VIRTUAL_WIDTH, 'center')
    love.graphics.setColor(0, 204, 102, 255)
    love.graphics.printf(' Meeting Alien Bros', 0, VIRTUAL_HEIGHT / 2 - 40, VIRTUAL_WIDTH, 'center')

    love.graphics.setFont(gFonts['medium'])
    love.graphics.setColor(25, 0, 51, 255)
    love.graphics.printf('Press Enter', 1, VIRTUAL_HEIGHT / 2 + 18, VIRTUAL_WIDTH, 'center')
    love.graphics.setColor(102, 0, 204, 255)
    love.graphics.printf('Press Enter', 0, VIRTUAL_HEIGHT / 2 + 16, VIRTUAL_WIDTH, 'center')
end