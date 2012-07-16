Strict

Private

Import bono
Import scene

Public

Class GameOverScene Extends Scene
    Private

    Field main:Sprite
    Field small:Sprite

    Public

    Method OnCreate:Void(director:Director)
        Super.OnCreate(director)

        main = New Sprite("gameover_main.png")
        main.OnCreate(director)
        main.Center(director)

        small = New Sprite("gameover_small.png")
        small.OnCreate(director)
        small.pos.x = director.size.x - small.size.x
    End

    Method OnRender:Void()
        router.previous.OnRender()
        RenderBlend()
        small.OnRender()
        main.OnRender()
    End

    Method OnTouchDown:Void(event:TouchEvent)
        router.Goto("menu")
    End

    Method OnKeyDown:Void(event:KeyEvent)
        router.Goto("menu")
    End
End
