Strict

Private

Import mojo
Import bono
Import severity

Public

Class MenuScene Extends Scene
    Method New()
        name = "menu"
    End

    Method OnCreate:Void()
        Local offset:Vector2D = New Vector2D(0, 140)
        Local easy:Sprite = New Sprite("01_02-easy.png", New Vector2D(0, 270))
        Local normal:Sprite = New Sprite("01_02-normal.png", easy.pos.Copy().Add(offset))
        Local advanced:Sprite = New Sprite("01_02-advanced.png", normal.pos.Copy().Add(offset))
        Local highscore:Sprite = New Sprite("01_04button-highscore.png", advanced.pos.Copy().Add(offset))

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
        If KeyDown(KEY_E)
            CurrentSeverity().Set(EASY)
            CurrentDirector().scenes.Goto("game")
        End
        If KeyDown(KEY_N)
            CurrentSeverity().Set(NORMAL)
            CurrentDirector().scenes.Goto("game")
        End
        If KeyDown(KEY_A)
            CurrentSeverity().Set(ADVANCED)
            CurrentDirector().scenes.Goto("game")
        End
        If KeyDown(KEY_H)
            CurrentDirector().scenes.Goto("highscore")
        End
    End
End
