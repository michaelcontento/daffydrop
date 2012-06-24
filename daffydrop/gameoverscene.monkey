Strict

Private

Import mojo
Import bono

Public

Class GameOverScene Extends Scene
    Method New()
        name = "gameover"
    End

    Method OnCreate:Void()
        Local image:Sprite = New Sprite("gameover.jpg")
        image.Center()
        layer.Add(image)
    End

    Method OnTouchDown:Void(event:TouchEvent)
        CurrentDirector().scenes.Goto("menu")
    End
End
