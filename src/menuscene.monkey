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
    Method OnCreate:String()
        Local offset:Vector2D = New Vector2D(0, 140)
        Local easy:Sprite = New Sprite("01_02-easy.png", New Vector2D(0, 270))
        Local normal:Sprite = New Sprite("01_02-normal.png", Vector2D.Add(easy.pos, offset))
        Local advanced:Sprite = New Sprite("01_02-advanced.png", Vector2D.Add(normal.pos, offset))
        Local highscore:Sprite = New Sprite("01_04button-highscore.png", Vector2D.Add(advanced.pos, offset))

        easy.CenterGameX()
        normal.CenterGameX()
        advanced.CenterGameX()
        highscore.CenterGameX()

        layer.Add(New Sprite("01_main.jpg"))
        layer.Add(easy)
        layer.Add(normal)
        layer.Add(advanced)
        layer.Add(highscore)

        Return "menu"
    End

    Method OnUpdate:Void()
        If KeyDown(KEY_P) Then CurrentGame().scenes.Goto("game")
    End
End
