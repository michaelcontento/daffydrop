Strict

Private

Import mojo
Import bono
Import scene
Import gamescene

Public

Class PauseScene Extends Scene
    Private

    Field overlay:Sprite

    Public

    Method OnCreate:Void(director:Director)
        overlay = New Sprite("pause.png")
        layer.Add(overlay)

        Super.OnCreate(director)
        overlay.Center(director)
    End

    Method OnRender:Void()
        Super.OnRender()
        router.previous.OnRender()
    End

    Method OnKeyDown:Void(event:KeyEvent)
        Select event.code
        Case KEY_SPACE, KEY_ENTER, KEY_P
            router.Goto(router.previousName)
        Default
            GameScene(router.previous).OnPauseLeaveGame()
            router.Goto("menu")
        End
    End

    Method OnTouchDown:Void(event:TouchEvent)
        router.Goto(router.previousName)
    End
End
