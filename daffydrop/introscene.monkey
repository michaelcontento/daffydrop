Strict

Private

Import mojo.graphics
Import bono
Import scene

Public

Class IntroScene Extends Scene
    Private

    Field background:Sprite
    Field timer:Int
    Const DURATION:Int = 1500

    Public

    Method OnCreate:Void(director:Director)
        background = New Sprite("logo.jpg")
        layer.Add(background)

        Super.OnCreate(director)
        background.Center(director)
    End

    Method OnUpdate:Void(delta:Float, frameTime:Float)
        If timer >= DURATION Then router.Goto("menu")
        timer += frameTime
    End

    Method OnRender:Void()
        Cls(255, 255, 255)
        Super.OnRender()
    End
End
