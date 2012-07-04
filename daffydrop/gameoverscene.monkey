Strict

Private

Import mojo
Import bono

Public

Class GameOverScene Extends Partial
    Private

    Field overlay:Sprite

    Public

    Method OnCreate:Void(director:Director)
        Super.OnCreate(director)

        overlay = New Sprite("gameover.png")
        overlay.OnCreate(director)
    End

    Method OnRender:Void()
        Router(director.handler).previous.OnRender()
        overlay.OnRender()
    End

    Method OnTouchDown:Void(event:TouchEvent)
        Router(director.handler).Goto("menu")
    End

    Method OnKeyDown:Void(event:KeyEvent)
        Router(director.handler).Goto("menu")
    End
End
