Strict

' MIRI: pfeile mit der selben hoehe wie die buttons
' MIRI: moeglichst wenig "transparenten ueberhang"

Import mojo
Import monkey

Import scene
Import sprite
Import game

Class MenuScene Extends Scene
    Method OnCreate:String()
        Local easy:Sprite = New Sprite("01_02-easy.png", 0, 270)
        Local normal:Sprite = New Sprite("01_02-normal.png", 0, easy.y + 140)
        Local advanced:Sprite = New Sprite("01_02-advanced.png", 0, normal.y + 140)
        Local highscore:Sprite = New Sprite("01_04button-highscore.png", 0, advanced.y + 140)

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
