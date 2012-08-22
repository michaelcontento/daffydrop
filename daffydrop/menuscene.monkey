Strict

Private

Import mojo
Import bono
Import severity
Import scene
Import appirater

Public

Class MenuScene Extends Scene
    Private

    Field easy:Sprite
    Field normal:Sprite
    Field advanced:Sprite
    Field highscore:Sprite

    Public

    Method OnCreate:Void(director:Director)
        Local offset:Vector2D = New Vector2D(0, 150)
        easy = New Sprite("buttons/01_02-easy.png", New Vector2D(0, 290))
        normal = New Sprite("buttons/01_02-normal_active.png", easy.pos.Copy().Add(offset))
        advanced = New Sprite("buttons/01_02-advanced_active.png", normal.pos.Copy().Add(offset))
        highscore = New Sprite("buttons/01_04button-highscore.png", advanced.pos.Copy().Add(offset))

        PlayMusic("sounds/background.mp3", 1)

        layer.Add(New Sprite("01_main.jpg"))
        layer.Add(easy)
        layer.Add(normal)
        layer.Add(advanced)
        layer.Add(highscore)

        Super.OnCreate(director)

        easy.CenterX(director)
        normal.CenterX(director)
        advanced.CenterX(director)
        highscore.CenterX(director)

        Appirater.Launched()
    End

    Method OnResume:Void(delta:Int)
        Appirater.Launched()
    End

    Method OnTouchDown:Void(event:TouchEvent)
        If easy.Collide(event.pos) Then PlayEasy()
        If normal.Collide(event.pos) Then PlayNormal()
        If advanced.Collide(event.pos) Then PlayAdvanced()
        If highscore.Collide(event.pos) Then router.Goto("highscore")
    End

    Method OnKeyDown:Void(event:KeyEvent)
        Select event.code
        Case KEY_E
            PlayEasy()
        Case KEY_N
            PlayNormal()
        Case KEY_A
            PlayAdvanced()
        Case KEY_H
            router.Goto("highscore")
        End
    End

    Private

    Method PlayEasy:Void()
        CurrentSeverity().Set(EASY)
        router.Goto("game")
    End

    Method PlayNormal:Void()
        CurrentSeverity().Set(NORMAL)
        router.Goto("game")
    End

    Method PlayAdvanced:Void()
        CurrentSeverity().Set(ADVANCED)
        router.Goto("game")
    End
End
