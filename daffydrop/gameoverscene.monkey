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
        director.Center(image)
        layer.Add(image)
    End

    Method OnTouchDown:Void(event:TouchEvent)
        scenes.Goto("menu")
    End
End
