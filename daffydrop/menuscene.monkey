Strict

Private

Import mojo
Import bono
Import severity

Public

Class MenuScene Extends Scene
    Private

    Field easy:Sprite
    Field normal:Sprite
    Field advanced:Sprite
    Field highscore:Sprite

    Public

    Method New()
        name = "menu"
    End

    Method OnCreate:Void()
        Local offset:Vector2D = New Vector2D(0, 140)
        easy = New Sprite("01_02-easy.png", New Vector2D(0, 270))
        normal = New Sprite("01_02-normal.png", easy.pos.Copy().Add(offset))
        advanced = New Sprite("01_02-advanced.png", normal.pos.Copy().Add(offset))
        highscore = New Sprite("01_04button-highscore.png", advanced.pos.Copy().Add(offset))

        easy.CenterX()
        normal.CenterX()
        advanced.CenterX()
        highscore.CenterX()

        layer.Add(New Sprite("01_main.jpg"))
        layer.Add(easy)
        layer.Add(normal)
        layer.Add(advanced)
        layer.Add(highscore)
    End

    Method OnUpdate:Void()
        If KeyDown(KEY_E) Then PlayEasy()
        If KeyDown(KEY_N) Then PlayNormal()
        If KeyDown(KEY_A) Then PlayAdvanced()
        If KeyDown(KEY_H) Then CurrentDirector().scenes.Goto("highscore")
    End

    Method OnTouchDown:Void(event:TouchEvent)
        If easy.Collide(event.pos) Then PlayEasy()
        If normal.Collide(event.pos) Then PlayNormal()
        If advanced.Collide(event.pos) Then PlayAdvanced()
        If highscore.Collide(event.pos) Then CurrentDirector().scenes.Goto("highscore")
    End

    Private

    Method PlayEasy:Void()
        CurrentSeverity().Set(EASY)
        CurrentDirector().scenes.Goto("game")
    End

    Method PlayNormal:Void()
        CurrentSeverity().Set(NORMAL)
        CurrentDirector().scenes.Goto("game")
    End

    Method PlayAdvanced:Void()
        CurrentSeverity().Set(ADVANCED)
        CurrentDirector().scenes.Goto("game")
    End
End
