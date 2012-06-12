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
        Local easy:Sprite = Sprite("01_02-easy.png")
        easy.y = 270
        Local gameCenterX:Int = CurrentGame().Width2() - easy.Width2()
        easy.x = gameCenterX

        Local normal:Sprite = Sprite("01_02-normal.png")
        normal.y = easy.y + 140
        normal.x = gameCenterX

        Local advanced:Sprite = Sprite("01_02-advanced.png")
        advanced.y = normal.y + 140
        advanced.x = gameCenterX

        Local highscore:Sprite = Sprite("01_04button-highscore.png")
        highscore.y = advanced.y + 140
        highscore.x = gameCenterX

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
