Strict

Private

Import mojo
Import bono
Import severity
Import scene
Import gamehighscore
Import highscorescene

Public

Class NewHighscoreScene Extends Scene
    Private

    Field highscore:GameHighscore = New GameHighscore()
    Field continueBtn:Sprite
    Field input:TextInput
    Const MAX_LENGTH:Int = 15

    Public

    Field score:Int

    Method OnCreate:Void(director:Director)
        Local background:Sprite = New Sprite("newhighscore.png")
        background.pos.y = 40
        layer.Add(background)

#If TARGET<>"ios" And TARGET<>"android"
        continueBtn = New Sprite("buttons/01_06-continue.png")
        layer.Add(continueBtn)
#End

        input = New TextInput("CoRa", New Vector2D(110, 415))
        input.color = New Color(3, 105, 187)
        layer.Add(input)

        Super.OnCreate(director)
    End

#If TARGET<>"ios" And TARGET<>"android"
    Method OnEnter:Void()
        continueBtn.CenterX(director)
        continueBtn.pos.y = input.pos.y + 175
    End
#End

    Method OnRender:Void()
        router.previous.OnRender()
        RenderBlend()
        Super.OnRender()
    End

    Method OnKeyDown:Void(event:KeyEvent)
        Super.OnKeyDown(event)
        If event.code = KEY_ENTER Then SaveAndContinue()
    End

#If TARGET<>"ios" And TARGET<>"android"
    Method OnTouchDown:Void(event:TouchEvent)
        If continueBtn.Collide(event.pos) Then SaveAndContinue()
    End
#End

    Private

    Method SaveAndContinue:Void()
        Local level:String = CurrentSeverity().ToString() + " "
        StateStore.Load(highscore)
        highscore.Add(level + input.text, score)
        StateStore.Save(highscore)

        HighscoreScene(router.Get("highscore")).lastScoreKey = level + input.text
        HighscoreScene(router.Get("highscore")).lastScoreValue = score
        router.Goto("highscore")
    End
End
