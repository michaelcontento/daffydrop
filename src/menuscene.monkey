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
        Local centerX:Int = CurrentGame().Width2() - easy.Width2()
        easy.x = centerX

        Local normal:Sprite = New Sprite("01_02-normal.png", centerX, easy.y + 140)
        Local advanced:Sprite = New Sprite("01_02-advanced.png", centerX, normal.y + 140)
        Local highscore:Sprite = New Sprite("01_04button-highscore.png", centerX, advanced.y + 140)

        pool.Add(New Sprite("01_main.jpg"))
        pool.Add(easy)
        pool.Add(normal)
        pool.Add(advanced)
        pool.Add(highscore)

        Return "menu"
    End

    Method OnUpdate:Void()
        If KeyDown(KEY_P) Then CurrentGame().scenes.Goto("game")
    End
End
