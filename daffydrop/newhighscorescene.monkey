Strict

Private

Import mojo
Import bono
Import bono.vendor.angelfont.simpleinput
Import severity

Public

Class NewHighscoreScene Extends BaseObject
    Private

    Field save:Sprite
    Field highscore:IntHighscore = New IntHighscore(10)
    Field input:SimpleInput
    Const MAX_LENGTH:Int = 15

    Public

    Field score:Int

    Method OnCreate:Void(director:Director)
        input = New SimpleInput("Anonymous")

        Local image:Sprite = New Sprite("newhighscore.png")
        image.Center(director)
        layer.Add(image)

        save = New Sprite("back.png")
        save.pos = director.size.Copy().Sub(save.size)
        save.CenterX(director)
        layer.Add(save)

        input.x = director.center.x
        input.y = director.center.y

        Super.OnCreate(director)
    End

    Method OnRender:Void()
        Super.OnRender()
        Router(director.handler).previous.OnRender()
        input.Draw()
    End

    Method OnUpdate:Void(delta:Float)
        Super.OnUpdate(delta)
        input.Update()
    End

    Method OnKeyDown:Void(event:KeyEvent)
        Super.OnKeyDown(event)
        If event.code = KEY_ENTER Then SaveAndContinue()
    End

    Method OnTouchDown:Void(event:TouchEvent)
        Super.OnTouchDown(event)
        If save.Collide(event.pos) Then SaveAndContinue()
    End

    Private

    Method SaveAndContinue:Void()
        Local level:String = " (" + CurrentSeverity().ToString() + ")"
        StateStore.Load(highscore)
        highscore.Add(input.text + level, score)
        StateStore.Save(highscore)
        Router(director.handler).Goto("menu")
    End
End
