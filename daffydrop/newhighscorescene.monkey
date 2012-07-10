Strict

Private

Import mojo
Import bono
Import severity
Import scene
Import gamehighscore

Public

Class NewHighscoreScene Extends Scene Implements RouterEvents
    Private

    Field highscore:GameHighscore = New GameHighscore()
    Field continueBtn:Sprite
    Field input:TextInput
    Const MAX_LENGTH:Int = 15

    Public

    Field score:Int

    Method OnCreate:Void(director:Director)
        Local background:Sprite = New Sprite("newhighscore.png")
        layer.Add(background)

        continueBtn = New Sprite("01_06-continue.png")
        layer.Add(continueBtn)

        input = New TextInput("CoRa", New Vector2D(90, 430))
        layer.Add(input)

        Super.OnCreate(director)

    End

    Method OnEnter:Void()
#If TARGET<>"glfw" And TARGET<>"html5"
        director.inputController.trackKeys = True
#End
        continueBtn.CenterX(director)
        continueBtn.pos.y = input.pos.y + 175
    End

    Method OnLeave:Void()
#If TARGET<>"glfw" And TARGET<>"html5"
        director.inputController.trackKeys = False
#End
    End

    Method OnRender:Void()
        router.previous.OnRender()
        Super.OnRender()
    End

    Method OnKeyDown:Void(event:KeyEvent)
        Super.OnKeyDown(event)
        If event.code = KEY_ENTER Then SaveAndContinue()
    End

    Method OnTouchDown:Void(event:TouchEvent)
        If continueBtn.Collide(event.pos) Then SaveAndContinue()
    End

    Private

    Method SaveAndContinue:Void()
        Local level:String = CurrentSeverity().ToString() + " "
        StateStore.Load(highscore)
        highscore.Add(level + input.text, score)
        StateStore.Save(highscore)
        router.Goto("menu")
    End
End
