Strict

Import mojo.graphics

Import scene
Import game
Import gameobject
Import gameobjectpool

Class PlayButton Extends GameObject
    Field image:Image
    Field posX:Int
    Field posY:Int

    Method New()
        image = LoadImage("01_01button-play.png")
        posX = (Game.GetInstance().Width() / 2) - (image.Width() / 2)
        posY = 300
    End

    Method OnRender:Void()
        DrawImage(image, posX, posY)
    End
End

Class HighscoreButton Extends GameObject
    Field image:Image
    Field posX:Int
    Field posY:Int

    Method New()
        image = LoadImage("01_04button-highscore.png")
        posX = (Game.GetInstance().Width() / 2) - (image.Width() / 2)
        posY = 640
    End

    Method OnRender:Void()
        DrawImage(image, posX, posY)
    End
End

Class MenuScene Extends Scene
    Field background:Image
    Field gameObjectPool:GameObjectPool

    Method New()
        name = "menu"
        gameObjectPool = New GameObjectPool()
    End

    Method OnEnter:Void()
        background = LoadImage("01_main.jpg")
        gameObjectPool.Add(New PlayButton())
        gameObjectPool.Add(New HighscoreButton())
    End

    Method OnUpdate:Void()
        gameObjectPool.OnUpdate()
    End

    Method OnRender:Void()
        DrawImage(background, 0, 0)
        gameObjectPool.OnRender()
    End
End
