Strict

Private

Import bono
Import scene

Public

Class GameOverScene Extends Scene
    Private

    Field overlay:Sprite

    Public

    Method OnCreate:Void(director:Director)
        Super.OnCreate(director)

        overlay = New Sprite("gameover.png")
        overlay.OnCreate(director)
    End

    Method OnRender:Void()
        router.previous.OnRender()
        overlay.OnRender()
    End

    Method OnTouchDown:Void(event:TouchEvent)
        router.Goto("menu")
    End

    Method OnKeyDown:Void(event:KeyEvent)
        router.Goto("menu")
    End
End
