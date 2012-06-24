Strict

Private

Import mojo
Import bono
Import bono.angelfont.simpleinput
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
        image.Center()
        layer.Add(image)

        save = New Sprite("back.png")
        save.pos = CurrentDirector().size.Copy().Sub(save.size)
        save.CenterX()
        layer.Add(save)

        input.x = CurrentDirector().center.x
        input.y = CurrentDirector().center.y
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
            highscore.Load()
            highscore.Add(input.text + level, score)
            highscore.Save()
            CurrentDirector().scenes.Goto("menu")
        End
    End
End
