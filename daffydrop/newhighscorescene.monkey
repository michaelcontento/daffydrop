Strict

Private

Import mojo
Import bono
Import bono.vendor.angelfont.simpleinput
Import severity
Import scene

Public

Class NewHighscoreScene Extends Scene Implements RouterEvents
    Private

    Field highscore:IntHighscore = New IntHighscore(10)
    Field continueBtn:Sprite
    Field input:SimpleInput
    Const MAX_LENGTH:Int = 15

    Public

    Field score:Int

    Method OnCreate:Void(director:Director)
        Local font:AngelFont = New AngelFont("CoRa")
        input = New SimpleInput("Anonymous")

        Local background:Sprite = New Sprite("newhighscore.png")
        layer.Add(background)

        continueBtn = New Sprite("01_06-continue.png")
        layer.Add(continueBtn)

        Super.OnCreate(director)

    End

    Method OnEnter:Void()
#If TARGET<>"glfw" And TARGET<>"html5"
        director.inputController.trackKeys = True
#End
        input.x = 90
        input.y = 430

        continueBtn.CenterX(director)
        continueBtn.pos.y = input.y + 100
    End

    Method OnLeave:Void()
#If TARGET<>"glfw" And TARGET<>"html5"
        director.inputController.trackKeys = False
#End
    End

    Method OnRender:Void()
        router.previous.OnRender()
        Super.OnRender()
        input.Draw()
    End

    Method OnUpdate:Void(delta:Float, frameTime:Float)
        input.Update()
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
        Local level:String = " (" + CurrentSeverity().ToString() + ")"
        StateStore.Load(highscore)
        highscore.Add(input.text + level, score)
        StateStore.Save(highscore)
        router.Goto("menu")
    End
End
