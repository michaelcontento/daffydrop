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
        continueBtn.Center(director)
        quitBtn.pos = continueBtn.pos.Copy()
        quitBtn.pos.y += continueBtn.size.y + 40
    End

    Method OnRender:Void()
        router.previous.OnRender()
        Super.OnRender()
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
        If continueBtn.Collide(event.pos)
            router.Goto(router.previousName)
        End

        If quitBtn.Collide(event.pos)
            GameScene(router.previous).OnPauseLeaveGame()
            router.Goto("menu")
        End
    End
End
