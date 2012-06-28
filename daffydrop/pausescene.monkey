Strict

Private

Import mojo
Import bono

Public

Class PauseScene Extends BaseObject
    Method OnCreate:Void(director:Director)
        Local image:Sprite = New Sprite("pause.png")
        image.Center(director)
        layer.Add(image)
        Super.OnCreate(director)
    End

    Method OnRender:Void()
        Super.OnRender()
        Router(director.handler).previous.OnRender()
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
