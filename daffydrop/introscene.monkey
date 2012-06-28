Strict

Private

Import mojo
Import bono

Public

Class IntroScene Extends NullObject
    Private

    Field background:Sprite
    Field timer:Int

    Public

    Method OnCreate:Void(director:Director)
        background = New Sprite("logo.jpg")
        background.Center(director)
        timer = Millisecs() + 1500
        Super.OnCreate(director)
    End

    Method OnUpdate:Void(delta:Float)
        Super.OnUpdate(delta)
        If Millisecs() > timer Then Router(director.handler).Goto("menu")
    End

    Method OnRender:Void()
        Super.OnRender()
        Cls(255, 255, 255)
        background.OnRender()
    End
End
