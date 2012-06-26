Strict

Private

Import mojo
Import bono
Import bono.vendor.angelfont.simpleinput
Import severity

Public

Class NewHighscoreScene Extends Scene
    Private

    Field save:Sprite
    Field highscore:IntHighscore = New IntHighscore(10)
    Field input:SimpleInput
    Const MAX_LENGTH:Int = 15

    Public

    Field score:Int

    Method New()
        name = "newhighscore"
    End

    Method OnCreate:Void()
        input = New SimpleInput("Anonymous")

        Local image:Sprite = New Sprite("newhighscore.png")
        director.Center(image)
        layer.Add(image)

        save = New Sprite("back.png")
        save.pos = director.size.Copy().Sub(save.size)
        director.CenterX(save)
        layer.Add(save)

        input.x = director.center.x
        input.y = director.center.y
    End

    Method OnRender:Void()
        Super.OnRender()
        input.Draw()
    End

    Method OnUpdate:Void()
        Super.OnUpdate()
        input.Update()
    End

    Method OnTouchDown:Void(event:TouchEvent)
        If save.Collide(event.pos)
            Local level:String = " (" + CurrentSeverity().ToString() + ")"
            StateStore.Load(highscore)
            highscore.Add(input.text + level, score)
            StateStore.Save(highscore)
            scenes.Goto("menu")
        End
    End
End
