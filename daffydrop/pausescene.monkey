Strict

Private

Import mojo
Import bono
Import scene

Public

Class PauseScene Extends Scene
    Private

    Field overlay:Sprite

    Public

    Method OnCreate:Void(director:Director)
        overlay = New Sprite("pause.png")
        overlay.Center(director)
        Super.OnCreate(director)
    End

    Method OnRender:Void()
        Super.OnRender()
        Router(director.handler).previous.OnRender()
        overlay.OnRender()
    End

    Method OnKeyDown:Void(event:KeyEvent)
        Super.OnKeyDown(event)
        Select event.code
        Case KEY_SPACE, KEY_ENTER, KEY_P
            Router(director.handler).Goto(Router(director.handler).previousName)
        Default
            Router(director.handler).Goto("menu")
        End
    End

    Method OnTouchDown:Void(event:TouchEvent)
        Super.OnTouchDown(event)
        Router(director.handler).Goto(Router(director.handler).previousName)
    End
End
