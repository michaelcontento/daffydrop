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
    Field continueBtn:Sprite
    Field quitBtn:Sprite

    Public

    Method OnCreate:Void(director:Director)
        overlay = New Sprite("pause.png")
        layer.Add(overlay)

        continueBtn = New Sprite("01_06-continue.png")
        layer.Add(continueBtn)

        quitBtn = New Sprite("01_07-quit.png")
        layer.Add(quitBtn)

        Super.OnCreate(director)
    End

    Method OnEnter:Void()
        overlay.Center(director)
        overlay.pos.y -= overlay.size.y
        overlay.pos.y -= 50

        continueBtn.Center(director)

        quitBtn.pos = continueBtn.pos.Copy()
        quitBtn.pos.y += continueBtn.size.y + 40
    End

    Method OnRender:Void()
        router.previous.OnRender()
        RenderBlend()
        Super.OnRender()
    End

    Method OnKeyDown:Void(event:KeyEvent)
        Select event.code
        Case KEY_ESCAPE, KEY_Q
            GameScene(router.previous).OnPauseLeaveGame()
            router.Goto("menu")
        Default
            router.Goto(router.previousName)
        End
    End

    Method OnTouchDown:Void(event:TouchEvent)
        If continueBtn.Collide(event.pos)
            router.Goto(router.previousName)
        End

        If quitBtn.Collide(event.pos)
            GameScene(router.previous).OnPauseLeaveGame()
            router.Goto("menu")
        End
    End
End
