Strict

' MIRI: pfeile mit der selben hoehe wie die buttons
' MIRI: moeglichst wenig "transparenten ueberhang"

Import mojo
Import monkey

Import scene
Import sprite
Import game
Import vector2d

Class MenuScene Extends Scene
    Method New()
        name = "menu"
    End

    Method OnEnter:Void()
        Local offset:Vector2D = New Vector2D(0, 140)
        Local easy:Sprite = New Sprite("01_02-easy.png", New Vector2D(0, 270))
        Local normal:Sprite = New Sprite("01_02-normal.png", easy.pos.Copy().Add(offset))
        Local advanced:Sprite = New Sprite("01_02-advanced.png", normal.pos.Copy().Add(offset))
        Local highscore:Sprite = New Sprite("01_04button-highscore.png", advanced.pos.Copy().Add(offset))

        easy.CenterGameX()
        normal.CenterGameX()
        advanced.CenterGameX()
        highscore.CenterGameX()

        layer.Add(New Sprite("01_main.jpg"))
        layer.Add(easy)
        layer.Add(normal)
        layer.Add(advanced)
        layer.Add(highscore)
    End

    Method OnUpdate:Void()
        If KeyDown(KEY_P) Then CurrentGame().scenes.Goto("game")
    End
End
