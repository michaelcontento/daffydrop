Strict

' MIRI: pfeile mit der selben hoehe wie die buttons
' MIRI: moeglichst wenig "transparenten ueberhang"

Import mojo
Import monkey

Import scene
Import sprite
Import game
Import gameobjectpool

Class MenuScene Extends Scene
    Field gameObjectPool:GameObjectPool

    Method New()
        name = "menu"

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

        gameObjectPool = New GameObjectPool()
        gameObjectPool.Add(New Sprite("01_main.jpg"))
        gameObjectPool.Add(easy)
        gameObjectPool.Add(normal)
        gameObjectPool.Add(advanced)
        gameObjectPool.Add(highscore)
    End

    Method OnUpdate:Void()
        If KeyDown(KEY_P) Then CurrentGame().scenes.Goto("game")
        gameObjectPool.OnUpdate()
    End

    Method OnRender:Void()
        gameObjectPool.OnRender()
    End
End
