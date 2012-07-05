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

    Field save:Sprite
    Field highscore:IntHighscore = New IntHighscore(10)
    Field input:SimpleInput
    Const MAX_LENGTH:Int = 15

    Public

    Field score:Int

    Method OnEnter:Void()
        director.inputController.trackKeys = True
    End

    Method OnLeave:Void()
#If TARGET<>"glfw" And TARGET<>"html5"
        director.inputController.trackKeys = False
#End
    End

    Method OnCreate:Void(director:Director)
        Local font:AngelFont = New AngelFont("CoRa")
        input = New SimpleInput("Anonymous")
        input.x = director.center.x
        input.y = director.center.y

        Local image:Sprite = New Sprite("newhighscore.png")
        layer.Add(image)

        save = New Sprite("back.png")
        layer.Add(save)

        Super.OnCreate(director)

        save.pos = director.size.Copy().Sub(save.size)
        save.CenterX(director)
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
        If save.Collide(event.pos) Then SaveAndContinue()
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
