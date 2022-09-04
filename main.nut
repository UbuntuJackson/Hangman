setFPS(60)
setResolution(400, 240)
setWindowTitle("Hangman")

::sprCursor <- newSprite("res/cursor.png", 8, 8, 0, 0, 0, 0)
::sprHangman <- newSprite("res/hangedman2-Sheet.png", 80, 80, 0, 0, 0, 0)
::sprFont <- newSprite("res/font.png", 6, 8, 0, 0, 0, 0)
::font <- newFont(sprFont, 0, 0, true, 0)
::sprButton <- newSprite("res/menu_hopefully.png", 16, 16, 0, 0, 0, 0)
::fontWidth <- 6
::Quit <- false



::Game <- class{
    timers = 0
    timer_p = null
    buttons = []
    hanged = 0
    word = []
    revealed = ""
    words = []
    constructor(){
        timers = {
        }
        timer_p = null
        buttons = []
        hanged = 0
        words = [
            "HANGMAN", "POTATO", "CAR", "WORM", "CROSS", "COMPUTER", "SCRIBBLE", "KART", "SUPER",
            "DEFINITELY", "COMMENT", "ROPE", "WORK", "SABER", "MARK", "DARK", "CLUSTER", "EAR", "PORK"
        ]
        word = words[randInt(words.len()-1)]
        revealed = ""
        for(local i = 0; i < 26; i++)
        {
            buttons.push(
                {
                    letter = (65 + i).tochar()
                    x = screenW()/2 - (16*6.5) + (i%13) * 16
                    y = 200 + floor(i/13) * 16
                    r = 8
                }
            )
        }

        for(local i = 0; i < word.len(); i++){ revealed += "?" }

    }

    function createTimer(_name, _frames)
    {
        if(!timers.rawin(_name)) timers[_name] <- Timer(_frames)
    }

    function updatebuttons()
    {
        foreach(a, i in buttons)
        {
            drawText(font, i.x, i.y, i.letter)
            if(distance2(mouseX(), mouseY(), i.x, i.y) < i.r)
            {
                if(mousePress(0) && hanged < 4 && findChar('?'.tochar(), revealed))
                {
                    if(findChar(i.letter, word)) foreach(j in findChar(i.letter, word)) revealed = replaceChar(j, i.letter, revealed)
                    else hanged += 1
                    buttons.remove(a)
                }
            }
        }
    }

    function otherGameEvents()
    {
        if(hanged == 4)
        {
            createTimer("display_loosing_title", 300)
            if(!timers.display_loosing_title.wait()) game = Game()
            else
            {
                revealed = word
                drawText(font, screenW()/2 - 9 * fontWidth / 2, screenH()/4 - 4, "You lost!")
            }

        }
        else if(!findChar('?'.tochar(), revealed))
        {
            if(!timers.rawin("display_winning_title")) timers.display_winning_title <- Timer(300)
            if(!timers.display_winning_title.wait()) game = Game()
            else drawText(font, screenW()/2 - 8 * fontWidth / 2, screenH()/4 - 4, "You won!")
        }
    }

}

::Timer <- class
{
    timer = 0
    times_up = false
    constructor(_timer)
    {
        timer = _timer
    }
    function wait()
    {
        if(timer > -1) timer--
        if(timer <= 0) return false
        else
        {
            times_up = true
            return true
        }
    }
}

function drawTextbox(_image, x, y, w, h)
{
    //Top
    drawSprite(_image, 0, x, y)
    for(local i = 1; i < w/16 - 1; i++)
    {
        drawSprite(_image, 1, x + 16*i, y)
    }
    drawSprite(_image, 2, x+w-16, y)
    //middle
    for(local i = 1; i < h/16 - 1; i++)
    {
        drawSprite(_image, 3, x, y + 16*i)
        for(local j = 1; j < w/16-1; j++)
        {
            drawSprite(_image, 4, x+j*16, y+16*i)
        }
        drawSprite(_image, 5, x+w-16, y + 16*i)
    }
    //Bottom
    drawSprite(_image, 6, x, y+h-16)
    for(local i = 1; i < w/16 - 1; i++)
    {
        drawSprite(_image, 7, x + 16*i, y+h-16)
    }
    drawSprite(_image, 8, x+w-16, y+h-16)
}

function findChar(_char, _str)
{
    local place = []
    foreach(a, i in _str)
    {
        if(i.tochar() == _char)
        {
            place.push(a)
        }
    }
    if(place.len() > 0) return place
    return false
}

function replaceChar(_index, _char, _str){ return _str.slice(0, _index) + _char + _str.slice(_index+1) }

function updateCursor(){ drawSprite(sprCursor, 0, mouseX(), mouseY()) }

::game <- Game()

while(!Quit && !getQuit())
{
    game.updatebuttons()
    drawSprite(sprHangman, game.hanged, screenW()/2 - 40, screenH()/2 - 40)
    drawText(font, screenW()/2 - game.revealed.len() * fontWidth / 2, screenH()/2 + 50, game.revealed)
    game.otherGameEvents()
    updateCursor()
    update()
}