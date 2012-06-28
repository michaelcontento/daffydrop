Strict

Private

Import mojo
Import bono

Public

Class GameOverScene Extends BaseObject
    Method OnCreate:Void(director:Director)
        Local image:Sprite = New Sprite("gameover.jpg")
        image.Center(director)
        layer.Add(image)
        Super.OnCreate(director)
    End

    Method OnRender:Void()
        Super.OnRender()
        Router(director.handler).previous.OnRender()
    End

    Method OnTouchDown:Void(event:TouchEvent)
        Super.OnTouchDown(event)
        Router(director.handler).Goto("menu")
    End
End
