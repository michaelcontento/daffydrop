Strict

' MIRI: pfeile mit der selben hoehe wie die buttons
' MIRI: moeglichst wenig "transparenten ueberhang"

Import mojo
Import monkey

Import scene
Import sprite
Import game
Import gameobject
Import gameobjectpool

Class HighscoreButton Extends Sprite
    Method New()
        Super.New("01_04button-highscore.png")
        x = (CurrentGame().Width() / 2) - (image.Width() / 2)
        y = 690
    End
End

Class PlayButtons Extends GameObject
    Field images:Image[]
    Field startPosY:Int
    Field offsetPosY:Int
    Field posX:Int

    Method New()
        images = [LoadImage("01_02-easy.png"), LoadImage("01_02-normal.png"), LoadImage("01_02-advanced.png")]
        posX = (CurrentGame().Width() / 2) - (images[0].Width() / 2)
        startPosY = 270
        offsetPosY = 140
    End

    Method OnRender:Void()
        Local posY:Int = startPosY
        For Local img:Image = EachIn images
            DrawImage(img, posX, posY)
            posY += offsetPosY
        End
    End
End

Class MenuScene Extends Scene
    Field gameObjectPool:GameObjectPool

    Method New()
        name = "menu"
        gameObjectPool = New GameObjectPool()
    End

    Method OnEnter:Void()
        gameObjectPool.Add(New Sprite("01_main.jpg"))
        gameObjectPool.Add(New PlayButtons())
        gameObjectPool.Add(New HighscoreButton())
    End

    Method OnUpdate:Void()
        If KeyDown(KEY_P) Then CurrentGame().sceneManager.Goto("game")
        gameObjectPool.OnUpdate()
    End

    Method OnRender:Void()
        gameObjectPool.OnRender()
    End
End
