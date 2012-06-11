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

Class PlayButton Extends Sprite
    Method New()
        Super.New("01_01button-play.png")
        x = (Game.GetInstance().Width() / 2) - (image.Width() / 2)
        y = 300
    End
End

Class LeftButton Extends Sprite
    Method New()
        Super.New("arrow-left.png")
        x = (165 - (image.Width() * 2)) / 4
        y = 470
    End
End

Class RightButton Extends Sprite
    Method New()
        Super.New("arrow-right.png")
        x = Game.GetInstance().Width() - image.Width() - ((165 - (image.Width() * 2)) / 4)
        y = 470
    End
End

Class HighscoreButton Extends Sprite
    Method New()
        Super.New("01_04button-highscore.png")
        x = (Game.GetInstance().Width() / 2) - (image.Width() / 2)
        y = 640
    End
End

Class SeverityButton Extends GameObject
    Field currentLevel:Int
    Field images:Image[]
    Field posY:Int
    Field posX:Int
    Field left:LeftButton
    Field right:RightButton

    Method New()
        images = [LoadImage("01_02-easy.png"), LoadImage("01_02-normal.png"), LoadImage("01_02-advanced.png")]
        posX = (Game.GetInstance().Width() / 2) - (images[0].Width() / 2)
        posY = 470

        currentLevel = 1
        left = New LeftButton()
        right = New RightButton()
    End

    Method OnUpdate:Void()
        If KeyDown(KEY_LEFT) Then Decrease()
        If KeyDown(KEY_RIGHT) Then Increase()
    End

    Method Increase:Void()
        currentLevel += 1
        If currentLevel > images.Length() - 1 Then currentLevel = 0
    End

    Method Decrease:Void()
        currentLevel -= 1
        If currentLevel < 0 Then currentLevel = images.Length() - 1
    End

    Method OnRender:Void()
        DrawImage(images[currentLevel], posX, posY)
        left.OnRender()
        right.OnRender()
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
        gameObjectPool.Add(New PlayButton())
        gameObjectPool.Add(New SeverityButton())
        gameObjectPool.Add(New HighscoreButton())
    End

    Method OnUpdate:Void()
        If KeyDown(KEY_P) Then Game.GetInstance().sceneManager.Goto("game")
        gameObjectPool.OnUpdate()
    End

    Method OnRender:Void()
        gameObjectPool.OnRender()
    End
End
